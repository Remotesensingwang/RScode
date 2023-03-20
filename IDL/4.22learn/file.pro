;coding=UTF-8
pro file
  input_directory='D:\01研究生学习\05FY-3D数据\data'
  out_directory='D:\01研究生学习\05FY-3D数据\data\out\'
  
  ;判断文件夹是否存在，不存在则新建该文件夹
  dir_test=file_test(out_directory,/directory)
  if dir_test eq 0 then begin
    file_mkdir,out_directory
  endif
  
  ;判断文件是否存在，存在即删除
  result_tiff_name=out_directory+'_TOA.tif'
  file=file_test(result_tiff_name)
  if file eq 1 then begin
    file_delete,result_tiff_name
  endif

  ;读取输入文件夹下有几个子文件夹
  filedir_list=file_search(input_directory,'*',count=dirnum,/test_directory)
  print,filedir_list
  
  ;读取文件夹下符合条件的文件
  file_list_geo=file_search(input_directory,'*_GEO1K_MS.HDF',count=file_n_geo)
  for file_i_Geo=0,file_n_geo-1 do begin
    geoinfo=get_Geo_info(file_list_geo[file_i_Geo],Bejing_lon,Beijin_lat)
    szdata[*,*,file_i_Geo]=geoinfo.file_szdata   ;获取每个HDF文件的太阳天顶角数据
    pointdata[*,*,file_i_Geo]=geoinfo.file_pos     ;获取每个文件与站点最近的经纬度数据下标
  endfor
  
end