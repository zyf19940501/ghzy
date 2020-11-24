# ghzy

在实际工作中，取数逻辑稍微有些复杂，故把常用的取数逻辑用函数打包，减少后期取数时的代码量。



### 安装

github上下载

```R
devtools::install_github('zyf19940501/ghzy')
```

Gitee下载



### 使用示例



#### 销售数据

用`get_salse_data()`函数获取按照目标维度汇总的销售数据



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
dt <- get_sales_data(con,年,月,分析大类,SHOP_NO,start_date = '2020-10-17',end_date = '2020-11-16',brand_name = '木九十事业部',category_name = c('镜架','太阳镜'))
dt <- get_sales_data(con,年,月,SHOP_NO,SKU_NO,start_date = '2020-10-17',end_date = '2020-11-16',brand_name = 'aojo事业部'，area_name = "华东")
dt <- get_sales_data(con,年,月,SHOP_NO,SKU_NO,start_date = '2020-10-17',end_date = '2020-11-16',brand_name = 'aojo事业部',channel_type = "直营")
```



#### 出货数据

用`get_shipment_data()`函数获取汇总的出货数据

```R
dt <- get_shipment_data(con,年,月,start_date = '2020-01-01',end_date = '2020-10-25',brand_name = '木九十事业部')
```



#### 库存数据

用`get_stock_data()函数获取汇总的库存数据`

```R
#默认参数 stock_date = 昨天,category_name 参数默认等于镜架 太阳镜
#按照SHOP_NO,SKU_NO 两个字段汇总 其余门店属性或商品属性可任意添加

#group by SHOP_NO,SKU_NO
ghzy::get_stock_data(con,SHOP_NO,SKU_NO,brand_name = '木九十事业部',category_name = c('镜架','太阳镜','镜片','老视成镜','防蓝光镜','隐形眼镜','周边商品','物料'))

# 完整资料 可以先按照shop_no sku_no 汇总后关联门店信息表 商品信息表
# step 1
dt <- ghzy::get_stock_data(con,SHOP_NO,SKU_NO,brand_name = '木九十事业部',category_name = c('镜架','太阳镜','镜片','老视成镜','防蓝光镜','隐形眼镜','周边商品','物料'))
store_table <- store(con,brand_name = c('木九十事业部','aojo事业部')) %>% collect()
sku_table <- sku(con = con,category_name = c('镜架','太阳镜','镜片','老视成镜','防蓝光镜','隐形眼镜','周边商品','物料')) %>% collect()
dt <- left_join(dt,store_table) %>% 
  left(sku_table)
```

