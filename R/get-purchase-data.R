
#' @title  get purchase stock data from BI database
#' @description  采购入库数据
#' @param con  BI connector
#' @param ...   汇总字段 可以按照 SHOP_NO,SKU_NO,年,月等
#' @param start_date   数据开始日期
#' @param end_date     数据结束日期
#' @param brand_name  事业部名称
#' @param channel_type 门店渠道
#' @param area_name 管辖区域 
#' @param boss_name 加盟商客户
#' @param shop_no the shop of Number
#' @param category_name the category name of goods
#' @encoding UTF-8
#' @import dbplyr
#' @import lubridate
#' @return
#' @export
#'
#' @examples
#'get_inventory_shipment_data(con = con,SKU_NO,brand_name = c('mujosh','aj'),
#'start_date = '2020-10-10',end_date = '2020-10-31',category = c("frame","sunglasses"))
#'get_purchase_data(con,SHOP_NO,brand_name = 'brand',start_date = '2021-01-01',end_date = '2021-01-10',category_name = 'frame')
#'
get_purchase_data <- function(con, ..., start_date, end_date,
                                        brand_name, channel_type = NULL, area_name = NULL,
                                        boss_name = NULL, shop_no = NULL, category_name = NULL) {
  
  store_table <- store(con,brand_name = brand_name,channel_type = channel_type ,area_name = area_name,boss_name = boss_name,shop_no = shop_no)
  sku_table <- sku(con, category_name = category_name)
  
  tbl(con, in_schema("DW", "DW_PURCHASE_STOCK_F")) %>%
    select(SHOP_NO,STOR_NO,QTY,PRICE,SKU_NO,BILL_DATE) %>% 
    filter(between(BILL_DATE, to_date(start_date, "yyyy-mm-dd"),to_date(end_date, "yyyy-mm-dd")))%>%
    filter(STOR_NO %in% c('DC011001','DC011996','DC011997','DC021001','DC021996','DC021997')) %>%  
    mutate(SHOP_NO = STOR_NO,年 = year(BILL_DATE), 月 = month(BILL_DATE)) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(...) %>%
    summarise(
      入库数量 = sum(QTY, na.rm = TRUE),
      入库金额 = sum(PRICE, na.rm = TRUE)
    ) %>%
    collect()
}


