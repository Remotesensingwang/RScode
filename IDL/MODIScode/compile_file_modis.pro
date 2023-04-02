;coding=utf-8
;*****************************************************
;3年文件的处理
;DH
;*****************************************************

pro compile_file_modis
  input_directory1='H:\00data\MODIS\MODIS_L1data\2019'
  input_directory2='H:\00data\MODIS\MODIS_L1data\2020'
  input_directory3='H:\00data\MODIS\MODIS_L1data\2021'
  dir_list_hdf=[[input_directory1],[input_directory2],[input_directory3]]
  dir_n_hdf=n_elements(dir_list_hdf)
  for dir_i_hdf=0,dir_n_hdf-1 do begin
    starttime=systime(1)
    modis_calculate_toa330,input_directory=dir_list_hdf[dir_i_hdf]
    print,string(dir_list_hdf[dir_i_hdf])+'处理完成!'+string(systime(1)-starttime)
  endfor

end