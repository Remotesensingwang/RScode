;coding=GB2312
pro test1
  ;encoding=��GB2312��
;  WRITE_CSV,'D:\IDLcode\1.csv',[2000,2020],[1,2],HEADER=['���','��ֵ'] 
;  print,'��ݵ�'
  kernel1 = [[ 1 , 2 , 4 , 2 , 1 ], [ 2 , 4 , 8 , 4 , 2 ],$
  [ 1 , 2 , 4 , 2 , 1 ]]
  help, kernel1
  kernel2 = [[-1,0,2,0,-1], [1,2,4,2,1], [-1,0,2,0,-1]]
  kernelWide = [kernel1, kernel2] ; concatenate along first dimension
  kernelTall = [[kernel1], [kernel2]] ; concatenate along second dimensio
  print,kernelWide
  print,kernelTall
end