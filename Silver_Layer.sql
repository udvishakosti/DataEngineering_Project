CREATE OR REFRESH MATERIALIZED VIEW
silver_billing_clean AS

WITH ranked_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY bill_id
            ORDER BY loaded_at
        ) AS row_num
    FROM healthcare_catalog.billing.bronze_hospital_billing
)

SELECT
    * EXCEPT (
        row_num,
        department,
        payer_type,
        city,
        service_category,
        total_amount
    ),

    COALESCE(NULLIF(TRIM(department), ''), 'Unknown') AS department,
    COALESCE(NULLIF(TRIM(payer_type), ''), 'Unknown') AS payer_type,
    COALESCE(NULLIF(TRIM(city), ''), 'Unknown') AS city,
    COALESCE(NULLIF(TRIM(service_category), ''), 'Unknown') AS service_category,
    COALESCE(total_amount, quantity * unit_price) AS total_amount

FROM ranked_data

WHERE row_num = 1
  AND quantity > 0
  AND unit_price >= 0;


CREATE OR REFRESH MATERIALIZED VIEW
silver_billing_rejected AS

WITH ranked_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY bill_id
            ORDER BY loaded_at
        ) AS row_num
    FROM healthcare_catalog.billing.bronze_hospital_billing
),

deduplicated_data AS (
    SELECT *
    FROM ranked_data
    WHERE row_num = 1
)

SELECT
    bill_id,
    visit_id,
    patient_id,
    patient_gender,
    patient_age,
    visit_date,
    visit_type,
    department,
    doctor_name,
    service_category,
    service_name,
    hospital_branch,
    city,
    region,
    payer_type,
    quantity,
    unit_price,
    total_amount,
    insurance_amount,
    payment_status,
    source_file,
    loaded_at,

    CASE
        WHEN quantity <= 0
            THEN 'Quantity is zero or negative'
        WHEN unit_price < 0
            THEN 'Unit price is negative'
    END AS reject_reason

FROM deduplicated_data

WHERE quantity <= 0
   OR unit_price < 0;
