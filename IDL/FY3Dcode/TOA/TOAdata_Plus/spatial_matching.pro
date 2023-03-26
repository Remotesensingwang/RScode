;coding=utf-8
;查找距离站点最近的坐标值下标
function Spatial_matching,extract_lon,extract_lat,lon,lat
  x=(lon-extract_lon)
  y=(lat-extract_lat)
  distance=sqrt(x^2+y^2)
  min_dis=min(distance)
  pos=where(distance eq min_dis)
  
  ;pos_col=pos mod 2048 ;pos的列（类型为数组）
  ;pos_line=pos/2048    ;pos的行（类型为数组）
  ;print,londata[pos_col,pos_line]
  ;print,[pos_col,pos_line]
  ;print,pos
  return,pos