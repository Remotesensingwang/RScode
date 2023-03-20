;coding=utf-8
pro pixelStatedata
  compile_opt idl2
  e=envi(/h)
  
  includenodataimg='D:\IDLcode\code\utf8file\data\01tif\binzhou2000.tif'
  includenodataraster=e.openraster(includenodataimg)
  includenodatarasterdata=includenodataraster.getdata(band=[0],interleave='bsq',PIXEL_STATE=pixelState)
  help,includenodataraster,pixelState
  
  ;0为goodpiexs  1为NAN值
  ;print,pixelState 
 
  ;该影像元数据中包括了DATA IGNORE VALUE='-3.40282e+038'。这样下面的正确做法中pixelState和ENVIRasterStatistics函数才能用。
  ;print,includenodataraster.metadata 
  
  ;这种方法不对，裁剪完的影像包括Nodata值（即DATA IGNORE VALUE），即pixelState=1
  print,mean(includenodatarasterdata,/nan) ;值为-Inf（负无穷）
  
  ;正确做法，可以去掉NoData、NaN值
  maskedData = includenodatarasterdata
  pos = WHERE(pixelState EQ 0, count)
  IF (count NE N_Elements(maskedData)) THEN $
    maskedData = maskedData[pos]

  Print, 'Masked raster standard deviation:', mean(maskedData)
  Print, 'Masked raster minimum value:', Min(maskedData)
  Print, 'Masked raster maximum value:', Max(maskedData)
  
  
  ;也可以利用ENVIRasterStatistics函数进行栅格数据数学统计(也可以忽略NoData、NaN值)
  stats = ENVIRasterStatistics(includenodataraster)
  print,stats.mean
  
  e.close
end