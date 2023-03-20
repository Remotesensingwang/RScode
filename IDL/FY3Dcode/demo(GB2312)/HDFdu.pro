;coding=GB2312
;HDF数据读取
pro HDFdu
;  a=[1,2,3]
;  b=a[2,0]
;  print,a,b
  file_id = H5F_OPEN('C:\Users\Wangxingtao\Downloads\MOD021KM.A2010228.0800.005.hdf')
  ;打开Data这个群组
  group_id=H5G_OPEN(file_id,'MODIS_SWATH_Type_L1B')
  ;H5D_OPEN打开这个叫Data数据集中的数据（EV_1KM_RefSB）
  dataset_id=H5D_OPEN(file_id,'/Data/EV_1KM_RefSB')
  ;读取数据集中的数据
  SdsData1=H5D_READ(dataset_id)
  help,sdsdata1
  ;读取属性可用
   DataCreatingTime_id= H5A_OPEN_Name(file_id,'Data Creating Time')
;  Slope_id=H5A_OPEN_Name(dataset_id,'Slope')
   DataCreatingTime=H5A_READ(DataCreatingTime_id)
;  Slope1=H5A_READ(Slope_id)
;  numD=N_Elements(SdsData1[*,*,3])
  ;print,SdsData1[*,*,0],numD
  print,DataCreatingTime,format='(A8)'
  h5d_close,file_id 
end
