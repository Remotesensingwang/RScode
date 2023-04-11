# coding=utf-8
import numpy as np
import pandas as pd

# **************************************
# DH fy3d和modis文件月均值匹配，并计算比率
# **************************************

# input_modis_file=r"H:\00data\TOA\DH\MODIS\407(20km)\data\base\aver_month_base_modis.xlsx"
input_modis_file=r'H:\00data\TOA\DH\MODIS\407(20km)\data\angle\aver_month_angle_modis.xlsx'

# input_fy3d_file=r'H:\00data\TOA\DH\FY3D\407(20km)\data\base\aver_month_base_fy.xlsx'
input_fy3d_file=r'H:\00data\TOA\DH\FY3D\407(20km)\data\angle\aver_month_angle_fy.xlsx'

# output_file=r'H:\00data\TOA\DH\H:\00data\aver_month_base.xlsx'

output_file=r'H:\00data\TOA\DH\01month\aver_month_angle.xlsx'
fyband =['F_B1', 'F_B2', 'F_B3', 'F_B4', 'F_B5', 'F_B6', 'F_B7', 'F_B8', 'F_B9', 'F_B10', 'F_B16', 'F_B17', 'F_B18']
modisband=['M_B3', 'M_B4', 'M_B1', 'M_B2', 'M_B26', 'M_B6', 'M_B7', 'M_B8', 'M_B9', 'M_B10', 'M_B17', 'M_B18', 'M_B19']
newlist=[]
for band in range(0,len(fyband)):
    df_modis_base = pd.read_excel(input_modis_file, sheet_name="aver_month_"+str(modisband[band]))  # From an Excel file
    df_fy3d_base = pd.read_excel(input_fy3d_file, sheet_name="aver_month_"+str(fyband[band]))  # From an Excel file
    # 用前一行的值填补空值
    df_modis_base.fillna(method='pad',axis=0,inplace=True)
    df_fy3d_base.fillna(method='pad',axis=0,inplace=True)

    m_year=df_modis_base['year'].values
    m_month = df_modis_base['month'].values
    m_dates = []
    for i in range(len(m_year)):
        m_date=str(int(m_year[i]))+'{:0>2d}'.format(m_month[i])
        m_dates.append(int(m_date))
    df_modis_base.loc[:, 'date'] = m_dates

    y_year=df_fy3d_base['year'].values
    y_month = df_fy3d_base['month'].values
    y_dates = []
    for i in range(len(y_year)):
        y_date=str(int(y_year[i]))+'{:0>2d}'.format(y_month[i])
        y_dates.append(int(y_date))
    df_fy3d_base.loc[:, 'date'] = y_dates

    df_modis_base.drop('year',axis=1,inplace=True)
    df_fy3d_base.drop('year',axis=1,inplace=True)

    result = pd.merge(df_fy3d_base, df_modis_base, how='outer', on=['date'])
    result[fyband[band]+'Ratio']=result[fyband[band]].values/result[modisband[band]].values
    result.drop(['month_x','month_y'],axis=1,inplace=True)
    # with pd.ExcelWriter(output_file, mode='a', engine='openpyxl') as writer:
    #     result.to_excel(writer, sheet_name=str(fyband[band]+'_'+modisband[band]), index=False, header=True)

    #  比率汇总到一个sheet表格里面
    # # rename_col=fyband[band]+str('Ratio')
    # # result1=result.rename(columns={'Ratio':rename_col})
    # result1.drop([fyband[band],modisband[band]],axis=1,inplace=True)
    # newlist.append(result1)
    print('1111')
# df = pd.concat(newlist,axis=1)
# with pd.ExcelWriter(output_file, mode='a', engine='openpyxl') as writer:
#     df.to_excel(writer, sheet_name='Ratio', index=False, header=True)
# df.to_excel(output_file,sheet_name='Ratio',index=False, header=True)
print('2222')