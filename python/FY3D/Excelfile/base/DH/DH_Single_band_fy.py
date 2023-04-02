# coding=utf-8
import numpy as np
import pandas as pd

# **************************************
# fy3d和modis文件的数据过滤
# 首先计筛选std<0.013的数据
# 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# **************************************

input_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\326(20km)\baseexcel\dh_dingbiao_fy3d20km.xlsx'
# *****************************Excel文件数据读取*****************************
for band in ['FY_B1', 'FY_B2', 'FY_B3', 'FY_B4']:
    band_STD=band+str('_STD')

    df_base_1 = pd.read_excel(input_file, sheet_name="dh_dingbiao_fy3d20km",usecols=['FY_DateBase','FY_CNOTNAN','FY_SZ','FY_SA','FY_VZ','FY_VA','FY_RA',band,band_STD])  # From an Excel file
    df_base_1.dropna(inplace = True)
    df_base=df_base_1[(df_base_1['FY_CNOTNAN']>50) & (df_base_1['FY_SZ']<59) & (df_base_1['FY_VZ']<39) & (df_base_1['FY_RA']>60)]

    # 将列表按每20个数据进行分割
    fy_new = np.array([])
    fy = df_base[band].values
    split_data = np.array_split(fy, len(fy) / 20 + 1)
    for data in split_data:
        filtered_data = np.zeros_like(data)
        for i in range(len(data)):
            local_mean = np.mean(data)  # 计算局部平均值
            local_std = np.std(data)  # 计算局部标准差
            # 如果该数据点偏离局部平均值超过2个局部标准差，则认为该数据点受到污染

            if abs(data[i] - local_mean) > 2 * local_std:
                filtered_data[i] = np.NAN  # 使用局部平均值替换该数据点
            else:
                filtered_data[i] = data[i]  # 如果该数据点没有受到污染，则不做处理
        fy_new = np.hstack((fy_new, filtered_data))
    df_base[band] = fy_new
    df_base.dropna(inplace=True)


    # with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
    #     df_base.to_excel(writer, sheet_name=band,index=False,header = True)
    print(band)

    datebase=df_base['FY_DateBase'].values
    year_out=[]
    month_out=[]
    day_out=[]
    for date in datebase:
        date_str=str(date)
        year=int(date_str[0:4])
        month=int(date_str[4:6])
        day=int(date_str[6:8])
        year_out.append(year)
        month_out.append(month)
        day_out.append(day)

    df_base['year']=year_out
    df_base['month']=month_out

    aver_month = df_base.groupby(['year', 'month']).mean()
    df_month = aver_month.loc[:, [band]]
    # input_file1 = r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\326(20km)\aver_month\aver_month_sz_vz_ra.xlsx'
    # with pd.ExcelWriter(input_file1, mode='a', engine='openpyxl') as writer:
    #     df_month.to_excel(writer, sheet_name="aver_month_"+str(band), index=True, header=True)
    print(band+'成功')
