/* ============================================================
   Logistics Delivery Analytics Platform
   Step 1: Create Database Tables
   Layers:
   1. Staging
   2. Clean
   3. Error Logging
   4. Reporting
   ============================================================ */



/* ============================================================
   1. STAGING TABLES
   Raw data is loaded here exactly as it appears in the CSV files.
   All columns are VARCHAR to preserve messy source data.
   ============================================================ */

DROP TABLE IF EXISTS stg_delivery_transactions;
GO

CREATE TABLE stg_delivery_transactions (
    delivery_id VARCHAR(20),
    order_date VARCHAR(30),
    delivery_date VARCHAR(30),
    partner VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(50),
    distance_km VARCHAR(50),
    delivery_time_hours VARCHAR(50),
    cost VARCHAR(50)
);
GO


DROP TABLE IF EXISTS stg_delivery_conditions;
GO

CREATE TABLE stg_delivery_conditions (
    condition_id VARCHAR(20),
    date VARCHAR(30),
    city VARCHAR(100),
    province VARCHAR(50),
    weather VARCHAR(50),
    traffic_level VARCHAR(50),
    fuel_price VARCHAR(50)
);
GO


/* ============================================================
   2. CLEAN TABLES
   Cleaned and standardized records are stored here.
   Data types are properly enforced.
   ============================================================ */

DROP TABLE IF EXISTS clean_delivery_transactions;
GO

CREATE TABLE clean_delivery_transactions (
    delivery_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    delivery_date DATE,
    partner VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(10),
    distance_km DECIMAL(10,2),
    delivery_time_hours DECIMAL(10,2),
    cost DECIMAL(10,2)
);
GO


DROP TABLE IF EXISTS clean_delivery_conditions;
GO

CREATE TABLE clean_delivery_conditions (
    condition_id VARCHAR(20) PRIMARY KEY,
    condition_date DATE,
    city VARCHAR(100),
    province VARCHAR(10),
    weather VARCHAR(50),
    traffic_level VARCHAR(50),
    fuel_price DECIMAL(10,2)
);
GO


/* ============================================================
   3. ERROR LOG TABLE
   Invalid or rejected records are stored here for auditability.
   This makes the ETL pipeline more realistic and professional.
   ============================================================ */

DROP TABLE IF EXISTS etl_error_log;
GO

CREATE TABLE etl_error_log (
    error_id INT IDENTITY(1,1) PRIMARY KEY,
    source_table VARCHAR(100),
    source_record_id VARCHAR(50),
    error_type VARCHAR(100),
    error_description VARCHAR(500),
    logged_at DATETIME DEFAULT GETDATE()
);
GO


/* ============================================================
   4. ETL RUN LOG TABLE
   Tracks whether each ETL execution succeeded or failed.
   ============================================================ */

DROP TABLE IF EXISTS etl_run_log;
GO

CREATE TABLE etl_run_log (
    run_id INT IDENTITY(1,1) PRIMARY KEY,
    procedure_name VARCHAR(100),
    run_status VARCHAR(50),
    records_loaded INT,
    error_message VARCHAR(1000),
    run_timestamp DATETIME DEFAULT GETDATE()
);
GO


/* ============================================================
   5. REPORTING TABLE
   Final analysis-ready table used for Python and R reporting.
   This joins delivery data with external conditions.
   ============================================================ */

DROP TABLE IF EXISTS fact_delivery_performance;
GO

CREATE TABLE fact_delivery_performance (
    delivery_id VARCHAR(20) PRIMARY KEY,
    delivery_date DATE,
    partner VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(10),
    weather VARCHAR(50),
    traffic_level VARCHAR(50),
    fuel_price DECIMAL(10,2),
    distance_km DECIMAL(10,2),
    delivery_time_hours DECIMAL(10,2),
    cost DECIMAL(10,2),
    order_date DATE,

    -- Derived metrics
    cost_per_km AS 
        CASE 
            WHEN distance_km > 0 THEN cost / distance_km
            ELSE NULL
        END,

    avg_speed_kmh AS 
        CASE 
            WHEN delivery_time_hours > 0 THEN distance_km / delivery_time_hours
            ELSE NULL
        END
);
GO


