# coding=utf-8
import numpy as np
import pandas as pd
import datetime

from FY3D.Demofunction.JDay_calculate import time2mjd

# **************************************
# fy3d和modis根据儒略日进行时间匹配
# 首先计算儒略日，然后将两个excel文件进行匹配
# **************************************




# input_modis_file=r'H:\00data\TOA\MODIS\removecloud\1kmstd\dh_dingbiao_modis_1km.xlsx'
# input_fy3d_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\dh_dingbiao_fy3d_1km.xlsx'
# output_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\dh-fy3-modis-1km.xlsx'

# input_modis_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\311\dh_dingbiao_modisd1km_4.xlsx'
# input_fy3d_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\311\dh_dingbiao_fy3d1km_4.xlsx'
# output_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\311\dh-fy3-modis-20km_4.xlsx'

# input_fy3d_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\315(20km-5)\dh_dingbiao_fy3d1km_5.xlsx'
# input_modis_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\315(20km-5)\dh_dingbiao_modis1km_5.xlsx'
# input_fy3d_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\317(10km-6)\dh_dingbiao_fy3d10km_6.xlsx'
# input_modis_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\317(10km-6)\dh_dingbiao_modis10km_6.xlsx'
output_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\315(20km-5)\dh-fy3-modis-20km_5.xlsx'

input_fy3d_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\20km\dh_dingbiao_fy3d20km_5-RA.xlsx'
input_modis_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\20km\dh_dingbiao_modisd20km_4-RA.xlsx'


# df_modis_base = pd.read_excel(input_modis_file,header=None)  # From an Excel file
# df_fy3d_base = pd.read_excel(input_fy3d_file,header=None)  # From an Excel file

df_modis_base = pd.read_excel(input_modis_file,sheet_name="2q+stdlt0.010")  # From an Excel file
df_fy3d_base = pd.read_excel(input_fy3d_file,sheet_name="2q+stdlt0.010-RA")  # From an Excel file

# df_modis_base.dropna(inplace = True)
# df_fy3d_base.dropna(inplace = True)
# 观测天顶角的筛选
# vz=38
# df_modis=df_modis_base[df_modis_base[5]<vz]

# ****************modis数据儒略日计算****************
jd_data_modis = []
datevalue = df_modis_base['MODIS_DateBase'].values
for date in datevalue:
    d = datetime.datetime.strptime(str(date), '%Y%m%d%H%M')
    JDdate = time2mjd(d)
    jd_data_modis.append(JDdate)

df_modis_base.loc[:,'MODIS_JD'] = jd_data_modis

# with pd.ExcelWriter(input_modis_file, mode='a', engine='openpyxl') as writer:
#     df_modis_base.to_excel(writer, sheet_name="Sheet2",index=False,header = False)



# ****************fy3d数据儒略日计算****************
jd_data_fy3d = []
datevalue = df_fy3d_base['FY_DateBase'].values
for date in datevalue:
    d = datetime.datetime.strptime(str(date), '%Y%m%d%H%M')
    JDdate = time2mjd(d)
    jd_data_fy3d.append(JDdate)

df_fy3d_base.loc[:,'FY_JD'] = jd_data_fy3d

# with pd.ExcelWriter(input_fy3d_file, mode='a', engine='openpyxl') as writer:
#     df_fy3d_base.to_excel(writer, sheet_name="Sheet2",index=False,header = False)


# df_fy3d = pd.read_excel(input_fy3d_file,sheet_name="Sheet2",header=None)  # From an Excel file
# df_modis = pd.read_excel(input_modis_file,sheet_name="Sheet2",header=None)  # From an Excel file

# df_fy3d.dropna(inplace = True)
#
# with pd.ExcelWriter(input_fy3d_file, mode='a', engine='openpyxl') as writer:
#     df_fy3d.to_excel(writer, sheet_name="Sheet3",index=False,header = False)


#待匹配的文件的长度（要明确这个）

fy3d_julday_data=df_fy3d_base['FY_JD'].values.ravel()
modis_julday_data=df_modis_base['MODIS_JD'].values.ravel()
length=fy3d_julday_data.size
# 根据儒略日进行时间匹配(前后60分钟)
MODIS_Data=np.ndarray(shape=(length,13), dtype=np.float64)+np.nan
for i in range(length):
    day_diff_time=fy3d_julday_data[i]-modis_julday_data

    # 计算满足条件的数值在数组所在的下标，需要注意np.where（）类型为元组，需要加[0],这样pos类型为数组（numpy.ndarray）！！！！！！！
    pos=np.where((day_diff_time>=-0.041667)&(day_diff_time<=0.041667))[0]
    # 防止匹配不到，即pos为空数组
    if pos.size!=0:
        minpos=np.where(day_diff_time==np.min(day_diff_time[pos]))[0]
        MODIS_Data[i,:]=df_modis_base.loc[minpos[0]].values

df_m=pd.DataFrame(MODIS_Data)
result = pd.concat([df_fy3d_base, df_m], axis=1)
result.dropna(inplace = True)
# result.to_excel(excel_writer=output_file,index=False,header = True)
with pd.ExcelWriter(input_fy3d_file, mode='a', engine='openpyxl') as writer:
    result.to_excel(writer, sheet_name="modis-fy3dRA-0.010", index=False, header=True)
# # print('1')