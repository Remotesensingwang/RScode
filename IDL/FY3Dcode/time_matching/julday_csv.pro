;coding=utf-8
;*****************************************************
;计算文件的儒略日与前一年12月31号的儒略日之间的差值 即下载站点表格中的 Day_of_Year(Fraction) 一列
;生成可以与站点表格中的 Day_of_Year(Fraction) 一列比较的CSV文件
;*****************************************************

pro julday_csv
  input_directory='E:\02FY3D\A202203090585162088'
  openw,lun,'D:\00julianday.csv',/get_lun,/append,width=500
  file_list_hdf=file_search(input_directory,'*_1000M_MS.HDF',count=file_n_hdf)
  for file_i_hdf=0,file_n_hdf-1 do begin
    file_name=file_basename(file_list_hdf[file_i_hdf])
    date_time=strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),19,13)
    year=fix(strmid(date_time,0,4))
    month=fix(strmid(date_time,4,2))
    day=fix(strmid(date_time,6,2))
    hour=fix(strmid(date_time,9,2))
    minute=fix(strmid(date_time,11,2))
    ;计算儒略日，并与年份的前一年（这里是2018年）12月31日00:00做比较，求出差值
    juldaytime =JULDAY(month,day,year,hour,minute)
    basetime=JULDAY(12,31,year-1,00,00,00)
    day_of_year=juldaytime - basetime
    printf,lun,file_name,day_of_year,format='(a,",",f0.6)'
  endfor
  free_lun,lun 
end