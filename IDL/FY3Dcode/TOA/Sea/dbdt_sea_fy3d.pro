;coding=utf-8
;*****************************************************
;DCC提取
;*****************************************************

pro DBDT_Sea_FY3D,FY3DFile,TOAdata,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2

  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data0047=TOAdata[*,*,0]  ;0.47um
  Data0055=TOAdata[*,*,1] ;0.55um
  Data0065=TOAdata[*,*,2]   ;0.65um
  Data0087=TOAdata[*,*,3] ;0.87um
  Data1080=Te_data[*,*,4]
  
  Data0746=TOAdata[*,*,13]
  ;  Data1200=Te_data[*,*,5]

  if keyword_set(area)  then begin
    Data1080=Data1080[col_min:col_max,line_min:line_max]
    ;    Data1200=Data1200[col_min:col_max,line_min:line_max]
  endif

  Data0047_std=get_std(Data0047,3,3)
  Data0055_std=get_std(Data0055,3,3)
  Data0065_std=get_std(Data0065,3,3)
  Data0087_std=get_std(Data0087,3,3)
  Data1080_std=get_std(Data1080,3,3)
  
  
  Data0746_std=get_std(Data0746,3,3)
  ;  Data1200_STD=get_std(Data1200,3,3)

  sz_angle=TOAdata[*,*,-8]
  vz_angle=TOAdata[*,*,-6]
  sca_angle=TOAdata[*,*,-3]

  DIM = SIZE(Data0746,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  CloudData[WHERE(Data0746 GT 0 AND Data0746 LT 1)] = 0B  ; 有效值为0
  
  
  std_nan=WHERE(~FINITE(Data0746),count)
  if count gt 0 then begin
    CloudData[std_nan]=10B
  endif
  
  std_ge=WHERE(Data0746 ge 0.022 and CloudData eq 0)
  CloudData[std_ge]=20B
  
  Data1080_ge=where(Data0746_std ge 0.0020 and CloudData eq 0)
  CloudData[Data1080_ge]=30B
  
  vz_angles=where(vz_angle ge 40 and CloudData eq 0)
  CloudData[vz_angles]=40B
  
  sca_angles=where(sca_angle ge 40 and CloudData eq 0)
  CloudData[sca_angles]=50B
  
  datetime=strmid(file_basename(FY3DFile,'.hdf'),19,8)+strmid(file_basename(FY3DFile,'.hdf'),28,4)
  out_dir='F:\FY3D_Sea\2019\tiff\cloud\'
;  result_tiff_name=out_dir+'Data1120_0640.tiff'
;  write_tiff,result_tiff_name,Data1080,planarconfig=2,compression=1,/float;,GEOTIFF=GEOTIFF 
;  write_tiff,out_dir+datetime+'Data0746_std.tiff',Data0746_std,planarconfig=2,/float
;  write_tiff,out_dir+datetime+'CloudData_SCA.tiff',CloudData,planarconfig=2,/float

end

