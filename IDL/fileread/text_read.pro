pro text_read
  openr,lun,'C:\Users\Wangxingtao\Desktop\dh_dingbiao.txt',/get_lun
  data=fltarr(24,497) ;该文件一共498行，但要跳过第一行，so一共有497行
  ;data=strarr(1,497)
  skip_lun,lun,1,/lines
  readf,lun,data  
  print,data[0,496]
  free_lun,lun
end