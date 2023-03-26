;coding=utf-8
;*****************************************************
;读取HDF4数据集属性内容
;*****************************************************

function get_hdf_attr, filename, dataset_name, attr_name
  ; 获取文件id
  file_id = hdf_sd_start(filename, /read)  ; 传入文件路径, 打开方式为read
  ; 获取数据集index
  dataset_index = hdf_sd_nametoindex(file_id, dataset_name)  ; 传入参数: 文件id, 数据集名称
  ; 获取数据集id
  dataset_id = hdf_sd_select(file_id, dataset_index)  ; 传入参数: 文件id, 数据集索引indedx
  ; 获取属性index
  attr_index = hdf_sd_attrfind(dataset_id, attr_name)
  ; 获取属性内容
  hdf_sd_attrinfo, dataset_id, attr_index, data=attr_data
  ;关闭数据集
  hdf_sd_endaccess, dataset_id
  ; 关闭文件
  hdf_sd_end, file_id  ; 传入文件id
  ; 返回属性内容
  return, attr_data
end