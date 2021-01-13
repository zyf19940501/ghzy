
#' @title  get warehouse shipment data from BI database
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
#' @param WBSTK 发货状态 默认为已经处理完成
#' @details 出货数据包含 "加盟期货发货单", "加盟现货发货单", "直营调拨发货单","直发订单发货单",'加盟政策性发货单','加盟退货收货单' 
#' '加盟免费发货单'等单据
#' 
#' YH_NO 要货单号,WBSTK 发货状态,默认为已经处理完成
#' 当需要添加字段时可用BILL_TYPE 字段，其余门店属性商品属性自行添加
#' @encoding UTF-8
#' @import dbplyr
#' @import lubridate
#' @return
#' @export
#'
#' @examples
#'get_inventory_shipment_data(con = con,BILL_TYPE,brand_name = 'mujosh',
#'start_date = '2020-10-10',end_date = '2020-10-31',category = c("frame","sunglasses"))
#'
get_inventory_shipment_data <- function(con, ..., start_date, end_date,
                                        brand_name, channel_type = NULL, area_name = NULL,
                                        boss_name = NULL, shop_no = NULL, category_name = NULL,WBSTK = "C") {
  
  store_table <- store(con,brand_name = brand_name,channel_type = channel_type ,area_name = area_name,boss_name = boss_name,shop_no = shop_no)
  sku_table <- sku(con, category_name = category_name)
  
  tbl(con, in_schema("DW", "DW_SHIPPING_F")) %>%
    filter(
      between(
        BILL_DATE, to_date(start_date, "yyyy-mm-dd"),
        to_date(end_date, "yyyy-mm-dd")
      ),
      BILL_TYPE %in% c('直营调拨发货单','加盟期货发货单','加盟现货发货单','加盟免费发货单','加盟政策性发货单','加盟退货收货单','直发订单发货单')
    ) %>%
    filter(STOR_NO %in% c('DC011001','DC011998','DC011005','DC011006','DC012998','DC012999'),WBSTK == WBSTK ) %>%  # 完全处理完成
    mutate(出货类型 = case_when(QTY > 0 ~ "正常出货",QTY < 0 ~ "出货退货",QTY == 0 ~ "未出货" )) %>% 
    mutate(年 = year(BILL_DATE), 月 = month(BILL_DATE)) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(...) %>%
    summarise(
      发货数量 = sum(QTY, na.rm = TRUE),
      发货金额 = sum(KZWI1,na.rm = TRUE)
    ) %>%
    collect()
}


