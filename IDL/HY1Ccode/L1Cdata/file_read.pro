;coding=GB2312
;coding=utf-8
;*****************************************************
;主要为L1C文件tiff格式数据的读取
;对敦煌定标场进行辐亮度计算（以敦煌定标场中心点为中心，计算9*9范围的均值）
;*****************************************************

pro file_read
  compile_opt idl2
  ;敦煌定标场中心坐标
  dh_lon=94.32083333333334
  dh_lat=40.1375
  input_directory='H:\00data\HY1C\2021_tiff'
  out_directory='H:\00data\HY1C\2021_tiff\'
  file_list_hdf=file_search(input_directory,'*.tiff',count=file_n_hdf)
  ;文件日期 角度 匹配站点范围各个波段的toa均值
  openw,lun,'H:\00data\HY1C\dh_toa2021_HY1C.txt',/get_lun,/append,width=500  
  ;*****************************************************文件批处理 *****************************************************
  for file_i_hdf=0,file_n_hdf-1 do begin
    starttime1=systime(1)
    ;获取文件的时间
    datetime=strmid(file_basename(file_list_hdf[file_i_hdf],'.tiff'),17,8)+strmid(file_basename(file_list_hdf[file_i_hdf],'.hdf'),26,4) 
    ;print,'111'  
    data_img=read_tiff(file_list_hdf[file_i_hdf],interleave=2,geotiff=geo_info)*0.1
    data_size=size(data_img)  
    resolution=geo_info.(0)
    ;tiff图像的左上角的经纬度坐标信息（0.00000000；0.00000000；0.00000000；129.48000；60.710000；0.00000000）
    geo_loc=geo_info.(1)
    lon_min=geo_loc[3]   
    lat_max=geo_loc[4]
    columns=fix((dh_lon-lon_min)/resolution[0])
    row=fix((lat_max-dh_lat)/resolution[1])
    
    if (columns ge 4 and columns le data_size[1]-4) and (row ge 4 and row le data_size[2]-4) then begin
      Longdata=lon_min+columns*resolution[0]
      Latdata=lat_max-row*resolution[1]
      ;dh_data_img=MAKE_ARRAY(9,9,data_size[3],value=!VALUES.F_NAN,/FLOAT)
      toadata_mean=[]
      for layer=0,data_size[3]-1 do begin
        data=data_img[*,*,layer]
        dh_data=data[columns-4:columns+4,row-4:row+4]
        
        toadata_mean=[toadata_mean,mean(dh_data,/nan)]
        ;dh_data_img[*,*,layer]=dh_data
        ;print,'111'
      endfor
    
    endif else begin
      print,file_basename(file_list_hdf[file_i_hdf])+'失败'
      continue
    endelse
    
    ;文件日期 角度 匹配站点范围各个波段的toa均值  ,逗号分隔
    data=[string(datetime),string(toadata_mean)]
    printf,lun,strcompress(data,/remove_all);,format='(25(a,:,","))'
    
    result_tiff_name=out_directory+strmid(file_basename(file_list_hdf[file_i_hdf],'.tiff'),17,15)+'_TOA_1km.tif'
    ;write_tiff,result_tiff_name,TOAdata,planarconfig=2,compression=1,/float   ;planarconfig=2(BSQ) 说明导入的数据是（列，行，通道数）这也是IDL的常用的，用envi打开格式为（2048 x 2000 x 4）,matlab打开格式为（2000，2048，4）
    print,file_basename(file_list_hdf[file_i_hdf])+STRCOMPRESS(string(Longdata))+STRCOMPRESS(string(Latdata))+string(systime(1)-starttime1)+string(file_n_hdf-file_i_hdf-1)
    ;print,'111'
    data_img=!null
    toadata_mean=!null    
    
  endfor
  free_lun,lun
  print,'所有文件提取完成'
end