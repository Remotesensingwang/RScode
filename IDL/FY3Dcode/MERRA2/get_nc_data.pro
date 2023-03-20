;coding=utf-8
;*****************************************************
;读取nc数据集的变量数据
;*****************************************************
function get_nc_data,nc_file,var_name
  nc_id = ncdf_open(nc_file,/nowrite)
  var_id = ncdf_varid(nc_id,var_name)
  ncdf_varget,nc_id,var_id,data
  return,data
  ncdf_close,nc_id
end