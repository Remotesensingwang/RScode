;coding=utf-8
;*****************************************************
;读取HDF数据集标签属性值（变量的属性值）
;*****************************************************

;*****************************************************读取数据集标签属性值****************************************************
;hd_file=文件路径名称，var_name=数据集具体标签名称(变量)，attr_name=具体标签的属性名称（变量的属性值）
function get_hdf5_attr_data,hd_file,var_name,attr_name
  file_id = H5F_OPEN(hd_file)
  dataset_id=H5D_OPEN(file_id,var_name)
  attr_id=H5A_OPEN_Name(dataset_id,attr_name)
  data=H5A_READ(attr_id) ;获取属性值
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end