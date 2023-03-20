;coding=GB2312
pro csv_read
;  filename='D:\FY3D\������1.csv'
;  data=read_csv(filename,header=head_name)
;  print,head_name
;  date=data.(0)
;  time=data.(1)
;  help,date[0]
;  n=n_elements(date)
;  datatime=strarr(n)
;  for i=0,n-1 do begin
;    split_data=strsplit(date[i],':',/extract)
;    day=split_data[0]
;    month=split_data[1]
;    year=split_data[2]
;    datatime[i]=year+month+day
;  endfor
;  help,datatime
;  s=where(datatime eq '20211202')
;  print,s
  ;a=JULDAY(03,24,2022,2,20)
  
;  b=float(a)
;  print,b
;  help,a
 ; print,datatime[15]
;  input_directory='D:\FY3D\A202203090585162088'
;  file_list=file_search(input_directory,'*_1000M_MS.HDF',count=file_n)
;  for file_i=0,file_n-1 do begin
;    senor_date=strmid(file_basename(file_list[0]),28,4)
;    tm=where(datatime eq senor_date)
;    print,'123'
;  endfor

 s='D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample2000.tif'
 ;a=read_tiff('D:\00BiShe\2data\1RSEIdata\02yhjs\imageToDriveExample2001.tif') 
 a=read_tiff('D:\PPT�ļ�\study\menu\Python\task1\img\sdjzimg.tif',INTERLEAVE=2)
; c=a[0,*,*]
; d=reform(c,920,1204)
; print,d[0:20]
 help,a
 print,a[0:20]
 ok = QUERY_TIFF('D:\PPT�ļ�\study\menu\Python\task1\img\sdjzimg.tif',s)
 help,s
 print,s

end