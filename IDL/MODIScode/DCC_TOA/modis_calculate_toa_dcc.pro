;coding=utf-8
;*****************************************************
;DCC提取
;范围：（-20S - +20N   85E - 125E）
;注意 这里限制了TOA的数据，其中对于于 0.7 以下的云反射率的观测值被丢弃
;*****************************************************

pro modis_calculate_toa_DCC
  compile_opt idl2
  input_directory='H:\00data\MODIS\DCC\DCC_L1data\2020' ;
  out_directory='C:\Users\lenovo\Downloads\DCC\01\tiff\'
  DestPath='H:\00data\MODIS\DCC\DCC_NAN\2020'
  ;文件日期 角度 匹配站点范围各个波段的toa均值 
  openw,lun,'H:\00data\MODIS\DCC\TOA\0.8\DCC_2020_modis-0.8.txt',/get_lun,/append,width=500

  file_list_hdf=file_search(input_directory,'*.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    
    ;错误文件的捕捉
    Catch, errorStatus
    if (errorStatus NE 0) then begin
      Catch, /CANCEL
      print,file_list_hdf[file_i_hdf]+'有问题'
      continue
    endif
    
    ;获取文件的时间、经纬度、四个角度
    ;datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,7)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4) 
    out_year_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,4))
    out_day_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),14,3))
    out_hour_fix=fix(strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4))
    date_julian=imsl_datetodays(31,12,out_year_fix-1);imsl相关的函数说明在ENVI安装目录help中的pdf中：advmathstats.pdf
    imsl_daystodate,date_julian+out_day_fix,day,month,year;将儒略日转化为日期  
    date=[year,month,day,out_hour_fix]
    datetime=strcompress(date.ToString('(I0,I02,I02,I04)'),/remove_all)
    
    ;获取1-19波段,26波段的DN值
    EV_250_RefSB_data=get_hdf_dataset(file_list_hdf[file_i_hdf],'EV_250_Aggr1km_RefSB') ;1-2波段

    ;获取SI数据的列、行号（有时行号为2030，有时为2040）
    DN_band_data_size=size(EV_250_RefSB_data)

    ;经纬度、四个角度数据重采样 插值方法为双线性插值法（interp）   
    lat=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'Latitude'),DN_band_data_size[1],DN_band_data_size[2],/interp)
    lon=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'Longitude'),DN_band_data_size[1],DN_band_data_size[2],/interp)
    sz_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarZenith'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01   ;太阳天顶角
    sa_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarAzimuth'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01  ;太阳方位角
    vz_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorZenith'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01  ;观测天顶角
    va_angle=congrid(get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorAzimuth'),DN_band_data_size[1],DN_band_data_size[2],/interp)*0.01 ;观测方位角
    ra_angle = abs(sa_angle - va_angle)
    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角
    ;太阳耀斑角
;    sca_angle_cos = -(cos(vz_angle * !DTOR) * cos(sz_angle * !DTOR) + sin(vz_angle * !DTOR) * sin(sz_angle * !DTOR) * cos(ra_angle * !DTOR))
;    sca_angle = acos(sca_angle_cos) / !DTOR
    
    
    coor_angle_data=[[[sz_angle]],[[sa_angle]],[[vz_angle]],[[va_angle]],[[ra_angle]],[[lon]],[[lat]]]
             
    pos=where((lon ge 85.0) and (lon le 125.0) and (lat ge -20.0) and (lat le 20.0),count)
       
    data_col=DN_band_data_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)
    s= file_list_hdf[file_i_hdf]
                                   
    if col_max-col_min lt 3 or line_max-line_min lt 3 or count eq 0 then begin      
      file_delete,file_list_hdf[file_i_hdf]
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC提取失败,并删除成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    ;注意这里只计算了前4个波段的TOA反射率
    MYD021KM_L1b_read,file_list_hdf[file_i_hdf],TOA_ref,sz_angle=sz_angle,/reflectance
    TOA_ref_angle=[[[TOA_ref]],[[coor_angle_data]]]
    ;去云去雪去水体处理
    DCC_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*]
    
