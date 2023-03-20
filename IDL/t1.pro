
;获取数据集内容
function get_dataset,filename,dataset_name
  ; 获取文件id
  file_id = hdf_sd_start(filename)
  ;获取数据集index
  dataset_index = hdf_sd_nametoindex(file_id,dataset_name)
  ;获取数据集id
  dataset_id=hdf_sd_select(file_id,dataset_index)
  ;获取数据集的内容
  hdf_sd_getdata,dataset_id,data
  ;关闭文件
  hdf_sd_end, file_id  ; 传入文件id
  return,data
end
pro t1

;  print,cc
;  p = scatterplot(a,a,xtitle='FY-',ytitle='iquam SST(K)',title='btd45c_cloud',$
;    symbol = '+', SYM_COLOR = 'blue',xrange = [260,300],yrange = [-2,3],font_size=10 )
;   

;    cc=findgen(3,4,3)+1
;    ;print,cc
;    help,cc
;    pos=5
;    
    pos= 2363846 ;    2361797    ; 2361798     2363845     2363846
    ;获取pos具体所对应的列，行号,可应用于数据的提取（截取）
    londata_col=2048
    pos_col=pos mod londata_col ;pos的列（类型为数组）
    pos_line=pos / londata_col    ;pos的行（类型为数组）
   ;(1153行 453 ) (1154 454 )

  a=[1,2,3,4,!VALUES.F_NAN]
  b=mean(a,/nan)
  c=mean(a)
  juldaytime =JULDAY(1,2,2021,06,25)
  basetime=JULDAY(1,2,2021,07,25)
  day_of_year=juldaytime - basetime
  ;print,day_of_year,format='(f0.6)'
  aa=2.0966782406903803 - 2.0965277780778706
  ;print,'1111'
end
;87.289502   2.0966782406903803  2.0965277780778706    0.00015044212   0.020833333
