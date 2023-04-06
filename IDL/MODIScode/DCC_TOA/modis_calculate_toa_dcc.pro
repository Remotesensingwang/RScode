;coding=utf-8
;*****************************************************
;DCC提取
;范围：（-20S - +20N   85E - 125E）
;注意 这里限制了TOA的数据，其中对于于 0.8 以下的云反射率的观测值被丢弃
;*****************************************************

pro modis_calculate_toa_DCC
  compile_opt idl2
  input_directory='H:\00data\MODIS\DCC\DCC_L1data\2020' ;
  out_directory='C:\Users\lenovo\Downloads\DCC\01\tiff\'
  DestPath='H:\00data\MODIS\DCC\DCC_NAN\2020'
  ;文件日期 角度 匹配站点范围各个波段的toa均值 
  ;openw,lun,'H:\00data\MODIS\DCC\TOA\0.8\DCC_2020_modis-0.8.txt',/get_lun,/append,width=500

  file_list_hdf=file_search(input_directory,'*.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    
    ;错误文件的捕捉
    Catch, errorStatus
    if (errorStatus NE 0) then begin
      Catch, /CANCEL
      print,!ERROR_STATE.Msg+'有问题'
      continue
    endif
    
    ;获取1-19波段,26波段的DN值
    EV_250_RefSB_data=get_hdf_dataset(file_list_hdf[file_i_hdf],'EV_250_Aggr1km_RefSB') ;1-2波段
    ;获取SI数据的列、行号（有时行号为2030，有时为2040）
    DN_band_data_size=size(temporary(EV_250_RefSB_data))
    
    ;获取文件的时间、经纬度、四个角度
    ;datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,7)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4) 
    out_year_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,4))
    out_day_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),14,3))
    out_hour_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4))
    date_julian=imsl_datetodays(31,12,out_year_fix-1);imsl相关的函数说明在ENVI安装目录help中的pdf中：advmathstats.pdf
    imsl_daystodate,date_julian+out_day_fix,day,month,year;将儒略日转化为日期  
    date=[year,month,day,out_hour_fix]
    datetime=strcompress(date.ToString('(I0,I02,I02,I04)'),/remove_all)
       
    ;*******************************读取MYD03数据，提取经纬度及四个角度********************************************