;    out_target=out_directory+string(datetime)+'_base.tiff'
;    write_tiff,out_target,DCC_TOA_ref_angle,planarconfig=2,compression=1,/float
    
    dbdt_dcc,file_list_hdf[file_i_hdf],DCC_TOA_ref_angle,cloud_data,col_min=col_min,col_max=col_max,line_min=line_min,line_max=line_max,/area
    
;    out_target=out_directory+string(datetime)+'_DCC.tiff'
;    write_tiff,out_target,DCC_TOA_ref_angle,planarconfig=2,compression=1,/float

    cloud_pos=where(cloud_data ne 0)
    DCC_pos=where(cloud_data eq 0,count_DCC_pos)

    if count_DCC_pos eq 0  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC范围数据内没有有效值,并移动成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
        
    DCC_TOA_ref_mean=[]
    DCC_TOA_ref_std=[]
    for band=0,3 do begin
      DCC_TOA_ref=DCC_TOA_ref_angle[*,*,band]
      fillvalue_pos=where(DCC_TOA_ref le 0.8 or DCC_TOA_ref ge 1,count)
      if count gt 0 then   DCC_TOA_ref[fillvalue_pos]=!values.F_NAN 
      DCC_TOA_ref[cloud_pos]=!values.F_NAN
      ;DCC_TOA_ref[where(DCC_TOA_ref le 0)]=!values.F_NAN
      DCC_TOA_ref_mean=[DCC_TOA_ref_mean,mean(DCC_TOA_ref,/nan)]
      DCC_TOA_ref_std=[DCC_TOA_ref_std,stddev(DCC_TOA_ref,/nan)]
      DCC_TOA_ref_angle[*,*,band]=DCC_TOA_ref
    endfor

    DCC_Data0047=DCC_TOA_ref_angle[*,*,2]
    DCC_Data0047_size=size(DCC_Data0047)
    NotNaN_pos=WHERE(FINITE(DCC_Data0047),count_notnan)
    
    if count_notnan eq 0  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC数据为NAN,并移动成功！'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    
    DCC_sz_angle=sz_angle[col_min:col_max,line_min:line_max]   ;太阳天顶角
    DCC_sa_angle=sa_angle[col_min:col_max,line_min:line_max]   ;太阳方位角
    DCC_vz_angle=vz_angle[col_min:col_max,line_min:line_max]   ;观测天顶角
    DCC_va_angle=va_angle[col_min:col_max,line_min:line_max]   ;观测方位角
    DCC_ra_angle =ra_angle[col_min:col_max,line_min:line_max]  ;相对方位角
    
    
    
    ;获取DCC范围四个角度的均值
;    DCC_angle_mean=[mean(DCC_TOA_ref_angle[*,*,-7]),mean(DCC_TOA_ref_angle[*,*,-6]),mean(DCC_TOA_ref_angle[*,*,-5]),mean(DCC_TOA_ref_angle[*,*,-4]),mean(DCC_TOA_ref_angle[*,*,-3])]
    DCC_angle_mean=[mean(DCC_sz_angle[NotNaN_pos]),mean(DCC_sa_angle[NotNaN_pos]),mean(DCC_vz_angle[NotNaN_pos]),mean(DCC_va_angle[NotNaN_pos]),mean(DCC_ra_angle[NotNaN_pos])]
    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(DCC_Data0047_size[4]),string(count_notnan),string(DCC_angle_mean),string(DCC_TOA_ref_mean),string(DCC_TOA_ref_std)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'

    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(lon[median(pos)]))+STRCOMPRESS(string(lat[median(pos)]))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)

    EV_250_RefSB_data=!null
    lat=!null
    lon=!null
    sz_angle=!null
    sa_angle=!null
    vz_angle=!null
    va_angle=!null
    ra_angle=!null
    TOA_ref=!null
    TOA_ref_angle=!null
    DCC_TOA_ref_angle=!null
    
    cloud_data=!null
    DCC_TOA_ref=!null
    DCC_TOA_ref_mean=!null
    DCC_TOA_ref_std=!null
    DCC_Data0064=!null
    
    DCC_sz_angle=!null
    DCC_sa_angle=!null
    DCC_vz_angle=!null
    DCC_va_angle=!null
    DCC_ra_angle=!null
    
    DCC_angle_mean=!null

  endfor
  free_lun,lun
  print,'所有文件提取完成'
end