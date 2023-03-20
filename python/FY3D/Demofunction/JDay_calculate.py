# coding=utf-8

# **************************************
# datetime类转mjd
# dateT 类型为 d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
# 格式转换
# **************************************


import datetime

import pandas as pd


#datetime类转mjd
def time2mjd(dateT):
    t0=datetime.datetime(1858,11,17,0,0,0,0)#简化儒略日起始日
    mjd=(dateT-t0).days
    mjd_s=dateT.hour*3600.0+dateT.minute*60.0+dateT.second+dateT.microsecond/1000000.0
    return (mjd+mjd_s/86400.0)+2400000.500000004

if __name__ == '__main__':

    df=pd.read_excel(r"D:\test.xlsx",header=None)  # From an Excel file

    data=[]
    datevalue=df[0].values
    for date in datevalue:
        d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
        JDdate = time2mjd(d)
        data.append(JDdate)
    df[0]=data
    df.to_excel(r'D:\tes1.xlsx',index=False,header = False)