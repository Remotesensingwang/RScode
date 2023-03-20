;coding=utf-8
;查找距离站点最近的坐标值下标
function Spatial_matching,extract_lon,extract_lat,lon,lat
  x=(lon-extract_lon)
  y=(lat-extract_lat)
  distance=sqrt(x^2+y^2)
  min_dis=min(distance)
  pos=where(distance eq min_dis)
  
  ;pos_col=pos mod 2048 ;pos的列（类型为数组）
  ;pos_line=pos/2048    ;pos的行（类型为数组）
  ;print,londata[pos_col,pos_line]
  ;print,[pos_col,pos_line]
  ;print,pos 
  return,pos
end

;读取数据集数据
function get_hdf5_data,hd_name,filename
  file_id = H5F_OPEN(hd_name)
  dataset_id=H5D_OPEN(file_id,filename)
  data=H5D_READ(dataset_id)
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end

;读取数据集标签属性值
;hd_name=文件路径名称，filename=数据集具体标签名称，attr_name=具体标签的属性名称
function get_hdf5_attr_data,hd_name,filename,attr_name
  file_id = H5F_OPEN(hd_name)
  dataset_id=H5D_OPEN(file_id,filename)
  attr_id=H5A_OPEN_Name(dataset_id,attr_name)
  data=H5A_READ(attr_id) ;获取属性值
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end

;获取太阳天顶角+站点匹配
function get_Geo_info,file,Bejing_lon,Beijin_lat
  Latdata=get_hdf5_data(file,'/Geolocation/Latitude')
  Londata=get_hdf5_data(file,'/Geolocation/Longitude')
  pos=Spatial_matching(Bejing_lon,Beijin_lat,Londata,Latdata)
  szdata=get_hdf5_data(file,'/Geolocation/SolarZenith')*0.01*!pi /180.00E ;太阳天顶角
  print,STRCOMPRESS(string(file_basename(file)))+'文件的经纬度为:'+STRCOMPRESS(string(Londata[pos]))+STRCOMPRESS(string(Latdata[pos]))
  return,{file_pos:pos,$
    file_szdata:szdata}
end


;计算1-4+7波段的TOA数据值
function get_TOAdata,file,szdata
  file_id=H5F_OPEN(file)
  earthsun_distance_ratio_id= H5A_OPEN_Name(file_id,'EarthSun Distance Ratio')
  earthsun_distance_ratio=H5A_READ(earthsun_distance_ratio_id);获取日地距离
  refSB_band1000m_data=get_hdf5_data(file,'/Data/EV_1KM_RefSB');获取5-19波段的DN值
  refSB_band250m_data=get_hdf5_data(file,'/Data/EV_250_Aggr.1KM_RefSB');获取1-4波段的DN值
  b7_data=refSB_band1000m_data[*,*,2]   ;获取B7波段的DN值
  
  ;获得每个波段的slpe和Intercept属性值（1-4波段）（5-19波段）
  refSB_band250m_slope=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_RefSB','Slope')
  refSB_band250m_Intercept=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_RefSB','Intercept')
  refSB_band1000m_slope=get_hdf5_attr_data(file,'/Data/EV_1KM_RefSB','Slope')
  refSB_band1000m_Intercept=get_hdf5_attr_data(file,'/Data/EV_1KM_RefSB','Intercept')

  ;获取定标值（1-19波段）
  caldata=get_hdf5_data(file,'/Calibration/VIS_Cal_Coeff')
  cal_0=caldata[0,*]
  cal_1=caldata[1,*]
  cal_2=caldata[2,*]

  band_data_size=size(refSB_band250m_data)

  ;存储读取的1-4，7波段的Ref与AOD数据
  band_data_ref=fltarr(band_data_size[1],band_data_size[2],band_data_size[3]+1)
  TOA_data=fltarr(band_data_size[1],band_data_size[2],band_data_size[3]+1)
  
  for layer_i=0,band_data_size[3]-1 do begin
    band_data_dn=((refSB_band250m_data[*,*,layer_i] ge 0) and (refSB_band250m_data[*,*,layer_i] le 4095))*refSB_band250m_data[*,*,layer_i]*refSB_band250m_slope[layer_i]+refSB_band250m_Intercept[layer_i]
    band_data_ref[*,*,layer_i]=cal_2[layer_i]*band_data_dn^2.0+cal_1[layer_i]*band_data_dn+cal_0[layer_i]
    ;s=cos(szdata[*,*,file_i_hdf])
    ;TOA_data[*,*,layer_i]=band_data_ref[*,*,layer_i]/cos(szdata)
    TOA_data[*,*,layer_i]=(earthsun_distance_ratio[0]^2*band_data_ref[*,*,layer_i])/cos(szdata)*0.01
    ;print,min(TOA_data[*,*,layer_i])
    ;print,max(TOA_data[*,*,layer_i])
  endfor
  
  b7_data_dn=((b7_data ge 0) and (b7_data le 4095))*b7_data*refSB_band1000m_slope[2]+refSB_band1000m_Intercept[2]
  b7_data_ref=cal_2[6]*b7_data_dn^2.0+cal_1[6]*b7_data_dn+cal_0[6]
  TOA_data[*,*,4]=(earthsun_distance_ratio[0]^2*b7_data_ref)/cos(szdata)*0.01
  band_data_ref[*,*,4]=b7_data_ref
  return,TOA_data
