;coding=utf-8
;*****************************************************
;对敦煌定标场进行TOA计算（以敦煌定标场中心点为中心，计算0.1°*0.1°范围的均值）
;先提取敦煌地区范围的TOA数据，并对敦煌地区范围内的数据进行去云处理，最后提取敦煌站点范围内的数据
;范围选取：
;*****************************************************

pro modis_calculate_toa317,input_directory=input_directory
  compile_opt idl2
  input_directory='H:\00data\MODIS\MODIS_L1data\2021'
  input_directory_GEO=''
;  out_directory='H:\00data\TOA\MODIS\removecloud\2019\1kmstd\tiff\'

  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\317(10km-6)\basetxt\dh_dingbiao2021_modis10km_6.txt',/get_lun,/append,width=500
  ;敦煌定标场中心坐标
  dh_lon=94.27
  dh_lat=40.18

  file_list_hdf=file_search(input_directory,'*.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    
    ;获取1-2波段的DN值
    EV_250_RefSB_data=get_hdf_dataset(file_list_hdf[file_i_hdf],'EV_250_Aggr1km_RefSB') ;1-2波段
    ;获取SI数据的列、行号（有时行号为2030，有时为2040）
    DN_band_data_size=size(EV_250_RefSB_data)
    
    
    ;获取文件的时间、经纬度、四个角度
    ;其中经纬度、四个角度数据重采样 插值方法为双线性插值法（interp）
    ;datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,7)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4)
    ;printf,lun,strcompress(lat,/remove_all)
    out_year_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,4))
    out_day_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),14,3))
    out_hour_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4))
    date_julian=imsl_datetodays(31,12,out_year_fix-1);imsl相关的函数说明在ENVI安装目录help中的pdf中：advmathstats.pdf
    imsl_daystodate,date_julian+out_day_fix,day,month,year;将儒略日转化为日期
    date=[year,month,day,out_hour_fix]
    datetime=strcompress(date.ToString('(I0,I02,I02,I04)'),/remove_all)
    
    ;*******************************读取MYD03数据，提取经纬度及四个角度********************************************
    basefile_i=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),8,18)
    file_i_geo='MYD03'+basefile_i+'.hdf'
    file_i_geo= input_directory_GEO+'\'+file_i_geo
    lat=get_hdf_dataset(file_i_geo,'Latitude')
    lon=get_hdf_dataset(file_i_geo,'Longitude')
    ;pos=Spatial_matching(dh_lon,dh_lat,lon,lat) ;获取距离站点最近的经纬度下标
    sz_angle=get_hdf_dataset(file_i_geo,'SolarZenith')*0.01;太阳天顶角
    sa_angle=get_hdf_dataset(file_i_geo,'SolarAzimuth')*0.01;太阳方位角
    vz_angle=get_hdf_dataset(file_i_geo,'SensorZenith')*0.01;观测天顶角
    va_angle=get_hdf_dataset(file_i_geo,'SensorAzimuth')*0.01;观测方位角
    ra_angle = abs(sa_angle - va_angle)
    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角

    ;*******************************经纬度及四个角度进行插值(双线性插值法(interp))，不需要MYD03产品******************************************** 
;    lat=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'Latitude'),DN_band_data_size[1],DN_band_data_size[2],/interp)
;    lon=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'Longitude'),DN_band_data_size[1],DN_band_data_size[2],/interp)
;    sz_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarZenith'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01   ;太阳天顶角
;    sa_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarAzimuth'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01  ;太阳方位角
;    vz_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorZenith'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01  ;观测天顶角
;    va_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorAzimuth'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01 ;观测方位角    
;    ra_angle = abs(sa_angle - va_angle)
;    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角
        
    coor_angle_data=[[[sz_angle]],[[sa_angle]],[[vz_angle]],[[va_angle]],[[ra_angle]],[[lon]],[[lat]]]

    ;*******************************提取敦煌地区范围的数据********************************************
    ;pos=where((lon ge 93.5) and (lon le 95) and (lat ge 39.5)and(lat le 41),count)
