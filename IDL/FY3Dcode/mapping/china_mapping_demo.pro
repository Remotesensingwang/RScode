;coding=utf-8
;*****************************************************
;制图
;对反演出来的AOD进行可视化显示
;*****************************************************
pro china_mapping_demo
  shp_china='E:\IDLcode\IDL\mappingdata\shpdata\chinashp.shp'
  data_mapping=read_tiff('E:\IDLcode\IDL\mappingdata\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_geo.tiff',geotiff=geo_info)
  
  ;地图视图显示范围
  display_lat_min=40.0
  display_lon_min=110.0
  display_lat_max=50.0
  display_lon_max=120.0
  
  ;地图在画布(窗口)上的显示位置(相对位置)
  image_x_start=0.1
  image_x_end=0.9
  image_y_start=0.1
  image_y_end=0.9
  data_size=size(data_mapping)
  ;print,geo_info
  ;tiff图像的分辨率（0.029999999；0.029999999；0.00000000）
  resolution=geo_info.(0)
  ;tiff图像的左上角的经纬度坐标信息（0.00000000；0.00000000；0.00000000；98.325668；57.595371；0.00000000）
  geo_loc=geo_info.(1)
  lon_min=geo_loc[3]
  lon_max=geo_loc[3]+data_size[1]*resolution[0]
  lat_max=geo_loc[4]
  lat_min=geo_loc[4]-data_size[2]*resolution[1]
  
  im=image(data_mapping,/order,$
    rgb_table=22,min_value=100,max_value=900,$   ;颜色设置，小于min的都是白色，大于max的都是红色（相对于22号来说）
    map_projection='Geographic',grid_units='degrees',limit=[display_lat_min,display_lon_min,display_lat_max,display_lon_max],$ ;地图视图（网格）的显示范围
    ;如果 grid_units 以“度”为单位，则 image_location 应设置为图像左下角的纬度和经度（地图定位），可以全图正确显示，image_dimensions设置网格的正确显示范围
    image_location=[lon_min,lat_min],image_dimensions=[lon_max-lon_min,lat_max-lat_min],$ 
    dimensions=[600,600],$ ;窗口的显示大小
    position=[image_x_start,image_y_start,image_x_end,image_y_end]) ;确定地图在窗口中的位置
    
    ;获取真正的地图在窗口中的位置，方便比例尺，指北针的位置放置
    true_position=im.position
    image_x_start=true_position[0]
    image_x_end=true_position[2]
    image_y_start=true_position[1]
    image_y_end=true_position[3]
    ;linestyle=2 设置为虚线，thick=2设置边界线的宽度
  m1=mapcontinents(shp_china,linestyle=2,color='black',thick=2)
  
  ;网格设置
  ;grid=im.mapgrid
  im.mapgrid.label_position=0
  im.mapgrid.linestyle=3
  im.mapgrid.thick=0.5
  im.mapgrid.horizon_thick=3
  im.mapgrid.font_name= 'Palatino';'Times Roman'
  im.mapgrid.font_size=13
  im.mapgrid.font_style=1 ;粗体
  
  lons=im.MAPGRID.longitudes
  lats=im.MAPGRID.latitudes
  
  for lons_i=0,N_ELEMENTS(lons)-1 do begin
    lons[lons_i].label_angle=0
    lons[lons_i].label_align=0.5
  endfor
  
  for lats_i=0,N_ELEMENTS(lats)-1 do begin
    lats[lats_i].label_angle=90
    lats[lats_i].label_align=0.5
  endfor

  lons[N_ELEMENTS(lons)-1].label_show=0
  lats[N_ELEMENTS(lats)-1].label_show=0
 
  ;网格经纬度显示间隔
  im.mapgrid.grid_latitude=3
  im.mapgrid.grid_longitude=3
    
  ;标题设置
  im.title='F$_1$Y3D_AOD^2'
  im.title.font_name='Times Roman' ;'Palatino'
  im.title.font_size=14
  im.title.font_style=1 ;粗体
end