;coding=utf-8
;*****************************************************
;DCC提取
;*****************************************************

pro DBDT_DCC,MOD02File,TOA_angle_data,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2
  File = MOD02File
  ;读取热红外数据
  MODIS_LEVEL1B_READ,File,31,Data1120,/TEMPERATURE

  if keyword_set(area)  then begin
    Data1120=Data1120[col_min:col_max,line_min:line_max]
  endif 
  Data0064=TOA_angle_data[*,*,0]
  Data0086=TOA_angle_data[*,*,1]
  Data0046=TOA_angle_data[*,*,2]
  Data0051=TOA_angle_data[*,*,3]

  Data0064_std=get_std(Data0064,3,3)
  Data0086_std=get_std(Data0086,3,3)
  Data0046_std=get_std(Data0046,3,3)
  Data0051_std=get_std(Data0051,3,3)

  Data1120_std=get_std_TB(Data1120,3,3)
  
  sz=TOA_angle_data[*,*,-7]
  vz=TOA_angle_data[*,*,-5]
    
  DIM = SIZE(Data1120,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data1120 gt 0)] = 0B  ; 有效值为0

  std_nan=WHERE(~FINITE(Data1120_std),count)
  if count gt 0 then begin
    CloudData[std_nan]=10B
  endif 
 
;  CloudData[std_nan]=10B
  std_ge=WHERE(Data1120_std ge 1 and CloudData eq 0)
  CloudData[std_ge]=20B
  Data1120_ge=where(Data1120 ge 205  and CloudData eq 0)
  CloudData[Data1120_ge]=30B
  angle=where(sz ge 40 or vz ge 40 and CloudData eq 0)
  CloudData[angle]=40B
  
  ;ss=[[[Data1120]],[[Data1120_std]]]
  ;datetime=strmid(file_basename(File,'.hdf'),10,7)+strmid(file_basename(File,'.hdf'),18,4)
  ;out_dir='F:\MODIS_DCC\tiff\cloud\'
  ;write_tiff,out_dir+datetime+'Data1120.tiff',ss,planarconfig=2,compression=1,/float
  ;write_tiff,out_dir+datetime+'Cloud_dcc.tiff',CloudData,planarconfig=2,compression=1,/float

end

