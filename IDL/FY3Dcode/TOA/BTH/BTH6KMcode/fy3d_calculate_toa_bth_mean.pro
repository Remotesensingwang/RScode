;coding=utf-8
;*****************************************************
;对BTH(京津冀)进行TOA计算,并重采样为6KM
;求的是各个波段的均值，pos是每个波段独立的
;*****************************************************

pro fy3d_calculate_toa_BTH_mean
  compile_opt idl2
  input_directory='H:\bth2021\1'
  out_directory='F:\FYdata\BTH6km\'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  ;openw,lun,'H:\00data\toa\FY3D\snowwatercloud\Yang(tbb)\2019\dh_toa2019_fy3d111.txt',/get_lun,/append,width=500


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

    ;*****************************************************去云处理*************************************************************
    fy3d_cloud,file_list_hdf[file_i_hdf],toadata,clouddata
    toadata_size=size(toadata)
    cloudpos=where(clouddata ne 0)

    ;去云+重采样为6KM即（6*6数组）
    for layer_i=0,toadata_size[3]-1 do begin
      data=toadata[*,*,layer_i]
      data[cloudpos]=!VALUES.F_NAN
      toadata[*,*,layer_i]=data
    endfor

    ;write_tiff,'H:\dtcloud\03cloudrbth\1\pro\0108toa.tif',toadata,planarconfig=2,compression=1,/float

    toadata_size=size(toadata)
    toadata_6km_col=(toadata_size[1]-2)/6
    toadata_6km_row=(toadata_size[2]-2)/6

    ;经纬度、四个角度数据重采样 插值方法为双线性插值法（interp）
    Latdata=congrid(Latdata,toadata_6km_col,toadata_6km_row,/interp)
    Longdata=congrid(Longdata,toadata_6km_col,toadata_6km_row,/interp)
    szdata=congrid(szdata,toadata_6km_col,toadata_6km_row,/interp)
    sadata=congrid(sadata,toadata_6km_col,toadata_6km_row,/interp)
    vzdata=congrid(vzdata,toadata_6km_col,toadata_6km_row,/interp)
    vadata=congrid(vadata,toadata_6km_col,toadata_6km_row,/interp)

    coor_angle_data_6km=[[[szdata]],[[sadata]],[[vzdata]],[[vadata]],[[Longdata]],[[Latdata]]]


    ;重采样为6KM即（6*6数组)
    toadata_6km=MAKE_ARRAY(toadata_6km_col,toadata_6km_row,toadata_size[3],value=!VALUES.F_NAN,/FLOAT)
    ;Data0065=toadata[*,*,2]

    for layer_i=0,toadata_size[3]-1 do begin
      ;按行存储，for循环j要在前面
      time2=systime(1)

      data_layer=toadata[*,*,layer_i]
      k=0L

      for j=0,toadata_size[2]-3,6 do begin
        for i=0,toadata_size[1]-3,6 do begin
          ;获取K具体所对应的列，行号,可应用于数据的提取（截取）
          k_col=k mod toadata_6km_col ;k的列（类型为数组）
          k_line=k / toadata_6km_col    ;k的行（类型为数组）

          value_layer=data_layer[i:i+5,j:j+5]
          NotNaN_pos=WHERE(FINITE(value_layer),/null) ;查找不是NaN的索引下标

          if n_elements(NotNaN_pos) ge 8 then begin
            ;NotNaN_value=value_layer[NotNaN_pos]
            toadata_6km[k_col,k_line,layer_i]=mean(value_layer,/nan)
            ;print,'1111'
          endif else begin
            k=k+1
            continue
          endelse
          k=k+1
        endfor
      endfor
      ;print,string(systime(1)-time2)+string(layer_i)
    endfor

    imginfo_data=[[[toadata_6km]],[[coor_angle_data_6km]]]

    result_tiff_name=out_directory+datetime+'_TOA6km.tif'
    ;compression数据压缩  planarconfig=2(BSQ) 说明导入的数据是（列，行，通道数）这也是IDL的常用的，用envi打开格式为（2048 x 2000 x 4）,matlab打开格式为（2000，2048，4）
    write_tiff,result_tiff_name,imginfo_data,planarconfig=2,compression=1,/float
    print,file_basename(file_list_hdf[file_i_hdf])+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)

    Latdata=!null
    Longdata=!null
    szdata=!null
    sadata=!null
    vzdata=!null
    vadata=!null
    coor_angle_data_6km=!null
    toadata=!null
    clouddata=!null
    imginfo_data=!null
    toadata_6km=!null
  endfor
  ;free_lun,lun
  print,'所有文件提取完成'
end