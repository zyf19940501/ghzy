

#' @title get sales data from BI database
#'
#' @description  获取销售数据 有数量、金额、吊牌金额三个指标，维度需自行指定
#'
#' @param con  BI con connector
#' @param brand_name 事业部名称
#' @param start_date 销售数据开始日期
#' @param end_date   销售数据截至日期
#' @param ... 汇总字段 默认为空 可指定任意门店属性或商品属性字段
#'
#' @import tidyverse
#' @import dbplyr
#' @return sales data
#' @export
#'
#'
#' @examples
#' get_sales_data
#' get_sales_data(con,brand_name = 'MUJOSH',start_date = '2020-01-01',end_date = '2020-10-25',SHOP_NO,SKU_NO)
#'
#' @encoding UTF-8



get_sales_data <- function(con,brand_name,start_date,end_date,...){
  tbl(con, in_schema("DW", "DW_SALE_SHOP_F")) %>%
    select(BILL_DATE1, SKU_NO, SHOP_NO, BILL_QTY, BILL_MONEY2, PRICE) %>%
    filter(between(
      BILL_DATE1, to_date(start_date, "yyyy-mm-dd"),
      to_date(end_date, "yyyy-mm-dd")
    )) %>%
    mutate(年 = year(BILL_DATE1), 月 = month(BILL_DATE1)) %>%
    inner_join(filter(store(con),一级部门==brand_name)) %>%
    inner_join(sku(con)) %>%
    group_by(...) %>%
    summarise(
      金额 = sum(BILL_MONEY2, na.rm = TRUE),
      数量 = sum(BILL_QTY, na.rm = TRUE),
      吊牌金额 = sum(BILL_QTY * PRICE, na.rm = TRUE)) %>%
    collect()


  # return(res)
}