/* ============================================================
   Done.
   Next step: load CSV files into staging tables.
   ============================================================ */


/* ============================================================
   Step 2: Extract
   Load Raw CSV Files into Staging Tables
   Source: Azure Blob Storage
   Target: SQL Staging Tables
   ============================================================ */


/* 1. Create master key only if missing */

IF NOT EXISTS (
    SELECT *
    FROM sys.symmetric_keys
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'LogisticsP97';
END;
GO

/* 2. Drop data source and credential first */
IF EXISTS (
    SELECT *
    FROM sys.external_data_sources
    WHERE name = 'LogisticsBlobStorage'
)
    DROP EXTERNAL DATA SOURCE LogisticsBlobStorage;
GO

IF EXISTS (
    SELECT *
    FROM sys.database_scoped_credentials
    WHERE name = 'LogisticsBlobCredential'
)
    DROP DATABASE SCOPED CREDENTIAL LogisticsBlobCredential;
GO

/* 3. Recreate credential with NEW container-level SAS */
CREATE DATABASE SCOPED CREDENTIAL LogisticsBlobCredential
WITH
    IDENTITY = 'SHARED ACCESS SIGNATURE',
    SECRET = 'sp=r&st=2026-06-22T19:34:40Z&se=2026-06-23T03:49:40Z&spr=https&sv=2026-02-06&sr=c&sig=KjwwupNbHJI%2BSmDpX0aTCQIK%2FZ8dSzUlCjzYU%2BW5QD8%3D'
GO

/* Recreate external data source */
CREATE EXTERNAL DATA SOURCE LogisticsBlobStorage
WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://fasihaf.blob.core.windows.net/raw-data',
    CREDENTIAL = LogisticsBlobCredential
);
GO


/* 4. Clear staging tables before reload */

DELETE FROM stg_delivery_transactions;
DELETE FROM stg_delivery_conditions;
GO

/* 5. Load transactions CSV */

