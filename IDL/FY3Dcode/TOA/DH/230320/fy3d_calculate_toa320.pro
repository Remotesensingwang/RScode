;coding=utf-8
;*****************************************************
;对敦煌定标场进行TOA计算（以敦煌定标场中心点为中心，计算0.03°*0.03°范围的均值）
;敦煌定标场的经纬度坐标为：39°51'34.7"N 94°41'27.6"E。
;*****************************************************

pro fy3d_calculate_toa320,input_directory=input_directory
  compile_opt idl2
  input_directory='H:\00data\FY3D\FY3D_dunhuang\2021'
  out_directory='H:\00data\FY3D\FY3D_dunhuang\tifout\removecloud\fycloudpro\2019\'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  ;openw,lun,'H:\00data\TOA\FY3D\removecloud\fycloudpro\2021\1kmstd\dh_toa2021_fy3d_1km_NAN00.txt',/get_lun,/append,width=500
  ;openw,lun,'H:\00data\TOA\FY3D\removecloud\fycloudpro\2019\QA_no\dh_toa2019_fy3d.txt',/get_lun,/append,width=500
  ;  openw,lun,'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\315(20km-5)\dh_dingbiao2021_fy3d1km_5.txt',/get_lun,/append,width=500
  openw,lun,'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\320(10km-6)\basetxt\dh_dingbiao2021_fy3d10km_6_anglepos.txt',/get_lun,/append,width=500
  ;敦煌定标场中心坐标
  dh_lon=94.27             ;94.4     ;94.32083333333334      ;
  dh_lat=40.18             ;40.1     ;40.1375                ;
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
    lat=get_hdf5_data(file_i_geo,'/Geolocation/Latitude')
    lon=get_hdf5_data(file_i_geo,'/Geolocation/Longitude')
    ;pos=Spatial_matching(dh_lon,dh_lat,lon,lat) ;获取距离站点最近的经纬度下标
    sz_angle=get_hdf5_data(file_i_geo,'/Geolocation/SolarZenith')*0.01;太阳天顶角
    sa_angle=get_hdf5_data(file_i_geo,'/Geolocation/SolarAzimuth')*0.01;太阳方位角
    vz_angle=get_hdf5_data(file_i_geo,'/Geolocation/SensorZenith')*0.01;观测天顶角
    va_angle=get_hdf5_data(file_i_geo,'/Geolocation/SensorAzimuth')*0.01;观测方位角
    ra_angle = abs(sa_angle - va_angle)
    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角
    coor_angle_data=[[[sz_angle]],[[sa_angle]],[[vz_angle]],[[va_angle]],[[ra_angle]],[[lon]],[[lat]]]

    ;*******************************提取敦煌地区范围的数据********************************************
    ;pos=where((lon ge 93.5) and (lon le 95) and (lat ge 39.5)and(lat le 41),count)
    ;pos=where((lon ge 94.216) and (lon le 94.416) and (lat ge 40.002)and(lat le 40.202),count)
    pos=where((lon ge 94.284) and (lon le 94.384) and (lat ge 40.044)and(lat le 40.144),count)
    lon_size=size(lon)
    ;提取敦煌地区范围的行列号
    data_col=lon_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)

    ;提取敦煌地区范围的经纬度、几何角度信息
    dh_lon=lon[col_min:col_max,line_min:line_max]
    dh_lat=lat[col_min:col_max,line_min:line_max]
    dh_sz_angle=sz_angle[col_min:col_max,line_min:line_max]
    dh_sa_angle=sa_angle[col_min:col_max,line_min:line_max]
    dh_vz_angle=vz_angle[col_min:col_max,line_min:line_max]
    dh_va_angle=va_angle[col_min:col_max,line_min:line_max]
    dh_ra_angle=ra_angle[col_min:col_max,line_min:line_max]
    if  count eq 0 or (col_max-col_min) lt 3 or (line_max-line_min) lt 3 then begin
      ;print,file_basename(file_list_hdf[file_i_hdf])+'pos失败'+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌范围提取失败'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;*****************************************************计算TOA(1-19波段)*****************************************************
    fy3d_level1b_read,file_list_hdf[file_i_hdf],sz_angle=sz_angle,TOA_ref,/reflectance
    
    TOA_ref_angle=[[[TOA_ref]],[[coor_angle_data]]] ;TOA_ref_angle为全幅影像，全波段的数据    
    dh_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*] ;dh_TOA_ref_angle为敦煌地区范围的全波段数据
    ;  0.354025 
    ;*****************************************************去云处理 只处理敦煌地区范围的*************************************************************
    cloud314,file_list_hdf[file_i_hdf],dh_TOA_ref_angle,cloud_data,col_min=col_min,col_max=col_max,line_min=line_min,line_max=line_max,/area

    cloud_pos=where(cloud_data ne 0)
    angle_pos=where(cloud_data eq 0)
    ;处理前4个波段的数据
    dh_TOA_ref_mean=[]
    dh_TOA_ref_std=[]
    for layer_i=0,3 do begin
      dh_TOA_ref=dh_TOA_ref_angle[*,*,layer_i]
      dh_TOA_ref[cloud_pos]=!VALUES.F_NAN
      dh_TOA_ref_mean=[dh_TOA_ref_mean,mean(dh_TOA_ref,/nan)]
      dh_TOA_ref_std=[dh_TOA_ref_std,stddev(dh_TOA_ref,/nan)]
      dh_TOA_ref_angle[*,*,layer_i]=dh_TOA_ref
    endfor


    dh_Data0047=dh_TOA_ref_angle[*,*,0]
    dh_Data0047_size=size(dh_Data0047)
    NotNaN_pos=WHERE(FINITE(dh_Data0047),count_notnan)

    if count_notnan eq 0  then begin
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌站点数据为NAN'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;*****************************************************获取以站点为中心0.1°*0.1°范围内各波段表观反射率的均值 *****************************************************

    ;获取敦煌站点0.1°范围内四个角度的均值
    dh_angle_mean=[mean(dh_sz_angle[angle_pos]),mean(dh_sa_angle[angle_pos]),mean(dh_vz_angle[angle_pos]),mean(dh_va_angle[angle_pos]),mean(dh_ra_angle[angle_pos])]

    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(dh_Data0047_size[4]),string(count_notnan),string(dh_angle_mean),string(dh_TOA_ref_mean),string(dh_TOA_ref_std)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    ;63.7572      190.347      29.8564      74.9847      115.363
    ;result_tiff_name=out_directory+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),19,13)+'_TOA_1km.tif'
    ;write_tiff,result_tiff_name,TOA_ref,planarconfig=2,compression=1,/float   ;planarconfig=2(BSQ) 说明导入的数据是（列，行，通道数）这也是IDL的常用的，用envi打开格式为（2048 x 2000 x 4）,matlab打开格式为（2000，2048，4）
    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(mean(dh_lon)))+STRCOMPRESS(string(mean(dh_lat)))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)

    sz_angle=!null
    sa_angle=!null
    vz_angle=!null
    va_angle=!null
    ra_angle=!null
    coor_angle_data=!null
    dh_sz_angle=!null
    dh_sa_angle=!null
    dh_vz_angle=!null
    dh_va_angle=!null
    dh_ra_angle=!null
    
    TOA_ref=!null
    TOA_ref_angle=!null
    dh_TOA_ref_angle=!null
    cloud_data=!null
    
    dh_TOA_ref=!null
    dh_Data0047=!null  
    dh_angle_mean=!null

    dh_TOA_ref_mean=!null
    dh_TOA_ref_std=!null
  endfor
  free_lun,lun
  print,'所有文件提取完成'
end