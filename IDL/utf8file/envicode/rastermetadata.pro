;coding=utf-8
pro rastermetadata
  compile_opt idl2
  
  e=envi(/h)
  imgdata='D:\00BiShe\2data\4Moran\00baseimg\imageToDriveExample2000.tif'
  ;sjimg='D:\02FY3D\山建影像\sdjzimg.tif'
  sjimg='D:\02FY3D\A202203090585162088\out\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_TOA.tif'
  raster=e.openraster(sjimg)
  help,raster.metadata       ;ENVIRasterMetadata对像
  print,raster.metadata.tags ;查看元数据的标签名（另一个属性为count元数据的数量）
  print,raster.metadata      ;打印元数据标签名和具体的值
  e.close
end