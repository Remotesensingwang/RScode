# coding=utf-8
import numpy as np
import pandas as pd
import datetime

from FY3D.Demofunction.JDay_calculate import time2mjd

# **************************************
# fy3d和modis根据儒略日进行时间匹配
# 首先计算儒略日，然后将两个excel文件进行匹配
# **************************************

input_fy3d_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\407(20km)\data\angle\dh_angle_fy.xlsx'
input_modis_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\407(20km)\data\angle\dh_angle_modis.xlsx'
# output_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\326(20km)\DH-modis-fy-20km.xlsx'
output_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\407(20km)\data\angle\angle.xlsx'
fyband =['F_B1', 'F_B2', 'F_B3', 'F_B4']
modisband=['M_B3', 'M_B4', 'M_B1', 'M_B2']

for band in range(0,4):

    df_modis_base = pd.read_excel(input_modis_file,sheet_name=modisband[band])  # From an Excel file
    df_fy3d_base = pd.read_excel(input_fy3d_file,sheet_name=fyband[band])  # From an Excel file

    # ****************modis数据儒略日计算****************
    jd_data_modis = []
    datevalue = df_modis_base['M_DateBase'].values
    for date in datevalue:
        d = datetime.datetime.strptime(str(date), '%Y%m%d%H%M')
        JDdate = time2mjd(d)
        jd_data_modis.append(JDdate)

    df_modis_base.loc[:,'M_JD'] = jd_data_modis

    # with pd.ExcelWriter(input_modis_file, mode='a', engine='openpyxl') as writer:
    #     df_modis_base.to_excel(writer, sheet_name="Sheet2",index=False,header = False)
    # ****************fy3d数据儒略日计算****************
    jd_data_fy3d = []
    datevalue = df_fy3d_base['F_DateBase'].values
    for date in datevalue:
        d = datetime.datetime.strptime(str(date), '%Y%m%d%H%M')
        JDdate = time2mjd(d)
        jd_data_fy3d.append(JDdate)

    df_fy3d_base.loc[:,'F_JD'] = jd_data_fy3d

    #待匹配的文件的长度（要明确这个）
    fy3d_julday_data=df_fy3d_base['F_JD'].values.ravel()
    modis_julday_data=df_modis_base['M_JD'].values.ravel()
    length=fy3d_julday_data.size
    # 根据儒略日进行时间匹配(前后60分钟)
    MODIS_Data=np.ndarray(shape=(length,10), dtype=np.float64)+np.nan
    for i in range(length):
        day_diff_time=fy3d_julday_data[i]-modis_julday_data
        # 计算满足条件的数值在数组所在的下标，需要注意np.where（）类型为元组，需要加[0],这样pos类型为数组（numpy.ndarray）！！！！！！！
        pos=np.where((day_diff_time>=-0.041667)&(day_diff_time<=0.041667))[0]
        # 防止匹配不到，即pos为空数组
        if pos.size!=0:
            minpos=np.where(day_diff_time==np.min(day_diff_time[pos]))[0]
            MODIS_Data[i,:]=df_modis_base.loc[minpos[0]].values

    df_m=pd.DataFrame(MODIS_Data)
    names = ['M_DateBase','M_SZ','M_SA','M_VZ','M_VA','M_RA',modisband[band],'M_COUNT',modisband[band]+'_C','M_JD']
    df_m.columns = names
    result = pd.concat([df_fy3d_base, df_m], axis=1)
    result.dropna(inplace = True)
    # result.to_excel(excel_writer=output_file,index=False,header = True)
    result['Ratio']=result[fyband[band]].values/result[modisband[band]].values
    result.drop(['F_COUNT','F_JD','M_COUNT','M_JD'],axis=1,inplace=True)
    with pd.ExcelWriter(output_file, mode='a', engine='openpyxl') as writer:
        result.to_excel(writer, sheet_name=modisband[band]+fyband[band], index=False, header=True)
    print(fyband[band]+'成功!')