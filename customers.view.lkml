view: customers {
    derived_table: {
      datagroup_trigger: bigquery_kmeans_default_datagroup
      explore_source: transaction_history {
        column: customer_id {}
        column: latest_purchase_hide {}
        column: count {}
        column: total_amount_spent {}
        column: unique_invoice_count {}
        derived_column: cum_sum {
          sql: sum(total_amount_spent) over(order by total_amount_spent desc);;
        }
        derived_column: customer_numbering {
          sql: row_number() over(order by total_amount_spent desc) ;;
        }
      }
    }

    dimension: customer_id {
      type: number
      primary_key: yes
    }
    dimension_group: latest_purchase_hide {
      type: time
      hidden: yes
    }
    dimension: count {
      type: number
    }
    dimension: total_amount_spent {
      type: number
    }
    dimension: cum_sum {
      type: number
    }
    dimension: unique_invoice_count {
      type: number
    }
    dimension_group: recency_of_purchase {
      type: duration
      hidden: yes
      sql_start: ${latest_purchase_hide_raw} ;;
      sql_end: TIMESTAMP("2018-12-10") ;;
    }
    dimension: days_since_purchse {
      type: number
      sql: ${days_recency_of_purchase} ;;
    }
    # ################################
    # viz use only
    measure: days_since_purchse_m {
      label: "Days Since Last Purchase"
      type: min
      sql: ${days_recency_of_purchase} ;;
    }
    measure: unique_invoice_count_m {
      label: "Unique Invoice Count"
      type: min
      sql: ${unique_invoice_count} ;;
    }
    measure: total_amount_spent_m {
      label: "Total Amount Spent"
      type: min
      sql: ${total_amount_spent} ;;
    }
    # Log of measures
    measure: days_since_purchase_log {
      type: min
      sql: LOG(${days_recency_of_purchase}) ;;
    }
    measure: unique_invoice_count_log {
      type: min
      sql: LOG(${unique_invoice_count}) ;;
    }
    measure: total_amount_spent_log {
      type: min
      sql: LOG(${total_amount_spent}) ;;
    }
    # ################################
    # ################################

    dimension: customer_numbering {}
    dimension: pareto_amount {
      value_format_name: percent_1
      sql: ${cum_sum} / ${company_total_amount.total_amount_spent} ;;
    }
    dimension: pareto_customer  {
      value_format_name: percent_1
      sql: ${customer_numbering} / ${company_total_amount.unique_customer_count} ;;
    }
    dimension: top_20_percent {
      type: yesno
      sql: ${pareto_customer} <= 0.2 ;;
    }
  }


explore: customers {
  join: company_total_amount {
    sql_on: 1 = 1 ;;
    relationship: one_to_one
  }
}


view: company_total_amount {
  derived_table: {
    datagroup_trigger: bigquery_kmeans_default_datagroup
    explore_source: transaction_history {
      column: total_amount_spent {}
      column: unique_customer_count {}
    }
  }
  dimension: total_amount_spent {
    type: number
  }
  dimension: unique_customer_count {
    type: number
  }
}

explore: company_total_amount {}
