;coding=utf-8
;*****************************************************
;MYD021KM数据进行云掩膜计算（云、水体、雪） 不是云的像元值为0
;*****************************************************

pro DBDT_cloud_copy,MOD02File,CloudData
  COMPILE_OPT IDL2

  ;  MOD02File = 'I:\MOD02_20-21\MOD021KM.A2020014.0145.061.2020014131957.hdf'
  ;  CloudDir = 'D:\data\predict_year'
  ;
  ;  CloudFile = CloudDir+'\'+file_basename(MOD02File,'.hdf')+'_cloud.tif'
  ;  TrueColorFile = CloudDir+'\'+file_basename(MOD02File,'.hdf')+'_TrueColor.tif'
  ;MOD02File='H:\data\MODIS\2021\MYD021KM.A2021001.0720.061.2021001223639.hdf'
  ;result_tiff_name='H:\00data\MODIS\MODIS_L1data\tifout\cloud.tif'
  File = MOD02File
  ;;读取1.38um波段
  MODIS_LEVEL1B_READ,File,26,Data0138,/REFLECTANCE
  ;;读取热红外数据
  MODIS_LEVEL1B_READ,File,31,Data1120,/TEMPERATURE
  MODIS_LEVEL1B_READ,File,32,Data1240,/TEMPERATURE

  MODIS_LEVEL1B_READ,File,1,Data0064,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,2,Data0086,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,3,Data0046,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,4,Data0051,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,7,Data0230,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,8,Data0412,/REFLECTANCE

  ;  MYD021KM_level1b_read,File,toadata,/reflectance
  ;  Data0064=toadata[*,*,0]
  ;  Data0086=toadata[*,*,1]
  ;  Data0046=toadata[*,*,2]
  ;  Data0051=toadata[*,*,3]
  ;  Data0230=toadata[*,*,6]
  ;  Data0412=toadata[*,*,7]
  ;  Data0138=toadata[*,*,18]

  DIM = SIZE(Data0064,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]
  ;
  ;  ;;定义真彩色图像并输出
  ;  TColorData = FLTARR(3,NS,NL)
  ;  TColorData[0,*,*] = Data0064
  ;  TColorData[1,*,*] = Data0051
  ;  TColorData[2,*,*] = Data0046
  ;  write_tiff,TrueColorFile,TColorData,/FLOAT

  DIM = SIZE(Data0046,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]

  CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
  ;;设置非背景值为0
  CloudData[WHERE(Data0046 GT 0 AND Data0046 LT 1)] = 0B  ;; 有效值为0

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


end

