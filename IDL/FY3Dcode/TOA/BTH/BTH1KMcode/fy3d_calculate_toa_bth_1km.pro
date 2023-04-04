;coding=utf-8
;*****************************************************
;对BTH(京津冀)进行TOA计算,(1KM)
;*****************************************************

pro fy3d_calculate_toa_BTH_1km

  compile_opt idl2
  ;input_directory='F:\FYdata\BTH_2021'
  input_directory='H:\bth2021\1'
  ;out_directory='F:\FYdata\BTH1KM\'
  out_directory='H:\dtcloud\03cloudrbth\1\fycloudpro\'
  file_list_hdf=file_search(input_directory,'*_1000M_MS.HDF',count=file_n_hdf)

  ;*****************************************************文件批处理 *****************************************************
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    
    ;错误文件的捕捉
    Catch, errorStatus
    if (errorStatus NE 0) then begin
      Catch, /CANCEL
      print,!ERROR_STATE.Msg+'有问题'
      continue
    endif
    
    ;获取文件的时间
    datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),19,8)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),28,4)

    ;获取GEO文件的经纬度及四个角度数据
    basefile_i_geo=file_basename(file_list_hdf[file_i_hdf])
    strput, basefile_i_geo, "GEO1K_MS.HDF",33 ;字符串替换
    file_i_geo= input_directory+'\'+basefile_i_geo
    Latdata=get_hdf5_data(file_i_geo,'/Geolocation/Latitude')
    Longdata=get_hdf5_data(file_i_geo,'/Geolocation/Longitude')
    szdata=get_hdf5_data(file_i_geo,'/Geolocation/SolarZenith')*0.01;太阳天顶角
    sadata=get_hdf5_data(file_i_geo,'/Geolocation/SolarAzimuth')*0.01;太阳方位角
    vzdata=get_hdf5_data(file_i_geo,'/Geolocation/SensorZenith')*0.01;观测天顶角
    vadata=get_hdf5_data(file_i_geo,'/Geolocation/SensorAzimuth')*0.01;观测方位角

    ;*****************************************************计算TOA(1-19波段)*****************************************************
    fy3d_level1b_read,file_list_hdf[file_i_hdf],szdata=szdata,toadata,/reflectance

    ;result_tiff_name=out_directory+datetime+'_baseTOA.tif'
    ;write_tiff,result_tiff_name,toadata,planarconfig=2,compression=1,/float

    ;*****************************************************去云处理*************************************************************
    fy3d_cloud_pro,file_list_hdf[file_i_hdf],toadata,clouddata
    toadata_size=size(toadata)
    cloudpos=where(clouddata ne 0)

    ;result_tiff_name=out_directory+datetime+'_cloudmask.tif'
    ;write_tiff,result_tiff_name,CloudData,planarconfig=2,/float

    ;去云
    for layer_i=0,toadata_size[3]-1 do begin
      data=toadata[*,*,layer_i]
      data[cloudpos]=!VALUES.F_NAN
      toadata[*,*,layer_i]=data
    endfor


    coor_angle_data_1km=[[[szdata]],[[sadata]],[[vzdata]],[[vadata]],[[Longdata]],[[Latdata]]]


    imginfo_data=[[[toadata]],[[coor_angle_data_1km]]]

    result_tiff_name=out_directory+datetime+'_TOA1km.tif'
    ;compression数据压缩  planarconfig=2(BSQ) 说明导入的数据是（列，行，通道数）这也是IDL的常用的，用envi打开格式为（2048 x 2000 x 4）,matlab打开格式为（2000，2048，4）
    write_tiff,result_tiff_name,imginfo_data,planarconfig=2,compression=1,/float
    print,file_basename(file_list_hdf[file_i_hdf])+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)

    Latdata=!null
    Longdata=!null
    szdata=!null
    sadata=!null
    vzdata=!null
    vadata=!null
    coor_angle_data_1km=!null
    toadata=!null
    clouddata=!null
    imginfo_data=!null
   
  endfor

  print,'所有文件提取完成'
end