connection: "lookerdata"

# include all the views
include: "*.view"

datagroup: bigquery_kmeans_default_datagroup {
  sql_trigger: SELECT MAX(pk) FROM transaction_history;;
  max_cache_age: "1 hour"
}

persist_with: bigquery_kmeans_default_datagroup

explore: transaction_history {
  sql_always_where: ifnull(${customer_id},-1) != -1
  and ${item_returned} = false
  and ${unit_price} > 0 and ${quantity} >0;;
}

explore: kmeans_predictions {
  join: transaction_history {
    fields: [transaction_history.number_of_clusters]
    sql_on: ${kmeans_predictions.customer_id} = ${transaction_history.customer_id} ;;
    relationship: one_to_one
  }
}

explore: centroids {
  join: centroids_categorical {
    sql: LEFT JOIN UNNEST(centroids.categorical_feature) as centroids_categorical ;;
    relationship: one_to_many
  }
  join: transaction_history {
    fields: [transaction_history.number_of_clusters]
    sql_on: 1 = 1 ;;
    relationship: one_to_one
  }
}
