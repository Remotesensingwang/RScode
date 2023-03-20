;coding=utf-8
;*****************************************************
;HY1C-COC L1B 数据可见光波段（1-8波段），TOA值计算，关键字（/reflectance）
;热红外波段（9-10波段）亮温值的计算，关键字（/temperature）
;*****************************************************

pro HY1C_levelLB_read,HY1CLBFile,imagedata,$
  reflectance=reflectance, temperature=temperature,szdata=szdata
  compile_opt idl2
  file=HY1CLBFile
  file_id=H5F_OPEN(file)
  ;earthsun_distance_ratio_id= H5A_OPEN_Name(file_id,'Earth-Sun Distance')
  ;earthsun_distance_ratio=H5A_READ(earthsun_distance_ratio_id);获取日地距离

  if keyword_set(reflectance) and keyword_set(szdata) then begin
    earthsun_distance_ratio_id= H5A_OPEN_Name(file_id,'Earth-Sun Distance')
    earthsun_distance_ratio=H5A_READ(earthsun_distance_ratio_id);获取日地距离
    ;获取1-8波段的辐亮度数值
    Data0412=get_hdf5_data(file,'/Geophysical Data/L_412')
    Data0443=get_hdf5_data(file,'/Geophysical Data/L_443')
    Data0490=get_hdf5_data(file,'/Geophysical Data/L_490')
    Data0520=get_hdf5_data(file,'/Geophysical Data/L_520')
    Data0565=get_hdf5_data(file,'/Geophysical Data/L_565')
    Data0670=get_hdf5_data(file,'/Geophysical Data/L_670')
    Data0750=get_hdf5_data(file,'/Geophysical Data/L_750')
    Data0865=get_hdf5_data(file,'/Geophysical Data/L_865')
    
    refSB_band_data=[[[Data0412]],[[Data0443]],[[Data0490]],[[Data0520]],[[Data0565]],[[Data0670]],[[Data0750]],[[Data0865]]] ;获取1-8波段的DN值

    band_data_size=size(refSB_band_data)
    ;存储读取的1-19波段的Ref与TOA数据
    ;band_data_ref=fltarr(band_data_size[1],band_data_size[2],band_data_size[3])
    imagedata=fltarr(band_data_size[1],band_data_size[2],band_data_size[3])
    ESUN_Data=[1717.17,1883.49,1971.04,1840.36,1797.81,1504.09,1268.18,962.589]
    for layer_i=0,band_data_size[3]-1 do begin
      imagedata[*,*,layer_i]=10*(!pi*earthsun_distance_ratio[0]^2*refSB_band_data[*,*,layer_i])/(ESUN_Data[layer_i]*cos(szdata*!dtor))
    endfor
    ;PRINT,'111'
  endif

  if keyword_set(temperature) then begin
    return
;    Emissive_band1000m_data=get_hdf5_data(file,'/Data/EV_1KM_Emissive') ;获取20-23波段的DN值
;    Emissive_band250m_data=get_hdf5_data(file,'/Data/EV_250_Aggr.1KM_Emissive') ;;获取24-25波段的DN值
;    Emissive_band_data=[[[Emissive_Band1000m_data]],[[Emissive_Band250m_data]]] ;获取20-25波段的DN值
;
;    Emissive_band1000m_slope=get_hdf5_attr_data(file,'/Data/EV_1KM_Emissive','Slope')
;    Emissive_band1000m_Intercept=get_hdf5_attr_data(file,'/Data/EV_1KM_Emissive','Intercept')
;    Emissive_band250m_slope=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_Emissive','Slope')
;    Emissive_band250m_Intercept=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_Emissive','Intercept')
;    Emissive_band_slope=[Emissive_band1000m_slope,Emissive_band250m_slope]
;    Emissive_band_Intercept=[Emissive_band1000m_Intercept,Emissive_band250m_Intercept]
;
;    Emissive_band_data_size=size(Emissive_band_data)
;
;    ;Rad_data=fltarr(Emissive_band_data_size[1],Emissive_band_data_size[2],Emissive_band_data_size[3])
;    imagedata=fltarr(Emissive_band_data_size[1],Emissive_band_data_size[2],Emissive_band_data_size[3])
;    mersi_equivmid_wn_data=[2634.359,2471.654,1382.621,1168.182,933.364,836.941]
;    tbbcorr_coeff_a_data=[1.00103,1.00085,1.00125,1.00030,1.00133,1.00065]
;    tbbcorr_coeff_b_data=[-0.4759,-0.3139,-0.2662,-0.0513,-0.0734,0.0875]
;
;    c1=1.1910427e-5   ;c1=1.191066e-5
;    c2=1.4387752   ;c2=1.438833  ;（一种基于FY3D/MERSI2的AOD遥感反演方法 ）（FY3MERSI地表温度反演和专题制图的MATLAB 实现）
;    for layer_i=0,Emissive_band_data_size[3]-1 do begin
;      Rad_data=Emissive_band_data[*,*,layer_i]*Emissive_band_slope[0]+Emissive_band_Intercept[0]
;      Te_data=(c2*mersi_equivmid_wn_data[layer_i])/(alog(1+c1*mersi_equivmid_wn_data[layer_i]^3/Rad_data))
;      imagedata[*,*,layer_i]=Te_data*tbbcorr_coeff_a_data[layer_i]+tbbcorr_coeff_b_data[layer_i]
;    endfor
  endif

end