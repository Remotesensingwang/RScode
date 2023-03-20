# coding=utf-8
import pandas as pd
import numpy as np
from math import log,pow

# 读取csv文件
input_csv=r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\20190328_20190402_Beijing-CAMS(AOD).csv'
df = pd.read_csv(input_csv)
# print(df.info())

# 取所需的列及其值
aod_500= df['AOD_500nm-AOD']
aod_675=df['AOD_675nm-AOD']
# print(aod_500)  #serie类型
aod_500_data=aod_500.values # 数组类型（即numpy.ndarray）
aod_675_data=aod_675.values # 数组类型（即numpy.ndarray）
length=aod_675.size

# 计算AOD_550nm的值(基于深度学习反演区域气溶胶光学厚度)
aod=np.ndarray(shape=(length,), dtype=np.float64)+np.nan
for i in range(length):
    data=aod_500_data[i]/aod_675_data[i]
    if data > 0:
        a=log(data)/log(500.0/675.0)
        b=aod_500_data[i]/pow(500,-a)
        aod[i]=b*pow(550,-a)

# 定义新列名并添加该列的值
df['AOD_550nm-AOD']=aod

#去除“AOD_550nm-AOD”这列空值所在的行
df.dropna(subset=['AOD_550nm-AOD'],inplace=True)
# 保存
out_csv=r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\20190328_20190402_Beijing-CAMS.csv'
df.to_csv(path_or_buf=out_csv,index=False)

# 时间匹配（站点前后30分钟的平均值）
df_file = pd.read_csv(r'D:\02FY3D\AERONETData\file_juldaytimes.csv') #待匹配的文件
df_AOD = pd.read_csv(out_csv)
# 读取所需列的数据
AOD_julday=df_AOD['Day_of_Year(Fraction)']
file_julday=df_file['juldaytime']
AOD_julday_data=AOD_julday.values # 数组类型（即numpy.ndarray）
file_julday_data=file_julday.values  # 数组类型（即numpy.ndarray）

#待匹配的文件的长度（要明确这个）
length=file_julday.size

# 根据儒略日进行时间匹配(前后30分钟)
Avg_AOD_550=np.ndarray(shape=(length,), dtype=np.float64)+np.nan
for i in range(length):
    day_diff_time=file_julday_data[i]-AOD_julday_data

    # 计算满足条件的数值在数组所在的下标，需要注意np.where（）类型为元组，需要加[0],这样pos类型为数组（numpy.ndarray）！！！！！！！
    pos=np.where((day_diff_time>=-0.020833333)&(day_diff_time<=0.020833333))[0]
    # 防止匹配不到，即pos为空数组
    if pos.size!=0:
        AOD_550=df_AOD['AOD_550nm-AOD'][pos]
        Avg_AOD_550[i]=np.mean(AOD_550.values)
#     print(pos)

# 定义新列名并添加该列的值
df_file['avg_AOD_550nm-AOD']=Avg_AOD_550
#去除“avg_AOD_550nm-AOD”这列空值所在的行
df_file.dropna(subset=['avg_AOD_550nm-AOD'],inplace=True)
# df_file.to_string()
df_file.to_csv(path_or_buf=r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\file_timematching.csv',index=False)
