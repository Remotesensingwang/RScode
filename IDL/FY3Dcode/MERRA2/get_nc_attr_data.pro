;coding=utf-8
;*****************************************************
;读取nc数据集标签属性值（变量的属性值）
;*****************************************************
;nc_file=文件路径名称，var_name=数据集具体标签名称（变量），attr_name=具体标签的属性名称（变量的属性名）
function get_nc_attr_data,nc_file,var_name,attr_name
  nc_id = ncdf_open(nc_file,/nowrite)
  var_id = ncdf_varid(nc_id,var_name)
  ncdf_attget,nc_id,var_id,attr_name,attr_value
  data=string(attr_value)
  return,data
  ;ncdf_attget,nc_id,'Filename' , data,/GLOBAL   ;获取全局属性值，但返回值data为Byte（字节类型），要转化为string类型
  ncdf_close,nc_id
end