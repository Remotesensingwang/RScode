;coding=utf-8
;*****************************************************
;DCC提取
;*****************************************************

pro DBDT_DCC_FY3D,FY3DFile,TOAdata,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2
  
  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data1080=Te_data[*,*,4]
;  Data1200=Te_data[*,*,5]
  
  if keyword_set(area)  then begin
    Data1080=Data1080[col_min:col_max,line_min:line_max]
;    Data1200=Data1200[col_min:col_max,line_min:line_max]
  endif
    
  Data1080_std=get_std_TB(Data1080,3,3)
;  Data1200_STD=get_std(Data1200,3,3)

  sz_angle=TOAdata[*,*,-7]
  vz_angle=TOAdata[*,*,-5]
  
  
  DIM = SIZE(Data1080,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
;  CloudData[WHERE(Data0047 GT 0 AND Data0047 LT 1)] = 0B  ; 有效值为0
  CloudData[WHERE(Data1080 gt 0)] = 0B  ; 有效值为0
  std_nan=WHERE(~FINITE(Data1080_std),count)
  if count gt 0 then begin
    CloudData[std_nan]=10B
  endif  
  std_ge=WHERE(Data1080_std ge 1 and CloudData eq 0)
  CloudData[std_ge]=20B
  Data1080_ge=where(Data1080 ge 205 and CloudData eq 0)
  CloudData[Data1080_ge]=30B
  angle=where(sz_angle ge 40 or vz_angle ge 40 and CloudData eq 0)
  CloudData[angle]=40B
  
  ;ss=[[[Data1080]],[[Data1080_std]]]  
  ;datetime=strmid(file_basename(FY3DFile,'.hdf'),19,8)+strmid(file_basename(FY3DFile,'.hdf'),28,4)
  ;out_dir='F:\FY_DCC\tiff\cloud\'
  ;write_tiff,out_dir+datetime+'Data_std.tiff',ss,planarconfig=2,compression=1,/float
  ;write_tiff,out_dir+datetime+'CloudData.tiff',CloudData,planarconfig=2,compression=1,/float
  ;write_tiff,out_dir+datetime+'Data1080.tiff',Data1080,planarconfig=2,compression=1,/float
  
  
end

