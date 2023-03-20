# coding=utf-8

import pandas as pd

import os


# **************************************
# excel文件合并+NAN去除
# **************************************

# basefilepath=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\03km'

# excel_files1='dh_dingbiao2019_modis_dropna.xlsx'
# excel_files2='dh_dingbiao2020_modis_dropna.xlsx'
# excel_files3='dh_dingbiao2021_modis_dropna.xlsx'

# 1kmplus
# excel_files1='dh_dingbiao2019_modis1km_2.xlsx'
# excel_files2='dh_dingbiao2020_modis1km_2.xlsx'
# excel_files3='dh_dingbiao2021_modis1km_2.xlsx'

# 0.3kmplus
# excel_files1='dh_dingbiao2019_modis003km_2.xlsx'
# excel_files2='dh_dingbiao2020_modis003km_2.xlsx'
# excel_files3='dh_dingbiao2021_modis003km_2.xlsx'

# **************************************FY3D**************************************
basefilepath=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\03km'
# 1kmplus
excel_files1='dh_dingbiao2019_fy3d003km_2.xlsx'
excel_files2='dh_dingbiao2020_fy3d003km_2.xlsx'
excel_files3='dh_dingbiao2021_fy3d003km_2.xlsx'


output_file=os.path.join(basefilepath,'dh_dingbiao_fy3d003km_2.xlsx')

dfs=[]

for fn in (os.path.join(basefilepath,excel_files1),os.path.join(basefilepath,excel_files2),os.path.join(basefilepath,excel_files3)):
    dfs.append(pd.read_excel(fn,sheet_name="Sheet2",header=None))

df=pd.concat(dfs)
df.dropna(inplace = True)
with pd.ExcelWriter(output_file, mode='a', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name="Sheet1",index=False,header = False)
# df.to_excel(excel_writer=output_file,index=False,header = False)


