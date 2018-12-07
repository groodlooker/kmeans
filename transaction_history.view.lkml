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

  dimension: item_returned {
    type: yesno
    sql: starts_with(${invoice_no},"C") ;;
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

  dimension: amount_spent {
    type: number
    sql: ${unit_price} * ${quantity} ;;
  }

  measure: total_amount_spent {
    type: sum
    sql: ${amount_spent} ;;
  }

  measure: latest_purchase_hide {
    type: date
    sql: MAX(${invoice_date}) ;;
  }

  measure: unique_customer_count {
    type: count_distinct
    sql: ${customer_id} ;;
  }

  measure: unique_invoice_count {
    type: count_distinct
    sql: ${invoice_no} ;;
  }

# pareto fields
  dimension: grand_total {
    type: number
    hidden: yes
    sql: (select sum(UnitPrice * Quantity) from transaction_history where 1=1) ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
