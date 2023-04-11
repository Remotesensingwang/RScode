;coding=utf-8
;*****************************************************
;对敦煌定标场进行TOA计算（以敦煌定标场中心点为中心，计算0.1°*0.1°范围的均值）
;先提取敦煌地区范围的TOA数据，并对敦煌地区范围内的数据进行去云处理，最后提取敦煌站点范围内的数据
;范围选取：
;*****************************************************

pro modis_calculate_toa326,input_directory=input_directory
  compile_opt idl2
;  input_directory='H:\00data\MODIS\MODIS_L1data\2019'
  input_directory_GEO=input_directory+'-GEO'
  out_directory='F:\modis_dh\tiff\cloutiff\dh\'
  DestPath='H:\00data\MODIS\MODIS_L1data\NAN'
  DestPath1='H:\00data\MODIS\MODIS_L1data\NAN-MYD03'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\407(20km)\dh_dingbiao_modis20km_0407.txt',/get_lun,/append,width=500
  ;敦煌定标场中心坐标
  dh_lon=94.27
  dh_lat=40.18

  file_list_hdf=file_search(input_directory,'MYD021KM*.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    
    ;错误文件的捕捉
    Catch, errorStatus
    if (errorStatus NE 0) then begin
      Catch, /CANCEL
      print,!ERROR_STATE.Msg+'有问题'
      continue
    endif
      
    ;获取1-2波段的DN值
    EV_250_RefSB_data=get_hdf_dataset(file_list_hdf[file_i_hdf],'EV_250_Aggr1km_RefSB') ;1-2波段
    ;获取SI数据的列、行号（有时行号为2030，有时为2040）
    DN_band_data_size=size(temporary(EV_250_RefSB_data))

    ;获取文件的时间、经纬度、四个角度
;    datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,7)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4)
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

    ;*******************************提取敦煌地区范围的数据********************************************
    pos=where((lon ge 94.216) and (lon le 94.416) and (lat ge 40.002)and(lat le 40.202),count)
;    pos=where((lon ge 94.284) and (lon le 94.384) and (lat ge 40.044)and(lat le 40.144),count)

    ;提取敦煌地区范围的行列号
    data_col=DN_band_data_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)

    if count eq 0 or (col_max-col_min) lt 3 or (line_max-line_min) lt 3 then begin
      ;file_delete,file_list_hdf[file_i_hdf]
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌范围提取失败并删除'+string(file_n_hdf-file_i_hdf-1)  
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
    coor_angle_data=[[[sz_angle]],[[temporary(sa_angle)]],[[temporary(vz_angle)]],[[temporary(va_angle)]],[[temporary(ra_angle)]],[[temporary(lon)]],[[temporary(lat)]]]
    ;这里计算的是1-19，26波段的toa反射率（总共22个波段，13、14），但没有进行太阳天顶角的校正
;    MYD021KM_L1b_read,file_list_hdf[file_i_hdf],TOA_ref_nosz,/reflectance
        
    MYD021KM_L1b_read,file_list_hdf[file_i_hdf],sz_angle=sz_angle,TOA_ref_nosz,/reflectance
;    TOA_ref_angle=[[[TOAdata]],[[temporary(coor_angle_data)]]] ;为全幅影像，全波段的数据
;    dh_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*]
;    write_tiff,'F:\modis_dh\tiff\basetiff\'+datetime+'TOA_base_DH.tiff',dh_TOA_ref_angle,planarconfig=2,compression=1,/float
        
    TOA_ref_nosz_angle=[[[TOA_ref_nosz]],[[temporary(coor_angle_data)]]] ;为全幅影像，全波段的数据
    dh_TOA_ref_nosz_angle=TOA_ref_nosz_angle[col_min:col_max,line_min:line_max,*] ;为敦煌地区范围的全波段数据,包括未太阳天顶角校正的可见光波段数据+角度坐标信息
    ;云掩膜，处理全图地区范围的
