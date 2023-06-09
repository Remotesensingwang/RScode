function hdf4_data_get,file_name,sds_name
  sd_id=hdf_sd_start(file_name,/read)
  sds_index=hdf_sd_nametoindex(sd_id,sds_name)
  sds_id=hdf_sd_select(sd_id,sds_index)
  hdf_sd_getdata,sds_id,data
  hdf_sd_endaccess,sds_id
  hdf_sd_end,sd_id
  return,data
end

function hdf4_attdata_get,file_name,sds_name,att_name
  sd_id=hdf_sd_start(file_name,/read)
  sds_index=hdf_sd_nametoindex(sd_id,sds_name)
  sds_id=hdf_sd_select(sd_id,sds_index)
  att_index=hdf_sd_attrfind(sds_id,att_name)
  hdf_sd_attrinfo,sds_id,att_index,data=att_data
  hdf_sd_endaccess,sds_id
  hdf_sd_end,sd_id
  return,att_data
end

pro modis_swath_glt_tiff_area
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init

  input_directory='C:\Users\lenovo\Downloads\DCC'
  ;output_directory='H:\00data\MODIS\MODIS_L1data\tifout\removecsw\2019\'
  output_directory='C:\Users\lenovo\Downloads\DCC\tiff\'
  directory_exist=file_test(output_directory,/directory)
  if (directory_exist eq 0) then begin
    file_mkdir,output_directory
  endif

  file_list_hdf=file_search(input_directory,'*.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    start_time=systime(1)
    result_name=output_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+"_geo.tiff"
    ;获取文件的时间、经纬度、四个角度
    datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),10,7)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),18,4)
    latdata=get_hdf_dataset(file_list_hdf[file_i_hdf],'Latitude')
    Longdata=get_hdf_dataset(file_list_hdf[file_i_hdf],'Longitude')
    ;printf,lun,strcompress(latdata,/remove_all)
    szdata=get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarZenith')*0.01
    sadata=get_hdf_dataset(file_list_hdf[file_i_hdf],'SolarAzimuth')*0.01
    vzdata=get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorZenith')*0.01
    vadata=get_hdf_dataset(file_list_hdf[file_i_hdf],'SensorAzimuth')*0.01


    ;获取1-19波段,26波段的DN值
    EV_250_RefSB_data=get_hdf_dataset(file_list_hdf[file_i_hdf],'EV_250_Aggr1km_RefSB') ;1-2波段

    ;获取SI数据的列、行号（有时行号为2030，有时为2040）
    DN_band_data_size=size(EV_250_RefSB_data)

    ;经纬度、四个角度数据重采样 插值方法为双线性插值法（interp）
    x_size=DN_band_data_size[1]  ;列
    y_size=DN_band_data_size[2]  ;行
    Latdata=congrid(Latdata,x_size,y_size,/interp)
    Longdata=congrid(Longdata,x_size,y_size,/interp)
    szdata=congrid(szdata,x_size,y_size,/interp)
    sadata=congrid(sadata,x_size,y_size,/interp)
    vzdata=congrid(vzdata,x_size,y_size,/interp)
    vadata=congrid(vadata,x_size,y_size,/interp)
    
    MYD021KM_level1b_read,file_list_hdf[file_i_hdf],szdata=szdata,toadata,/reflectance
    ;去云去雪去水体处理
;    dbdt_cloud,file_list_hdf[file_i_hdf],clouddata
;    cloudpos=where(clouddata ne 0)
;    for layer_i=0,6 do begin
;      data=toadata[*,*,layer_i]
;      data[cloudpos]=!VALUES.F_NAN
;      toadata[*,*,layer_i]=data
;    endfor   
    pos=where((Longdata ge 170.0) or (Longdata le -160.0) and (Latdata ge -20.0) and (Latdata le 20.0),count)
    if count eq 0 then continue ;969874 [969874]
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
    write_tiff,out_target,toadata[col_min:col_max,line_min:line_max,0:6],planarconfig=2,compression=1,/float

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
  endfor
  envi_batch_exit,/no_confirm
end