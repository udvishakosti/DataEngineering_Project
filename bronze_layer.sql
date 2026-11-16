# ==========================================
# HOSPITAL BILLING PROJECT
# BRONZE LAYER
# ==========================================

from pyspark.sql import functions as F
from pyspark import pipelines as dp


@dp.table(
    name="healthcare_catalog.billing.bronze_hospital_billing",
    comment="Raw hospital billing records ingested from the raw_files volume",
)
def bronze_hospital_billing():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("cloudFiles.inferColumnTypes", "true")
        .option("header", "true")
        .load("/Volumes/healthcare_catalog/billing/raw_files")
        .withColumn("source_file", F.col("_metadata.file_name"))
        .withColumn("loaded_at", F.current_timestamp())
    )
