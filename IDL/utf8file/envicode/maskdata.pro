;coding=utf-8
pro maskdata
  compile_opt idl2
  e=envi(/h)
  outmaskimgfile='D:\00BiShe\2data\4Moran\masktif.tif'
  
  baseimgdata='D:\00BiShe\2data\4Moran\00baseimg\imageToDriveExample2000.tif'
  shpdata='D:\00BiShe\2data\4Moran\01shpdata\city_taian.shp'
  baseraster=e.OpenRaster(baseimgdata)
  shp=e.OpenVector(shpdata)
  maskraster=ENVIVectorMaskRaster(baseraster,shp)
  
  ;DATA_IGNORE_VALUE必须设置,这样PIXEL_STATE像素状态码才会把像素值为0的数的状态码为1
  maskraster.Export, outmaskimgfile, 'TIFF', DATA_IGNORE_VALUE=0 
  
 
  maskimg= e.OpenRaster(outmaskimgfile)
  data=maskimg.GetData(band=[0])
  print,maskimg.metadata  ;没有DATA_IGNORE_VALUE，只包含BAND NAMES
  help,data
  data1=mean(data,/nan)
  print,data1
  stats = ENVIRasterStatistics(maskimg)
  print,stats.mean
  
  ;设置成临时文件，newFile为临时文件名（包括绝对路径）
  newFile = e.GetTemporaryFilename('.tif') 
  ;print,newFile
  e.Close
end