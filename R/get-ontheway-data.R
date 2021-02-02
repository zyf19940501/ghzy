
#' @title  get on the way data from BI database
#'
#' @param con  BI connector
#' @param brand_name  事业部名称
#' @param channel_type 门店渠道
#' @param area_name 管辖区域 
#' @param boss_name 加盟商客户
#' @param shop_no the shop of Number
#' @param category_name the category name of goods
#' @details 本在途数据仅仅是门店在途数据即总仓发货给门店的在途或门店发给总仓的在途两种类型，并不包含采购在途
#' @encoding UTF-8
#' @import dbplyr
#' @import lubridate
#' @return a data.frame 
#' @export
#'
#' @examples
#'get_ontheway_data(con = con,brand_name = 'mujosh',category = c("frame","sunglasses"))
#'
get_ontheway_data <- function(con,brand_name, channel_type = NULL, area_name = NULL,
                               boss_name = NULL, shop_no = NULL, category_name = NULL) {
  
  store_table <- store(con,brand_name = brand_name,channel_type = channel_type ,
                     area_name = area_name,boss_name = boss_name,shop_no = shop_no)
  
  sku_table <- sku(con, category_name = category_name) %>% 
    select(SKU_NO,分析大类,吊牌价,最早销售日期)
  
  tbl(con, in_schema("DW", "DW_TRANSIT_F")) %>%
    filter(SHOP_NO %in% c('DC011001','DC011002')) %>% 
    group_by(STOR_NO,SKU_NO) %>% 
    summarise(QTY = sum(QTY,na.rm = TRUE)) %>% 
    rename(SHOP_NO = STOR_NO) %>% 
    inner_join(store_table) %>%
    inner_join(sku_table) %>%
    collect()
}


