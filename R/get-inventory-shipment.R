
#' @title  get warehouse shipment data from BI database
#'
#' @description   获取仓库发货数据
#' @param con  BI con connector
#' @param brand_name 事业部
#' @param start_date  时间周期
#' @param end_date  时间周期
#' @param ...   出货量汇总字段
#'
#' @details 出货数据包含 "加盟期货发货单", "加盟现货发货单", "直营调拨发货单","直发订单发货单",'加盟政策性发货单'五种单据，
#' YH_NO 要货单号,WBSTK 发货状态
#' 当需要添加字段时可用BILL_TYPE 字段，其余门店属性商品属性自行添加
#' @encoding UTF-8
#'
#'
#' @import dbplyr
#' @return
#' @export
#'
#' @examples
#'get_inventory_shipment_data(con = con,brand_name = 'mujosh',
#'start_date = '2020-10-10',end_date = '2020-10-31',BILL_TYPE)
#'
get_inventory_shipment_data <- function(con, brand_name, start_date, end_date, ...) {
  tbl(con, in_schema("DW", "DW_SHIPPING_F")) %>%
    filter(
      between(
        BILL_DATE, to_date(start_date, "yyyy-mm-dd"),
        to_date(end_date, "yyyy-mm-dd")
      ),
      BILL_TYPE %in% c("加盟期货发货单", "加盟现货发货单", "直营调拨发货单","直发订单发货单",'加盟政策性发货单')
    ) %>%
    mutate(年 = year(BILL_DATE), 月 = month(BILL_DATE)) %>%
    inner_join(filter(store(con), 一级部门 == brand_name)) %>%
    inner_join(sku(con)) %>%
    group_by(...) %>%
    summarise(
      发货数量 = sum(QTY, na.rm = TRUE),
      发货金额 = sum(KZWI1,na.rm = TRUE)
    ) %>%
    collect()
}