;    basefile_i=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),8,18)
;    file_i_geo='MYD03'+basefile_i+'.hdf'
;    file_i_geo= input_directory_GEO+'\'+file_i_geo
;    lat=get_hdf_dataset(file_i_geo,'Latitude')
;    lon=get_hdf_dataset(file_i_geo,'Longitude')
;    ;pos=Spatial_matching(dh_lon,dh_lat,lon,lat) ;获取距离站点最近的经纬度下标
;    sz_angle=get_hdf_dataset(file_i_geo,'SolarZenith')*0.01;太阳天顶角
;    sa_angle=get_hdf_dataset(file_i_geo,'SolarAzimuth')*0.01;太阳方位角
;    vz_angle=get_hdf_dataset(file_i_geo,'SensorZenith')*0.01;观测天顶角
;    va_angle=get_hdf_dataset(file_i_geo,'SensorAzimuth')*0.01;观测方位角
;    ra_angle = abs(sa_angle - va_angle)
;    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角



    ;*******************************经纬度及四个角度进行插值(双线性插值法(interp))，不需要MYD03产品********************************************
    lat=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'Latitude'),DN_band_data_size[1],DN_band_data_size[2],/interp)
    lon=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'Longitude'),DN_band_data_size[1],DN_band_data_size[2],/interp)
    sz_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarZenith'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01   ;太阳天顶角
    sa_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarAzimuth'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01  ;太阳方位角
    vz_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorZenith'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01  ;观测天顶角
    va_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorAzimuth'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01 ;观测方位角
    ra_angle = abs(sa_angle - va_angle)
    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角
                
    pos=where((lon ge 85.0) and (lon le 125.0) and (lat ge -20.0) and (lat le 20.0),count)
       
    data_col=DN_band_data_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)
                                   
    if col_max-col_min lt 3 or line_max-line_min lt 3 or count eq 0 then begin      
      file_delete,file_list_hdf[file_i_hdf]
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC提取失败,并删除成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    DCC_sz_angle=sz_angle[col_min:col_max,line_min:line_max]   ;太阳天顶角
    DCC_sa_angle=sa_angle[col_min:col_max,line_min:line_max]   ;太阳方位角
    DCC_vz_angle=vz_angle[col_min:col_max,line_min:line_max]   ;观测天顶角
    DCC_va_angle=va_angle[col_min:col_max,line_min:line_max]   ;观测方位角
    DCC_ra_angle =ra_angle[col_min:col_max,line_min:line_max]  ;相对方位角
    
    coor_angle_data=[[[sz_angle]],[[temporary(sa_angle)]],[[temporary(vz_angle)]],[[temporary(va_angle)]],[[temporary(ra_angle)]],[[temporary(lon)]],[[temporary(lat)]]]
    
    ;注意这里只计算了前4个波段的TOA反射率
    MYD021KM_L1b_read,file_list_hdf[file_i_hdf],TOA_ref,sz_angle=temporary(sz_angle),/reflectance
    TOA_ref_angle=[[[TOA_ref]],[[temporary(coor_angle_data)]]]
    ;去云去雪去水体处理
    DCC_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*]
    
    
    dbdt_dcc,file_list_hdf[file_i_hdf],DCC_TOA_ref_angle,cloud_data,col_min=col_min,col_max=col_max,line_min=line_min,line_max=line_max,/area
    

    cloud_pos=where(cloud_data ne 0)
    DCC_pos=where(cloud_data eq 0,count_DCC_pos)

    if count_DCC_pos eq 0  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC范围数据内没有有效值,并移动成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
            
    ;处理1-19,26波段的数据
    DCC_TOA_ref_mean=[]
    ;    DCC_TOA_ref_std=[]
    DCC_TOA_ref_count=[]
    for layer_i=0,21 do begin
      DCC_TOA_ref=DCC_TOA_ref_angle[*,*,layer_i]
      fillvalue_pos=where(DCC_TOA_ref le 0.8 or DCC_TOA_ref ge 1 or $
        ~FINITE(get_std(DCC_TOA_ref,3,3)) or get_std(DCC_TOA_ref,3,3) ge 0.03,count)
      if count gt 0 then   DCC_TOA_ref[fillvalue_pos]=!values.F_NAN
      DCC_TOA_ref[cloud_pos]=!VALUES.F_NAN
      DCC_TOA_ref_mean=[DCC_TOA_ref_mean,mean(DCC_TOA_ref,/nan)]
      ;      DCC_TOA_ref_std=[DCC_TOA_ref_std,stddev(DCC_TOA_ref,/nan)]
      DCC_NotNaN_pos_i=WHERE(FINITE(DCC_TOA_ref),count_notnan)
      DCC_TOA_ref_count=[DCC_TOA_ref_count,count_notnan]
      DCC_TOA_ref_angle[*,*,layer_i]=temporary(DCC_TOA_ref)
    endfor
    

    DCC_Data0064=DCC_TOA_ref_angle[*,*,0]
    NotNaN_pos=WHERE(FINITE(temporary(DCC_Data0064)),count_notnan1)
    
    if count_notnan1 le 100  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC数据为NAN1,并移动成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
        
    ;获取DCC范围四个角度的均值
;    DCC_angle_mean=[mean(DCC_TOA_ref_angle[*,*,-7]),mean(DCC_TOA_ref_angle[*,*,-6]),mean(DCC_TOA_ref_angle[*,*,-5]),mean(DCC_TOA_ref_angle[*,*,-4]),mean(DCC_TOA_ref_angle[*,*,-3])]
    DCC_angle_mean=[mean(DCC_sz_angle[NotNaN_pos]),mean(DCC_sa_angle[NotNaN_pos]),mean(DCC_vz_angle[NotNaN_pos]),mean(DCC_va_angle[NotNaN_pos]),mean(DCC_ra_angle[NotNaN_pos])]
    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(DCC_angle_mean),string(DCC_TOA_ref_mean),string(DCC_TOA_ref_count)]
    ;printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(mean(temporary(DCC_lon))))+STRCOMPRESS(string(mean(temporary(DCC_lat))))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
    
    poss=[temporary(pos),temporary(cloud_pos),temporary(DCC_pos),temporary(fillvalue_pos),temporary(DCC_NotNaN_pos_i),temporary(NotNaN_pos)]
    DCC_coor_angle_data=[[[temporary(DCC_sz_angle)]],[[temporary(DCC_sa_angle)]],[[temporary(DCC_vz_angle)]],[[temporary(DCC_va_angle)]],[[temporary(DCC_ra_angle)]]]
    
    
    TOA_ref=!null
    TOA_ref_angle=!null
    DCC_TOA_ref_angle=!null
    
    cloud_data=!null
    DCC_TOA_ref_mean=!null
    DCC_TOA_ref_std=!null      
    DCC_angle_mean=!null
    poss=!null
    DCC_coor_angle_data=!null
  endfor
  ;free_lun,lun
  print,'所有文件提取完成'
end