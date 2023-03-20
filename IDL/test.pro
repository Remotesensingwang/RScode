;function get_std, banddata, filter_h, filter_w
;  ;banddata 是原始的二维数组  ;fileter_h 是滑块的高度  ;filter_w 是滑块的宽度
;  ; invalid_value 是数据中的无效值、空值等，根据需要其是否参与计算
;  ; 函数返回一个与初始矩阵大小相同的，标准差矩阵
;  w = n_elements(banddata[*, 0])
;  h = n_elements(banddata[0, *])
;  im = banddata
;  im2 = im^2
;  ones = replicate(1.0, w, h) ; 初始化一个全1数组(3*3区域内有效的像元数)
;  ;  ids_invalid = WHERE(im gt invalid_value, count_ids_invalid)
;  ;  IF count_ids_invalid GT 0 THEN ones[ids_invalid] = invalid_value
;  kernel = replicate(1.0, filter_h, filter_w) ;设定卷积核的大小(和滑块大小相同)
;  s = convol(im, kernel, /center, /edge_zero)  ;piexs*piexs区域内每个有效的像元的toa之和
;  s2 = convol(im2, kernel, /center, /edge_zero) ;piexs*piexs区域内每个有效的像元的toa平方之和
;  ns = convol(ones, kernel, /center, /edge_zero) ;piexs*piexs区域内有效的像元数
;  kernel_mean=s/ns                               ;piexs*piexs区域内有效的像元的toa的均值
;  std = sqrt(abs((s2 - s^2 / ns) / (ns - 1.0) ))
;  std_size=size(std)
;  std_col=std_size[1]
;  std_row=std_size[2]
;  ;将第一行和最后一行归零。
;  std[*,[0,std_row-1]]=100
;  ;将第一列和最后一列归零。
;  std[[0,std_col-1],*]=100
;  mstd=std*kernel_mean*sqrt(filter_h*filter_w)
;  return,{std:std,$
;    mstd:mstd}
;end


pro test
   cc=findgen(14,13)
   ;print,cc
   print,cc.TYPENAME

  data=findgen(5,7)+1
  data[0,0]=!VALUES.F_NAN
  data[0,1]=!VALUES.F_NAN
  ;data1=findgen(20,14)+10000
  ;s=[[[data]],[[data1]]]
  ;help,s
  
  ;print,data
  std1=get_std(data,3,3)
  std_1=std1.std
  NotNaN_ID=WHERE(~FINITE(data))
  if data[0,0] eq !VALUES.F_NAN then begin
    print,'duidudidudid'
  endif
  
  DIM = SIZE(data,/DIMENSIONS)
  NS = DIM[0]
  NL = DIM[1]
  CloudData = MAKE_ARRAY(NS,NL,VALUE=100,/FLOAT) ;;背景值为1
  FOR i = 1,Ns-2,1 DO BEGIN
    FOR j = 1,Nl-2,1 DO BEGIN
      tmpData = Data[i-1:i+1,j-1:j+1]
      w = WHERE(tmpData GT 0,countw)
      IF countw EQ 9 THEN BEGIN
        ;;计算STD-NEW 标准偏差
        MeanValue = MEAN(tmpData)
        data2=stddev(tmpData)
        StdNew = (TOTAL((tmpData-MeanValue)^2) / 8)^0.5
        CloudData[i,j]=StdNew
        ;print,'111'
      endif
    endfor
   endfor
  ;help,data1
  ;print,CloudData
  ;print,'22222'
  ;print,std_1
  dh_radata=findgen(3,3)+1
  ;print,dh_radata
  dh_radata=(dh_radata le 4)*dh_radata+(dh_radata gt 4)*(9-dh_radata)
  print,dh_radata
  
end