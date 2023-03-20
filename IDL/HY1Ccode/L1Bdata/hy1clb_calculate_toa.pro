;coding=utf-8
;*****************************************************
;处理HY-1C COCTS L1B数据（.h5）
;对敦煌定标场进行TOA计算（以敦煌定标场中心点为中心，计算0.03°*0.03°范围的均值）
;*****************************************************

pro HY1CLB_calculate_toa
  compile_opt idl2
  input_directory='H:\00data\HY1C\2021L1B\DATA'
  out_directory='H:\00data\HY1C\2021L1B\tifout\basetiff\'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'H:\00data\HY1C\2021L1B\TOA\dh_toa2021_HY1C_.txt',/get_lun,/append,width=500

  ;敦煌定标场中心坐标
  dh_lon=94.32083333333334
  dh_lat=40.1375
  file_list_hdf=file_search(input_directory,'*.h5',count=file_n_hdf)


  ;*****************************************************文件批处理 *****************************************************
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    ;Result = H5F_IS_HDF5(file_list_hdf[file_i_hdf])
    ;获取文件的时间
    datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.h5'),17,8)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),26,4)
    Latdata=get_hdf5_data(file_list_hdf[file_i_hdf],'/Navigation Data/Latitude')
    Longdata=get_hdf5_data(file_list_hdf[file_i_hdf],'/Navigation Data/Longitude')
    szdata=get_hdf5_data(file_list_hdf[file_i_hdf],'/Navigation Data/Sun Zenith Angle');太阳天顶角
    sadata=get_hdf5_data(file_list_hdf[file_i_hdf],'/Navigation Data/Sun Azimuth Angle');太阳方位角
    vzdata=get_hdf5_data(file_list_hdf[file_i_hdf],'/Navigation Data/Satellite Zenith Angle');观测天顶角
    vadata=get_hdf5_data(file_list_hdf[file_i_hdf],'/Navigation Data/Satellite Azimuth Angle');观测方位角

    ;*****************************************************以站点为中心取0.1°*0.1范围内的数据下标*****************************************************
    x=0.03
    lon_min=dh_lon-x
    lon_max=dh_lon+x
    lat_min=dh_lat-x
    lat_max=dh_lat+x

    pos=where(((Longdata ge lon_min) and (Longdata le lon_max)) and ((Latdata ge lat_min)and(Latdata le lat_max)),/null)

    ;判断pos最近点是否为！null，否则失败
    if pos eq !null then begin
      ;print,file_basename(file_list_hdf[file_i_hdf])+'pos失败'+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
      print,file_basename(file_list_hdf[file_i_hdf])+'失败'
      continue
    endif
    
    ;获取站点范围四个角度的均值
    point_degree=[mean(szdata[pos]),mean(sadata[pos]),mean(vzdata[pos]),mean(vadata[pos])]

    ;*****************************************************计算TOA(1-19波段)*****************************************************
    HY1C_levelLB_read,file_list_hdf[file_i_hdf],szdata=szdata,toadata,/reflectance

    ;*****************************************************去云处理*************************************************************
    HY1C_L1B_cloud,file_list_hdf[file_i_hdf],toadata,clouddata

    ;result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\mask\mask.tif'
    ;write_tiff,result_tiff_name_cloud,clouddata,planarconfig=2,compression=1,/float


    toadata_size=size(toadata)
    cloudpos=where(clouddata ne 0)

    for layer_i=0,toadata_size[3]-1 do begin
      data=toadata[*,*,layer_i]
      data[cloudpos]=!VALUES.F_NAN
      ;data[cloudpos]=-100
      toadata[*,*,layer_i]=data
    endfor

    ;result_tiff_name_cloud='H:\00data\HY1C\H1C_OPER_OCT_L1B_20210101T042500_20210101T043000_12148_10\cloud\mask\toa033.tif'
    ;write_tiff,result_tiff_name_cloud,toadata,planarconfig=2,compression=1,/float


    ;*****************************************************获取以站点为中心0.03°*0.03°范围内各波段表观反射率的均值 *****************************************************
    pixs_TOAdata_mean=[]
    for band=0,toadata_size[3]-1 do begin
      ;pixs_TOAdata[*,*,band]=get_spmatching_data(TOAdata[*,*,band],3,pos_col[0],pos_line[0])
      pixs_TOAdata=toadata[*,*,band]
      pixs_TOAdata_mean=[pixs_TOAdata_mean,mean(pixs_TOAdata[pos],/nan)]
    endfor
    ;print,pixs_TOAdata_mean

    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(n_elements(pos)),string(point_degree),string(pixs_TOAdata_mean)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'

    result_tiff_name=out_directory+strmid(file_basename(file_list_hdf[file_i_hdf],'.h5'),17,15)+strmid(file_basename(file_list_hdf[file_i_hdf],'.h5'),48,6)+'_baseTOA.tif'
    ;write_tiff,result_tiff_name,toadata,planarconfig=2,compression=1,/float

    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(Longdata[median(pos)]))+STRCOMPRESS(string(Latdata[median(pos)]))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)

    szdata=!null
    sadata=!null
    vzdata=!null
    vadata=!null
    point_degree=!null
    toadata=!null
    clouddata=!null
    pixs_TOAdata=!null
    pixs_TOAdata_mean=!null

  endfor
  free_lun,lun
  print,'所有文件提取完成'
end