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
  MODIS_LEVEL1B_READ,File,32,Data1240,/TEMPERATURE
  
;  MODIS_LEVEL1B_READ,File,1,Data0064,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,2,Data0086,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,3,Data0046,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,4,Data0051,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,7,Data0230,/REFLECTANCE
;  MODIS_LEVEL1B_READ,File,8,Data0412,/REFLECTANCE

  if keyword_set(area) then begin
    Data1120=Data1120[col_min:col_max,line_min:line_max]
    Data1240=Data1240[col_min:col_max,line_min:line_max]
  endif

  Data0064=toadata_noza[*,*,0]
  Data0086=toadata_noza[*,*,1]
  Data0046=toadata_noza[*,*,2]
  Data0051=toadata_noza[*,*,3]
  Data0230=toadata_noza[*,*,6]
  Data0412=toadata_noza[*,*,7]
  Data0138=toadata_noza[*,*,21]
  
  DIM = SIZE(Data0064,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]



  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;设置非背景值为0
  CloudData[WHERE(Data0046 GT 0 AND Data0046 LT 1)] = 0B  ; 有效值为0

  GFCData = FLTARR(ns,nl)

  FOR i = 1,NS-2,1 DO BEGIN
    FOR j = 1,NL-2,1 DO BEGIN
      tmpData = Data0046[i-1:i+1,j-1:j+1]
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
  

    w2 = WHERE(Data0046 GT 0.4)
    CloudData[w2] = 20B
    w3 = WHERE(Data0138 GT 0.025)
    CloudData[w3] = 25B

    w5 = WHERE(Data0051 GT 0.25)
    CloudData[w5] = 30B

    IF N_ELEMENTS(Data0860) GT 0 THEN BEGIN
      w4 = WHERE((Data0860-Data1120) GT 1.0)
      CloudData[w4] = 55B ;;卷云
    ENDIF

    ;;冰雪
    NDSIData = (Data0051-Data0230) / (Data0230+Data0051)
    w = WHERE(NDSIData GT 0.35 AND Data0086 GT 0.11 AND Data0051 GT 0.1 AND Data1120 LT 283 AND CloudData EQ 0)
    CloudData[w] = 60B
    ;水体
    NDWIData = (Data0051-Data0086) / (Data0086+Data0051)
    CloudData[WHERE(NDWIData GT 0.0 )] = 70B

    ;write_tiff,result_tiff_name,CloudData,planarconfig=2,/float;,GEOTIFF=GEOTIFF
    
    ;场地均一性控制
    
    sz=toadata_noza[*,*,-6]
    vz=toadata_noza[*,*,-4]
    
    
    Data0064_std=get_std(Data0064/cos(sz*!dtor),3,3)
    Data0086_std=get_std(Data0086/cos(sz*!dtor),3,3)
    Data0046_std=get_std(Data0046/cos(sz*!dtor),3,3)
    Data0051_std=get_std(Data0051/cos(sz*!dtor),3,3)
    ;  Data0124_std=get_std(Data0124,3,3)
    ;  Data0163_std=get_std(Data0163,3,3)
    ;  Data0230_std=get_std(Data0230,3,3)
    
;    std_nan=WHERE(~FINITE(Data0064_std) or ~FINITE(Data0086_std) or ~FINITE(Data0046_std) or ~FINITE(Data0051_std))
;    CloudData[std_nan]=100B
    std_ge=WHERE(Data0064_std ge 0.05 or Data0086_std ge 0.05 or Data0046_std ge 0.05 or Data0051_std ge 0.05)
    CloudData[std_ge]=150B
    ;angle=where(sz ge 40 or vz ge 40)
;    angle=where(vz ge 40)
;    CloudData[angle]=200B
;    write_tiff,'H:\00data\MODIS\MODIS_L1data\tifout\dtcloud\data1120.tiff',Data1120,planarconfig=2,compression=1,/float
;    out_target='H:\00data\MODIS\MODIS_L1data\tifout\dtcloud\CloudData.tiff'
;    write_tiff,out_target,CloudData,planarconfig=2,compression=1,/float
    
    
  end

