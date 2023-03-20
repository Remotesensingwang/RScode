;coding=utf-8
pro rasterlearn
  compile_opt idl2
  e=envi(/h)
  
  imgdata='D:\00BiShe\2data\4Moran\00baseimg\imageToDriveExample2000.tif'
  sjimg='D:\02FY3D\山建影像\sdjzimg.tif'
  sjraster=e.openraster(sjimg)
  print,sjraster.interleave ; sjimg其类型为'BIP',如果不设置interleave='bsq',则返回的sjrasterdata数组为[通道,列,行]
  sjrasterdata=sjraster.getdata(band=[0],interleave='bsq',PIXEL_STATE=pixelState)
  help,sjrasterdata,pixelState
  
  ;创建栅格并保持为临时文件 
  ;file = e.GetTemporaryFilename()
  ;maskRaster = ENVIRaster(sjrasterdata,uri=file,interleave='bsq')
  ;maskRaster.Save
  
  ;ENVIRaster.Export 导出（method）
  
  ;ENVISubsetRaster 虚拟栅格,继承了ENVIRaster所有的属性和方法
  ;SubRaster = ENVISubsetRaster(Raster, BANDS=0)
  ;SubRaster.Export, '路径', 'TIFF'
  
  ;栅格数据数学统计(可以忽略NoData值)
  stats = ENVIRasterStatistics(sjraster)
  print,stats.mean
  print,mean(sjrasterdata,/nan)
  e.close
end

  