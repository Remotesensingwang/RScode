;coding=utf-8
;*****************************************************
;MYD021KM数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;注意这是局部计算
;*****************************************************

pro DBDT_cloud_MODIS,MOD02File,toadata_noza,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2

  File = MOD02File
  ;读取热红外数据
  MODIS_LEVEL1B_READ,File,31,Data1120,/TEMPERATURE

  if keyword_set(area) then begin
    Data1120=Data1120[col_min:col_max,line_min:line_max]
  endif

  Data0064=toadata_noza[*,*,0]
  Data0086=toadata_noza[*,*,1]
  Data0047=toadata_noza[*,*,2]
  Data0051=toadata_noza[*,*,3]
  Data0230=toadata_noza[*,*,6]
  Data0412=toadata_noza[*,*,7]
  Data0138=toadata_noza[*,*,21]


  Data0047_std=get_std(Data0047,3,3)
  Data0138_std=get_std(Data0138,3,3) ;;4.8 12:00updata   get_std_tb(Data0138,3,3)


  DIM = SIZE(Data0064,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0064 GT 0 AND Data0064 LT 1 AND Data1120 GT 0) ] = 0B  ; 有效值为0

  nan_Data0086=where(Data0086 LE 0 OR Data0086 GE 1 AND CloudData EQ 0)
  nan_Data0230=where(Data0230 LE 0 OR Data0230 GE 1 AND CloudData EQ 0)
  nan_Data0412=where(Data0412 LE 0 OR Data0412 GE 1 AND CloudData EQ 0)
  CloudData[nan_Data0086]=1B
  CloudData[nan_Data0230]=2B
  CloudData[nan_Data0412]=3B

  FOR i = 1,NS-2,1 DO BEGIN
    FOR j = 1,NL-2,1 DO BEGIN
      max_value=max(Data0412[i-1:i+1,j-1:j+1])
      min_value=min(Data0412[i-1:i+1,j-1:j+1])
      if(max_value/min_value) GT 1.1 then begin
        CloudData[i,j] = 35B
      endif
    ENDFOR
  ENDFOR


  w1=where(Data1120 LT 270 AND CloudData EQ 0)
  CloudData[w1] = 10B
  
;  w11=where(~FINITE(Data0047_std) or ~FINITE(Data0138_std))
  
  w2 = WHERE(Data0047 ge 0.4 OR Data0047 LE 0 or Data0047_std ge 0.0025 or ~FINITE(Data0047_std)  AND CloudData EQ 0)
  CloudData[w2] = 20B
  w3 = WHERE(Data0138 ge 0.025 OR Data0138 LE 0  or Data0138_std ge 0.003 or ~FINITE(Data0138_std)  AND CloudData EQ 0)
  CloudData[w3] = 25B

  w5 = WHERE(Data0051 ge 0.25 OR Data0051 LE 0 AND CloudData EQ 0)
  CloudData[w5] = 30B

  IF N_ELEMENTS(Data0086) GT 0 THEN BEGIN
    w4 = WHERE((Data0086-Data1120) GT 1.0 AND CloudData EQ 0)
    CloudData[w4] = 35B ;;卷云
  ENDIF

  ;;冰雪
  NDSIData = (Data0051-Data0230) / (Data0230+Data0051)
  w = WHERE(NDSIData GT 0.35 AND Data0086 GT 0.11 AND Data0051 GT 0.1 AND Data1120 LT 283 AND CloudData EQ 0)
  CloudData[w] = 60B
  ;水体
  NDWIData = (Data0051-Data0086) / (Data0086+Data0051)
  CloudData[WHERE(NDWIData GT 0.0 AND CloudData EQ 0)] = 70B
  ;sz=toadata_noza[*,*,-7]
  vz=toadata_noza[*,*,-5]
  ;观测天顶角限制
  angle=where(vz ge 40 AND CloudData EQ 0)
  CloudData[angle]=200B
  ;datetime=strmid(file_basename(File,'.hdf'),10,7)+strmid(file_basename(File,'.hdf'),18,4)
  ;out_dir='F:\modis_dh\tiff\cloud\dh\'
  ;write_tiff,out_dir+datetime+'Data_std_dh.tiff',ss,planarconfig=2,compression=1,/float
  ;write_tiff,out_dir+datetime+'Cloud_dh.tiff',CloudData,planarconfig=2,compression=1,/float

end

