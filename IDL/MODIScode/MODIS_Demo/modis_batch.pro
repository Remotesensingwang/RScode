;coding=utf-8
;*****************************************************
;MODIS数据文件下载链接补全
;并保存为txt，结合IDM使用
;*****************************************************

pro MODIS_batch

  e=envi(/headless)
  filename=dialog_pickfile(title="打开csv文件")
  readCSV=read_csv(filename,count=lines,header=header,record_start=1)
  address=readCSV.field1
  nums=n_elements(address)
  result=strarr(nums)
  for i=0,nums-1 do begin
    result[i]="https://ladsweb.modaps.eosdis.nasa.gov/archive/orders/501861868/"+address[i]
  endfor
  output=dialog_pickfile(title="输出文件为文本文件")
  openw,lun,output,/get_lun
  printf,lun,result
  free_lun,lun
end
