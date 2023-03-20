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
  
  ;下标为数组和范围的组合
  ;表达式arr[[1, 3, 5], 7:9]是一个 9 元素的 3 x 3 数组 元素下标是[1,7] [3,7] [5,7]、[1,8]....
  arr = BINDGEN(10,12)
  help,arr
  print, arr
  print,arr[[1,3,5],7:9]
  
  ;将第一行和最后一行归零。
  arr[*,[0,12-1]]=0
  ;将第一列和最后一列归零。
  arr[[0,10-1],*]=0
  
  ;arr[[1, 3, 5],8]  ;结果一维
  ;arr[8,[1, 3, 5]] ;结果二维
  ;arr[[-2,-1,0]] ;结果全是第一个元素（负下标组成的下标数组）
  ;创建单位矩阵 A = FLTARR(N, N)、A[INDGEN(N) * (N + 1)] = 1.0
  A = FLTARR(10, 10)
  A[INDGEN(10) * 11] = 1.0
  
  ;PRINT, !VALUES.F_NAN EQ !NULL  ;NaN与NULL不等价
  
  
  ;获取pos(标量)具体所对应的列，行号,可应用于数据的提取（截取）
  Londata= findgen(3,2)
  pos=3
  londata_size=size(Londata)
  londata_col=londata_size[1]
  pos_col=pos mod londata_col ;pos列
  pos_row=pos/londata_col     ;pos的行
  ;print,londata[pos_col,pos_line]
  print,[pos_col,pos_row]

end