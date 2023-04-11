;coding=utf-8
;*****************************************************
;FY3D数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;注意这里的TOA数据包括角度数据了
;是在FY3D_cloud_pro.pro的基础上修改的
;去云阈值改变：近红外波段（870nm gt 0.5）、热红外窗区通道（1080nm lt 260K）
;;场地均一性控制
;*****************************************************

pro cloud314,FY3DFile,TOAdata,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  fy3d_level1b_read,FY3Dfile,Te_data,/temperature
  Data0047=TOAdata[*,*,0]  ;0.47um
  Data0055=TOAdata[*,*,1] ;0.55um
  Data0065=TOAdata[*,*,2]   ;0.65um
  Data0087=TOAdata[*,*,3] ;0.87um
  Data0138=TOAdata[*,*,4]   ;1.38um
  Data0164=TOAdata[*,*,5] ;1.64um
  Data0213=TOAdata[*,*,6] ;2.13um
  Data0412=TOAdata[*,*,7] ;0.412um
  Data0055_result=get_std(Data0055,3,3)
  Data0138_result=get_std(Data0138,3,3)
  Data1080=Te_data[*,*,4]
  ;Data1200=Te_data[*,*,5]

  result_tiff_name='F:\cloud\cloud\Data108001010705.tif'
  ;write_tiff,result_tiff_name,Data1080,planarconfig=2,/float
  if keyword_set(area) then begin
    Data1080=Data1080[col_min:col_max,line_min:line_max]
  endif
  
  
  DIM = SIZE(Data0047,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0047 GT 0 AND Data0047 LT 1)] = 0B  ; 有效值为0
  ;w1=where(((Data0055_result ge 0.0024) and (Data0047 ge 0.24)) or ((Data0138_result ge 0.0024) and (Data0138 ge 0.014)),/null)
  ;CloudData[w1]=15B

  ;  Data0047_result=get_std(Data0047,3,3)
  ;  Data0138_result=get_std(Data0138,3,3)
  ;  Data1080_result=get_std(Data1080,3,3)

  w1=where(Data1080 LT 260 and Data1080 GT 10 and CloudData EQ 0)
  CloudData[w1] = 10B
  w2=where(Data0087 ge 0.5 and CloudData EQ 0)
  CloudData[w2] = 20B

  FOR i = 1,NS-2,1 DO BEGIN
    FOR j = 1,NL-2,1 DO BEGIN
      max_value=max(Data0412[i-1:i+1,j-1:j+1])
      min_value=min(Data0412[i-1:i+1,j-1:j+1])
      if(max_value/min_value)gt 1.1 then begin
        CloudData[i,j] = 30B
      endif
    ENDFOR
  ENDFOR


 ; w3 = WHERE((Data0055 GT 0.25 or Data0138 gt 0.025) and CloudData EQ 0)
  ;CloudData[w3] = 30B

  ;  w5 = WHERE(Data0055 GT 0.25 and CloudData EQ 0)
  ;  CloudData[w5] = 30B

  ;冰雪
  NDSIData = (Data0055-Data0213) / (Data0213+Data0055)
  w = WHERE(NDSIData GT 0.35 AND Data0087 GT 0.11 AND Data0055 GT 0.1 AND Data1080 LT 285 AND CloudData EQ 0)
  CloudData[w] = 60B
  ;水体
  NDWIData = (Data0055-Data0087) / (Data0087+Data0055)
  CloudData[WHERE(NDWIData GT 0.0 and CloudData EQ 0 )] = 70B
  ;result_tiff_name='H:\dtcloud\03cloudrbth\3\MODISPOS\data\cloudmask.tif'
  ;write_tiff,result_tiff_name,CloudData,planarconfig=2,/float;,GEOTIFF=GEOTIFF

  ;去小于0的TOA值
  toadata_size=size(TOAdata)
  datapos=[]
  for layer_i=1,3 do begin
    data=TOAdata[*,*,layer_i]
    pos=where(data le 0,count)
    if count gt 0 then begin
      datapos=[datapos,pos]
    endif
  endfor

  if datapos ne !null then begin
    var= datapos[sort(datapos)]
    var_datapos=var[uniq(var)]
    clouddata[var_datapos]=80B
  endif

  ;场地均一性控制

  ;sz=TOAdata[*,*,-7]
  vz=TOAdata[*,*,-5]

  ;angle=where(sz ge 40 or vz ge 40)
  angle=where(vz ge 40)
  CloudData[angle]=200B


  result_tiff_name='F:\cloud\cloud\cloudmask01010705.tif'
  ;write_tiff,result_tiff_name,CloudData,planarconfig=2,/float
end