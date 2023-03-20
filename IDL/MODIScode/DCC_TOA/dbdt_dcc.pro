;coding=utf-8
;*****************************************************
;DCC提取
;*****************************************************

pro DBDT_DCC,MOD02File,TOA_angle_data,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2
  File = MOD02File
  ;;读取1.38um波段
 ; MODIS_LEVEL1B_READ,File,26,Data0138,/REFLECTANCE
  ;;读取热红外数据
  MODIS_LEVEL1B_READ,File,31,Data1120,/TEMPERATURE
;  MODIS_LEVEL1B_READ,File,32,Data1240,/TEMPERATURE
;  MODIS_LEVEL1B_READ,File,1,Data0064,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,2,Data0086,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,3,Data0046,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,4,Data0051,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,7,Data0230,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,8,Data0412,/REFLECTANCE

  ;DIM = SIZE(Data1120,/DIMENSIONS)
  ;NS = DIM[0]
  ;NL = DIM[1]
  if keyword_set(area)  then begin
    Data1120=Data1120[col_min:col_max,line_min:line_max]
  endif 
  Data0064=TOA_angle_data[*,*,0]
  Data0086=TOA_angle_data[*,*,1]
  Data0046=TOA_angle_data[*,*,2]
  Data0051=TOA_angle_data[*,*,3]
;  Data0124=TOA_angle_data[*,*,4]
;  Data0163=TOA_angle_data[*,*,5]
;  Data0230=TOA_angle_data[*,*,6]

  Data0064_std=get_std(Data0064,3,3)
  Data0086_std=get_std(Data0086,3,3)
  Data0046_std=get_std(Data0046,3,3)
  Data0051_std=get_std(Data0051,3,3)
;  Data0124_std=get_std(Data0124,3,3)
;  Data0163_std=get_std(Data0163,3,3)
;  Data0230_std=get_std(Data0230,3,3)
  Data1120_std=get_std(Data1120,3,3)
  ;CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;;设置非背景值为0
  ;CloudData[WHERE(Data0064 GT 0 AND Data0046 LT 1)] = 0B  ; 有效值为0
  
  sz=TOA_angle_data[*,*,-7]
  vz=TOA_angle_data[*,*,-5]
  
  
  DIM = SIZE(Data0064,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]



  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0046 GT 0 AND Data0046 LT 1)] = 0B  ; 有效值为0
  std_nan=WHERE(~FINITE(Data0064_std) or ~FINITE(Data0086_std) or ~FINITE(Data0046_std) or ~FINITE(Data0051_std) or ~FINITE(Data1120_std))
  CloudData[std_nan]=10B
  std_ge=WHERE(Data0064_std ge 0.03 or Data0086_std ge 0.03 or Data0046_std ge 0.03 or Data0051_std ge 0.03 or Data1120_std ge 1 )
  CloudData[std_ge]=20B
  Data1120_ge=where(Data1120 ge 205)
  CloudData[Data1120_ge]=30B
  angle=where(sz ge 40 or vz ge 40)
  CloudData[angle]=40B
  
;  for band=0,6 do begin
;    data=TOA_angle_data[*,*,band]
;    data_std=get_std(data,3,3)
;    pos=where(data_std.std ge 0.03 or Data1120_std.std ge 1 or Data1120 ge 205 or sz ge 40 or vz ge 40 or data le 0 or data ge 1)
;    data[pos]=!VALUES.F_NAN
;    TOA_angle_data[*,*,band]=data
;  endfor
  result_tiff_name='C:\Users\lenovo\Downloads\DCC\01\tiff\Data1120_0730.tiff'
  ;write_tiff,result_tiff_name,Data1120,planarconfig=2,/float;,GEOTIFF=GEOTIFF
  ;print,'1'


end

