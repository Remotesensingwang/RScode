;coding=utf-8
;*****************************************************
;MYD021KM数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;注意这是局部计算
;*****************************************************

pro DBDT_cloud_area,MOD02File,toadata_noza,CloudData,area=area,$
  col_min=col_min, col_max=col_max,line_min=line_min,line_max=line_max
  COMPILE_OPT IDL2

  File = MOD02File
  ;;读取1.38um波段
  ;MODIS_LEVEL1B_READ,File,26,Data0138,/REFLECTANCE
  ;;读取热红外数据
  MODIS_LEVEL1B_READ,File,31,Data1120,/TEMPERATURE
;  MODIS_LEVEL1B_READ,File,32,Data1240,/TEMPERATURE
  
;  MODIS_LEVEL1B_READ,File,1,Data0064,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,2,Data0086,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,3,Data0047,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,4,Data0051,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,7,Data0230,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,8,Data0412,/REFLECTANCE

  if keyword_set(area) then begin
    Data1120=Data1120[col_min:col_max,line_min:line_max]
;    Data1240=Data1240[col_min:col_max,line_min:line_max]
  endif

  Data0064=toadata_noza[*,*,0]
  Data0086=toadata_noza[*,*,1]
  Data0047=toadata_noza[*,*,2]
  Data0051=toadata_noza[*,*,3]
  Data0230=toadata_noza[*,*,6]
  Data0412=toadata_noza[*,*,7]
  Data0138=toadata_noza[*,*,21]
  
  
  Data0047_std=get_std(Data0047,3,3)
  Data0138_std=get_std_TB(Data0138,3,3)
  
  
  DIM = SIZE(Data0064,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]



  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0064 GT 0 AND Data0064 LT 1 AND Data1120 GT 0) ] = 0B  ; 有效值为0
  
  
;  nan=where(Data0138 GT 0 AND Data0138 LT 1 AND Data1120 GT 0 AND CloudData eq 0)
  
  nan_Data0086=where(Data0086 LE 0 OR Data0086 GE 1 AND CloudData EQ 0)
  nan_Data0230=where(Data0230 LE 0 OR Data0230 GE 1 AND CloudData EQ 0)
  nan_Data0412=where(Data0412 LE 0 OR Data0412 GE 1 AND CloudData EQ 0)
  CloudData[nan_Data0086]=1B
  CloudData[nan_Data0230]=2B
  CloudData[nan_Data0412]=3B
   
  FOR i = 1,NS-2,1 DO BEGIN
    FOR j = 1,NL-2,1 DO BEGIN
      tmpData = Data0047[i-1:i+1,j-1:j+1]
      tmpData2 = Data0138[i-1:i+1,j-1:j+1]
      tmpData3 = Data1120[i-1:i+1,j-1:j+1]
      w = WHERE(tmpData GT 0,countw)
      IF countw EQ 9 THEN BEGIN
        ;;计算STD-NEW 标准偏差
        MeanValue = MEAN(tmpData)
        StdNew = (TOTAL((tmpData-MeanValue)^2) / 9.0)^0.5
        MeanValue2 = MEAN(tmpData2)
        StdNew2 = (TOTAL((tmpData2-MeanValue2)^2) / 9.0)^0.5
        MeanValue3 = MEAN(tmpData3)
        StdNew3 = (TOTAL((tmpData3-MeanValue3)^2) / 9.0)^0.5

        ;;加权标准偏差
        WEI_StdNew=StdNew*MeanValue/3.0

        IF StdNew GT 0.0075 and WEI_StdNew GT 0.0025 THEN BEGIN
          CloudData[i,j] = 5B
        ENDIF
        IF StdNew2 GT 0.003 THEN BEGIN
          CloudData[i,j] = 10B
        ENDIF
        IF StdNew3 GT 4 THEN BEGIN
          CloudData[i,j] = 15B
        ENDIF

      ENDIF


      max_value=max(Data0412[i-1:i+1,j-1:j+1])
      min_value=min(Data0412[i-1:i+1,j-1:j+1])
      if(max_value/min_value)gt 1.1 then begin
        CloudData[i,j] = 35B
      endif else if(Data1120[i,j] LT 270 and Data1120[i,j] GT 10) then begin
        CloudData[i,j] = 40B
;      endif else if (Data1120[i,j] GE 270 and Data1120[i,j] LT 281 and (Data1120[i,j] - Data1240[i,j]) GT -0.5)then begin
;        CloudData[i,j] = 45B
      endif else if (Data0138[i,j] GT 0.018)then begin
        CloudData[i,j] = 50B
      endif

    ENDFOR
  ENDFOR
  
  ;out_target='E:\RS_Code\IDL_RS\FY3Dcode\TOA\BTH\CloudData.tiff'
  ;write_tiff,out_target,CloudData,planarconfig=2,compression=1,/float
  

    w2 = WHERE(Data0047 GT 0.4 OR Data0047 LE 0 AND CloudData EQ 0)
    CloudData[w2] = 20B
    w3 = WHERE(Data0138 GT 0.025 OR Data0138 LE 0 AND CloudData EQ 0)
    CloudData[w3] = 25B

    w5 = WHERE(Data0051 GT 0.25 OR Data0051 LE 0 AND CloudData EQ 0)
    CloudData[w5] = 30B

    IF N_ELEMENTS(Data0086) GT 0 THEN BEGIN
      w4 = WHERE((Data0086-Data1120) GT 1.0 AND CloudData EQ 0)
      CloudData[w4] = 55B ;;卷云
    ENDIF

    ;;冰雪
    NDSIData = (Data0051-Data0230) / (Data0230+Data0051)
    w = WHERE(NDSIData GT 0.35 AND Data0086 GT 0.11 AND Data0051 GT 0.1 AND Data1120 LT 283 AND CloudData EQ 0)
    CloudData[w] = 60B
    ;水体
    NDWIData = (Data0051-Data0086) / (Data0086+Data0051)
    CloudData[WHERE(NDWIData GT 0.0 AND CloudData EQ 0)] = 70B

    ;write_tiff,result_tiff_name,CloudData,planarconfig=2,/float;,GEOTIFF=GEOTIFF
    
    ;场地均一性控制

    ;angle=where(sz ge 40 or vz ge 40)
    angle=where(vz ge 40 AND CloudData EQ 0)
    CloudData[angle]=200B
;    datetime=strmid(file_basename(File,'.hdf'),10,7)+strmid(file_basename(File,'.hdf'),18,4)
;    out_dir='F:\modis_dh\tiff\cloud\dh\'
;    write_tiff,out_dir+datetime+'Data_std_dh.tiff',ss,planarconfig=2,compression=1,/float
;    write_tiff,out_dir+datetime+'Cloud_dh.tiff',CloudData,planarconfig=2,compression=1,/float
        
  end

