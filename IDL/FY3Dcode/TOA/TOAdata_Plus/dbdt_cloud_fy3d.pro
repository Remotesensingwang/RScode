;coding=utf-8
;*****************************************************
;FY3D数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;注意这里的TOA数据包括角度数据了
;*****************************************************

pro DBDT_cloud_FY3D,FY3DFile,TOAdata,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2

  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data0047=TOAdata[*,*,0]  ;0.47um
  Data0055=TOAdata[*,*,1] ;0.55um
  Data0065=TOAdata[*,*,2]   ;0.65um
  Data0087=TOAdata[*,*,3] ;0.87um
  Data0138=TOAdata[*,*,4]   ;1.38um
  ;Data0164=TOAdata[*,*,5] ;1.64um
  Data0213=TOAdata[*,*,6] ;2.13um
  Data0412=TOAdata[*,*,7] ;0.412um
  
  Data0055_std=get_std(Data0055,3,3)
  Data0047_std=get_std(Data0047,3,3)
  Data0138_std=get_std(Data0138,3,3)
  Data1080=Te_data[*,*,4]
  ;Data1200=Te_data[*,*,5]


  if keyword_set(area) then begin
    Data1080=Data1080[col_min:col_max,line_min:line_max]
  endif

  DIM = SIZE(Data0047,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0065 GT 0 AND Data0065 LT 1 AND Data1080 GT 0)] = 0B  ; 有效值为0

  nan_Data0087=where(Data0087 LE 0 OR Data0087 GE 1 AND CloudData EQ 0)
  nan_Data0213=where(Data0213 LE 0 OR Data0213 GE 1 AND CloudData EQ 0)
  nan_Data0412=where(Data0412 LE 0 OR Data0412 GE 1 AND CloudData EQ 0)

  CloudData[nan_Data0087]=2B
  CloudData[nan_Data0213]=3B
  CloudData[nan_Data0412]=4B
  
  for i = 1,ns-2,1 do begin
    for j = 1,nl-2,1 do begin
      max_value=max(Data0412[i-1:i+1,j-1:j+1])
      min_value=min(Data0412[i-1:i+1,j-1:j+1])
      if(max_value/min_value) gt 1.1 then begin
        Clouddata[i,j] = 40B
      endif
    endfor
  endfor
  
  
  
  w1=where(Data1080 LT 260 AND CloudData EQ 0)
  CloudData[w1] = 10B

  w2 = WHERE(Data0047 ge 0.4 OR Data0047 le 0 or Data0055_std ge 0.0025 or ~FINITE(Data0055_std)  and CloudData EQ 0)
  CloudData[w2] = 20B
  w3 = WHERE(Data0138 ge 0.015 OR Data0138 le 0  or Data0138_std ge 0.0025 or ~FINITE(Data0138_std)  and CloudData EQ 0)
  CloudData[w3] = 25B

  w5 = WHERE(Data0055 ge 0.25 or Data0055 le 0 and CloudData eq 0)
  CloudData[w5] = 30B

  IF N_ELEMENTS(Data0087) gt 0 THEN BEGIN
    w4 = WHERE((Data0087-Data1080) GT 1.0 and CloudData eq 0)
    CloudData[w4] = 35B ;;卷云
  ENDIF

  ;冰雪
  NDSIData = (Data0055-Data0213) / (Data0213+Data0055)
  w5 = WHERE(NDSIData GT 0.35 AND Data0087 GT 0.11 AND Data0055 GT 0.1 AND Data1080 LT 285 AND CloudData EQ 0)
  CloudData[w5] = 60B
  ;水体
  NDWIData = (Data0055-Data0087) / (Data0087+Data0055)
  CloudData[WHERE(NDWIData GT 0.0 AND CloudData EQ 0 )] = 70B
      

  ;场地均一性控制

  ;sz=TOAdata[*,*,-6]
  vz=TOAdata[*,*,-5]

  
  ;angle=where(sz ge 40 or vz ge 40)
  angle=where(vz GE 40)
  CloudData[angle]=200B

  datetime=strmid(file_basename(FY3DFile,'.hdf'),19,8)+strmid(file_basename(FY3DFile,'.hdf'),28,4)
  out_dir='F:\fy_dh\tiff\cloud\dh\'
;  write_tiff,out_dir+datetime+'CloudData_dh.tiff',CloudData,planarconfig=2,compression=1,/float
;  write_tiff,out_dir+datetime+'Data_std_dh.tiff',ss,planarconfig=2,compression=1,/float
end

