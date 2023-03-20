# coding=utf-8
import pandas as pd
import numpy as np
from math import log,pow

# 读取csv文件
input_csv=r'C:\Users\Wangxingtao\Desktop\test.xlsx'
df = pd.read_excel(input_csv)
df.info()
cc=df[df.iloc[:,5]>0.01]
cc_data=cc.values
cc.to_csv(path_or_buf=r'C:\Users\Wangxingtao\Desktop\test.csv',index=False)
print(cc)
# pos=np.where(cc_data<0.02)[0]
# print(cc_data[pos])
# print(len(cc_data[pos]))
