;coding=GB2312
;�ռ�ƥ��
function Spatial_matching,extract_lon,extract_lat,lon,lat
  x=(lon-extract_lon)
  y=(lat-extract_lat)
  distance=sqrt(x^2+y^2)
  min_dis=min(distance)
  pos=where(distance eq min_dis)
  return,pos
end

;��ȡ���ݼ�����
function get_hdf5_data,hd_name,filename
  file_id = H5F_OPEN(hd_name)
  dataset_id=H5D_OPEN(file_id,filename)
  data=H5D_READ(dataset_id)
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end

;��ȡ���ݼ���ǩ����ֵ
;hd_name=�ļ�·�����ƣ�filename=���ݼ������ǩ���ƣ�attr_name=�����ǩ����������
function get_hdf5_attr_data,hd_name,filename,attr_name
  file_id = H5F_OPEN(hd_name)
  dataset_id=H5D_OPEN(file_id,filename)
  attr_id=H5A_OPEN_Name(dataset_id,attr_name)
  data=H5A_READ(attr_id) ;��ȡ����ֵ
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end

;���䶨��
pro Radiometric_Calibration

  Bejing_lon=116.381
  Beijin_lat=39.977
  ;spoint=MAKE_ARRAY(file_n,/L64)
  ;input_directory='D:\FY3D\A202203090585162088'
  input_directory='D:\01�о���ѧϰ\05FY-3D����\data'
  out_directory='D:\01�о���ѧϰ\05FY-3D����\data\'
  dir_test=file_test(out_directory,/directory)
  if dir_test eq 0 then begin
    file_mkdir,out_directory
  endif
  
  ;��ȡ̫���춥��
  file_list_Geo=file_search(input_directory,'*_GEO1K_MS.HDF',count=file_n_Geo)
  sz=MAKE_ARRAY([2048,2000,file_n_Geo],/integer) ;�洢ÿ���ļ���̫���춥��
  for file_i_Geo=0,file_n_Geo-1 do begin
    starttime=systime(1)
    SZdata=get_hdf5_data(file_list_Geo[file_i_Geo],'/Geolocation/SolarZenith');̫���춥��
    sz[*,*,file_i_Geo]=SZdata
  endfor

 ;���䶨��+TOA����
  file_list=file_search(input_directory,'*_1000M_MS.HDF',count=file_n)
  for file_i=0,file_n-1 do begin
    starttime=systime(1)
    file_id=H5F_OPEN(file_list[file_i]) 
    earthsun_distance_ratio_id= H5A_OPEN_Name(file_id,'EarthSun Distance Ratio')
    earthsun_distance_ratio=H5A_READ(earthsun_distance_ratio_id) ;��ȡ�յؾ���
    band_data=get_hdf5_data(file_list[file_i],'/Data/EV_1KM_RefSB') ;��ȡȫ�����ε�DNֵ��5-19���Σ�
    band_data_size=size(band_data)
    ;print,band_data_size
    band_data_ref=fltarr(band_data_size[1],band_data_size[2],band_data_size[3])
    TOA_data=fltarr(band_data_size[1],band_data_size[2],band_data_size[3])
    ;nired_data=band_data[*,*,2] ;band7�������Ⲩ�Σ�

    band_slope=get_hdf5_attr_data(file_list[file_i],'/Data/EV_1KM_RefSB','Slope')
    ;nired_slope=band_slope[2]
 
    band_Intercept=get_hdf5_attr_data(file_list[file_i],'/Data/EV_1KM_RefSB','Intercept')
    ;nired_Intercept=band_Intercept[2]
    
    caldata=get_hdf5_data(file_list[file_i],'/Calibration/VIS_Cal_Coeff')
    cal_0=caldata[0,*]
    cal_1=caldata[1,*]
    cal_2=caldata[2,*]
    
    ;nired_cal_0=cal_0[6]
    ;nired_cal_1=cal_1[6]
    ;nired_cal_2=cal_2[6]
    
    sz_data=sz[*,*,file_i]
    sz_data=((sz_data ge 0) and (sz_data le 18000))*sz_data/100.0  ;�ļ��е��춥�Ƿ�ΧΪ0-18000,��Ҫ��100
   
   ;����ÿ�����ε�TOA
    for layer_i=0,band_data_size[3]-1 do begin
      dn_band= ((band_data[*,*,layer_i] ge 0) and (band_data[*,*,layer_i] le 4095))*band_data[*,*,layer_i]*band_slope[layer_i]+band_Intercept[layer_i]
      band_data_ref[*,*,layer_i]=cal_2[layer_i+4]*dn_band^2.0+cal_1[layer_i+4]*dn_band+cal_0[layer_i+4]
      TOA_data[*,*,layer_i]=(earthsun_distance_ratio[0]^2*band_data_ref[*,*,layer_i])/cos(sz_data)
      print,TOA_data[0,0,layer_i]
    endfor
     
    ;�ļ�д��
    output_dat_name=out_directory+file_basename(file_list[file_i],'.hdf')+'_rc.dat'
    openw,1,output_dat_name
    writeu,1,TOA_data
    free_lun,1
    dn_band=!null
    band_data_ref=!null
    TOA_data=!null
   
    ;dn_nired=nired_slope*(nired_data-nired__Intercept)
    ;TOA_nired=(nired_cal_2*dn_nired^2.0+nired_cal_1*dn_nired+nired_cal_0)/COS(sz[*,*,file_i])
    ;print,TOA_nired[0,0]
    print,'��'+STRCOMPRESS(string(file_i+1))+'���ļ����ѵ�ʱ��Ϊ:'+STRCOMPRESS(string(systime(1)-starttime)) 
    ;a=JULDAY(1,1,)
  endfor
end