end

;以站点为中心取pixs*pixs个数据（pixs为奇数）
function get_spmatching_data,arr,pixs,xloc,yloc
  iw=intarr(pixs)+1  ;3   3/2=1
  m=indgen(pixs)-pixs/2 ;3 3/2=1
  mx=m#iw
  my=iw#m
  arrsize=size(arr)
  if (xloc gt pixs/2)&&(yloc ge pixs/2)&& $
    (xloc le arrsize[1]-pixs/2)&&(yloc ge pixs/2)&& $
    (xloc gt pixs/2)&&(yloc le arrsize[2]-pixs/2)&& $
    (xloc le arrsize[1]-pixs/2)&&(yloc le arrsize[2]-pixs/2) then begin
    data=arr[xloc+mx,yloc+my]
  endif else begin
    data=!VALUES.F_NAN
  endelse
  return,data
end


pro Spatial_matching_Demo
  compile_opt idl2  
  ;input_directory='D:\01研究生学习\05FY-3D数据\data'
  input_directory='D:\02FY3D\A202203090585162088'
  ;out_directory='D:\01研究生学习\05FY-3D数据\data\out\'
  out_directory='D:\02FY3D\A202203090585162088\out\'
  dir_test=file_test(out_directory,/directory)
  
  if dir_test eq 0 then begin
    file_mkdir,out_directory
  endif
  
  Bejing_lon=116.31667;116.381
  Beijin_lat=39.93333;39.977
  
  file_list_geo=file_search(input_directory,'*_GEO1K_MS.HDF',count=file_n_geo)
  szdata=MAKE_ARRAY([2048,2000,file_n_geo],/float) ;存储每个文件的太阳天顶角
  pointdata=MAKE_ARRAY(file_n_geo,/L64)
  szdatasize=size(szdata)
  starttime=systime(1)
  for file_i_Geo=0,file_n_geo-1 do begin
    geoinfo=get_Geo_info(file_list_geo[file_i_Geo],Bejing_lon,Beijin_lat)
    szdata[*,*,file_i_Geo]=geoinfo.file_szdata   ;获取每个HDF文件的太阳天顶角数据
    pointdata[file_i_Geo]=geoinfo.file_pos     ;获取每个文件与站点最近的经纬度数据下标
  endfor
  print,'经纬度 提取完成 耗时'+string(systime(1)-starttime)
  
 
  file_list_hdf=file_search(input_directory,'*_1000M_MS.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    TOAdata=get_TOAdata(file_list_hdf[file_i_hdf],szdata[*,*,file_i_hdf])
    ;help,TOAdata
    
    ;获取pos具体所对应的列，行号,可应用于数据的提取（截取）
    londata_col=szdatasize[1]
    pos_col=pointdata[file_i_hdf] mod londata_col ;pos的列（类型为数组）
    pos_line=pointdata[file_i_hdf]/londata_col    ;pos的行（类型为数组）
    ;print,londata[pos_col,pos_line]
    ;print,[pos_col,pos_line]
    ;print,TOAdata[pos_col,pos_line,0]
    TOAdata_size=size(TOAdata)
    pixs_TOAdata=MAKE_ARRAY(13,13,TOAdata_size[3],/float)

    for band=0,TOAdata_size[3]-1 do begin
      pixs_TOAdata[*,*,band]=get_spmatching_data(TOAdata[*,*,band],13,pos_col[0],pos_line[0])
    endfor
    if FINITE(pixs_TOAdata[0]) then begin ;判段第一个数组是否为NAN，若不是返回1，即为真
      result_tiff_name=out_directory+file_basename(file_list_hdf[file_i_hdf],'.hdf')+'_TOA.tif'
      write_tiff,result_tiff_name,pixs_TOAdata,planarconfig=2,/float   ;planarconfig=2(BSQ) 说明导入的数据是（列，行，通道数）这也是IDL的常用的，用envi打开格式为（2048 x 2000 x 4）,matlab打开格式为（2000，2048，4）
      print,file_basename(file_list_hdf[file_i_hdf])+'提取完成 耗时'+string(systime(1)-starttime1)
    endif else begin
      print,file_basename(file_list_hdf[file_i_hdf])+'提取失败 耗时'+string(systime(1)-starttime1)
    endelse
    TOAdata=!null
    pixs_TOAdata=!null 
  endfor
  szdata=!null
  pointdata=!null
  print,'所有文件提取完成'
end