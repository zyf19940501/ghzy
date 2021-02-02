
#' @title merge sales data  and stock data from BI database pro
#' @description  full join sales data and stock data pro
#' @param dates  the list of date
#' @param con  BI con connector
#' @param dates the start date of you select 
#' @param brand_name  the name of brand
#' @param channel_type direct store and franchise store ,the channel of store sales
#' @param area_name area name 
#' @param boss_name the franchise customer 
#' @param shop_no the shop of Number
#' @param category_name the category name of goods
#' @encoding UTF-8
#' @return  a dataframe
#' @examples
#' mydt <- merge_sales_stock_data(dates = c('2020-01-01','2020-10-11'),con,brand_name = "mujosh")
#' @export
#' 
#' 
merge_sales_stock_data <- function(dates,con,brand_name,channel_type = NULL ,area_name = NULL,boss_name = NULL,category_name = NULL,shop_no = NULL){
  
  start_date <- as_date(dates[1])
  end_date <- as_date(dates[2])
  
  start_tp <- start_date
  end_tp <- ceiling_date(end_date,unit = 'month') - days(1)
  
  i <- 1
  result <- list()
  while(start_tp <= end_tp){
    temp <- start_tp %m+% months(1)
    tempp <- temp -days(1)
    res <- c(start_tp,tempp)
    
    result[[i]] <- res
    start_tp <- temp
    i <- i+1
    #print(i)
  }
  
  result[[i-1]][2] <- end_date
  res <- furrr::future_map_dfr(result,merge_sales_stock_month_data,con = con,
                               brand_name = brand_name,channel_type = channel_type,area_name = area_name,
                               boss_name = boss_name,category_name = category_name,shop_no = shop_no)
  return(res)
}








