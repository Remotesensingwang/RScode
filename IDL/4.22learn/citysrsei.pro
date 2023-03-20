;coding=GB2312
pro citysRSEI
  input_directory='D:\00BiShe\2data\4Moran\03caiqieimg\08zibo'
  file_list=file_search(input_directory,'*.tif',count=file_n)
  meandata=MAKE_ARRAY(file_n,/FLOAT) ;存储每个年份的RSEI均值
  for file_i=0,file_n-1 do begin
    RSEI_Data=read_tiff(file_list[file_i])
    ;HELP,RSEI_Data
    NotNaN_ID=WHERE(FINITE(RSEI_Data)) ;查找不是NaN的索引下标
    NotNaN_Data=RSEI_Data[NotNaN_ID]   ;去除NaN，不然与浮点数比较会报错（Floating illegal operand）
    NotNaN_Data[where((NotNaN_Data lt 0),/NULL)]=!VALUES.F_NAN ; 将无效值（NODATA） 即把小于0的数设置为NaN 
    ;print,mean(NotNaN_Data,/NAN)
    meandata[file_i]=mean(NotNaN_Data,/NAN) ;计算均值
  endfor
  help,meandata
  print,meandata
  ;文件写入
  out_directory='D:\00BiShe\2data\4Moran\03caiqieimg\00\'
  a=strmid(file_basename(file_list[0],'.tif'),2,4)
  print,a
  outfilename=out_directory+strmid(file_basename(file_list[0],'.tif'),2,4)+'.csv'
  outfile_test=file_test(outfilename)
  if outfile_test eq 1 then begin
    ;file_mkdir,outfile_test
    print,'--------1----------------------'
  endif
  ;WRITE_CSV,outfilename,[2000:2020],meandata,HEADER=['年份','均值'],TABLE_HEADER=strmid(file_basename(file_list[0],'.tif'),2,4)
  meandata=!null
  
end