# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import csv
from scipy import optimize

# **************************************
# 对包含FY3D和MODIS数据的EXCEL文件进行数学分析，计算稳定性评价指标
# 注意该excel文件已完成FY3D和MODIS日期数据匹配
# 评价指标为
# **************************************

input_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\03km\dh-fy3-modis-003km_2.xlsx'
# output_fig=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\plot'+'\\'

# *****************************Excel文件数据读取*****************************
df_base = pd.read_excel(input_file, sheet_name="Sheet1")  # From an Excel file

modis_band=['MODIS_B3','MODIS_B4','MODIS_B1','MODIS_B2','MODIS_B6','MODIS_B7']
fy_band=['FY_B1','FY_B2','FY_B3','FY_B4','FY_B6','FY_B7']


# *****************************计算趋势拟合线（Y=A * x + B）*****************************
def f_1(x, A, B):
    return A * x + B


# *****************************以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B7*****************************
# band=5
with open(r"H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\03km\plot\test-003km-21.csv", "w") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["band", "Relative_bias", "Dall_fy3d", "Dall_modis", "Dyear_fy3d", "Dyear_modis", "index_fy3d", "index_modis"])
    for band in range(0,6):
        # 计算日期总数，FY3D和MODIS数据的拟合趋势线系数
        N = len(df_base['FY_DateBase'].values)
        X_FYdata=np.arange(N)+1   #FY3D线性方程的X
        Y_FYdata=df_base[fy_band[band]].values #FY3D线性方程的Y
        Y_MODISdata=df_base[modis_band[band]].values #MODIS线性方程的Y(MODIS线性方程的X与FY3D一样)
        # 系数计算 A,B  (Y=A*X+B)
        A_FYdata, B_FYdata = optimize.curve_fit(f_1, X_FYdata,Y_FYdata)[0]
        A_MODISdata, B_MODISdata = optimize.curve_fit(f_1, X_FYdata, Y_MODISdata)[0]
        y_fy = A_FYdata * X_FYdata + B_FYdata
        y_modis = A_MODISdata * X_FYdata + B_MODISdata

        # 相对偏差的计算
        Relative_bias=100*(y_fy[-1]-np.mean(Y_MODISdata))/np.mean(Y_MODISdata)

        # 总/年衰减率计算
        Dall_fy3d=100*(y_fy[0]-y_fy[-1])/y_fy[0]
        Dall_modis=100*(y_modis[0]-y_modis[-1])/y_modis[0]

        Dyear_fy3d=(Dall_fy3d/N)*365
        Dyear_modis=(Dall_modis/N)*365

        # 稳定性指标
        # index_fy3d=1
        aa_fy3d=0
        aa_modis=0
        for i in range(0,N):
            a=Y_FYdata[i] - y_fy[i]
            b=Y_MODISdata[i]-y_modis[i]
            aa_fy3d=aa_fy3d+np.square(a/(y_fy[0]-a/y_fy[0]))
            aa_modis=aa_modis+np.square(b/(y_modis[0]-b/y_modis[0]))
        index_fy3d=np.sqrt(aa_fy3d/N)
        index_modis=np.sqrt(aa_modis/N)
        # 0.00921570397694171
        # df.to_excel(excel_writer=output_file,index=False,header = False)
        result= [band, Relative_bias, Dall_fy3d,Dall_modis,Dyear_fy3d,Dyear_modis,index_fy3d,index_modis]
        #写入多行用writerows
        writer.writerow(result)
print('1')