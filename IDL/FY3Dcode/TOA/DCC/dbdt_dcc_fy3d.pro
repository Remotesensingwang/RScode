;coding=utf-8
;*****************************************************
;DCC提取
;*****************************************************

pro DBDT_DCC_FY3D,FY3DFile,TOAdata,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2
  
  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data0047=TOAdata[*,*,0]  ;0.47um
  Data0055=TOAdata[*,*,1] ;0.55um
  Data0065=TOAdata[*,*,2]   ;0.65um
  Data0087=TOAdata[*,*,3] ;0.87um
  Data1080=Te_data[*,*,4]
  ;Data1200=Te_data[*,*,5]
  
  if keyword_set(area)  then begin
    Data1080=Data1080[col_min:col_max,line_min:line_max]
    Data1200=Data1200[col_min:col_max,line_min:line_max]
  endif
  
  Data0047_std=get_std(Data0047,3,3)
  Data0055_std=get_std(Data0055,3,3)
  Data0065_std=get_std(Data0065,3,3)
  Data0087_std=get_std(Data0087,3,3)
  Data1080_std=get_std(Data1080,3,3)
  ;Data1200_STD=get_std(Data1200,3,3)
  
  sz_angle=TOAdata[*,*,-7]
  vz_angle=TOAdata[*,*,-5]
  
  
  DIM = SIZE(Data0047,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0047 GT 0 AND Data0047 LT 1)] = 0B  ; 有效值为0
  
  std_nan=WHERE(~FINITE(Data0047_std) or ~FINITE(Data0055_std) or ~FINITE(Data0065_std) or ~FINITE(Data0087_std) or ~FINITE(Data1080_std),count)
  if count gt 0 then begin
    CloudData[std_nan]=10B
  endif  
  std_ge=WHERE(Data0047_std ge 0.03 or Data0055_std ge 0.03 or Data0065_std ge 0.03 or Data0087_std ge 0.03 or Data1080_std ge 1 )
  CloudData[std_ge]=20B
  Data1080_ge=where(Data1080 ge 205)
  CloudData[Data1080_ge]=30B
  angle=where(sz_angle ge 40 or vz_angle ge 40)
  CloudData[angle]=40B
  
end

