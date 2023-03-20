;coding=GB2312
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
  data=H5A_READ(attr_id)  ;获取属性值
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end


pro hdftotiff
  hdfpath='D:\01研究生学习\05FY-3D数据\data\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS.HDF'
  ;data=get_hdf5_data(hdfpath,'/Data/EV_1KM_RefSB')
  ;size1=data[*,*,[0,1,2,3]]
  ;help,size1
  out_data='D:\01研究生学习\05FY-3D数据\data\hdftotiff111.tif'
;
;  mc=[0.5d,0.5d,142.008d,40.1436d]
;  ps=[1d/3600,1d/3600]
;  ;map_info=envi_map_info_create(/geographic,mc=mc,ps=ps)
;  map_info={$
;    MODELPIXELSCALETAG:[ps[0],ps[1],0.0],$
;    MODELTIEPOINTTAG:[0.0,0.0,0.0,mc[2],mc[3],0.0],$
;    GTMODELTYPEGEOKEY:2,$
;    GTRASTERTYPEGEOKEY:1,$
;    GEOGRAPHICTYPEGEOKEY:4326,$
;    GEOGCITATIONGEOKEY:'GCS_WGS_1984',$
;    GEOGANGULARUNITSGEOKEY:9102,$
;    GEOGSEMIMAJORAXISGEOKEY:6378137.0,$
;    GEOGINVFLATTENINGGEOKEY:298.25722}
  ;planarconfig=2 说明导入的数据是（列，行，通道数）这也是IDL的常用的，用envi打开格式为（2048 x 2000 x 4）,matlab打开格式为（2000，2048，4）
  ;存储方式 BSQ(列，行，通道数),gdal(pixel)   BIP(通道数，列，行) gdal(band)     BIL(列，通道数，行) 按行交错的波段
 ; write_tiff,out_data,size1,planarconfig=2,/float
  ;,GEOTIFF=map_info  
  
  ;tiff读取
  imgdata=read_tiff('E:\IDLcode\python\LC08_L1GT_137032_20190819_20190902_01_T2_B1.TIF')
  
  print,mean(imgdata)
  print,imgdata
  
   ;与mtalab结合的麻烦做法
;  fulldata=reform(size1,4096000,4)
;  fulldatat=transpose(fulldata)
;  write_tiff,out_data,fulldatat,/float

end