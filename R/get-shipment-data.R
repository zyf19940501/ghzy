
#' Title get shipment data from Finance shipment table
#'
#' @description  从财务出货表中获取出货数据
#'
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
get_shipment_data <- function(con, ..., start_date, end_date,
                              brand_name, channel_type = NULL, area_name = NULL,
                              boss_name = NULL, shop_no = NULL, category_name = NULL) {
  store_table <- store(con,
    brand_name = brand_name, channel_type = channel_type,
    area_name = area_name, boss_name = boss_name, shop_no = shop_no
  )

  sku_table <- sku(con, category_name = category_name)

  tbl(con, in_schema("DW", "DW_FIC_SALE_F")) %>%
    select(BILL_DATE1, SKU_NO, SHOP_NO, BILL_QTY, MONEY, PRICE_MONEY) %>%
    filter(between(
      BILL_DATE1, to_date(start_date, "yyyy-mm-dd"),
      to_date(end_date, "yyyy-mm-dd")
    )) %>%
    mutate(年 = year(BILL_DATE1), 月 = month(BILL_DATE1)) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(...) %>%
    summarise(
      含税销售金额 = sum(MONEY, na.rm = TRUE),
      数量 = sum(BILL_QTY, na.rm = TRUE),
      吊牌金额 = sum(PRICE_MONEY, na.rm = TRUE)
    ) %>%
    collect() %>%
    arrange(...)
  # return(res)
}




