connection: "lookerdata"

# include all the views
include: "*.view"

datagroup: bigquery_kmeans_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: bigquery_kmeans_default_datagroup
