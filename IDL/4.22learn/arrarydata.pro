;coding=GB2312
pro arrarydata
  kernel1 = [[ 1 , 2 , 4 , 2 , 1 ], [ 2 , 4 , 8 , 4 , 2 ],$
  [ 1 , 2 , 4 , 2 , 1 ]]
  help, kernel1
  kernel2 = [[-1,0,2,0,-1], [1,2,4,2,1], [-1,0,2,0,-1]]
  help, kernel2
  kernelWide = [kernel1, kernel2] ; concatenate along first dimension
  kernelTall = [[kernel1], [kernel2]] ; concatenate along second dimensio
  help,kernelWide
;  print,kernelWide
;  help, kernelTall
;  print,kernelTall
  print,size(kernelWide)
  
  ;�±�Ϊ����ͷ�Χ�����
  ;���ʽarr[[1, 3, 5], 7:9]��һ�� 9 Ԫ�ص� 3 x 3 ���� Ԫ���±���[1,7] [3,7] [5,7]��[1,8]....
  arr = BINDGEN(10,12)
  help,arr
  print, arr
  print,arr[[1,3,5],7:9]
  
  ;����һ�к����һ�й��㡣
  arr[*,[0,12-1]]=0
  ;����һ�к����һ�й��㡣
  arr[[0,10-1],*]=0
  
  ;arr[[1, 3, 5],8]  ;���һά
  ;arr[8,[1, 3, 5]] ;�����ά
  ;arr[[-2,-1,0]] ;���ȫ�ǵ�һ��Ԫ�أ����±���ɵ��±����飩
  ;������λ���� A = FLTARR(N, N)��A[INDGEN(N) * (N + 1)] = 1.0
  A = FLTARR(10, 10)
  A[INDGEN(10) * 11] = 1.0
  
  ;PRINT, !VALUES.F_NAN EQ !NULL  ;NaN��NULL���ȼ�
  
  
  ;��ȡpos(����)��������Ӧ���У��к�,��Ӧ�������ݵ���ȡ����ȡ��
  Londata= findgen(3,2)
  pos=3
  londata_size=size(Londata)
  londata_col=londata_size[1]
  pos_col=pos mod londata_col ;pos��
  pos_row=pos/londata_col     ;pos����
  ;print,londata[pos_col,pos_line]
  print,[pos_col,pos_row]

end