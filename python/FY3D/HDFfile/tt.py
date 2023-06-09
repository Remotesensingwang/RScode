# # coding=utf-8
# import numpy as np
# import pandas as pd
# import datetime
#
# from FY3D.Demofunction.JDay_calculate import time2mjd
# from MODIS.Demofunction import timereolace
#
# # **************************************
# # fy3d和modis文件的数据过滤
# # 首先计筛选std<0.013的数据
# # 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# # **************************************
#
# input_file=r'H:\00data\MODIS\DCC\TOA\DCC_2019_modis-2.xlsx'
#
# # *****************************Excel文件数据读取*****************************
# df_base_1 = pd.read_excel(input_file, sheet_name="Sheet1")  # From an Excel file
# df_base_1.dropna(inplace = True)
# df_base=df_base_1[df_base_1['MODIS_B1_STD']<0.1]
#
#
# # ****************已知年份和一年中的第几天(20210010720)，计算具体对应的年月日(MODIS数据处理)****
# # date_region=df_base['MODIS_DateBase'].values.ravel()
# #
# # data = []
# # for date in date_region:
# #         year = str(date)[0:4]
# #         day = str(date)[4:7]
# #         hour = str(date)[7:11]
# #         time =timereolace.date_conversation(year, day, hour)
# #         data.append(time)
# # df_base['MODIS_DateBase']=data
#
#
#
# # for fyband in ['FY_B1','FY_B2','FY_B3','FY_B4'] :
# for fyband in ['MODIS_B1']:
#     # 将列表按每20个数据进行分割
#     fy_new=np.array([])
#     fy=df_base[fyband].values
#     # fyb[i]=df_base['FY_B{indes}'.format(indes=i)].values
#     split_data = np.array_split(fy,len(fy)/60+1)
#     split_data = [0]
#     for data in split_data:
#         data=df_base['MODIS_B1'].values
#         filtered_data = np.zeros_like(data)
#         for i in range(len(data)):
#             local_mean = np.mean(data)  # 计算局部平均值
#             local_std = np.std(data)  # 计算局部标准差
#             # 如果该数据点偏离局部平均值超过2个局部标准差，则认为该数据点受到污染
#
#             if abs(data[i] - local_mean) > 2 * local_std:
#                 filtered_data[i] = np.NAN  # 使用局部平均值替换该数据点
#             else:
#                 filtered_data[i] = data[i]  # 如果该数据点没有受到污染，则不做处理
#         fy_new = np.hstack((fy_new, filtered_data))
#     df_base[fyband]=fy_new
# df_base.dropna(inplace = True)
# # 626
#
# with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
#         df_base.to_excel(writer, sheet_name="2q+stdlt0.1",index=False,header = True)
# print('111')
from MODIS.Demofunction import timereolace

time = timereolace.date_conversation('2019', '244', '0525')
print(time)