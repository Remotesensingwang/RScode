;coding=utf-8
;*****************************************************
;HY1C_L1B数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;cloud wuhan
;water Yang
;snow wuhan
;*****************************************************


pro HY1C_L1B_cloud,HY1C_L1BFile,TOAdata,CloudData
  compile_opt idl2
  ;HY1C_levelLB_read,HY1C_L1BFile,Te_data,/temperature
  Data0047=TOAdata[*,*,2]  ;0.490um
  Data0055=TOAdata[*,*,4] ;0.565um
  Data0087=TOAdata[*,*,7] ;0.865um

  ;Data0213=TOAdata[*,*,6] ;2.13um
  Data0055_result=get_std(Data0055,3,3)

  ;Data0108=Te_data[*,*,5]
  DIM = size(Data0087,/dimensions)
  NS = DIM[0]
  NL = DIM[1]
  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0087 GT 0 AND Data0087 LT 1)] = 0B  ; 有效值为0
  ;*****************************************************去云处理*****************************************************
  ;cloudpos=where(((Data0055_result.std ge 0.0025) and (Data0047 ge 0.4)) or ((Data0138_result.std ge 0.0025) and (Data0138 ge 0.015)),/null)
;  result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\Data00865.tif'
;  write_tiff,result_tiff_name_cloud,Data0087,planarconfig=2,compression=1,/float
;  
;  
;  result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\Data00490.tif'
;  write_tiff,result_tiff_name_cloud,Data0047,planarconfig=2,compression=1,/float
;  
;  result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\std_Data00565.tif'
;  write_tiff,result_tiff_name_cloud,Data0055_result.std,planarconfig=2,compression=1,/float
  
  cloudpos=where(Data0087 ge 0.33,/null)
  CloudData[cloudpos]=50B
  
  result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\mask\cloud033.tif'
  ;write_tiff,result_tiff_name_cloud,CloudData,planarconfig=2,compression=1,/float
  
  ;*****************************************************去水体处理*****************************************************

  ;水体
  NDWIData = (Data0055-Data0087) / (Data0055+Data0087)
;  result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\NDWIData.tif'
;  write_tiff,result_tiff_name_cloud,NDWIData,planarconfig=2,compression=1,/float
  CloudData[WHERE((NDWIData ge 0.0)  and (CloudData eq 0))] = 60B
  result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\mask\water.tif'
  ;write_tiff,result_tiff_name_cloud,CloudData,planarconfig=2,compression=1,/float
  ;CloudData[WHERE((NDWIData GT 0.0) and (Data0213 lt 0.16))] = 60B

  ;*****************************************************去雪处理*****************************************************
;print,'1111'

;  ndsi=(Data0087-Data0164)/(Data0087+Data0164)
;  snowpos=where((ndsi ge 0.1) and (Data0108 le 145) and (CloudData eq 0),/null)
;  CloudData[snowpos]=70B
end