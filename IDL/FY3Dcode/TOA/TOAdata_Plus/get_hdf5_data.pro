;coding=utf-8
;*****************************************************
;读取HDF数据集数据
;*****************************************************
function get_hdf5_data,hd_file,var_name
  file_id = H5F_OPEN(hd_file)
  dataset_id=H5D_OPEN(file_id,var_name)
  data=H5D_READ(dataset_id)
  return,data
  h5d_close,dataset_id
  h5d_close,file_id
end
