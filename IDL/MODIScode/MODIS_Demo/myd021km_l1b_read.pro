;coding=utf-8
;*****************************************************
;注意如果设置了szdata这个关键字，则这里只计算1-4波段的TOA反射率的值，且已完成SZ校正！！！！！！！！！！！！！
;MODIS数据可见光波段（1-19，26波段），TOA值计算，关键字（/reflectance）
;热红外波段（20-25波段）亮温值的计算，关键字（/temperature）
;*****************************************************

pro MYD021KM_L1b_read,MYD021KMFile,imagedata,$
  reflectance=reflectance,sz_angle=sz_angle
  compile_opt idl2
  file=MYD021KMFile

  ;获取1-19波段,26波段的DN值
  EV_250_RefSB_data=get_hdf_dataset(file,'EV_250_Aggr1km_RefSB') ;1-2波段
  EV_500_RefSB_data=get_hdf_dataset(file,'EV_500_Aggr1km_RefSB') ;3-7波段
  EV_1KM_RefSB_data=get_hdf_dataset(file,'EV_1KM_RefSB') ;8-19波段，26波段
  DN_band_data=[[[temporary(EV_250_RefSB_data)]],[[temporary(EV_500_RefSB_data)]],[[temporary(EV_1KM_RefSB_data)]]]

  ;获取1-19波段,26波段的reflectance_scales值
  EV_250_RefSB_scales=get_hdf_attr(file,'EV_250_Aggr1km_RefSB','reflectance_scales')
  EV_500_RefSB_scales=get_hdf_attr(file,'EV_500_Aggr1km_RefSB','reflectance_scales')
  EV_1KM_RefSB_scales=get_hdf_attr(file,'EV_1KM_RefSB','reflectance_scales')
  scales_band_data=[EV_250_RefSB_scales,EV_500_RefSB_scales,EV_1KM_RefSB_scales]

  ;获取1-19波段,26波段的reflectance_offsets值
  EV_250_RefSB_offsets=get_hdf_attr(file,'EV_250_Aggr1km_RefSB','reflectance_offsets')
  EV_500_RefSB_offsets=get_hdf_attr(file,'EV_500_Aggr1km_RefSB','reflectance_offsets')
  EV_1KM_RefSB_offsets=get_hdf_attr(file,'EV_1KM_RefSB','reflectance_offsets')
  offsets_band_data=[EV_250_RefSB_offsets,EV_500_RefSB_offsets,EV_1KM_RefSB_offsets]


  DN_band_data_size=size(DN_band_data)
  imagedata=fltarr(DN_band_data_size[1],DN_band_data_size[2],DN_band_data_size[3])
  pos=where(DN_band_data[*,*,1] le 0 or DN_band_data[*,*,1] ge 32767)
  ;print,'1111'
  ;存储读取的1-19波段,26波段的TOA数据,没有进行太阳天顶角的校正
  ;计算TOA   R=reflectance_scale*(DN-reflectance _offset)
  if keyword_set(reflectance) then begin
    for layer_i=0,DN_band_data_size[3]-1 do begin
      imagedata[*,*,layer_i]=(DN_band_data[*,*,layer_i] gt 0 and DN_band_data[*,*,layer_i] le 32767)*scales_band_data[layer_i]*(DN_band_data[*,*,layer_i]-offsets_band_data[layer_i])
    endfor
  endif

  ;存储读取的1-4波段TOA数据,并进行太阳天顶角的校正
  if keyword_set(reflectance) and keyword_set(sz_angle) then begin
    imagedata=fltarr(DN_band_data_size[1],DN_band_data_size[2],4)
    for layer_i=0,3 do begin   ;float(DN_band_data[*,*,layer_i] gt 0 and DN_band_data[*,*,layer_i] lt 32767)
      ;pos=where(DN_band_data[*,*,layer_i] le 0 or DN_band_data[*,*,layer_i] ge 32767)
      imagedata[*,*,layer_i]=(DN_band_data[*,*,layer_i] gt 0 and DN_band_data[*,*,layer_i] lt 32767)*(scales_band_data[layer_i]*(DN_band_data[*,*,layer_i]-offsets_band_data[layer_i]))/cos(sz_angle*!dtor)
      ;imagedata[pos]=-1
    endfor
  endif

end