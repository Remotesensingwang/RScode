;coding=utf-8
;*****************************************************
;注意 这里只计算DCC的，则这里只计算1-4波段的TOA反射率的值！！！！！！！！！！！！！
;FY3D数据可见光波段（1-19波段），TOA值计算，关键字（/reflectance）
;热红外波段（20-25波段）亮温值的计算，关键字（/temperature）
;*****************************************************

pro fy3d_level1b_read,FY3DFile,imagedata,$
  reflectance=reflectance, temperature=temperature,sz_angle=sz_angle
  compile_opt idl2
  file=FY3DFile
  
  if keyword_set(reflectance) and keyword_set(sz_angle) then begin
    file_id=H5F_OPEN(file)
    earthsun_distance_ratio_id= H5A_OPEN_Name(file_id,'EarthSun Distance Ratio')
    earthsun_distance_ratio=H5A_READ(earthsun_distance_ratio_id);获取日地距离
    refSB_band1000m_data=get_hdf5_data(file,'/Data/EV_1KM_RefSB');获取5-19波段的DN值
    refSB_band250m_data=get_hdf5_data(file,'/Data/EV_250_Aggr.1KM_RefSB');获取1-4波段的DN值
    refSB_band_data=[[[temporary(refSB_band250m_data)]],[[temporary(refSB_band1000m_data)]]] ;获取1-19波段的DN值

    ;获得每个波段的slpe和Intercept属性值（1-4波段）（5-19波段）
    refSB_band250m_slope=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_RefSB','Slope')
    refSB_band250m_Intercept=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_RefSB','Intercept')
    refSB_band1000m_slope=get_hdf5_attr_data(file,'/Data/EV_1KM_RefSB','Slope')
    refSB_band1000m_Intercept=get_hdf5_attr_data(file,'/Data/EV_1KM_RefSB','Intercept')

    refSB_band_slope=[refSB_band250m_slope,refSB_band1000m_slope]
    refSB_band_Intercept=[refSB_band250m_Intercept,refSB_band1000m_Intercept]

    ;获取定标值（1-19波段）
    caldata=get_hdf5_data(file,'/Calibration/VIS_Cal_Coeff')
    cal_0=caldata[0,*]
    cal_1=caldata[1,*]
    cal_2=caldata[2,*]

    band_data_size=size(refSB_band_data)
    ;存储读取的1-19波段的Ref与TOA数据
    ;band_data_ref=fltarr(band_data_size[1],band_data_size[2],band_data_size[3])
    imagedata=fltarr(band_data_size[1],band_data_size[2],band_data_size[3])
 
;    for layer_i=0,band_data_size[3]-1 do begin
    for layer_i=0,3 do begin
      band_data_dn=refSB_band_data[*,*,layer_i]*refSB_band_slope[layer_i]+refSB_band_Intercept[layer_i]
      band_data_ref=cal_2[layer_i]*band_data_dn^2.0+cal_1[layer_i]*band_data_dn+cal_0[layer_i]
      imagedata[*,*,layer_i]=(refSB_band_data[*,*,layer_i] gt 0 and refSB_band_data[*,*,layer_i] lt 4095)*(earthsun_distance_ratio[0]^2*band_data_ref)/cos(sz_angle*!dtor)*0.01      
    endfor
    
    h5f_close,file_id
  endif
  if keyword_set(temperature) then begin
    Emissive_band1000m_data=get_hdf5_data(file,'/Data/EV_1KM_Emissive') ;获取20-23波段的DN值
    Emissive_band250m_data=get_hdf5_data(file,'/Data/EV_250_Aggr.1KM_Emissive') ;;获取24-25波段的DN值
    Emissive_band_data=[[[temporary(Emissive_Band1000m_data)]],[[temporary(Emissive_Band250m_data)]]] ;获取20-25波段的DN值
       
    Emissive_band1000m_slope=get_hdf5_attr_data(file,'/Data/EV_1KM_Emissive','Slope')
    Emissive_band1000m_Intercept=get_hdf5_attr_data(file,'/Data/EV_1KM_Emissive','Intercept')
    Emissive_band250m_slope=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_Emissive','Slope')
    Emissive_band250m_Intercept=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_Emissive','Intercept')
    Emissive_band_slope=[Emissive_band1000m_slope,Emissive_band250m_slope]
    Emissive_band_Intercept=[Emissive_band1000m_Intercept,Emissive_band250m_Intercept]

    Emissive_band_data_size=size(Emissive_band_data)

    ;Rad_data=fltarr(Emissive_band_data_size[1],Emissive_band_data_size[2],Emissive_band_data_size[3])
    imagedata=fltarr(Emissive_band_data_size[1],Emissive_band_data_size[2],Emissive_band_data_size[3])
    mersi_equivmid_wn_data=[2634.359,2471.654,1382.621,1168.182,933.364,836.941]
    tbbcorr_coeff_a_data=[1.00103,1.00085,1.00125,1.00030,1.00133,1.00065]
    tbbcorr_coeff_b_data=[-0.4759,-0.3139,-0.2662,-0.0513,-0.0734,0.0875]   
    
    c1=1.1910427e-5   ;c1=1.191066e-5    
    c2=1.4387752   ;c2=1.438833  ;（一种基于FY3D/MERSI2的AOD遥感反演方法 ）（FY3MERSI地表温度反演和专题制图的MATLAB 实现）
    
    ;获取热红外波段的有效值的范围 其中1KM为20-23波段,250m为24-25波段
    valid_range_1KM=get_hdf5_attr_data(file,'/Data/EV_1KM_Emissive','valid_range')
    valid_range_250M=get_hdf5_attr_data(file,'/Data/EV_250_Aggr.1KM_Emissive','valid_range')
;    HELP,valid_range_1KM[0]
    for layer_i=0,Emissive_band_data_size[3]-1 do begin
      Rad_data=Emissive_band_data[*,*,layer_i]*Emissive_band_slope[layer_i]+Emissive_band_Intercept[layer_i]
      Te_data=(c2*mersi_equivmid_wn_data[layer_i])/(alog(1+c1*mersi_equivmid_wn_data[layer_i]^3/Rad_data))   
      if layer_i lt 4 then begin
        imagedata[*,*,layer_i]=(Emissive_band_data[*,*,layer_i] gt valid_range_1KM[0] and Emissive_band_data[*,*,layer_i] lt valid_range_1KM[1])*(Te_data*tbbcorr_coeff_a_data[layer_i]+tbbcorr_coeff_b_data[layer_i])
      endif else begin
        imagedata[*,*,layer_i]=(Emissive_band_data[*,*,layer_i] gt valid_range_250M[0] and Emissive_band_data[*,*,layer_i] lt valid_range_250M[1])*(Te_data*tbbcorr_coeff_a_data[layer_i]+tbbcorr_coeff_b_data[layer_i])
      endelse
      
    endfor
  endif
  
end