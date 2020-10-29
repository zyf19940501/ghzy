#' sku
#'
#' @description get the sku information from BI database
#'
#' @param con  BI con connector
#'
#' @import dbplyr tidyverse
#' @encoding UTF-8
#' @export
#'
#' @return  a dataframe
#'
#' @examples
#' sku <- sku(con)

sku <- function(con) {
  sku_table <- tbl(con, in_schema("DW", "MD_GOODS_DETAIL")) %>%
    filter(BRAND_NAME != "Starter") %>% # remove starter
    select(
      SKU_NO, SAP_NO, SKC_NO, CUSTOM_NO, FREE_CHAR, GOODS_NAME,
      GOODS_NAME1, GOODS_NAME2, GOODS_NAME3, KONDM, GOODS_TYPE1,
      KBETR, UPR_HK, GOODS_TYPE2, ZBRAND, ZJKCZ, ZJKDX,
      ZJKKS, ZJKYS, ZYJKX, ZJPGN, ZJPYS, ZNFRS,
      ZQJ, ZZJ, ZZSL, BRAND_NAME, BG_DATE, BG_DATE1, SYS_ID
    ) %>%
    rename(
      SAP_NO = SAP_NO, 款号 = CUSTOM_NO, 商品简称 = FREE_CHAR, 商品名称 = GOODS_NAME, 大类名称 = GOODS_NAME1,
      中类名称 = GOODS_NAME2, 小类名称 = GOODS_NAME3, 定价品类 = KONDM, 是否标配镜片 = GOODS_TYPE1, 吊牌价 = KBETR,
      海外吊牌价 = UPR_HK, 价格带 = GOODS_TYPE2, 厂商品牌 = ZBRAND, 镜框材质 = ZJKCZ, 镜框大小 = ZJKDX, 镜框款式 = ZJKKS,
      镜框颜色 = ZJKYS, 眼镜框型 = ZYJKX, 镜片功能 = ZJPGN, 镜片颜色 = ZJPYS, 能否染色 = ZNFRS, 球镜 = ZQJ, 柱镜 = ZZJ, 折射率 = ZZSL,
      商品品牌 = BRAND_NAME, 系统上市时间 = BG_DATE, 最早销售日期 = BG_DATE1, SYS_ID = SYS_ID
    ) %>% # SYS_ID = 1 SAP
    mutate(分析大类 = case_when(
      大类名称 == "镜架" ~ "镜架",
      大类名称 == "太阳镜" ~ "太阳镜",
      大类名称 == "防蓝光镜" ~ "防蓝光镜",
      大类名称 == "老视成镜" ~ "老视成镜",
      大类名称 == "镜片" ~ "镜片",
      大类名称 == "隐形眼镜" ~ "隐形眼镜",
      大类名称 == "物料" ~ "物料",
      大类名称 == "周边商品" ~ "周边商品",
      is.na(大类名称) | 大类名称 == "其他" ~ "其他"
    ))
}
