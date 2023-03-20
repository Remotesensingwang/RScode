;coding=utf-8
;*****************************************************
;局部标准差计算中需要对图像与进行局部求和操作。
;https://blog.csdn.net/weixin_33853827/article/details/94181585?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-94181585-blog-109385441.t0_edu_mlt&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-94181585-blog-109385441.t0_edu_mlt&utm_relevant_index=3
;*****************************************************
function get_std, banddata, filter_h, filter_w
  ;banddata 是原始的二维数组  ;fileter_h 是滑块的高度  ;filter_w 是滑块的宽度
  ; invalid_value 是数据中的无效值、空值等，根据需要其是否参与计算
  ; 函数返回一个与初始矩阵大小相同的，标准差矩阵
  w = n_elements(banddata[*, 0])
  h = n_elements(banddata[0, *])
  im = banddata
  im2 = im^2
  ones = replicate(1.0, w, h) ; 初始化一个全1数组(3*3区域内有效的像元数)
  ;  ids_invalid = WHERE(im gt invalid_value, count_ids_invalid)
  ;  IF count_ids_invalid GT 0 THEN ones[ids_invalid] = invalid_value
  kernel = replicate(1.0, filter_h, filter_w) ;设定卷积核的大小(和滑块大小相同)
  s = convol(im, kernel, /center, /edge_zero)  ;piexs*piexs区域内每个有效的像元的toa之和
  s2 = convol(im2, kernel, /center, /edge_zero) ;piexs*piexs区域内每个有效的像元的toa平方之和
  ns = convol(ones, kernel, /center, /edge_zero) ;piexs*piexs区域内有效的像元数
  kernel_mean=s/ns                               ;piexs*piexs区域内有效的像元的toa的均值
  std = sqrt(abs((s2 - s^2 / ns) / (ns - 1.0) ))
  std_size=size(std)
  std_col=std_size[1]
  std_row=std_size[2]
  ;将第一行和最后一行归零。
  std[*,[0,std_row-1]]=100
  ;将第一列和最后一列归零。
  std[[0,std_col-1],*]=100
  ;mstd=std*kernel_mean*sqrt(filter_h*filter_w)
;  return,{std:std,$
;    mstd:mstd}
  return,std
end