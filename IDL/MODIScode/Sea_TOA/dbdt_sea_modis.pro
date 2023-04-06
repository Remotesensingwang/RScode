;coding=utf-8
;*****************************************************
;海洋站点数据提取（Sea）
;*****************************************************

pro DBDT_Sea_MODIS,MODISFile,TOAdata,CloudData
  COMPILE_OPT IDL2

  Data0748=TOAdata[*,*,16]
  Data0064=TOAdata[*,*,0]

  Data0748_std=get_std(Data0748,3,3)

;  sz_angle=TOAdata[*,*,-8]
  vz_angle=TOAdata[*,*,-6]
  sca_angle=TOAdata[*,*,-3]

  DIM = SIZE(Data0748,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]
   
  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  CloudData[WHERE(Data0748 GT 0 AND Data0748 LT 1)] = 0B  ; 有效值为0


  std_nan=WHERE(~FINITE(Data0748_std),count)
  if count gt 0 then begin
    CloudData[std_nan]=10B
  endif
  
  
  
  std_ge=WHERE(Data0748 ge 0.030 and CloudData eq 0)
  CloudData[std_ge]=20B

  Data1080_ge=where(Data0748_std ge 0.0010 and CloudData eq 0)
  CloudData[Data1080_ge]=30B

  vz_angles=where(vz_angle ge 40 and CloudData eq 0)
  CloudData[vz_angles]=40B
  
  Data0064_ge=WHERE(Data0064 ge 0.039 and CloudData eq 0)
  CloudData[Data0064_ge]=50B

  sca_angles=where(sca_angle ge 40 and CloudData eq 0)
  CloudData[sca_angles]=60B

;  datetime=strmid(file_basename(MODISFile,'.hdf'),10,7)+strmid(file_basename(MODISFile,'.hdf'),18,4)
;  out_dir='F:\MODIS_Sea\2019\test\tiff\cloud\'
;  write_tiff,out_dir+datetime+'Data0748_std-nan.tiff',Data0748_std,planarconfig=2,/float
;  write_tiff,out_dir+datetime+'CloudData_SCA.tiff',CloudData,planarconfig=2,/float

end