;    pos=where((lon ge 94.216) and (lon le 94.416) and (lat ge 40.002)and(lat le 40.202),count)
    pos=where((lon ge 94.284) and (lon le 94.384) and (lat ge 40.044)and(lat le 40.144),count)
    
    ;提取敦煌地区范围的行列号
    data_col=DN_band_data_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)

    if count eq 0 or (col_max-col_min) lt 3 or (line_max-line_min) lt 3 then begin
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌范围提取失败'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
        
    ;提取敦煌地区范围的经纬度、几何角度信息
    dh_lon=lon[col_min:col_max,line_min:line_max]
    dh_lat=lat[col_min:col_max,line_min:line_max]
    dh_sz_angle=sz_angle[col_min:col_max,line_min:line_max]
    dh_sa_angle=sa_angle[col_min:col_max,line_min:line_max]
    dh_vz_angle=vz_angle[col_min:col_max,line_min:line_max]
    dh_va_angle=va_angle[col_min:col_max,line_min:line_max]
    dh_ra_angle=ra_angle[col_min:col_max,line_min:line_max]

    ;dh_toa=toadata[col_min:col_max,line_min:line_max,0:6]
    ; print,string(col_max-col_min+1)+string(line_max-line_min+1)

    ;这里计算的是1-19，26波段的toa反射率（总共22个波段，13、14），但没有进行太阳天顶角的校正
    MYD021KM_L1b_read,file_list_hdf[file_i_hdf],TOA_ref_nosz,/reflectance
    ;MYD021KM_level1b_read,file_list_hdf[file_i_hdf],sz_angle=sz_angle,toadata,/reflectance

    TOA_ref_nosz_angle=[[[TOA_ref_nosz]],[[coor_angle_data]]] ;为全幅影像，全波段的数据
    dh_TOA_ref_nosz_angle=TOA_ref_nosz_angle[col_min:col_max,line_min:line_max,*] ;为敦煌地区范围的全波段数据,包括未太阳天顶角校正的可见光波段数据+角度坐标信息


    ;去云去雪去水体处理，只处理敦煌地区范围的
    DBDT_cloud_area315,file_list_hdf[file_i_hdf],dh_TOA_ref_nosz_angle,cloud_data,col_min=col_min,col_max=col_max,line_min=line_min,line_max=line_max,/AREA

   
    cloud_pos=where(cloud_data ne 0)

    dh_TOA_ref_mean=[]
    dh_TOA_ref_std=[]

    ;处理前4个波段的数据
    for layer_i=0,3 do begin
      dh_TOA_ref=dh_TOA_ref_nosz_angle[*,*,layer_i]/cos(dh_sz_angle*!dtor) ;敦煌地区的toa反射率
      dh_TOA_ref[cloud_pos]=!VALUES.F_NAN
      dh_TOA_ref_mean=[dh_TOA_ref_mean,mean(dh_TOA_ref,/nan)]
      dh_TOA_ref_std=[dh_TOA_ref_std,stddev(dh_TOA_ref,/nan)]
      dh_TOA_ref_nosz_angle[*,*,layer_i]=dh_TOA_ref ;此时为敦煌范围TOA反射率去云的真值
    endfor

    dh_Data0064=dh_TOA_ref_nosz_angle[*,*,0]
    dh_Data0064_size=size(dh_Data0064)
    NotNaN_pos=WHERE(FINITE(dh_Data0064),count_notnan)

    ;    if count_notnan lt 120  then begin
    if count_notnan eq 0  then begin
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌站点数据为NAN'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;获取敦煌范围内四个角度的均值
    dh_angle_mean=[mean(dh_sz_angle[NotNaN_pos]),mean(dh_sa_angle[NotNaN_pos]),mean(dh_vz_angle[NotNaN_pos]),mean(dh_va_angle[NotNaN_pos]),mean(dh_ra_angle[NotNaN_pos])]

    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(dh_Data0064_size[4]),string(count_notnan),string(dh_angle_mean),string(dh_TOA_ref_mean),string(dh_TOA_ref_std)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'

    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(mean(dh_TOA_ref_nosz_angle[*,*,-2])))+STRCOMPRESS(string(mean(dh_TOA_ref_nosz_angle[*,*,-1])))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)

    EV_250_RefSB_data=!null
    lat=!null
    lon=!null
    sz_angle=!null
    sa_angle=!null
    vz_angle=!null
    va_angle=!null
    ra_angle=!null
    coor_angle_data=!null
    dh_lon=!null
    dh_lat=!null    
    dh_sz_angle=!null
    dh_sa_angle=!null
    dh_vz_angle=!null
    dh_va_angle=!null
    dh_ra_angle=!null
    TOA_ref_nosz=!null
    TOA_ref_nosz_angle=!null     
    cloud_data=!null
    dh_TOA_ref_nosz_angle=!null
    dh_TOA_ref=!null
    dh_Data0064=!null    
    dh_angle_mean=!null
    dh_TOA_ref_mean=!null
    dh_TOA_ref_std=!null
  endfor
  free_lun,lun
  print,'所有文件提取完成'
end