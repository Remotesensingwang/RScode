;coding=utf-8
;*****************************************************
;3年文件的处理
;*****************************************************

pro compile_file_fy
  input_directory1='H:\00data\FY3D\FY3D_dunhuang\2019'
  input_directory2='H:\00data\FY3D\FY3D_dunhuang\2020'
  input_directory3='H:\00data\FY3D\FY3D_dunhuang\2021'
  dir_list_hdf=[[input_directory1],[input_directory2],[input_directory3]]
  dir_n_hdf=n_elements(dir_list_hdf)
  for dir_i_hdf=0,dir_n_hdf-1 do begin
    fy3d_calculate_toa330,input_directory=dir_list_hdf[dir_i_hdf]
  endfor

end