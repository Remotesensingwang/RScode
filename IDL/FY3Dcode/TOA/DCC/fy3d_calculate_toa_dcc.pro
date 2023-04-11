;coding=utf-8
;*****************************************************
;DCC提取
;范围：（-20S - +20N   85E - 125E）
;注意 这里限制了TOA的数据，其中对于于 0.8 以下的云反射率的观测值被丢弃
;*****************************************************

pro fy3d_calculate_toa_DCC,input_directory=input_directory
  compile_opt idl2
  ;input_directory='F:\FY_DCC\hdf'
  DestPath='H:\00data\FY3D\DCC\L1_data_NAN\2019'
  ;out_directory='F:\FY_DCC\tiff\cloutiff\'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'H:\00data\FY3D\DCC\TOA\0.0\DCC_fy-0.0.txt',/get_lun,/append,width=500
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
    ;hour=fix(strmid(datetime,8,2))
    ;获取GEO文件的经纬度及四个角度数据
    basefile_i_geo=file_basename(file_list_hdf[file_i_hdf])
    strput, basefile_i_geo, "GEO1K_MS.HDF",33 ;字符串替换
    file_i_geo= input_directory+'\'+basefile_i_geo
    lat=get_hdf5_data(file_i_geo,'/Geolocation/Latitude')
    lon=get_hdf5_data(file_i_geo,'/Geolocation/Longitude')
    ;pos=Spatial_matching(DCC_lon,DCC_lat,lon,lat) ;获取距离站点最近的经纬度下标
    sz_angle=get_hdf5_data(file_i_geo,'/Geolocation/SolarZenith')*0.01;太阳天顶角
    sa_angle=get_hdf5_data(file_i_geo,'/Geolocation/SolarAzimuth')*0.01;太阳方位角
    vz_angle=get_hdf5_data(file_i_geo,'/Geolocation/SensorZenith')*0.01;观测天顶角
    va_angle=get_hdf5_data(file_i_geo,'/Geolocation/SensorAzimuth')*0.01;观测方位角
    ra_angle = abs(sa_angle - va_angle)
    ra_angle = (ra_angle le 180.0) * ra_angle + (ra_angle gt 180.0) * (360.0 - ra_angle)  ;相对方位角
    

    ;*******************************DCC范围的数据********************************************
    pos=where((lon ge 85.0) and (lon le 125.0) and (lat ge -20.0) and (lat le 20.0),count)
    lon_size=size(lon)
    ;提取DCC范围的行列号
    data_col=lon_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)

    ;提取DCC范围的经纬度、几何角度信息
    DCC_lon=lon[col_min:col_max,line_min:line_max]
    DCC_lat=lat[col_min:col_max,line_min:line_max]
    DCC_sz_angle=sz_angle[col_min:col_max,line_min:line_max]
    DCC_sa_angle=sa_angle[col_min:col_max,line_min:line_max]
    DCC_vz_angle=vz_angle[col_min:col_max,line_min:line_max]
    DCC_va_angle=va_angle[col_min:col_max,line_min:line_max]
    DCC_ra_angle=ra_angle[col_min:col_max,line_min:line_max]
    coor_angle_data=[[[sz_angle]],[[temporary(sa_angle)]],[[temporary(vz_angle)]],[[temporary(va_angle)]],[[temporary(ra_angle)]],[[temporary(lon)]],[[temporary(lat)]]]
    
    if  count eq 0 or (col_max-col_min) lt 3 or (line_max-line_min) lt 3 then begin
      file_delete,[file_list_hdf[file_i_hdf],file_i_geo]
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC范围提取失败,并删除成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif
    
    
    ;*****************************************************计算TOA(1-19波段)*****************************************************
    fy3d_level1b_read,file_list_hdf[file_i_hdf],sz_angle=temporary(sz_angle),TOA_ref,/reflectance

    TOA_ref_angle=[[[TOA_ref]],[[temporary(coor_angle_data)]]] ;TOA_ref_angle为全幅影像，全波段的数据
    DCC_TOA_ref_angle=TOA_ref_angle[col_min:col_max,line_min:line_max,*] ;DCC_TOA_ref_angle为DCC范围的全波段数据
    ;write_tiff,'F:\FY_DCC\tiff\basetiff\'+datetime+'TOA_Base.tiff',DCC_TOA_ref_angle,planarconfig=2,compression=1,/float;,GEOTIFF=GEOTIFF

    ;*****************************************************去云处理 只处理DCC范围的*************************************************************
    DBDT_DCC_FY3D,file_list_hdf[file_i_hdf],DCC_TOA_ref_angle,cloud_data,col_min=col_min,col_max=col_max,line_min=line_min,line_max=line_max,/area

    cloud_pos=where(cloud_data ne 0)
    DCC_pos=where(cloud_data eq 0,count_DCC_pos)

    if count_DCC_pos eq 0  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC范围数据为NAN,并移动成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;处理1-19波段的数据
    DCC_TOA_ref_mean=[]
    ;DCC_TOA_ref_std=[]
    DCC_TOA_ref_count=[]
    DCC_TOA_ref_angle_size=size(DCC_TOA_ref_angle)
    std=fltarr(DCC_TOA_ref_angle_size[1],DCC_TOA_ref_angle_size[2],22)    
    
    for layer_i=0,18 do begin
      DCC_TOA_ref=DCC_TOA_ref_angle[*,*,layer_i]
      
      ;ss1=get_std(DCC_TOA_ref,3,3)
      ;std[*,*,layer_i]=ss1 
                     
      fillvalue_pos=where(DCC_TOA_ref le 0 or DCC_TOA_ref ge 1 or $ 
        ~FINITE(get_std(DCC_TOA_ref,3,3)) or get_std(DCC_TOA_ref,3,3) ge 0.02,count)
      if count gt 0 then   DCC_TOA_ref[fillvalue_pos]=!values.F_NAN
      DCC_TOA_ref[cloud_pos]=!VALUES.F_NAN      
      DCC_TOA_ref_mean=[DCC_TOA_ref_mean,mean(DCC_TOA_ref,/nan)]
      ;DCC_TOA_ref_std=[DCC_TOA_ref_std,stddev(DCC_TOA_ref,/nan)]
      DCC_NotNaN_pos_i=WHERE(FINITE(DCC_TOA_ref),count_notnan)
      DCC_TOA_ref_count=[DCC_TOA_ref_count,count_notnan]
      DCC_TOA_ref_angle[*,*,layer_i]=temporary(DCC_TOA_ref)
    endfor
    ;write_tiff,out_directory+datetime+'std.tiff',std,planarconfig=2,compression=1,/float;,GEOTIFF=GEOTIFF
    ;write_tiff,out_directory+datetime+'TOA_cloud-0.0.tiff',DCC_TOA_ref_angle,planarconfig=2,compression=1,/float;,GEOTIFF=GEOTIFF


    DCC_Data0065=DCC_TOA_ref_angle[*,*,2]
    DCC_Data0065_size=size(DCC_Data0065)
    NotNaN_pos=WHERE(FINITE(temporary(DCC_Data0065)),count_notnan1)

    if count_notnan1 le 100  then begin
      file_move,file_list_hdf[file_i_hdf],DestPath
      file_move,file_i_geo,DestPath
      print,file_basename(file_list_hdf[file_i_hdf])+'DCC范围数据为NAN1，并移动成功'+string(file_n_hdf-file_i_hdf-1)
      continue
    endif

    ;*****************************************************获取DCC范围内各波段表观反射率的均值 *****************************************************

    DCC_angle_mean=[mean(DCC_sz_angle[NotNaN_pos]),mean(DCC_sa_angle[NotNaN_pos]),mean(DCC_vz_angle[NotNaN_pos]),mean(DCC_va_angle[NotNaN_pos]),mean(DCC_ra_angle[NotNaN_pos])]

    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(DCC_angle_mean),string(DCC_TOA_ref_mean),string(DCC_Data0065_size[4]),string(DCC_TOA_ref_count)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(mean(temporary(DCC_lon))))+STRCOMPRESS(string(mean(temporary(DCC_lat))))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
    
    
    poss=[temporary(pos),temporary(cloud_pos),temporary(DCC_pos),temporary(fillvalue_pos),temporary(DCC_NotNaN_pos_i),temporary(NotNaN_pos)]
    DCC_coor_angle_data=[[[temporary(DCC_sz_angle)]],[[temporary(DCC_sa_angle)]],[[temporary(DCC_vz_angle)]],[[temporary(DCC_va_angle)]],[[temporary(DCC_ra_angle)]]]
    
    TOA_ref=!null
    TOA_ref_angle=!null
    DCC_TOA_ref_angle=!null
    cloud_data=!null

    DCC_angle_mean=!null
    DCC_TOA_ref_mean=!null
    DCC_TOA_ref_count=!null
    poss=!null
    DCC_coor_angle_data=!null
;    DCC_TOA_ref_std=!null
  endfor
  free_lun,lun
  print,'所有文件提取完成'
end