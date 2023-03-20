;coding=GB2312
pro arr
  a=[[0,5,3],[4,0,2],[0,7,8]]
  b=[[0,0,1],[9,7,4],[1,0,2]]
  c=(a gt 3)*a ;保留A中大于3的结果，其余元素置为0
  d=(b le 4)*b+(b gt 4)*9 ;保留B中小于等于4的结果，其余元素置为9
  e=float(a+b)/2.0
  ;计算A和B的均值，0值不纳入计算（如5和0的均值仍为5）
  f=float(a+b)
  g=(a gt 0)+(b gt 0)
  h=f/g
  ;print,h
  
  ;b=[[1,2,3,4],[2,3,5,6]]+1
  ;total(b[where(b gt 5)]) ;求大于5的元素总和
  ;total(b gt 5);求大于5一共几个元素
  
  
  ;求100*100图像中某个点周围5*5元素的平均值
  arr=indgen(100,100)
  iw=intarr(5)+1
  m=indgen(5)-5/2
  mx=m#iw
  my=iw#m
  print,mx
  print,'my'
  print,my
  xLoc=20
  yLon=20
  print,mean(arr[xLoc+mx,yLon+my])
  ;print,arr[0,0]
  print,arr[xLoc+mx,yLon+my]
end