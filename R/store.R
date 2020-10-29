#' @title ghzy
#'
#' @description  get the store information from BI database
#'
#'
#' @param con  BI con connector
#'
#' @import dbplyr tidyverse
#' @encoding UTF-8
#' @return  a dataframe
#'
#' @examples
#' store <- store(con)
#' @export
#'
#'



store <- function(con) {

  # store information
  store_table1 <- tbl(con, in_schema("DW", "MD_SHOP_DETAIL")) %>%
    select(
      SHOP_NO, SHOP_NAME, ERP_NO, BRAND_NAME, SHOP_TYPE39,
      SHOP_TYPE29, COUNT_NAME, SHOP_AREA, PROVINCE_NAME, CITY_NAME, NIELS,
      SHOP_PNAME1, SHOP_PNAME2, SHOP_TYPE04, SHOP_TYPE05, SHOP_TYPE15,
      SHOP_TYPE36, SHOP_TYPE37, SHOP_TYPE48, SHOP_TYPE47, SHOP_TYPE49, SHOP_BRAN
    ) %>%
    rename(
      SHOP_NO = SHOP_NO, 门店名称 = SHOP_NAME, 原ERP店编码 = ERP_NO, 品牌 = BRAND_NAME, 一级部门 = SHOP_TYPE39,
      门店性质 = SHOP_TYPE29, 国家 = COUNT_NAME, 管辖区域 = SHOP_AREA, 省份 = PROVINCE_NAME, 城市 = CITY_NAME,
      城市等级 = NIELS, 门店负责人 = SHOP_PNAME1, 区域经理 = SHOP_PNAME2, 经营状态 = SHOP_TYPE04, 店铺类型 = SHOP_TYPE05,
      老板 = SHOP_TYPE15, 加盟商编码 = SHOP_TYPE36, 加盟商名称 = SHOP_TYPE37, 重点客户标识 = SHOP_TYPE48, 年可比店 = SHOP_TYPE47,
      当月可比店 = SHOP_TYPE49, 门店属性 = SHOP_BRAN
    ) %>% # rename
    mutate(仓位类型 = '门店库存')


  store_table2 <- tbl(con, in_schema("DW", "MD_HOUSE_DETAIL")) %>%
    select(SHOP_NO = STOR_NO, SHOP_NAME = STORE_NAME, fuzhu1 = SHOP_NO) %>%
    filter(SHOP_NO %in% c("DC011001", "DC011002", "DC011994", "DC011998", "DC011999", "DC011003", "DC011996", "DC011997", "EM061001", "DC021001", "DC021002", "DC021994", "DC021998", "DC021999", "DC021003", "DC021996", "DC021997")) %>%
    mutate(ERP_NO = "") %>%
    mutate(BRAND_NAME = case_when(
      fuzhu1 == "DC01" ~ "木九十",
      fuzhu1 == "DC01" ~ "木九十",
      fuzhu1 == "DC02" ~ "aojo"
    )) %>%
    mutate(SHOP_TYPE39 = case_when(
      fuzhu1 == "DC01" ~ "木九十事业部",
      fuzhu1 == "DC01" ~ "木九十事业部",
      fuzhu1 == "DC02" ~ "aojo事业部"
    )) %>%
    select(SHOP_NO, SHOP_NAME , ERP_NO,BRAND_NAME,SHOP_TYPE39) %>%
    mutate(
      SHOP_TYPE29 = "总仓",
      COUNT_NAME = "",
      SHOP_AREA = "总仓",
      PROVINCE_NAME = "总仓",
      CITY_NAME = "总仓",
      NIELS = "",
      SHOP_PNAME1 = "",
      SHOP_PNAME2 = "",
      SHOP_TYPE04 = "正常营业",
      SHOP_TYPE05 = "",
      SHOP_TYPE15 = "",
      SHOP_TYPE36 = "",
      SHOP_TYPE37 = "",
      SHOP_TYPE48 = 1,
      SHOP_TYPE47 = "1",
      SHOP_TYPE49 = "1",
      SHOP_BRAN = "总仓"
    ) %>%
    rename(
      SHOP_NO = SHOP_NO, 门店名称 = SHOP_NAME, 原ERP店编码 = ERP_NO, 品牌 = BRAND_NAME, 一级部门 = SHOP_TYPE39,
      门店性质 = SHOP_TYPE29, 国家 = COUNT_NAME, 管辖区域 = SHOP_AREA, 省份 = PROVINCE_NAME, 城市 = CITY_NAME,
      城市等级 = NIELS, 门店负责人 = SHOP_PNAME1, 区域经理 = SHOP_PNAME2, 经营状态 = SHOP_TYPE04, 店铺类型 = SHOP_TYPE05,
      老板 = SHOP_TYPE15, 加盟商编码 = SHOP_TYPE36, 加盟商名称 = SHOP_TYPE37, 重点客户标识 = SHOP_TYPE48, 年可比店 = SHOP_TYPE47,
      当月可比店 = SHOP_TYPE49, 门店属性 = SHOP_BRAN
    ) %>%
    mutate(仓位类型 = '总仓库存')

  store_table <- union_all(store_table1,store_table2)
}

