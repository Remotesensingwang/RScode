;coding=utf-8
;*****************************************************
;读取HDF4数据集数据
;*****************************************************
function get_hdf_dataset,filename,dataset_name
  ; 获取文件id
  file_id = hdf_sd_start(filename)
  ;获取数据集index
  dataset_index = hdf_sd_nametoindex(file_id,dataset_name)
  ;获取数据集id
  dataset_id=hdf_sd_select(file_id,dataset_index)
  ;获取数据集的内容
  hdf_sd_getdata,dataset_id,data
  ;关闭文件
  hdf_sd_end, file_id  ; 传入文件id
  return,data
end