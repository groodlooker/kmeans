view: input_data {
    derived_table: {
      datagroup_trigger: bigquery_kmeans_default_datagroup
      explore_source: customers {
        column: customer_id {}
        column: total_amount_spent_log {}
        column: days_since_purchase_log {}
        column: unique_invoice_count_log {}
        column: top_20_percent {}
      }
    }
    dimension: customer_id {
      type: number
    }
    dimension: total_amount_spent_log {
      type: number
    }
    dimension: days_since_purchase_log {
      type: number
    }
    dimension: unique_invoice_count_log {
      type: number
    }
    dimension: top_20_percent {
      label: "Customers Top 20 Percent (Yes / No)"
      type: yesno
    }
  }

#   CREATE MODEL yourdataset.my_model OPTIONS(
#    model_type='kmeans', num_clusters=3, distance_type='euclidean') AS SELECT * FROM data;

view: kmeans_model {
  derived_table: {
    datagroup_trigger: bigquery_kmeans_default_datagroup
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='kmeans',
        num_clusters= {% parameter transaction_history.number_of_clusters %},
        distance_type='euclidean')
        AS
        SELECT *
        FROM ${input_data.SQL_TABLE_NAME};;
  }
  parameter: number_of_clusters {
    type: number
    default_value: "3"
  }
}

view: centroids {
  derived_table: {
    sql: SELECT * FROM ML.CENTROIDS(MODEL ${kmeans_model.SQL_TABLE_NAME}) ;;
  }
  dimension: centroid_id {
    type: number
  }
  dimension: numerical_feature {
    type: string
  }
  dimension: feature_value {
    type: number
  }
  measure: avg_feature_value {
    type: average
    sql: ${feature_value} ;;
  }
}

view: centroids_categorical {
  dimension: category {}
  dimension: feature_value {}
  measure: avg_value {
    type: average
    sql: ${feature_value} ;;
  }
}

# SELECT * FROM ML.PREDICT(MODEL kmeans_demo.my_model, (SELECT * FROM higgs.test LIMIT 5))

view: kmeans_predictions {
  derived_table: {
#     datagroup_trigger: bigquery_kmeans_default_datagroup
    sql: SELECT *
      FROM ML.PREDICT(
      MODEL ${kmeans_model.SQL_TABLE_NAME},
      (SELECT * FROM ${input_data.SQL_TABLE_NAME}));;
  }
  dimension: customer_id {type:number}
  dimension: total_amount_spent_log {type:number}
  dimension: days_since_purchase_log {type:number}
  dimension: unique_invoice_count_log {type:number}
  dimension: top_20_percent {
    type:yesno
    label: "Top 20"
    }
  dimension: centroid_id {type:number}
  dimension: nearest_centroids_distance {}
  measure: m_total_amount_spent_log {
    type: max
    sql: ${total_amount_spent_log} ;;
  }
  measure: m_unique_invoice_count_log {
    type: max
    sql: ${unique_invoice_count_log} ;;
  }
  measure: m_days_since_purchase_log {
    type: max
    label: "Days Since Purch"
    sql: ${days_since_purchase_log} ;;
  }
#   measure: m_nearest_centroids_distance {
#     type: average
#     sql: ${nearest_centroids_distance} ;;
#   }
}