;    DBDT_cloud_area,file_list_hdf[file_i_hdf],TOA_ref_nosz_angle,cloud_data    
    ;云掩膜，只处理敦煌地区范围的
    DBDT_cloud_MODIS,file_list_hdf[file_i_hdf],dh_TOA_ref_nosz_angle,cloud_data,col_min=col_min,col_max=col_max,line_min=line_min,line_max=line_max,/AREA


    cloud_pos=where(cloud_data ne 0)
    dh_pos=where(cloud_data eq 0,count_dh_pos)

    if count_dh_pos eq 0  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath1
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌范围数据内没有有效值,并移动成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    dh_TOA_ref_mean=[]
;    dh_TOA_ref_std1=[]
    dh_TOA_ref_count=[]
    ;处理1-19,26波段的数据(13lo 13hi 14lo 14hi)
    for layer_i=0,21 do begin
;      dh_TOA_ref=TOA_ref_nosz_angle[*,*,layer_i]/cos(sz_angle*!dtor) ;全图的toa反射率
      dh_TOA_ref=dh_TOA_ref_nosz_angle[*,*,layer_i] ;敦煌地区的toa反射率
      dh_TOA_ref_std=get_std(dh_TOA_ref,3,3)
      fillvalue_pos_i=where(dh_TOA_ref le 0 or dh_TOA_ref ge 1 or ~FINITE(dh_TOA_ref_std) or dh_TOA_ref_std ge 0.01,count)      
      if count gt 0 then   dh_TOA_ref[fillvalue_pos_i]=!values.F_NAN
      dh_TOA_ref[cloud_pos]=!VALUES.F_NAN
      dh_TOA_ref_mean=[dh_TOA_ref_mean,mean(dh_TOA_ref,/nan)]
      dh_NotNaN_pos_i=WHERE(FINITE(dh_TOA_ref),count_notnan)
      dh_TOA_ref_count=[dh_TOA_ref_count,count_notnan]
;      dh_TOA_ref_std1=[dh_TOA_ref_std1,stddev(dh_TOA_ref,/nan)]
;      TOA_ref_nosz_angle[*,*,layer_i]=temporary(dh_TOA_ref) ;此时为全图范围TOA反射率去云的真值
      dh_TOA_ref_nosz_angle[*,*,layer_i]=temporary(dh_TOA_ref) ;此时为敦煌范围TOA反射率去云的真值
    endfor
    
;    write_tiff,out_directory+datetime+'TOA_cloud_dh-chong-1.tiff',dh_TOA_ref_nosz_angle,planarconfig=2,compression=1,/float
    
    
    dh_Data0064=dh_TOA_ref_nosz_angle[*,*,0]
    dh_Data0064_size=size(dh_Data0064)
    NotNaN_pos=WHERE(FINITE(temporary(dh_Data0064)),count_notnan)

    ;    if count_notnan lt 120  then begin
    if count_notnan eq 0  then begin
      print,file_basename(file_list_hdf[file_i_hdf])+'敦煌站点数据为NAN'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;获取敦煌范围内四个角度的均值
    dh_angle_mean=[mean(dh_sz_angle[NotNaN_pos]),mean(dh_sa_angle[NotNaN_pos]),mean(dh_vz_angle[NotNaN_pos]),mean(dh_va_angle[NotNaN_pos]),mean(dh_ra_angle[NotNaN_pos])]

    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(dh_angle_mean),string(dh_TOA_ref_mean),string(dh_Data0064_size[4]),string(dh_TOA_ref_count)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(mean(temporary(dh_lon))))+STRCOMPRESS(string(mean(temporary(dh_lat))))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
    
    poss=[temporary(pos),temporary(cloud_pos),temporary(dh_pos),temporary(NotNaN_pos)]
    dh_coor_angle_data=[[[temporary(dh_sz_angle)]],[[temporary(dh_sa_angle)]],[[temporary(dh_vz_angle)]],[[temporary(dh_va_angle)]],[[temporary(dh_ra_angle)]]]    
    
    TOA_ref_nosz=!null
    TOA_ref_nosz_angle=!null
    cloud_data=!null
    dh_TOA_ref_nosz_angle=!null
    
    dh_angle_mean=!null
    dh_TOA_ref_mean=!null
    dh_TOA_ref_std=!null
    poss=!null
    dh_coor_angle_data=!null
  endfor
  free_lun,lun
  print,'所有文件提取完成'
end