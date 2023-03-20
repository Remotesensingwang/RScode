# coding=utf-8
import pandas as pd
import numpy as np
from math import log,pow
# csv文件读取
def readcsv(path):
    data=pd.read_csv(path)
    return data

# 对原始的站点数据进行处理，即计算计算AOD_550nm的值
def calAOD_main():
    input_basecsv=r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\20190328_20190402_Beijing-CAMS(AOD).csv' #下载的原始AOD站点数据
    out_csv = r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\20190328_20190402_Beijing-CAMS.csv' #处理原始AOD站点后的数据

    df=readcsv(input_basecsv)

    # 取所需的列及其值
    aod_500 = df['AOD_500nm-AOD']
    aod_675 = df['AOD_675nm-AOD']
    # print(aod_500)  #serie类型
    aod_500_data = aod_500.values  # 数组类型（即numpy.ndarray）
    aod_675_data = aod_675.values  # 数组类型（即numpy.ndarray）
    length = aod_675.size

    # 计算AOD_550nm的值(基于深度学习反演区域气溶胶光学厚度)
    aod = np.ndarray(shape=(length,), dtype=np.float64) + np.nan
    for i in range(length):
        data = aod_500_data[i] / aod_675_data[i]
        if data > 0:
            a = log(data) / log(500.0 / 675.0)
            b = aod_500_data[i] / pow(500, -a)
            aod[i] = b * pow(550, -a)
    # 定义新列名并添加该列的值
    df['AOD_550nm-AOD'] = aod
    # 去除“AOD_550nm-AOD”这列空值所在的行
    df.dropna(subset=['AOD_550nm-AOD'], inplace=True)
    # 保存
    df.to_csv(path_or_buf=out_csv, index=False)

# 时间匹配（时间匹配改进版（pandas））
def timematcging(df_AOD,df_file,df_AOD_fields,df_file_fields):
    AOD_julday = df_AOD[df_AOD_fields]
    file_julday = df_file[df_file_fields]

    # 待匹配的文件的长度（要明确这个）
    length = file_julday.size
    Avg_AOD_550 = np.ndarray(shape=(length,), dtype=np.float64) + np.nan

    # 根据儒略日进行时间匹配（前后30分钟的数据）
    for i in range(length):
        data = file_julday[i] - AOD_julday
        # form=df_AOD[(data >= -0.020833333) & (data <= 0.020833333)]
        # aod550=form['AOD_550nm-AOD']
        # aodmean=aod550.mean()
        # Avg_AOD_550[i]=aodmean
        # print('qwwqeqw')
        Avg_AOD_550[i] = df_AOD[(data >= -0.020833333) & (data <= 0.020833333)]['AOD_550nm-AOD'].mean()
    return Avg_AOD_550


def timematcging_main():
    filepath=r'D:\02FY3D\AERONETData\file_juldaytimes.csv' #待匹配的文件
    AODpath=r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\20190328_20190402_Beijing-CAMS.csv' #AOD站点数据
    outcsvtimeatchingfile=r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\file_timematching.csv' #最终AOD站点与文件匹配的数据

    df_AOD_fields='Day_of_Year(Fraction)'  #所需AOD站点数据的列名
    df_file_fields='Day_of_Year' #所需待文件数据的列名

    df_file=readcsv(filepath)
    df_AOD=readcsv(AODpath)

    Avg_AOD_550=timematcging(df_AOD,df_file,df_AOD_fields,df_file_fields)
    # 文件保存
    df_file['avg_AOD_550nm-AOD']=Avg_AOD_550
    df_file.dropna(subset=['avg_AOD_550nm-AOD'],inplace=True)
    df_file.to_csv(path_or_buf=outcsvtimeatchingfile,index=False)
    print('文件保存成功')
def main():
    calAOD_main()
    timematcging_main()


if __name__ == '__main__':
    main()