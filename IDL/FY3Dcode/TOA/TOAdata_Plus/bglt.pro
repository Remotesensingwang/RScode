;coding=GB2312

;��1��ȡ��γ�����ݼ���Ŀ�����ݼ�
;��2����������ݼ�
;��3����ENVI�ӿڶ�ȡ���ݼ�(envi_ open_ file)
;��4����ENVI�ӿ�����GLT (envi_ _proj_ create, envi_ .glt_ doit)
;��5����ENVI�ӿڴ�GLT��Ŀ�����ݼ�����ͶӰ(envi_ georef_ from_ .glt_ doit)
;��6ɾ���м����ݣ�����Ŀ����



pro Bglt
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init
  
;  file='D:\FY3D\000AAA\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_georef.img'
;  envi_open_file,file,r_fid=fid
;  mapinfor=envi_get_map_info(fid=fid,undefined=uDefined) 
;  if uDefined eq 1 then print '�ļ�������map_info'
;  help,mapinfor
;  ;help,mapinfor.PROJ

  
  
  in_dir='D:\FY3D\A202203090585162088'
  out_directory='D:\FY3D\000AAA\'
  dir_test=file_test(out_directory,/directory)
  if dir_test eq 0 then begin
    file_mkdir,out_directory
  endif
  
  ;��ȡ��γ��
  file_list=file_search(in_dir,'*_GEO1K_MS.HDF',count=file_n)
  lon=MAKE_ARRAY([2048, 2000,file_n],/FLOAT)
  lat=MAKE_ARRAY([2048, 2000,file_n],/FLOAT)
  for file_i=0,file_n-1 do begin
    starttime=systime(1)
    Londata=get_hdf5_data(file_list[file_i],'/Geolocation/Longitude')
    Latdata=get_hdf5_data(file_list[file_i],'/Geolocation/Latitude')
    lon[*,*,file_i]=Londata
    lat[*,*,file_i]=Latdata
    print,'��'+STRCOMPRESS(string(file_i+1))+'���ļ����ѵ�ʱ��Ϊ:'+STRCOMPRESS(string(systime(1)-starttime))
  endfor
  ;help,lat

  ;��ȡ��У��Ӱ��
  file_list1000K=file_search(in_dir,'*1000M_MS.HDF',count=file_1000n)
  for file_i1000K=0,file_1000n-1 do begin
    starttime=systime(1)
    banddata=get_hdf5_data(file_list1000K[file_i1000K],'/Data/EV_1KM_RefSB')
    band5=banddata[*,*,0]
    FY_Londata=lon[*,*,file_i1000K]
    FY_Latdata=lat[*,*,file_i1000K]
    out_lon=out_directory+'outlon.tiff'
    out_lat=out_directory+'outlat.tiff'
    out_targetband=out_directory+'out_targetband.tiff'
    write_tiff,out_lon,FY_Londata,/float
    write_tiff,out_lat,FY_Latdata,/float
    write_tiff,out_targetband,band5,/float
    ;help,banddata

    ;envi�ļ���
    envi_open_file,out_lon,r_fid=x_fid ;�򿪾����ļ�����ȡ����id
    envi_open_file,out_lat,r_fid=y_fid
    envi_open_file,out_targetband,r_fid=target_fid
    
    envi_file_query,x_fid,dims=geodata_dims
    
    ;GLT�ļ����������
    out_name_glt=out_directory+file_basename(file_list1000K[file_i1000K],'.hdf')+'_glt.img'
    out_name_glt_hdr=out_directory+file_basename(file_list1000K[file_i1000K],'.hdf')+'_glt.hdr'
    i_proj=envi_proj_create(/geographic)
    o_proj=envi_proj_create(/geographic)
    envi_glt_doit,$  ;����GLT�ļ�
      i_proj=i_proj,x_fid=x_fid,y_fid=y_fid,x_pos=0,y_pos=0,$ ;ָ������GLT����Ҫ������������Ϣ
      o_proj=o_proj,pixel_size=0.03,rotation=0.0,out_name=out_name_glt,r_fid=glt_fid ;ָ�����GLT�ļ���Ϣ
    
    ;��ͶӰ�ļ����  
    out_name_geo=out_directory+file_basename(file_list1000K[file_i1000K],'.hdf')+'_georef.img'
    out_name_geo_hdr=out_directory+file_basename(file_list1000K[file_i1000K],'.hdf')+'_georef.hdr'
    envi_georef_from_glt_doit,$ ;�ļ���ͶӰ
      glt_fid=glt_fid,$ ;ָ����ͶӰ�����GLT�ļ���Ϣ
      fid=target_fid,pos=0,$ ;ָ����ͶӰ�ļ���Ϣ,pos=0Ϊ��0�㣬���Ϊpos=[0,3,5,6]
      out_name=out_name_geo,r_fid=geo_fid ;ָ�������ͶӰ���ļ���Ϣ
     
     ;����Ϊtiff�ļ�
     result_tiff_name=out_directory+file_basename(file_list1000K[file_i1000K],'.hdf')+'_geo.tiff'
     map_info=envi_get_map_info(fid=geo_fid)
     geo_loc=map_info.(1)
     px_size=map_info.(2)
     envi_file_query,geo_fid,dims=geodata_dims
     target_tiff_data=envi_get_data(fid=geo_fid,pos=0,dims=geodata_dims)
     geo_info={$
       MODELPIXELSCALETAG:[px_size[0],px_size[1],0.0],$
       MODELTIEPOINTTAG:[0.0,0.0,0.0,geo_loc[2],geo_loc[3],0.0],$
       GTMODELTYPEGEOKEY:2,$
       GTRASTERTYPEGEOKEY:1,$
       GEOGRAPHICTYPEGEOKEY:4326,$
       GEOGCITATIONGEOKEY:'GCS_WGS_1984',$
       GEOGANGULARUNITSGEOKEY:9102,$
       GEOGSEMIMAJORAXISGEOKEY:6378137.0,$
       GEOGINVFLATTENINGGEOKEY:298.25722}
     write_tiff,result_tiff_name,target_tiff_data,/float, geotiff=geo_info
     
     ;envi�ļ��ر�
     envi_file_mng,id=x_fid,/remove
     envi_file_mng,id=y_fid,/remove
     envi_file_mng,id=target_fid,/remove
     envi_file_mng,id=glt_fid,/remove
     envi_file_mng,id=geo_fid,/remove
     
     ;envi�м��ļ�ɾ��
     file_delete,[out_lon,out_lat,out_targetband,out_name_glt,out_name_glt_hdr,out_name_geo,out_name_geo_hdr]
     endtime=systime(1)
     print,[out_name_geo,string(endtime-starttime)]
  endfor
  envi_batch_exit,/no_confirm
end