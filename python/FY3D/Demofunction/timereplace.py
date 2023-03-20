# coding=utf-8
import pandas as pd
import datetime

# **************************************
# 已知年份和一年中的第几天，计算具体对应的年月日(MODIS数据处理)
# 格式转换
# **************************************

# 已知年份和一年中的第几天
# 计算具体的日期
def date_conversation(year, day, hour):
    # 输入的字符串类型的年和日转换为整型
    year = int(year)
    day = int(day)
    # first_day：此年的第一天
    # 类型：datetime
    first_day = datetime.datetime(year, 1, 1)
    # 用一年的第一天+天数-1，即可得到我们期望的日期
    # -1是因为当年的第一天也算一天
    wanted_day = first_day + datetime.timedelta(day - 1)
    # 返回需要的字符串形式的日期
    wanted_day = datetime.datetime.strftime(wanted_day, '%Y%m%d')
    day = wanted_day + hour
    return day

if __name__ == '__main__':

    df=pd.read_excel(r"D:\test.xlsx",header=None)  # From an Excel file

    data=[]
    datevalue=df[0].values
    for date in datevalue:
        year=str(date)[0:4]
        day=str(date)[4:7]
        hour=str(date)[7:11]
        time=date_conversation(year,day,hour)
        data.append(time)

    df[0]=data
    df.to_excel(r'D:\tes1.xlsx',index=False,header = False)

