#' @title merge sales data  and stock data from BI database
#' @description  full join sales data and stock data
#' @param con  BI con connector
#' @param date the start date of you select 
#' @param brand_name  the name of brand
#' @param channel_type direct store and franchise store ,the channel of store sales
#' @param area_name area name 
#' @param boss_name the franchise customer 
#' @param shop_no the shop of Number
#' @param category_name the category name of goods
#' 
#'
#' @details  the output data group by year month SHOP_NO SKU_NO sales num sales money the price money  goods stocks number
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
#' @import lubridate
#' @return a data.frame about sales and stock data
#'
#' @examples
#' # Not run
#' merge_sales_stock_month_data(con,category_name,date = list('2020-01-01','2020-10-25'),brand_name = 'MUJOSH')
#'
#' @encoding UTF-8
#' @export
#' 
#' 


merge_sales_stock_month_data <- function(con,date,brand_name,channel_type = NULL ,area_name = NULL,boss_name = NULL,category_name = NULL,shop_no = NULL){
  
  store_table <- store(con,brand_name = brand_name,channel_type = channel_type ,area_name = area_name,boss_name = boss_name,shop_no = shop_no)
  
  sku_table <- sku(con,category_name =  category_name )
  
  if(is.null(date)){
    stop("请输入时间周期")
  }
  
  # if(any(is.null(start_date),is.null(end_date))){
  #   stop("错误,请指定开始结束日期")
  # }
  # 
  # if(start_date != floor_date(start_date,unit = 'month')){
  #   stop("开始日期指定错误,请选定月初时间")
  # }
  # 
  # start_date <- as_date(start_date,tx ='CST')
  # end_date <- as_date(end_date,tz= 'CST')
  # 
  start_date <- date[[1]]
  end_date <- date[[2]]
  stock_date <- date[[2]]
  
  sales_res <- tbl(con, in_schema("DW", "DW_SALE_SHOP_F")) %>%
    select(BILL_DATE1, SKU_NO, SHOP_NO, BILL_QTY, BILL_MONEY2, PRICE) %>%
    filter(between(
      BILL_DATE1, to_date(start_date, "yyyy-mm-dd"),
      to_date(end_date, "yyyy-mm-dd")
    )) %>%
    mutate(年 = year(BILL_DATE1), 月 = month(BILL_DATE1)) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(年,月,SHOP_NO,SKU_NO) %>%
    summarise(
      金额 = sum(BILL_MONEY2, na.rm = TRUE),
      数量 = sum(BILL_QTY, na.rm = TRUE),
      吊牌金额 = sum(BILL_QTY * PRICE, na.rm = TRUE)) %>%
    collect() %>%
    mutate(折扣率:= 金额 / 吊牌金额) 
  
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
  
  
  stock_res <- union_all(res1, res2) %>%
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    group_by(年,月,SHOP_NO,SKU_NO) %>%
    summarise(
      可用库存 = sum(STOCK_QTY1, na.rm = TRUE),
      非限制使用库存 = sum(STOCK_QTY2, na.rm = TRUE),
      库存吊牌金额 = sum(PRICE, na.rm = TRUE)
    ) %>%
    collect()
  
  res_output <- full_join(sales_res,stock_res,by= c('年','月','SHOP_NO','SKU_NO'))
  # return(res)
}
