
#' Title get shipment data from Finance shipment table
#'
#' @description  从财务出货表中获取出货数据
#'
#' @param con  BI connector
#' @param brand_name  事业部
#' @param start_date   时间周期
#' @param end_date     时间周期
#' @param ...   汇总字段 可以按照 SHOP_NO,SKU_NO,年,月等
#' @import  dbplyr
#' @return shipment data
#' @export
#'
#' @examples
#' get_shipment_data(con,brand_name = '木九十事业部',start_date = '2020-01-01',end_date = '2020-10-25',年,月)
#'
#'
#' @encoding UTF-8
#'
get_shipment_data <- function(con,brand_name,start_date,end_date,...){
  tbl(con, in_schema("DW", "DW_FIC_SALE_F")) %>%
    select(BILL_DATE1, SKU_NO, SHOP_NO, BILL_QTY,MONEY,PRICE_MONEY) %>%
    filter(between(
      BILL_DATE1, to_date(start_date, "yyyy-mm-dd"),
      to_date(end_date, "yyyy-mm-dd")
    )) %>%
    mutate(年 = year(BILL_DATE1), 月 = month(BILL_DATE1)) %>%
    inner_join(filter(store(con),一级部门==brand_name)) %>%
    inner_join(sku(con)) %>%
    group_by(...) %>%
    summarise(
      含税销售金额 = sum(MONEY, na.rm = TRUE),
      数量 = sum(BILL_QTY, na.rm = TRUE),
      吊牌金额 = sum(PRICE_MONEY, na.rm = TRUE)) %>%
    collect()
  # return(res)
}




