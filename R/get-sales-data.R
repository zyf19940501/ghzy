

#' @title get sales data from BI database
#'
#' @description  获取销售数据 有数量、金额、吊牌金额三个指标，维度需自行指定
#'
#' @param con  BI con connector
#' @param ... 汇总字段 默认为空 可指定任意门店属性或商品属性字段
#' @param start_date 销售数据开始日期
#' @param end_date   销售数据结束日期
#' @param brand_name 事业部名称
#' @param channel_type 门店渠道
#' @param area_name 管辖区域 
#' @param boss_name 加盟商客户
#' @param category_name the category name of goods
#' 
#'
#' @details  该包系列中`...`参数,为用户想要汇总字段，最小的维度可到SHOP_NO,SKU_NO,其余的字段属性可根据需要添加
#'
#' 门店属性:SHOP_NO 门店名称 原ERP店编码 品牌 一级部门 门店性质 国家 管辖区域 省份 城市 城市等级 门店负责人 区域经理 经营状态 店铺类型 老板 加盟商编码 加盟商名称 重点客户标识 年可比店 当月可比店 门店属性 仓位类型
#'
#' 商品属性:SKU_NO SAP_NO SKC_NO 款号 商品简称 商品名称 大类名称 中类名称 小类名称 定价品类 是否标配镜片 吊牌价 海外吊牌价 价格带 厂商品牌 镜框材质 镜框大小 镜框款式 镜框颜色 眼镜框型 镜片功能 镜片颜色 能否染色 球镜 柱镜 折射率 商品品牌 系统上市时间 最早销售日期 SYS_ID 分析大类
#'
#' 以上字段可以参考spb数据库中store_table 和sku_table.
#'
#' 当需要添加字段属性较多时，可以用 get_sales_data()在关联门店信息表和商品信息表

#'
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



get_sales_data <- function(con,...,start_date,end_date,brand_name,channel_type = NULL ,area_name = NULL,boss_name = NULL,category_name = NULL){

  store_table <- store(con,brand_name = brand_name,channel_type = channel_type ,area_name = area_name,boss_name = boss_name)
  
  sku_table <- sku(con,category_name =  category_name )
  
  tbl(con, in_schema("DW", "DW_SALE_SHOP_F")) %>%
    select(BILL_DATE1, SKU_NO, SHOP_NO, BILL_QTY, BILL_MONEY2, PRICE) %>%
    filter(between(
      BILL_DATE1, to_date(start_date, "yyyy-mm-dd"),
      to_date(end_date, "yyyy-mm-dd")
    )) %>%
    mutate(年 = year(BILL_DATE1), 月 = month(BILL_DATE1)) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(...) %>%
    summarise(
      金额 = sum(BILL_MONEY2, na.rm = TRUE),
      数量 = sum(BILL_QTY, na.rm = TRUE),
      吊牌金额 = sum(BILL_QTY * PRICE, na.rm = TRUE)) %>%
    collect() %>%
    mutate(折扣率:= 金额 / 吊牌金额) %>% 
    arrange(...)


  # return(res)
}



