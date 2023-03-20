# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

from MODIS.Demofunction import timereolace
from MODIS.Demofunction.Scatter_Date_Demo import Scatter_Date

# **************************************
# MODIS数据处理
# 首先将一年的日期转化为datetime64格式，
# 然后以一年的日期为横坐标对TOA进行稳定性分析，制作散点图
# **************************************


input_file=r'H:\00data\TOA\MODIS\snowwatercloud\2021\003\QA_MODIS\dh_dingbiao2021_modis_003_QA.xlsx'
output_file=r'H:\00data\TOA\MODIS\snowwatercloud\2021\003\QA_MODIS\dh_dingbiao2021_modis_003_QA_dropna.xlsx'
output_fig=r'H:\00data\TOA\MODIS\snowwatercloud\2021\003'+'\\'
# *****************************Excel文件数据处理（去除NAN）*****************************
df = pd.read_excel(input_file,header=None)  # From an Excel file
df.dropna(inplace = True)

# 清除0值
for x in df.index:
    for y in range(6,28):
        if df.loc[x,y] == 0 :
            df.drop(x,inplace = True)
            break

# 清除B26波段小于0的值
for x in df.index:
  if df.loc[x,27] < 0 :
    df.drop(x,inplace = True)

# ****************已知年份和一年中的第几天(20210010720)，计算具体对应的年月日(MODIS数据处理)****
date_region=df[0].values.ravel()

data = []
for date in date_region:
    year = str(date)[0:4]
    day = str(date)[4:7]
    hour = str(date)[7:11]
    time =timereolace.date_conversation(year, day, hour)
    data.append(time)

df[0]=data

# 将日期转化为datatime64格式（numpy.datetime64('2021-01-01T06:25:00.000000')）
dates=[]
for date in data:
    d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    date64=np.datetime64(d)
    dates.append(date64)
df[28]=dates

# 以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B7
for band in range(6,13):
    x_label='Date'
    y_label='TOA Reflectance'
    title='B{b}'.format(b=band-5)
    figname = output_fig + 'toa2021_modis_B{index}.png'.format(index=band - 5)
    Scatter_Date(df[28],df[band],x_label,y_label,title,figname)
df.to_excel(excel_writer=output_file,index=False,header = False)

