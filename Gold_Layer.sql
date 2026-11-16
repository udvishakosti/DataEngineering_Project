
-- =====================================================
-- HOSPITAL BILLING ANALYTICS
-- GOLD LAYER - FINAL SQL CODE
-- =====================================================

-- 1. MONTHLY REVENUE SUMMARY
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW
healthcare_catalog.billing.gold_monthly_revenue_final
AS
SELECT
    CAST(DATE_TRUNC('MONTH', visit_date) AS DATE)
        AS revenue_month,

    COUNT(DISTINCT bill_id) AS total_bills,

    COUNT(DISTINCT visit_id) AS total_visits,

    SUM(total_amount) AS total_revenue,

    SUM(COALESCE(insurance_amount, 0))
        AS insurance_revenue,

    SUM(
        total_amount - COALESCE(insurance_amount, 0)
    ) AS patient_payable_amount

FROM silver_billing_clean

GROUP BY
    CAST(DATE_TRUNC('MONTH', visit_date) AS DATE);


-- 2. DEPARTMENT-WISE SUMMARY
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW
healthcare_catalog.billing.gold_department_summary_final
AS
SELECT
    INITCAP(TRIM(department)) AS department,

    COUNT(DISTINCT bill_id) AS total_bills,

    COUNT(DISTINCT visit_id) AS total_visits,

    SUM(total_amount) AS total_revenue,

    SUM(total_amount) /
        NULLIF(COUNT(DISTINCT visit_id), 0)
        AS average_revenue_per_visit,

    SUM(COALESCE(insurance_amount, 0))
        AS insurance_revenue

FROM silver_billing_clean

GROUP BY INITCAP(TRIM(department));


-- 3. HOSPITAL BRANCH SUMMARY
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW
healthcare_catalog.billing.gold_branch_summary_final
AS
SELECT
    INITCAP(TRIM(hospital_branch)) AS hospital_branch,

    INITCAP(TRIM(city)) AS city,

    INITCAP(TRIM(region)) AS region,

    COUNT(DISTINCT bill_id) AS total_bills,

    COUNT(DISTINCT visit_id) AS total_visits,

    SUM(total_amount) AS total_revenue,

    AVG(total_amount) AS average_bill_amount

FROM silver_billing_clean

GROUP BY
    INITCAP(TRIM(hospital_branch)),
    INITCAP(TRIM(city)),
    INITCAP(TRIM(region));


-- 4. PAYER-WISE SUMMARY
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW
healthcare_catalog.billing.gold_payer_summary_final
AS
SELECT
    INITCAP(TRIM(payer_type)) AS payer_type,

    COUNT(DISTINCT bill_id) AS total_bills,

    COUNT(DISTINCT visit_id) AS total_visits,

    SUM(total_amount) AS total_revenue,

    SUM(COALESCE(insurance_amount, 0))
        AS insurance_amount,

    SUM(
        CASE
            WHEN LOWER(TRIM(payment_status)) = 'pending'
            THEN total_amount
            ELSE 0
        END
    ) AS pending_amount

FROM silver_billing_clean

GROUP BY INITCAP(TRIM(payer_type));


-- 5. DATA QUALITY AND RECONCILIATION SUMMARY
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW
healthcare_catalog.billing.gold_data_quality_final
AS

WITH bronze_stats AS (

    SELECT
        COUNT(*) AS bronze_total_records,

        COUNT(DISTINCT bill_id) AS unique_bill_ids,

        SUM(
            CASE
                WHEN patient_id IS NULL THEN 1
                ELSE 0
            END
        ) AS missing_patient_ids,

        SUM(
            CASE
                WHEN quantity <= 0 THEN 1
                ELSE 0
            END
        ) AS invalid_quantity_records,

        SUM(
            CASE
                WHEN unit_price < 0 THEN 1
                ELSE 0
            END
        ) AS negative_price_records,

        SUM(
            CASE
                WHEN department IS NULL
                  OR TRIM(department) = ''
                THEN 1
                ELSE 0
            END
        ) AS missing_department_records,

        SUM(
            CASE
                WHEN payer_type IS NULL
                  OR TRIM(payer_type) = ''
                THEN 1
                ELSE 0
            END
        ) AS missing_payer_records,

        SUM(
            CASE
                WHEN total_amount IS NULL THEN 1
                ELSE 0
            END
        ) AS missing_amount_records

    FROM healthcare_catalog.billing.bronze_hospital_billing
),

clean_stats AS (

    SELECT
        COUNT(*) AS clean_records

    FROM silver_billing_clean
),

rejected_stats AS (

    SELECT
        COUNT(*) AS rejected_records

    FROM silver_billing_rejected
)

SELECT
    b.bronze_total_records,

    b.unique_bill_ids,

    b.bronze_total_records - b.unique_bill_ids
        AS duplicate_extra_records,

    b.missing_patient_ids,

    b.invalid_quantity_records,

    b.negative_price_records,

    b.missing_department_records,

    b.missing_payer_records,

    b.missing_amount_records,

    c.clean_records,

    r.rejected_records,

    c.clean_records + r.rejected_records
        AS total_silver_records,

    b.unique_bill_ids -
        (c.clean_records + r.rejected_records)
        AS reconciliation_difference

FROM bronze_stats b

CROSS JOIN clean_stats c

CROSS JOIN rejected_stats r;
