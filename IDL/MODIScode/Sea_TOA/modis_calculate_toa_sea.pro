;coding=utf-8
;*****************************************************
;先提取海洋地区范围的TOA数据，并对海洋地区范围内的数据进行去云处理
;范围选取：10-20N 150-65E
;*****************************************************

pro modis_calculate_toa_sea,input_directory=input_directory
  compile_opt idl2
  input_directory='E:\modissea\MYD021km\00'
  input_directory_GEO='E:\modissea\MYD03'
  DestPath='E:\modissea\NAN_MYD021km'
  DestPath1='E:\modissea\NAN_MYD03'  

  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'E:\modissea\TNP_modis_2019.txt',/get_lun,/append,width=500

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
    file_i_geo= input_directory_GEO+'\'+'MYD03'+basefile_i+'.hdf'
    lat=get_hdf_dataset(file_i_geo,'Latitude')
    lon=get_hdf_dataset(file_i_geo,'Longitude')
    ;pos=Spatial_matching(TNP_lon,TNP_lat,lon,lat) ;获取距离站点最近的经纬度下标
    sz_angle=get_hdf_dataset(file_i_geo,'SolarZenith')*0.01;太阳天顶角
    sa_angle=get_hdf_dataset(file_i_geo,'SolarAzimuth')*0.01;太阳方位角
    vz_angle=get_hdf_dataset(file_i_geo,'SensorZenith')*0.01;观测天顶角
    va_angle=get_hdf_dataset(file_i_geo,'SensorAzimuth')*0.01;观测方位角
    ra_angle = abs(sa_angle - va_angle)
    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角
    
    sca_angle_cos = (cos(vz_angle * !DTOR) * cos(sz_angle * !DTOR) + sin(vz_angle * !DTOR) * sin(sz_angle * !DTOR) * cos(ra_angle * !DTOR))
    sca_angle = acos(sca_angle_cos) / !DTOR   ;太阳耀斑角
    ;146.469      146.552      146.614      146.689      146.751      146.818 -
    ;33.5305      33.4485      33.3864      33.3111      33.2491      33.1824 +
    
    ;*******************************提取海洋范围的数据********************************************
    pos=where((lon ge 150.0) and (lon le 165.0) and (lat ge 10.0) and (lat le 20.0),count)

    ;提取海洋地区范围的行列号
    data_col=DN_band_data_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)

    if count eq 0 or (col_max-col_min) lt 3 or (line_max-line_min) lt 3 then begin
      file_delete,[file_list_hdf[file_i_hdf],file_i_geo]      
      print,file_basename(file_list_hdf[file_i_hdf])+'海洋范围提取失败并删除'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;提取海洋地区范围的经纬度、几何角度信息
    TNP_lon=lon[col_min:col_max,line_min:line_max]
    TNP_lat=lat[col_min:col_max,line_min:line_max]
    TNP_sz_angle=sz_angle[col_min:col_max,line_min:line_max]
    TNP_sa_angle=sa_angle[col_min:col_max,line_min:line_max]
    TNP_vz_angle=vz_angle[col_min:col_max,line_min:line_max]
    TNP_va_angle=va_angle[col_min:col_max,line_min:line_max]
    TNP_ra_angle=ra_angle[col_min:col_max,line_min:line_max]
    TNP_sca_angle=sca_angle[col_min:col_max,line_min:line_max]
    
    coor_angle_data=[[[sz_angle]],[[temporary(sa_angle)]],[[temporary(vz_angle)]],[[temporary(va_angle)]],[[temporary(ra_angle)]],[[temporary(sca_angle)]],[[temporary(lon)]],[[temporary(lat)]]]
    ;这里计算的是1-19，26波段的toa反射率（总共22个波段，13、14）,并进行了太阳天顶角的校正   
    MYD021KM_L1b_read,file_list_hdf[file_i_hdf],TOA_ref,sz_angle=temporary(sz_angle),/reflectance
    TOA_ref_angle=[[[TOA_ref]],[[temporary(coor_angle_data)]]] ;TOA_ref_angle为全幅影像，全波段的数据
    TNP_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*] ;为海洋地区范围的全波段数据,包括经过太阳天顶角校正的可见光波段数据+角度坐标信息
    ;云掩膜，只处理海洋地区范围的
    DBDT_Sea_MODIS,file_list_hdf[file_i_hdf],TNP_TOA_ref_angle,cloud_data

    cloud_pos=where(cloud_data ne 0)
    TNP_pos=where(cloud_data eq 0,TNP_count)
    
    if TNP_count eq 0 then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath1      
      print,file_basename(file_list_hdf[file_i_hdf])+'海洋范围数据为NAN,并移动成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    ;处理1-19,26波段的数据(13lo 13hi 14lo 14hi)
    TNP_TOA_ref_mean=[]
    TNP_TOA_ref_count=[]
    for layer_i=0,21 do begin
      TNP_TOA_ref=TNP_TOA_ref_angle[*,*,layer_i]
      fillvalue_pos_i=where(TNP_TOA_ref le 0 or TNP_TOA_ref ge 1,count)
      if count gt 0 then   TNP_TOA_ref[fillvalue_pos_i]=!values.F_NAN
      TNP_TOA_ref[cloud_pos]=!VALUES.F_NAN
      TNP_TOA_ref_mean=[TNP_TOA_ref_mean,mean(TNP_TOA_ref,/nan)]
      TNP_NotNaN_pos_i=WHERE(FINITE(TNP_TOA_ref),count_notnan)
      TNP_TOA_ref_count=[TNP_TOA_ref_count,count_notnan]
      TNP_TOA_ref_angle[*,*,layer_i]=temporary(TNP_TOA_ref)
    endfor
    
    TNP_Data0064=TNP_TOA_ref_angle[*,*,0]
    TNP_Data0064_size=size(TNP_Data0064)
    TNP_NotNaN_pos=WHERE(FINITE(temporary(TNP_Data0064)),count_notnan1)

    if count_notnan1 eq 0  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath1
      print,file_basename(file_list_hdf[file_i_hdf])+'海洋数据有效值不足，并移动成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    ;获取海洋范围内五个角度的均值
    ;断点添加
    TNP_angle_mean=[mean(TNP_sz_angle[TNP_NotNaN_pos]),mean(TNP_sa_angle[TNP_NotNaN_pos]),$
      mean(TNP_vz_angle[TNP_NotNaN_pos]),mean(TNP_va_angle[TNP_NotNaN_pos]),$
      mean(TNP_ra_angle[TNP_NotNaN_pos]),mean(TNP_sca_angle[TNP_NotNaN_pos])]
    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(TNP_angle_mean),string(TNP_TOA_ref_mean),string(TNP_Data0064_size[4]),string(TNP_TOA_ref_count)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(mean(temporary(TNP_lon))))+STRCOMPRESS(string(mean(temporary(TNP_lat))))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
    TNP_coor_angle_data=[[[temporary(TNP_sz_angle)]],[[temporary(TNP_sa_angle)]],[[temporary(TNP_vz_angle)]],[[temporary(TNP_va_angle)]],[[temporary(TNP_ra_angle)]],[[temporary(TNP_sca_angle)]]]
    poss=[temporary(pos),temporary(cloud_pos),temporary(TNP_pos),temporary(fillvalue_pos_i),temporary(TNP_NotNaN_pos_i),temporary(TNP_NotNaN_pos)]
    
    TOA_ref=!null
    TOA_ref_angle=!null 
    TNP_TOA_ref_angle=!null   
    cloud_data=!null
    TNP_angle_mean=!null
    TNP_TOA_ref_mean=!null
    TNP_TOA_ref_count=!null
    TNP_coor_angle_data=!null      
    poss=!null 
  endfor
  free_lun,lun
  print,'所有文件提取完成'
end