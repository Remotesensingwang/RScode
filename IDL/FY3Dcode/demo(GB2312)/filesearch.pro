;coding=GB2312
pro filesearch
  dir='C:\Users\Wangxingtao\Desktop\研究生学习\05FY-3D数据\data'
  file_list=file_search(dir,'*.HDF',count=file_n)
  ;print,file_list,file_n,file_list[0]
  data=strmid(file_basename(file_list[0]),19,13)
  help,data
  print,data,format='(A4)'
end