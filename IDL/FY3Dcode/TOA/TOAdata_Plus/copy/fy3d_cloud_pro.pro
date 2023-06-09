;coding=utf-8
;*****************************************************
;FY3D数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;注意这里的TOA数据包括角度数据了
;*****************************************************

pro FY3D_cloud_pro,FY3DFile,TOAdata,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2

  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data0047=TOAdata[*,*,0]  ;0.47um
  Data0055=TOAdata[*,*,1] ;0.55um
  Data0065=TOAdata[*,*,2]   ;0.65um
  Data0087=TOAdata[*,*,3] ;0.87um
  Data0138=TOAdata[*,*,4]   ;1.38um
;  Data0164=TOAdata[*,*,5] ;1.64um
  Data0213=TOAdata[*,*,6] ;2.13um
  Data0412=TOAdata[*,*,7] ;0.412um
  Data0055_result=get_std(Data0055,3,3)
  Data0138_result=get_std(Data0138,3,3)
  Data1080=Te_data[*,*,4]
;  Data1200=Te_data[*,*,5]

  
  if keyword_set(area) then begin
    Data1080=Data1080[col_min:col_max,line_min:line_max]
  endif
  
  DIM = SIZE(Data0047,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0047 GT 0 AND Data0047 LT 1 AND Data1080 GT 0)] = 0B  ; 有效值为0
  
  nan_Data0065=where(Data0065 LE 0 OR Data0065 GE 1 AND CloudData EQ 0)
  nan_Data0087=where(Data0087 LE 0 OR Data0087 GE 1 AND CloudData EQ 0)
  nan_Data0213=where(Data0213 LE 0 OR Data0213 GE 1 AND CloudData EQ 0)
  nan_Data0412=where(Data0412 LE 0 OR Data0412 GE 1 AND CloudData EQ 0)
  CloudData[nan_Data0065]=1B
  CloudData[nan_Data0087]=2B
  CloudData[nan_Data0213]=3B
  CloudData[nan_Data0412]=4B
  
  ;BTH (Data0047 ge 0.24)
  ;dh (Data0047 ge 0.4)
  w1=where(((Data0055_result ge 0.0024) and (Data0047 ge 0.4)) or ((Data0138_result ge 0.0024) and (Data0138 ge 0.014)),/null)
  CloudData[w1]=15B

;  Data0047_result=get_std(Data0047,3,3)
;  Data0138_result=get_std(Data0138,3,3)
;  Data1080_result=get_std(Data1080,3,3)

  w2=where(Data1080 LT 260 AND Data1080 GT 10 AND CloudData EQ 0)
  CloudData[w2] = 40B

  FOR i = 1,NS-2,1 DO BEGIN
    FOR j = 1,NL-2,1 DO BEGIN
      max_value=max(Data0412[i-1:i+1,j-1:j+1])
      min_value=min(Data0412[i-1:i+1,j-1:j+1])
      if(max_value/min_value) GT 1.1 then begin
        CloudData[i,j] = 35B
      endif
    ENDFOR
  ENDFOR


  w3 = WHERE(Data0055 GT 0.25 OR Data0055 LE 0 OR Data0138 GT 0.025 OR Data0138 LE 0 AND CloudData EQ 0)
  CloudData[w3] = 30B

;  w5 = WHERE(Data0055 GT 0.25 and CloudData EQ 0)
;  CloudData[w5] = 30B

  ;冰雪
  NDSIData = (Data0055-Data0213) / (Data0213+Data0055)
  w = WHERE(NDSIData GT 0.35 AND Data0087 GT 0.11 AND Data0055 GT 0.1 AND Data1080 LT 285 AND CloudData EQ 0)
  CloudData[w] = 60B
  ;水体
  NDWIData = (Data0055-Data0087) / (Data0087+Data0055)
  CloudData[WHERE(NDWIData GT 0.0 AND CloudData EQ 0 )] = 70B
  ;result_tiff_name='H:\dtcloud\03cloudrbth\3\MODISPOS\data\cloudmask.tif'
  ;write_tiff,result_tiff_name,CloudData,planarconfig=2,/float;,GEOTIFF=GEOTIFF

;  ;去小于0的TOA值
;  toadata_size=size(TOAdata)
;  datapos=[]
;  for layer_i=1,6 do begin
;    data=TOAdata[*,*,layer_i]
;    pos=where(data le 0,count)
;    if count gt 0 then begin
;      datapos=[datapos,pos]
;    endif     
;  endfor
;  
;  if datapos ne !null then begin     
;    var= datapos[sort(datapos)]
;    var_datapos=var[uniq(var)]
;    clouddata[var_datapos]=80B
;  endif
  
  ;场地均一性控制

  ;sz=TOAdata[*,*,-6]
  vz=TOAdata[*,*,-5]
  
  Data0047_std=get_std(Data0047,3,3)
  Data0055_std=get_std(Data0055,3,3)
  Data0065_std=get_std(Data0065,3,3)
  Data0087_std=get_std(Data0087,3,3)
  ;  Data0124_std=get_std(Data0124,3,3)
  ;  Data0163_std=get_std(Data0163,3,3)
  ;  Data0230_std=get_std(Data0230,3,3)

  std_nan=WHERE(~FINITE(Data0047_std) OR ~FINITE(Data0055_std) OR ~FINITE(Data0065_std) OR ~FINITE(Data0087_std),count)
  if count GT 0 then CloudData[std_nan]=100B
  std_ge=WHERE(Data0047_std GE 0.05 OR Data0055_std GE 0.05 OR Data0065_std GE 0.05 OR Data0087_std GE 0.05)
  CloudData[std_ge]=150B
  ;angle=where(sz ge 40 or vz ge 40)
  angle=where(vz GE 40)
  CloudData[angle]=200B
  
;  datetime=strmid(file_basename(FY3DFile,'.hdf'),19,8)+strmid(file_basename(FY3DFile,'.hdf'),28,4)
;  out_dir='H:\00data\FY3D\FY3D_Sea\2019\tiff\cloud\'  
;  write_tiff,out_dir+datetime+'CloudData.tiff',CloudData,planarconfig=2,/float
end

