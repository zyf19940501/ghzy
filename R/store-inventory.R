
#' get store inventory from BI database
#'
#' @param con  BI con connector
#' @param ... 需要添加汇总字段,默认年,月,SHOP_NO,SKU_NO
#' @param brand_name  事业部名称
#' @param channel_type 门店渠道
#' @param area_name 管辖区域 
#' @param boss_name 加盟商客户
#' @param shop_no the shop of Number
#' @param stock_date  库存日期 默认昨天
#' @param category_name  分析大类
#' 
#' @import dbplyr
#' @return a data frame
#' @encoding UTF-8
#' @export
#'
#' @examples
#' dt <- get_store_inventory_data(con = con,SHOP_NO,brand_name = 'mujosh',stock_date = lubridate::today()-days(1),goods_categories = c('lens'))

get_store_inventory_data <- function(con, ..., brand_name,channel_type = NULL,
                                     area_name = NULL,boss_name = NULL,shop_no = NULL, 
                                     stock_date = Sys.Date()- 1, category_name  = c("镜架", "太阳镜")) {

  # store stcok
  store_table <- store(con,
                       brand_name = brand_name, channel_type = channel_type,
                       area_name = area_name, boss_name = boss_name, shop_no = shop_no
  )
  
  sku_table <- sku(con, category_name = category_name)
  
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

