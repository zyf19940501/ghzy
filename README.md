# ghzy

在实际工作中，取数逻辑稍微有些复杂，故把常用的取数逻辑用函数打包，减少后期取数时的代码量。



## 安装

github上下载

```R
devtools::install_github('zyf19940501/ghzy')
```

Gitee下载

```R
remotes::install_git('https://gitee.com/zhongyufei/ghzy')
```



## 使用示例



### 销售数据

用`get_salse_data()`函数获取按照目标维度汇总的销售数据

详情请查看函数帮助

```R
library(ROracle)
library(DBI)
library(ghzy)
library(tidyverse)
library(dplyr)
library(dbplyr)
#连接数仓
drv <-dbDriver("Oracle")
connect.string <- '(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = ghbi) ))'
con <- dbConnect(drv,username = "", password = "",dbname = connect.string)
## Not run
dt <- get_sales_data(con,年,月,分析大类,SHOP_NO,start_date = '2020-10-17',end_date = '2020-11-16',brand_name = '事业部名称',category_name = c('镜架','太阳镜'))
dt <- get_sales_data(con,年,月,SHOP_NO,SKU_NO,start_date = '2020-10-17',end_date = '2020-11-16',brand_name = '事业部名称1'，area_name = "华东")
dt <- get_sales_data(con,年,月,SHOP_NO,SKU_NO,start_date = '2020-10-17',end_date = '2020-11-16',brand_name = '事业部名称1',channel_type = "直营")
```



### 出货数据

#### 财务出货口径

用`get_shipment_data()`函数获取汇总的出货数据

其他可用汇总字段包含门店属性、商品属性，具体请查看 `store()`,`sku()`函数的帮助

```R
## not run
dt <- get_shipment_data(con,年,月,start_date = '2020-01-01',end_date = '2020-10-25',brand_name = '事业部名称')
```

#### 总仓出货口径

```R
# 可以添加出货类型字段汇总
dt <- get_inventory_shipment_data(con = con,BILL_TYPE,brand_name = 'mujosh',start_date = '2020-10-10',end_date = '2020-10-31',
category = c("镜架","太阳镜"))
```



### 库存数据

#### 门店总仓库存

用`get_stock_data()函数获取汇总的库存数据`，包含门店以及总仓库存

其他可用参数包含门店属性、商品属性，具体请查看 `store()`,`sku()`函数的帮助

```R
#默认参数 stock_date = 昨天,category_name 参数默认等于镜架 太阳镜

#按照SHOP_NO,SKU_NO 两个字段汇总 其余门店属性或商品属性可任意添加

#group by SHOP_NO,SKU_NO
dt <- get_stock_data(con,SHOP_NO,SKU_NO,brand_name = '事业部名称',category_name = c('镜架','太阳镜','镜片','老视成镜','防蓝光镜','隐形眼镜','周边商品','物料'))

# 完整信息 可以先按照shop_no sku_no 汇总后关联门店信息表 商品信息表

dt <- get_stock_data(con,SHOP_NO,SKU_NO,brand_name = '事业部名称',category_name = c('镜架','太阳镜','镜片','老视成镜','防蓝光镜','隐形眼镜','周边商品','物料'))
store_table <- store(con,brand_name = c('事业部名称','事业部名称1')) %>% collect()
sku_table <- sku(con = con,category_name = c('镜架','太阳镜','镜片','老视成镜','防蓝光镜','隐形眼镜','周边商品','物料')) %>% collect()
dt <- left_join(dt,store_table) %>% 
  left(sku_table)
```

#### 总仓库存

用`get_total_warehouse_data()`函数获取总仓的库存数据，其余同上

``` R
get_total_warehouse_data(con ,SHOP_NO,SKU_NO,brand_name = '事业部名称')
```


### 销售库存合并

用`merge_sales_stock_date()`函数获取销售库存合并后的数据，按照全连接的方式。

输出结果维度包含：年、月、SHOP_NO、SKU_NO,以及销售金额、销售量以及库存量等。

按照年月汇总后的数据中库存量的时间是根据指定的结束时间。长时间周期中，月库存是指当月月末库存。

考虑总仓到库存，为了方便统一，将总仓当作门店处理，本函数输出的明细将包含总仓的SHOP_NO，在实际用Excel建模时，可以依据`仓位类型`字段区分门店库存以及总仓库存.

``` R
#单月合并
dt <- merge_sales_stock_month_data(con = con,date = c('2020-10-01','2020-10-30'),brand_name = '事业部名称')

# 跨月合并
# 一定时间周期内合并，如下所示：
dt <- ghzy::merge_sales_stock_data(dates = c('2020-10-01','2020-11-30'),con = con, brand_name = '事业部名称')

# 其他完整月份库存是月末库存，11月的库存是11-10日的库存
dt <- ghzy::merge_sales_stock_data(dates = c('2020-01-01','2020-11-10'),con = con, brand_name = '事业部名称')
```