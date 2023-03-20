# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

from MODIS.mapping.Scatter_Date_Demo import Scatter_Date

# **************************************
# MODIS数据处理
# 首先将一年的日期转化为datetime64格式，
# 然后以一年的日期为横坐标对TOA进行稳定性分析，制作散点图
# **************************************


input_file=r'H:\00data\HY1C\2021L1B\TOA\all\dh_toa2021_HY1C_.xlsx'
output_file=r'H:\00data\HY1C\2021L1B\TOA\all\dh_toa2021_HY1C_dropna.xlsx'
output_fig=r'H:\00data\HY1C\2021L1B\TOA\all'+'\\'
# *****************************Excel文件数据处理（去除NAN）*****************************
df = pd.read_excel(input_file,header=None)  # From an Excel file
df.dropna(inplace = True)

# ****************已知年份和一年中的第几天(20210010720)，计算具体对应的年月日(MODIS数据处理)****
date_region=df[0].values.ravel()

# 将日期转化为datatime64格式（numpy.datetime64('2021-01-01T06:25:00.000000')）
dates=[]
for date in date_region:
    d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    date64=np.datetime64(d)
    dates.append(date64)
df[14]=dates

# 以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B7
for band in range(6,14):
    x_label='Date'
    y_label='TOA Reflectance'
    title='B{b}'.format(b=band-5)
    figname = output_fig + 'toa2021_hy1c_B{index}.png'.format(index=band - 5)
    Scatter_Date(df[14],df[band],x_label,y_label,title,figname)
df.to_excel(excel_writer=output_file,index=False,header = False)

