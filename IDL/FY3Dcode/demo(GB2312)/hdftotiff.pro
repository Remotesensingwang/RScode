;coding=GB2312
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
  data=H5A_READ(attr_id)  ;��ȡ����ֵ
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end


pro hdftotiff
  hdfpath='D:\01�о���ѧϰ\05FY-3D����\data\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS.HDF'
  ;data=get_hdf5_data(hdfpath,'/Data/EV_1KM_RefSB')
  ;size1=data[*,*,[0,1,2,3]]
  ;help,size1
  out_data='D:\01�о���ѧϰ\05FY-3D����\data\hdftotiff111.tif'
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
  ;planarconfig=2 ˵������������ǣ��У��У�ͨ��������Ҳ��IDL�ĳ��õģ���envi�򿪸�ʽΪ��2048 x 2000 x 4��,matlab�򿪸�ʽΪ��2000��2048��4��
  ;�洢��ʽ BSQ(�У��У�ͨ����),gdal(pixel)   BIP(ͨ�������У���) gdal(band)     BIL(�У�ͨ��������) ���н���Ĳ���
 ; write_tiff,out_data,size1,planarconfig=2,/float
  ;,GEOTIFF=map_info  
  
  ;tiff��ȡ
  imgdata=read_tiff('E:\IDLcode\python\LC08_L1GT_137032_20190819_20190902_01_T2_B1.TIF')
  
  print,mean(imgdata)
  print,imgdata
  
   ;��mtalab��ϵ��鷳����
;  fulldata=reform(size1,4096000,4)
;  fulldatat=transpose(fulldata)
;  write_tiff,out_data,fulldatat,/float

end