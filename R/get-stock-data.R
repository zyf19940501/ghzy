
#' @title get stock data from BI database
#'
#' @description 从BI数仓中获取库存数据 按照年、月、SHOP_NO,SKU_NO汇总
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
#' @return  a data frame  包含门店库存和总仓库存 可由仓位类型区分
#' @import  dbplyr
#' @encoding UTF-8
#' @export
#'
#' @examples
#' dt <- get_stock_data(con = con,SHOP_NO,SKU_NO,brand_name = 'mujosh',stock_date = lubridate::today()-days(1),goods_categories = c('frame','sunglasses'))
#'
#'
get_stock_data <- function(con, ..., brand_name,channel_type = NULL,area_name = NULL,boss_name = NULL,shop_no = NULL, 
                           stock_date = Sys.Date()- 1, category_name  = c("镜架", "太阳镜")) {
   
  # store stcok
  store_table <- store(con,
                       brand_name = brand_name, channel_type = channel_type,
                       area_name = area_name, boss_name = boss_name, shop_no = shop_no
  )
  
  sku_table <- sku(con, category_name = category_name)


  res1 <- tbl(con, in_schema("DW", "DW_GOODS_STOCK_F")) %>%
    filter(
      STOCK_DATE == to_date(stock_date, "yyyy-mm-dd")
    ) %>%
    mutate(年 = year(STOCK_DATE), 月 = month(STOCK_DATE)) %>%
    select(年, 月, SHOP_NO, SKU_NO, STOCK_QTY, STOCK_QTY1, STOCK_QTY2, PRICE)



  # inventory stock

  res2 <- tbl(con, in_schema("DW", "DW_GOODS_STOCK_F")) %>%
    filter(SHOP_NO %in% c("DC01", "DC02", "EM01","EM06")) %>%
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

