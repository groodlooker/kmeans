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
  join: kmeans_predictions {
    fields: [kmeans_predictions.m_days_since_purchase_log,
      kmeans_predictions.m_unique_invoice_count_log,kmeans_predictions.m_total_amount_spent_log,
      kmeans_predictions.centroid_id]
    sql_on: ${transaction_history.customer_id} = ${kmeans_predictions.customer_id} ;;
    relationship: many_to_one
  }
  join: nearest_centroids {
    fields: [nearest_centroids.avg_distance,nearest_centroids.centroid_id]
    sql: LEFT JOIN UNNEST(kmeans_predictions.nearest_centroids_distance) as nearest_centroids ;;
    relationship: one_to_many
  }
  join: customers {
    view_label: "Customer Facts"
    fields: [customers.top_20_percent,
      customers.days_since_purchse_m,customers.total_amount_spent_m,
      customers.unique_invoice_count_m]
    sql_on: ${transaction_history.customer_id} = ${customers.customer_id} ;;
    relationship: many_to_one
  }
  join: company_total_amount {
    fields: []
    sql_on: 1 = 1 ;;
    relationship: one_to_one
  }
}

explore: kmeans_predictions {
  join: transaction_history {
    fields: [transaction_history.number_of_clusters]
    sql_on: ${kmeans_predictions.customer_id} = ${transaction_history.customer_id} ;;
    relationship: one_to_one
  }
  join: nearest_centroids {
    sql: LEFT JOIN UNNEST(kmeans_predictions.nearest_centroids_distance) as nearest_centroids ;;
    relationship: one_to_many
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

# explore: customer_transactions {
#   from: transaction_history
#   extends: [transaction_history]
#   join: kmeans_predictions {
#     sql_on: ${customer_transactions.customer_id} = ${kmeans_predictions.customer_id} ;;
#     relationship: many_to_one
#   }
#   join: customers {
#     sql_on: ${customer_transactions.customer_id} = ${customers.customer_id} ;;
#     relationship: many_to_one
#   }
#   join: company_total_amount {
#     sql_on: 1 = 1 ;;
#     relationship: one_to_one
#   }
# }
