;coding=GB2312
pro xianrsei
  input_directory='D:\00BiShe\2data\4Moran\03caiqieimg\09xianimg'
  filedir_list=file_search(input_directory,'*',count=dirnum,/test_directory)
  for filedir_i=0,dirnum-1 do begin
    file_list=file_search(filedir_list[filedir_i],'*.tif',count=file_n)
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
    ;help,meandata
    ;print,meandata
    
    ;�ļ�����
    out_directory='D:\00BiShe\2data\4Moran\03caiqieimg\00\xian\'
    csvfilename=strmid(file_basename(file_list[0],'.tif'),4)
    ;outfilename=out_directory+csvfilename+'.csv'
    
    ;WRITE_CSV,outfilename,[2000:2020],meandata,HEADER=['���','��ֵ'],TABLE_HEADER=csvfilename
    meandata=!null
    print,filedir_i
  endfor
end