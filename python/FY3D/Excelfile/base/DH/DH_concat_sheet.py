# coding=utf-8
import numpy as np
import pandas as pd

# **************************************
# DH sheet表格合并
# **************************************

input_file=r'H:\00data\TOA\DH\01month\aver_month_angle.xlsx'
fyband =['F_B1', 'F_B2', 'F_B3', 'F_B4', 'F_B5', 'F_B6', 'F_B7', 'F_B8', 'F_B9', 'F_B10', 'F_B16', 'F_B17', 'F_B18']
modisband=['M_B3', 'M_B4', 'M_B1', 'M_B2', 'M_B26', 'M_B6', 'M_B7', 'M_B8', 'M_B9', 'M_B10', 'M_B17', 'M_B18', 'M_B19']
newlist=[]
for band in range(0,len(fyband)):
    df_base = pd.read_excel(input_file, sheet_name=fyband[band]+'_'+modisband[band])  # From an Excel file
    rename_col=fyband[band]+str('Ratio')
    df_base.rename(columns={'Ratio':rename_col},inplace=True)
    df_base.drop([fyband[band],modisband[band]],axis=1,inplace=True)
    newlist.append(df_base)
reslut = pd.concat(newlist,axis=1)
with pd.ExcelWriter(input_file, mode='a', engine='openpyxl') as writer:
    reslut.to_excel(writer, sheet_name='Ratio', index=False, header=True)
# df.to_excel(output_file,sheet_name='Ratio',index=False, header=True)
print('1111')