;coding=GB2312
pro zz
  basetime=JULDAY(12,31,2020,00,00,00)
  ;print,basetime,format='(d)'
  time=JULDAY(01,02,2021,05,30,14)
  time_q30=JULDAY(01,02,2021,05,00,14)
  time_h30=JULDAY(01,02,2021,06,00,14)
  ;time_difference=time_q30-time  ; -0.020833333
  time_difference=time_h30-time
  
  ;print,time_difference 
  
  time1=time-basetime
  ;print,time1
   
   
   ;tiff��ȡ
  imgdata=read_tiff('D:\02FY3D\A202203090585162088\out\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_TOA.tif',interleave=2)

  help,imgdata
  ;print,imgdata
  
  
  
  compile_opt idl2
  e=envi(/h)

  sjimg='D:\02FY3D\A202203090585162088\out\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_TOA.tif'
  sjraster=e.openraster(sjimg)
  print,sjraster.interleave ; sjimg������Ϊ'BIP',���������interleave='bsq',�򷵻ص�sjrasterdata����Ϊ[ͨ��,��,��]
  sjrasterdata=sjraster.getdata(band=[0],interleave='bsq',PIXEL_STATE=pixelState)
  help,sjrasterdata,pixelState
  print,sjrasterdata
  ;դ��������ѧͳ��(���Ժ���NoDataֵ)
  stats = ENVIRasterStatistics(sjraster)
  print,stats.mean
  e.close
  
 
end