;coding=GB2312
pro arr
  a=[[0,5,3],[4,0,2],[0,7,8]]
  b=[[0,0,1],[9,7,4],[1,0,2]]
  c=(a gt 3)*a ;����A�д���3�Ľ��������Ԫ����Ϊ0
  d=(b le 4)*b+(b gt 4)*9 ;����B��С�ڵ���4�Ľ��������Ԫ����Ϊ9
  e=float(a+b)/2.0
  ;����A��B�ľ�ֵ��0ֵ��������㣨��5��0�ľ�ֵ��Ϊ5��
  f=float(a+b)
  g=(a gt 0)+(b gt 0)
  h=f/g
  ;print,h
  
  ;b=[[1,2,3,4],[2,3,5,6]]+1
  ;total(b[where(b gt 5)]) ;�����5��Ԫ���ܺ�
  ;total(b gt 5);�����5һ������Ԫ��
  
  
  ;��100*100ͼ����ĳ������Χ5*5Ԫ�ص�ƽ��ֵ
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