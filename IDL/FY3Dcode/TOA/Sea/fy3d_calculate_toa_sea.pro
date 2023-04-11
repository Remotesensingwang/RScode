;coding=utf-8
;*****************************************************
;先提取海洋地区范围的TOA数据，并对海洋地区范围内的数据进行去云处理
;范围选取：10-20N 150-65E
;*****************************************************

pro fy3d_calculate_toa_sea,input_directory=input_directory
  compile_opt idl2
  ;input_directory='F:\FY3D_Sea\2019\HDF'
  input_directory='E:\fysea\201912'
  ;out_directory='F:\FY3D_Sea\2019\tiff\cloudtiff\SCA_0022_std0020\'
  ;out_directory='F:\FY3D_Sea\2019\tiff\cloudtiff\SCA_0030_std0010_red0039\'
  DestPath='E:\fysea\NAN'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'E:\fysea\TNP_fy3d_2019.txt',/get_lun,/append,width=500

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
    strput, basefile_i_geo, "GEO1K_MS.HDF",33 ;字符串替换     ;basefile_i_geo=basefile_i.Replace('MYD021KM','MYD03')
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
        
    sca_angle_cos = (cos(vz_angle * !DTOR) * cos(sz_angle * !DTOR) + sin(vz_angle * !DTOR) * sin(sz_angle * !DTOR) * cos(ra_angle * !DTOR))
    sca_angle = acos(sca_angle_cos) / !DTOR   ;太阳耀斑角
    
;    coor_angle_data=[[[sz_angle]],[[sa_angle]],[[vz_angle]],[[va_angle]],[[ra_angle]],[[sca_angle]],[[lon]],[[lat]]]
           
    ;*******************************提取海洋范围的数据********************************************
    pos=where((lon ge 150.0) and (lon le 165.0) and (lat ge 10.0) and (lat le 20.0),count)
    lon_size=size(lon)
    ;提取海洋地区范围的行列号
    data_col=lon_size[1]
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
    
    ;*****************************************************计算TOA(1-19波段)*****************************************************
    fy3d_level1b_read,file_list_hdf[file_i_hdf],sz_angle=temporary(sz_angle),TOA_ref,/reflectance 
;    fy3d_level1b_read,file_list_hdf[file_i_hdf],sz_angle=sz_angle,TOA_ref,/reflectance         
    TOA_ref_angle=[[[TOA_ref]],[[temporary(coor_angle_data)]]] ;TOA_ref_angle为全幅影像，全波段的数据
    TNP_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*] ;为海洋地区范围的全波段数据,包括经过太阳天顶角校正的可见光波段数据+角度坐标信息
    ;云掩膜，只处理海洋地区范围的
    DBDT_Sea_FY3D,file_list_hdf[file_i_hdf],TNP_TOA_ref_angle,cloud_data
    cloud_pos=where(cloud_data ne 0)
    TNP_pos=where(cloud_data eq 0,TNP_count)

    if TNP_count eq 0 then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'海洋范围数据为NAN,并移动成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;处理前19个波段的数据
    TNP_TOA_ref_mean=[]
    TNP_TOA_ref_count=[]
    for layer_i=0,18 do begin
      TNP_TOA_ref=TNP_TOA_ref_angle[*,*,layer_i]
      fillvalue_pos_i=where(TNP_TOA_ref le 0 or TNP_TOA_ref ge 1,count)
      if count gt 0 then   TNP_TOA_ref[fillvalue_pos_i]=!values.F_NAN
      TNP_TOA_ref[cloud_pos]=!VALUES.F_NAN
      TNP_TOA_ref_mean=[TNP_TOA_ref_mean,mean(TNP_TOA_ref,/nan)]
      TNP_NotNaN_pos_i=WHERE(FINITE(TNP_TOA_ref),count_notnan)
      TNP_TOA_ref_count=[TNP_TOA_ref_count,count_notnan]
      TNP_TOA_ref_angle[*,*,layer_i]=temporary(TNP_TOA_ref)
    endfor

    TNP_Data0065=TNP_TOA_ref_angle[*,*,2]
    TNP_Data0065_size=size(TNP_Data0065)
    TNP_NotNaN_pos=WHERE(FINITE(temporary(TNP_Data0065)),count_notnan1)

    if count_notnan1 eq 100  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'海洋数据有效值不足,并移动成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;获取海洋范围内五个角度的均值
    ;断点添加
    TNP_angle_mean=[mean(TNP_sz_angle[TNP_NotNaN_pos]),mean(TNP_sa_angle[TNP_NotNaN_pos]),$
      mean(TNP_vz_angle[TNP_NotNaN_pos]),mean(TNP_va_angle[TNP_NotNaN_pos]),$
      mean(TNP_ra_angle[TNP_NotNaN_pos]),mean(TNP_sca_angle[TNP_NotNaN_pos])]
    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(TNP_angle_mean),string(TNP_TOA_ref_mean),string(TNP_Data0065_size[4]),string(TNP_TOA_ref_count)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    print,file_basename(file_list_hdf[file_i_hdf])+$
      STRCOMPRESS(string(mean(temporary(TNP_lon))))+STRCOMPRESS(string(mean(temporary(TNP_lat))))+$
      string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
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