;coding=GB2312
pro citysRSEI
  input_directory='D:\00BiShe\2data\4Moran\03caiqieimg\08zibo'
  file_list=file_search(input_directory,'*.tif',count=file_n)
  meandata=MAKE_ARRAY(file_n,/FLOAT) ;�洢ÿ����ݵ�RSEI��ֵ
  for file_i=0,file_n-1 do begin
    RSEI_Data=read_tiff(file_list[file_i])
    ;HELP,RSEI_Data
    NotNaN_ID=WHERE(FINITE(RSEI_Data)) ;���Ҳ���NaN�������±�
    NotNaN_Data=RSEI_Data[NotNaN_ID]   ;ȥ��NaN����Ȼ�븡�����Ƚϻᱨ��Floating illegal operand��
    NotNaN_Data[where((NotNaN_Data lt 0),/NULL)]=!VALUES.F_NAN ; ����Чֵ��NODATA�� ����С��0��������ΪNaN 
    ;print,mean(NotNaN_Data,/NAN)
    meandata[file_i]=mean(NotNaN_Data,/NAN) ;�����ֵ
  endfor
  help,meandata
  print,meandata
  ;�ļ�д��
  out_directory='D:\00BiShe\2data\4Moran\03caiqieimg\00\'
  a=strmid(file_basename(file_list[0],'.tif'),2,4)
  print,a
  outfilename=out_directory+strmid(file_basename(file_list[0],'.tif'),2,4)+'.csv'
  outfile_test=file_test(outfilename)
  if outfile_test eq 1 then begin
    ;file_mkdir,outfile_test
    print,'--------1----------------------'
  endif
  ;WRITE_CSV,outfilename,[2000:2020],meandata,HEADER=['���','��ֵ'],TABLE_HEADER=strmid(file_basename(file_list[0],'.tif'),2,4)
  meandata=!null
  
end