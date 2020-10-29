
#' @title get stock data from BI database
#'
#' @description 从BI数仓中获取库存数据 按照年、月、SHOP_NO,SKU_NO汇总
#' @param con  BI con connector
#' @param brand_name  事业部
#' @param stock_date  库存日期 默认昨天
#' @param goods_categories 分析大类
#' @param ... 需要添加汇总字段,默认年,月,SHOP_NO,SKU_NO
#'
#' @return  data frame
#' @import tidyverse dbplyr data.table
#' @encoding UTF-8
#' @export
#'
#' @examples
#' dt <- get_stock_data(con = con,brand_name = 'mujosh',stock_date = lubridate::today()-days(1),goods_categories = c('镜架','太阳镜'),分析大类,仓位类型)
#'
#'
get_stock_data <- function(con, brand_name, stock_date, goods_categories = c("镜架", "太阳镜"), ...) {

  # store stcok
  store_table <- filter(store(con), 一级部门 == brand_name)
  sku_table <- sku(con) %>%
    filter(分析大类 %in% goods_categories)


  res1 <- tbl(con, in_schema("DW", "DW_GOODS_STOCK_F")) %>%
    filter(
      STOCK_DATE == to_date(stock_date, "yyyy-mm-dd")
    ) %>%
    mutate(年 = year(STOCK_DATE), 月 = month(STOCK_DATE)) %>%
    select(年, 月, SHOP_NO, SKU_NO, STOCK_QTY, STOCK_QTY1, STOCK_QTY2, PRICE)



  # inventory stock

  res2 <- tbl(con, in_schema("DW", "DW_GOODS_STOCK_F")) %>%
    filter(SHOP_NO %in% c("DC01", "DC02", "EM01")) %>%
    filter(
      STOCK_DATE == to_date(stock_date, "yyyy-mm-dd")
    ) %>%
    mutate(年 = year(STOCK_DATE), 月 = month(STOCK_DATE)) %>%
    mutate(SHOP_NO = STOR_NO) %>%
    select(年, 月, SHOP_NO, SKU_NO, STOCK_QTY, STOCK_QTY1, STOCK_QTY2, PRICE)


  res <- union_all(res1, res2) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(...) %>%
    summarise(
      可用库存 = sum(STOCK_QTY1, na.rm = TRUE),
      非限制使用库存 = sum(STOCK_QTY2, na.rm = TRUE),
      库存吊牌金额 = sum(PRICE, na.rm = TRUE)
    ) %>%
    collect()

  return(res)
}

