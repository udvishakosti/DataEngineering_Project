Data quality was an important part of this project. Before using hospital billing records for business analysis, I implemented validation checks to identify duplicate records, invalid values, missing information, and incomplete billing details.

The main objective was to ensure that the Gold layer contains reliable data for reporting and analysis.

### A. Duplicate Record Validation

**Rule:** Each `bill_id` should have only one record in the final Silver dataset.

**Validation approach:**
- Used the `ROW_NUMBER()` window function.
- Applied `PARTITION BY bill_id` to identify duplicate billing records.
- Ordered records using `loaded_at`.
- Retained the first record (`row_num = 1`).
- Removed additional duplicate records from the clean dataset.

**SQL logic:**

```sql
ROW_NUMBER() OVER (
    PARTITION BY bill_id
    ORDER BY loaded_at
) AS row_num
```

**Result:**
- Bronze records: 1,010
- Unique bill IDs: 990
- Duplicate extra records: 20

### B. Quantity Validation

**Rule:** Quantity must be greater than zero.

**Validation conditions:**
- Quantity = 0 → Invalid
- Quantity < 0 → Invalid
- Quantity > 0 → Valid

**SQL condition:**

```sql
quantity <= 0
```

**Result:** 14 invalid quantity records were identified and moved to the rejected dataset.

### C. Unit Price Validation

**Rule:** Unit price must not be negative.

**Validation conditions:**
- Unit price < 0 → Invalid
- Unit price = 0 → Allowed by the implemented rule
- Unit price > 0 → Valid

**SQL condition:**

```sql
unit_price < 0
```

**Result:** 8 records with negative unit prices were identified and rejected.

### D. Missing Patient ID Validation

**Rule:** Identify records where `patient_id` is NULL.

**SQL condition:**

```sql
patient_id IS NULL
```

**Result:** 8 records had missing patient IDs.

**Business decision:** These records were retained in the clean dataset because the billing information could still be valid even when patient identification was unavailable.

Missing patient IDs were reported as a data quality issue but were not treated as a rejection condition.

### E. Missing Department Validation

**Rule:** Identify records where department information is missing or blank.

**SQL condition:**

```sql
department IS NULL
OR TRIM(department) = ''
```

**Result:** 12 records were identified in the Bronze layer.

Missing department values were handled during Silver transformation by replacing blank values with `Unknown`.

### F. Missing Payer Validation

**Rule:** Identify records where payer information is missing or blank.

**SQL condition:**

```sql
payer_type IS NULL
OR TRIM(payer_type) = ''
```

**Result:** 10 records were identified in the Bronze layer.

Missing payer values were standardized as `Unknown` during Silver transformation.

### G. Missing Amount Validation

**Rule:** Identify records where total billing amount is NULL.

**SQL condition:**

```sql
total_amount IS NULL
```

**Result:** 15 records were identified in the Bronze layer.

The Silver transformation calculates the amount using quantity multiplied by unit price when the total amount is missing.

```sql
COALESCE(
    total_amount,
    quantity * unit_price
)
```

### H. Clean and Rejected Record Separation

Records were separated into two datasets based on the implemented validation rules.

**Clean records:**
- Duplicate records removed.
- Quantity greater than zero.
- Unit price greater than or equal to zero.
- Missing patient IDs retained.
- Selected missing categorical values standardized as `Unknown`.
- Missing total amounts calculated when possible.

**Rejected records:**
- Quantity less than or equal to zero.
- Negative unit price.

This approach ensures that invalid billing records do not enter the Gold analytical layer.

---

## 2. Data Quality Results

| Data Quality Check | Records Identified |
|---|---:|
| Duplicate extra records | 20 |
| Missing patient IDs | 8 |
| Invalid quantity | 14 |
| Negative unit price | 8 |
| Missing department | 12 |
| Missing payer type | 10 |
| Missing total amount | 15 |
| Clean records | 968 |
| Rejected records | 22 |

**Note:** Missing-value counts are independent checks on the Bronze dataset. A record may have more than one data quality issue, so these counts should not be added together to calculate rejected records.

---

## 3. Data Reconciliation Framework

Data reconciliation was implemented to verify that the records were correctly accounted for across the Bronze and Silver layers.

The purpose was to ensure that no unique billing records were unexpectedly lost during deduplication and validation.

### A. Bronze Layer Reconciliation

| Metric | Count |
|---|---:|
| Total Bronze records | 1,010 |
| Unique bill IDs | 990 |
| Duplicate extra records | 20 |

**Formula:**

```text
Duplicate Extra Records =
Total Bronze Records - Unique Bill IDs
```

```text
1,010 - 990 = 20
```

### B. Silver Layer Reconciliation

After removing duplicates, the 990 unique billing records were separated into clean and rejected datasets.

| Metric | Count |
|---|---:|
| Unique billing records | 990 |
| Clean records | 968 |
| Rejected records | 22 |
| Total Silver records | 990 |

**Formula:**

```text
Total Silver Records =
Clean Records + Rejected Records
```

```text
968 + 22 = 990
```

### C. End-to-End Reconciliation

The final reconciliation formula was:

```text
Bronze Records =
Clean Records
+ Rejected Records
+ Duplicate Extra Records
```

Substituting the actual project results:

```text
1,010 = 968 + 22 + 20
```

**Reconciliation Difference:**

```text
Unique Bill IDs - (Clean Records + Rejected Records)
```

```text
990 - (968 + 22) = 0
```

**Final Result:** Reconciliation successfully passed with a difference of zero.

### D. Reconciliation Status

| Validation | Expected | Actual | Status |
|---|---:|---:|---|
| Bronze records | 1,010 | 1,010 | Passed |
| Unique bill IDs | 990 | 990 | Passed |
| Duplicate extra records | 20 | 20 | Passed |
| Clean records | 968 | 968 | Passed |
| Rejected records | 22 | 22 | Passed |
| Total Silver records | 990 | 990 | Passed |
| Reconciliation difference | 0 | 0 | Passed |

---

## 4. Business Value of Data Quality and Reconciliation

Implementing data quality and reconciliation checks helped achieve the following:

- Improved reliability of hospital billing information.
- Prevented duplicate billing records from affecting revenue analysis.
- Identified invalid quantities and negative prices.
- Preserved valid billing records with missing patient identification.
- Improved handling of missing department, payer, and billing amount values.
- Ensured that every unique billing record was accounted for.
- Increased confidence in Gold-layer revenue summaries and dashboards.

These checks helped establish a reliable foundation for hospital revenue reporting and business analysis.
