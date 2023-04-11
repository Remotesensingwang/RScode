;coding=utf-8
;*****************************************************
;FY3D数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;cloud wuhan
;water Yang
;snow wuhan
;*****************************************************
pro fy3d_cloud,FY3DFile,TOAdata,CloudData
  compile_opt idl2
  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data0047=TOAdata[*,*,0]  ;0.47um
  Data0055=TOAdata[*,*,1] ;0.55um
  Data0065=TOAdata[*,*,2]   ;0.65um
  Data0087=TOAdata[*,*,3] ;0.87um
  Data0138=TOAdata[*,*,4]   ;1.38um
  Data0164=TOAdata[*,*,5] ;1.64um
  Data0213=TOAdata[*,*,6] ;2.13um
  Data0055_result=get_std(Data0055,3,3)
  Data0138_result=get_std(Data0138,3,3)
  Data0108=Te_data[*,*,5]
  DIM = size(Data0047,/dimensions)
  NS = DIM[0]
  NL = DIM[1]
  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0047 GT 0 AND Data0047 LT 1)] = 0B  ; 有效值为0
  ;*****************************************************去云处理*****************************************************     
  ;cloudpos=where(((Data0055_result.std ge 0.0025) and (Data0047 ge 0.4)) or ((Data0138_result.std ge 0.0025) and (Data0138 ge 0.015)),/null)
  cloudpos=where(((Data0055_result.std ge 0.0024) and (Data0047 ge 0.24)) or ((Data0138_result.std ge 0.0024) and (Data0138 ge 0.014)),/null)
  CloudData[cloudpos]=50B
  ;*****************************************************去水体处理*****************************************************
  
  ;水体
  NDWIData = (Data0055-Data0087) / (Data0055+Data0087)
  CloudData[WHERE((NDWIData ge 0.0)  and (CloudData eq 0))] = 60B
  ;CloudData[WHERE((NDWIData GT 0.0) and (Data0213 lt 0.16))] = 60B

  ;*****************************************************去雪处理*****************************************************  


  ndsi=(Data0087-Data0164)/(Data0087+Data0164)
  snowpos=where((ndsi ge 0.1) and (Data0108 le 145) and (CloudData eq 0),/null)
  CloudData[snowpos]=70B
end