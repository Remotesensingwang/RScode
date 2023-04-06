;coding=utf-8
;*****************************************************
;海洋站点数据提取（Sea）
;*****************************************************

pro DBDT_Sea_FY3D,FY3DFile,TOAdata,CloudData
  
  COMPILE_OPT IDL2

  Data0065=TOAdata[*,*,2]   ;0.65um 
  Data0746=TOAdata[*,*,13]
  
  Data0746_std=get_std(Data0746,3,3)
;  sz_angle=TOAdata[*,*,-8]
  vz_angle=TOAdata[*,*,-6]
  sca_angle=TOAdata[*,*,-3]

  DIM = SIZE(Data0746,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  CloudData[WHERE(Data0746 GT 0 AND Data0746 LT 1)] = 0B  ; 有效值为0
  
  
  std_nan=WHERE(~FINITE(Data0746_std),count)
  if count gt 0 then begin
    CloudData[std_nan]=10B
  endif
  
  std_ge=WHERE(Data0746 ge 0.03 and CloudData eq 0)
  CloudData[std_ge]=20B
  
  Data1080_ge=where(Data0746_std ge 0.0010 and CloudData eq 0)
  CloudData[Data1080_ge]=30B

  Data0065_ge=WHERE(Data0065 ge 0.039 and CloudData eq 0)
  CloudData[Data0065_ge]=40B  
  
  vz_angles=where(vz_angle ge 40 and CloudData eq 0)
  CloudData[vz_angles]=50B
  
  sca_angles=where(sca_angle ge 40 and CloudData eq 0)
  CloudData[sca_angles]=60B
  
;  pos=[temporary(std_ge),temporary(Data1080_ge),temporary(Data0065_ge),temporary(vz_angles),temporary(sca_angles)]
  
  
;  datetime=strmid(file_basename(FY3DFile,'.hdf'),19,8)+strmid(file_basename(FY3DFile,'.hdf'),28,4)
;  out_dir='F:\FY3D_Sea\2019\tiff\cloud\'
;  write_tiff,out_dir+datetime+'Data0746_std.tiff',Data0746_std,planarconfig=2,/float
;  write_tiff,out_dir+datetime+'CloudData_SCA.tiff',CloudData,planarconfig=2,/float

end

