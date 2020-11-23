# ghzy

在实际工作中，取数逻辑稍微有些复杂，故把常用的取数逻辑用函数打包，减少后期取数时的代码量。


## install 

devtools::install_github("zyf19940501/ghzy")

在光合作用工作时，把常用的取数逻辑用函数打包，减少后期取数时的代码量，以及重复量。



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
