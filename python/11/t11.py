# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import csv
from scipy import optimize
from scipy.interpolate import interp1d

input_file = r'H:\00data\TOA\3D_MODIS_HY1C\FY3D_MODIS\RSF-copy.xlsx'

    # *****************************Excel文件数据读取*****************************
df_base= pd.read_excel(input_file,sheet_name='Sheet2')  # From an Excel file
# vz=120
# df_base=df_base_1[df_base_1[2]>120]
band0=df_base['b'].values
print(band0)
band1=df_base['band1'].values
f1 = interp1d(band1,df_base['real'])
y1 = f1(band0)
print('1111')
df_base['bb']=y1
print('2222')
s=y1*df_base['f'].values
fenzi=np.trapz(s)
fenmu=np.trapz(df_base['f'].values)
result_band1 = fenzi/fenmu
print('333')


# modis_band = ['MODIS_B3', 'MODIS_B4', 'MODIS_B1', 'MODIS_B2', 'MODIS_B6', 'MODIS_B7']
# # 35.66665288798689
# # 0.12533535519976438
#
#     # *****************************计算趋势拟合线（Y=A * x + B）*****************************
# def f_1(x, A, B):
#     return A * x + B
#     # 计算日期总数，FY3D和MODIS数据的拟合趋势线系数
# N = len(df_base[0].values)
# X_FYdata = np.arange(N) + 1  # FY3D线性方程的X
# Y_MODISdata = df_base[8].values  # MODIS线性方程的Y(MODIS线性方程的X与FY3D一样)
# # 系数计算 A,B  (Y=A*X+B)
# A_MODISdata, B_MODISdata = optimize.curve_fit(f_1, X_FYdata, Y_MODISdata)[0]
# y_modis = A_MODISdata * X_FYdata + B_MODISdata
#
# # 相对偏差的计算
#
#
# Dall_modis = 100 * (y_modis[0] - y_modis[-1]) / y_modis[0]
#
#
# Dyear_modis = (Dall_modis / N) * 365
#
# # 稳定性指标
# # index_fy3d=1
# aa_fy3d = 0
# aa_modis = 0
# for i in range(0, N):
#     b = Y_MODISdata[i] - y_modis[i]
#     aa_modis = aa_modis + np.square(b / (y_modis[0] - b / y_modis[0]))
# index_modis = np.sqrt(aa_modis / N)
# print(Dyear_modis)
# print(index_modis)