# coding=utf-8
import numpy as np
import pandas as pd
import datetime

from FY3D.Demofunction.JDay_calculate import time2mjd
from MODIS.Demofunction import timereolace

# **************************************
# fy3d和modis文件的数据过滤
# 首先计筛选std<0.013的数据
# 进行2q过滤（Assessment of Radiometric Degradation of FY -3A MERSI Reflective Solar Bands Using TOA Reflectance of Pseudoinvariant Calibration Sites）
# **************************************


input_file=r'H:\00data\TOA\MODIS\removecloud\2019\1kmstd\326(20km)\aver_month\aver_month_sz_vz_ra.xlsx'

df_base_1 = pd.read_excel(input_file, sheet_name="dh_dingbiao_modis20km",usecols=['MODIS_DateBase', 'MODIS_CNOTNAN', 'MODIS_SZ', 'MODIS_SA', 'MODIS_VZ', 'MODIS_VA','MODIS_RA', 'band', 'band_STD'])  # From an Excel file
df_base_1.dropna(inplace=True)
df_base = df_base_1[(df_base_1['MODIS_CNOTNAN'] > 50) & (df_base_1['MODIS_SZ'] < 59) & (df_base_1['MODIS_VZ'] < 39) & (df_base_1['MODIS_RA'] > 60)]
