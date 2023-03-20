;coding=utf-8
;*****************************************************
;提取41-42N,94-95E范围的数据
;进行BLT重投影（波段选择的是FY3D TOA数据的前7个波段）
;*****************************************************

pro fy3d_glt
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init
  input_directory='H:\00data\FY3D\FY3D_dunhuang\2019'
  ;input_directory='F:\FYdata\fy3d\2021'
  output_directory='H:\00data\TOA\FY3D\tiff\'
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  ;openw,lun,'H:\00data\TOA\FY3D\removecloud\fycloudpro\2021\1kmstd\dh_toa2021_fy3d_1km_NAN00.txt',/get_lun,/append,width=500

  ;敦煌定标场中心坐标
  dh_lon=94.4     ;94.32083333333334      ;94.27
  dh_lat=40.1     ;40.1375                ;40.18
  file_list_hdf=file_search(input_directory,'*_1000M_MS.HDF',count=file_n_hdf)

  ;*****************************************************文件批处理 *****************************************************
  for file_i_hdf=0,file_n_hdf-1 do begin
    start_time=systime(1)
    result_name=output_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+'_geo.tiff'
    ;获取文件的时间
    datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),19,8)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),28,4)

    ;获取GEO文件的经纬度及四个角度数据
    basefile_i_geo=file_basename(file_list_hdf[file_i_hdf])
    strput, basefile_i_geo, "GEO1K_MS.HDF",33 ;字符串替换
    file_i_geo= input_directory+'\'+basefile_i_geo
    Latdata=get_hdf5_data(file_i_geo,'/Geolocation/Latitude')
    Longdata=get_hdf5_data(file_i_geo,'/Geolocation/Longitude')
    ;pos=Spatial_matching(dh_lon,dh_lat,Longdata,Latdata) ;获取距离站点最近的经纬度下标
    szdata=get_hdf5_data(file_i_geo,'/Geolocation/SolarZenith')*0.01;太阳天顶角
    sadata=get_hdf5_data(file_i_geo,'/Geolocation/SolarAzimuth')*0.01;太阳方位角
    vzdata=get_hdf5_data(file_i_geo,'/Geolocation/SensorZenith')*0.01;观测天顶角
    vadata=get_hdf5_data(file_i_geo,'/Geolocation/SensorAzimuth')*0.01;观测方位角

    ;*****************************************************计算TOA(1-19波段)*****************************************************
    fy3d_level1b_read,file_list_hdf[file_i_hdf],szdata=szdata,toadata,/reflectance

    ;*****************************************************去云处理*************************************************************
    fy3d_cloud_pro,file_list_hdf[file_i_hdf],toadata,clouddata

    toadata_size=size(toadata)
    cloudpos=where(clouddata ne 0)

    for layer_i=0,toadata_size[3]-1 do begin
      data=toadata[*,*,layer_i]
      data[cloudpos]=!VALUES.F_NAN
      ;data[cloudpos]=-100
      toadata[*,*,layer_i]=data
    endfor


    pos=where((Longdata ge 94) and (Longdata le 95) and (Latdata ge 40) and (Latdata le 41),count)
    if count eq 0 then continue
    data_size=size(toadata)
    data_col=data_size[1]
    pos_col=pos mod data_col
    pos_line=pos/data_col
    col_min=min(pos_col)
    col_max=max(pos_col)
    line_min=min(pos_line)
    line_max=max(pos_line)

    out_lon=output_directory+'lon_out.tiff'
    out_lat=output_directory+'lat_out.tiff'
    out_target=output_directory+'target.tiff'
    write_tiff,out_lon,Longdata[col_min:col_max,line_min:line_max],/float
    write_tiff,out_lat,Latdata[col_min:col_max,line_min:line_max],/float
    write_tiff,out_target,toadata[col_min:col_max,line_min:line_max,*],planarconfig=2,compression=1,/float

    envi_open_file,out_lon,r_fid=lon_fid;打开经度数据，获取经度文件id
    envi_open_file,out_lat,r_fid=lat_fid;打开纬度数据，获取纬度文件id
    envi_open_file,out_target,r_fid=target_fid;打开目标数据，获取目标文件id

    out_name_glt=output_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+'_glt.img'
    out_name_glt_hdr=output_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+'_glt.hdr'
    input_proj=envi_proj_create(/geographic)
    output_proj=envi_proj_create(/geographic)
    envi_glt_doit,$
      x_fid=lon_fid,y_fid=lat_fid,x_pos=0,y_pos=0,i_proj=input_proj,$;指定创建GLT所需输入数据信息
      o_proj=output_proj,pixel_size=pixel_size,rotation=0.0,out_name=out_name_glt,r_fid=glt_fid;指定输出GLT文件信息

    out_name_geo=output_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+'_georef.img'
    out_name_geo_hdr=output_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+'_georef.hdr'
    envi_georef_from_glt_doit,$
      glt_fid=glt_fid,$;指定重投影所需GLT文件信息
      fid=target_fid,pos=[0,1,2,3,4,5,6],$;指定待投影数据id
      out_name=out_name_geo,background=!VALUES.F_NAN,r_fid=geo_fid;指定输出重投影文件信息


    map_info=envi_get_map_info(fid=geo_fid)
    geo_loc=map_info.(1)
    px_size=map_info.(2)
    envi_file_query,geo_fid,dims=data_dims
    target_data=MAKE_ARRAY(data_dims[2]-data_dims[1]+1,data_dims[4]-data_dims[3]+1,7,value=!VALUES.F_NAN,/float)
    for band=0,6 do begin
      target_data[*,*,band]=envi_get_data(fid=geo_fid,pos=band,dims=data_dims)
    endfor
    
    ;    print,geo_loc,px_size
    geo_info={$
      MODELPIXELSCALETAG:[px_size[0],px_size[1],0.0],$;X,Y,Z方向的像元分辨率
      MODELTIEPOINTTAG:[0.0,0.0,0.0,geo_loc[2],geo_loc[3],0.0],$
      ;坐标转换信息，前三个0.0代表栅格图像上的第0，0，0个像元位置（z方向一般不存在），
      ;后面-180.0代表x方向第0个位置对应的经度是-180.0度，90.0代表y方向第0个位置对应的经度是90.0度。
      GTMODELTYPEGEOKEY:2,$
      GTRASTERTYPEGEOKEY:1,$
      GEOGRAPHICTYPEGEOKEY:4326,$
      GEOGCITATIONGEOKEY:'GCS_WGS_1984',$
      GEOGANGULARUNITSGEOKEY:9102,$
      GEOGSEMIMAJORAXISGEOKEY:6378137.0,$
      GEOGINVFLATTENINGGEOKEY:298.25722}
    write_tiff,result_name,target_data,planarconfig=2,compression=1,/float,geotiff=geo_info

    envi_file_mng,id=lon_fid,/remove
    envi_file_mng,id=lat_fid,/remove
    envi_file_mng,id=target_fid,/remove
    envi_file_mng,id=glt_fid,/remove
    envi_file_mng,id=geo_fid,/remove
    file_delete,[out_lon,out_lat,out_target,out_name_glt,out_name_glt_hdr,out_name_geo,out_name_geo_hdr]
    end_time=systime(1)
    print,'The GLT file creating time is:'+strcompress(string(end_time-start_time))+' s'

    szdata=!null
    sadata=!null
    vzdata=!null
    vadata=!null
    toadata=!null
    clouddata=!null

  endfor
  envi_batch_exit,/no_confirm
  ;free_lun,lun
  print,'所有文件提取完成'
end