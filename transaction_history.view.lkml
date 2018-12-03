view: transaction_history {
  sql_table_name: online_retail.transaction_history ;;

  dimension: pk {
    type: number
    primary_key: yes
    sql: ${TABLE}.pk ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.Country ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.CustomerID ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.Description ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.InvoiceDate ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.InvoiceNo ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.Quantity ;;
  }

  dimension: stock_code {
    type: string
    sql: ${TABLE}.StockCode ;;
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}.UnitPrice ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