BULK INSERT stg_delivery_transactions
FROM 'logistics_delivery_transactions_v3.csv'
WITH (
    DATA_SOURCE = 'LogisticsBlobStorage',
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO


/* 6. Load conditions CSV */

BULK INSERT stg_delivery_conditions
FROM 'logistics_delivery_conditions_v3.csv'
WITH (
    DATA_SOURCE = 'LogisticsBlobStorage',
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO


/* 7. Verify extract */

SELECT COUNT(*) AS transaction_rows
FROM stg_delivery_transactions;

SELECT COUNT(*) AS condition_rows
FROM stg_delivery_conditions;

/* ============================================================
   Done.
   Next step: Transform and Load
   ============================================================ */


/* ============================================================
   Step 3: Transform + Load 
   Purpose:
   - Clean staging data
   - Log invalid records
   - Load final reporting table
   ============================================================ */

BEGIN TRY
    BEGIN TRANSACTION;

    /* Clear previous ETL outputs */
    DELETE FROM clean_delivery_transactions;
    DELETE FROM clean_delivery_conditions;
    DELETE FROM fact_delivery_performance;
    DELETE FROM etl_error_log;


    /* ============================================================
       1. LOG TRANSACTION ERRORS
       ============================================================ */

    -- Duplicate delivery IDs
    INSERT INTO etl_error_log (
        source_table,
        source_record_id,
        error_type,
        error_description
    )
    SELECT
        'stg_delivery_transactions',
        delivery_id,
        'Duplicate Delivery ID',
        'This delivery_id appears more than once in the transactions file.'
    FROM stg_delivery_transactions
    GROUP BY delivery_id
    HAVING COUNT(*) > 1;


    -- Missing delivery time
    INSERT INTO etl_error_log (
        source_table,
        source_record_id,
        error_type,
        error_description
    )
    SELECT
        'stg_delivery_transactions',
        delivery_id,
        'Missing Delivery Time',
        'delivery_time_hours is missing and cannot be used for performance analysis.'
    FROM stg_delivery_transactions
    WHERE delivery_time_hours IS NULL
       OR LTRIM(RTRIM(delivery_time_hours)) = '';


    /* ============================================================
       2. CLEAN DELIVERY TRANSACTIONS
       ============================================================ */

    INSERT INTO clean_delivery_transactions (
        delivery_id,
        order_date,
        delivery_date,
        partner,
        city,
        province,
        distance_km,
        delivery_time_hours,
        cost
    )
    SELECT
        delivery_id,
        TRY_CONVERT(DATE, order_date),
        TRY_CONVERT(DATE, delivery_date),
        LTRIM(RTRIM(partner)),
        LTRIM(RTRIM(city)),

        CASE
            WHEN province IN ('ON', 'Ontario', 'Ont.') THEN 'ON'
            WHEN province IN ('QC', 'Quebec', 'Que.') THEN 'QC'
            ELSE NULL
        END AS province,

        TRY_CONVERT(DECIMAL(10,2), distance_km),
        TRY_CONVERT(DECIMAL(10,2), delivery_time_hours),
        TRY_CONVERT(DECIMAL(10,2), cost)

    FROM stg_delivery_transactions
    WHERE delivery_id NOT IN (
        SELECT delivery_id
        FROM stg_delivery_transactions
        GROUP BY delivery_id
        HAVING COUNT(*) > 1
    )
    AND delivery_time_hours IS NOT NULL
    AND LTRIM(RTRIM(delivery_time_hours)) <> '';


    /* ============================================================
       3. LOG CONDITIONS ERRORS
       ============================================================ */

    -- Missing traffic level
    INSERT INTO etl_error_log (
        source_table,
        source_record_id,
        error_type,
        error_description
    )
    SELECT
        'stg_delivery_conditions',
        condition_id,
        'Missing Traffic Level',
        'traffic_level is missing and cannot be used for traffic impact analysis.'
    FROM stg_delivery_conditions
    WHERE traffic_level IS NULL
       OR LTRIM(RTRIM(traffic_level)) = '';


    /* ============================================================
       4. CLEAN DELIVERY CONDITIONS
       ============================================================ */

    INSERT INTO clean_delivery_conditions (
        condition_id,
        condition_date,
        city,
        province,
        weather,
        traffic_level,
        fuel_price
    )
    SELECT
        condition_id,

        COALESCE(
            TRY_CONVERT(DATE, date, 23),
            TRY_CONVERT(DATE, date, 103)
        ) AS condition_date,

        LTRIM(RTRIM(city)),

        CASE
            WHEN province IN ('ON', 'Ontario', 'Ont.') THEN 'ON'
            WHEN province IN ('QC', 'Quebec', 'Que.') THEN 'QC'
            ELSE NULL
        END AS province,

        LTRIM(RTRIM(weather)),
        LTRIM(RTRIM(traffic_level)),
        TRY_CONVERT(DECIMAL(10,2), fuel_price)

    FROM stg_delivery_conditions
    WHERE traffic_level IS NOT NULL
      AND LTRIM(RTRIM(traffic_level)) <> '';


    /* ============================================================
       5. LOAD FINAL REPORTING TABLE
       Join cleaned transactions with cleaned conditions
       ============================================================ */

    -- preventing duplicate-key errors
WITH condition_daily AS (
    SELECT
        condition_date,
        province,
        MAX(weather) AS weather,
        MAX(traffic_level) AS traffic_level,
        AVG(fuel_price) AS fuel_price
    FROM clean_delivery_conditions
    GROUP BY condition_date, province
)

    INSERT INTO fact_delivery_performance (
        delivery_id,
        order_date,
        delivery_date,
        partner,
        city,
        province,
        weather,
        traffic_level,
        fuel_price,
        distance_km,
        delivery_time_hours,
        cost
    )
    SELECT
        t.delivery_id,
        t.order_date,
        t.delivery_date,
        t.partner,
        t.city,
        t.province,
        c.weather,
        c.traffic_level,
        c.fuel_price,
        t.distance_km,
        t.delivery_time_hours,
        t.cost
        FROM clean_delivery_transactions t
OUTER APPLY (
    SELECT TOP 1
        c.weather,
        c.traffic_level,
        c.fuel_price
    FROM clean_delivery_conditions c
    WHERE c.province = t.province
    ORDER BY 
        ABS(DATEDIFF(DAY, t.order_date, c.condition_date)),
        CASE 
            WHEN c.city = t.city THEN 0 
            ELSE 1 
        END
) c;


    /* ============================================================
       6. LOG SUCCESSFUL ETL RUN
       ============================================================ */

    INSERT INTO etl_run_log (
        procedure_name,
        run_status,
        records_loaded,
        error_message
    )
    VALUES (
        'Manual Transform Load Script',
        'Success',
        @@ROWCOUNT,
        NULL
    );

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;

    INSERT INTO etl_run_log (
        procedure_name,
        run_status,
        records_loaded,
        error_message
    )
    VALUES (
        'Manual Transform Load Script',
        'Failed',
        0,
        ERROR_MESSAGE()
    );

    THROW;
END CATCH;

/* ==================================
Step 3 Done .....
======================================*/

/* ============================================================
   Step 4: Reporting Views
   Purpose:
   Create analysis-ready views for business reporting
   ============================================================ */

DROP VIEW IF EXISTS vw_delivery_kpis;
GO

CREATE VIEW vw_delivery_kpis AS
SELECT
    COUNT(*) AS total_deliveries,
    AVG(delivery_time_hours) AS avg_delivery_time_hours,
    AVG(cost) AS avg_delivery_cost,
    AVG(cost_per_km) AS avg_cost_per_km,
    AVG(avg_speed_kmh) AS avg_speed_kmh
FROM fact_delivery_performance;
GO


DROP VIEW IF EXISTS vw_partner_performance;
GO

CREATE VIEW vw_partner_performance AS
SELECT
    partner,
    COUNT(*) AS total_deliveries,
    AVG(delivery_time_hours) AS avg_delivery_time_hours,
    AVG(cost) AS avg_cost,
    AVG(cost_per_km) AS avg_cost_per_km,
    AVG(avg_speed_kmh) AS avg_speed_kmh
FROM fact_delivery_performance
GROUP BY partner;
GO


DROP VIEW IF EXISTS vw_weather_impact;
GO

CREATE VIEW vw_weather_impact AS
SELECT
    weather,
    COUNT(*) AS total_deliveries,
    AVG(delivery_time_hours) AS avg_delivery_time_hours,
    AVG(cost) AS avg_cost,
    AVG(avg_speed_kmh) AS avg_speed_kmh
FROM fact_delivery_performance
GROUP BY weather;
GO


DROP VIEW IF EXISTS vw_traffic_impact;
GO

CREATE VIEW vw_traffic_impact AS
SELECT
    traffic_level,
    COUNT(*) AS total_deliveries,
    AVG(delivery_time_hours) AS avg_delivery_time_hours,
    AVG(cost) AS avg_cost,
    AVG(avg_speed_kmh) AS avg_speed_kmh
FROM fact_delivery_performance
GROUP BY traffic_level;
GO


DROP VIEW IF EXISTS vw_city_performance;
GO

CREATE VIEW vw_city_performance AS
SELECT
    city,
    province,
    COUNT(*) AS total_deliveries,
    AVG(delivery_time_hours) AS avg_delivery_time_hours,
    AVG(cost) AS avg_cost,
    AVG(cost_per_km) AS avg_cost_per_km,
    AVG(avg_speed_kmh) AS avg_speed_kmh
FROM fact_delivery_performance
GROUP BY city, province;
GO

/* Step 4 Done */




