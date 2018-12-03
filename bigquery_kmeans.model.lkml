connection: "lookerdata"

# include all the views
include: "*.view"

datagroup: bigquery_kmeans_default_datagroup {
  sql_trigger: SELECT MAX(pk) FROM transaction_history;;
  max_cache_age: "1 hour"
}

persist_with: bigquery_kmeans_default_datagroup
