
#' get store inventory from BI database
#'
#' @param con BI con connector
#' @param brand_name 事业部
#' @param stock_date 库存日期 默认昨天
#' @param goods_categories 分析大类
#' @param ... 需要添加汇总字段,默认年,月,SHOP_NO,SKU_NO
#'
#' @import dbplyr
#' @return a data frame
#' @encoding UTF-8
#' @export
#'
#' @examples
#' dt <- get_store_inventory_data(con = con,brand_name = 'mujosh',stock_date = lubridate::today()-days(1),goods_categories = c('lens'),SHOP_NO)

get_store_inventory_data <- function(con, brand_name, stock_date, goods_categories , ...) {

  # store stcok
  store_table <- filter(store(con), 一级部门 == brand_name)
  sku_table <- sku(con) %>%
    filter(分析大类 %in% goods_categories)
  # inventory stock

  res <- tbl(con, in_schema("DW", "DW_GOODS_STOCK_F")) %>%
    filter(
      STOCK_DATE == to_date(stock_date, "yyyy-mm-dd")
    ) %>%
    mutate(年 = year(STOCK_DATE), 月 = month(STOCK_DATE)) %>%
    select(年, 月, SHOP_NO, SKU_NO, STOCK_QTY, STOCK_QTY1, STOCK_QTY2, PRICE)%>%
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

