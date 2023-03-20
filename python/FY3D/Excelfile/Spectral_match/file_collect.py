# coding=utf-8
import linecache
import os
from glob import glob
import numpy as np
import pandas as pd

# **************************************
# 数据的提取
# 读取Radcalnet下的*.output的所以文件，提取 24-235行的数据（400-2500nm）
# **************************************

srcdirfilepath=r'C:\Users\lenovo\Downloads\Radcalnet_alldata\BTCN' # output文件读取路径
outputpath=r'C:\Users\lenovo\Downloads\Radcalnet_alldata\00'  #xlsx文件输出路径

def get_line_context(file_path, line_number):
    list_s=linecache.getline(file_path, line_number).strip().split()
    arr=np.array(list_s,dtype=np.float64)
    return arr

# glob获得路径下所有文件，可根据需要修改
src_file_list = glob(str(srcdirfilepath + '\\') + '*.output')
for srcfile in src_file_list:
    fpath, fname = os.path.split(srcfile)  # 分离文件名和路径
    Data = np.ndarray(shape=(211, 14), dtype=np.float64) + np.nan
    for num in range(24,235):
        Data[num - 24, :] = get_line_context(srcfile,num)
    df=pd.DataFrame(Data)
    names = ['band', '09:00','09:30','10:00','10:30','11:00','11:30','12:00','12:30','13:00','13:30','14:00','14:30','15:00']
    df.columns = names
    df.to_excel(excel_writer=os.path.join(outputpath,fname[0:22]+str('.xlsx')),index=False)
    # print('1')