# coding=utf-8
import datetime

import numpy as np
import pandas as pd

import os

from MODIS.Demofunction import timereolace

# **************************************
# excel文件去除空值
# MODIS数据日期处理为年月日（由年积日转化为年月日）
# 三年的excel文件的合并
# **************************************

# **************************************MODIS# **************************************

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

# **************************************FY3D **************************************
basefilepath=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\317(10km-6)\baseexcel'

excel_files1='dh_dingbiao2019_fy3d10km_6.xlsx'
excel_files2='dh_dingbiao2020_fy3d10km_6.xlsx'
excel_files3='dh_dingbiao2021_fy3d10km_6.xlsx'


# excel_files=[excel_files1,excel_files2,excel_files3]
# for excel_file in excel_files:
#
#     df = pd.read_excel(os.path.join(basefilepath,excel_file),header=None)  # From an Excel file
    # df.dropna(inplace = True)
#
    # # ****************已知年份和一年中的第几天(20210010720)，计算具体对应的年月日(MODIS数据处理)****
    # date_region=df[0].values.ravel()
    #
    # data = []
    # for date in date_region:
    #     year = str(date)[0:4]
    #     day = str(date)[4:7]
    #     hour = str(date)[7:11]
    #     time =timereolace.date_conversation(year, day, hour)
    #     data.append(time)
    #
    # df[0]=data
    # data=date_region

    # # 将日期转化为datatime64格式（numpy.datetime64('2021-01-01T06:25:00.000000')）
    # dates=[]
    # for date in data:
    #     d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    #     date64=np.datetime64(d)
    #     dates.append(date64)
    # df[21]=dates

    # with pd.ExcelWriter(os.path.join(basefilepath,excel_file), mode='a', engine='openpyxl') as writer:
    #     df.to_excel(writer, sheet_name="Sheet2",index=False,header = False)

# 提前要有这个output_file文件
output_file=os.path.join(basefilepath,'dh_dingbiao_fy3d10km_6.xlsx')

dfs=[]

for fn in (os.path.join(basefilepath,excel_files1),os.path.join(basefilepath,excel_files2),os.path.join(basefilepath,excel_files3)):
    dfs.append(pd.read_excel(fn,header=None))

df1=pd.concat(dfs)
with pd.ExcelWriter(output_file, mode='a', engine='openpyxl') as writer:
    df1.to_excel(writer, sheet_name="Sheet1",index=False,header = False)
# df.to_excel(excel_writer=output_file,index=False,header = False)
