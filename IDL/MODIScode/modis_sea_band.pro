
pro modis_sea_band
  filename='H:\00data\MODIS\MODIS_L1data\2021\MYD021KM.A2021001.0720.061.2021001223639.hdf'
  file=filename
  MODIS_LEVEL1B_READ,File,1,Data0055,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,2,Data0067,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,3,Data0068,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,4,Data0075,/REFLECTANCE
  MODIS_LEVEL1B_READ,File,5,Data0087,/REFLECTANCE

  
  refSB_band_data=[[[Data0055]],[[Data0067]],[[Data0068]],[[Data0075]],[[Data0087]]]
  
  result_tiff_name_cloud='H:\00data\MODIS\MODIS_L1data\tifout\202100112345.tif'
  write_tiff,result_tiff_name_cloud,refSB_band_data,planarconfig=2,compression=1,/float
  
end