# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import timereolace

# **************************************
# 首先将一年的日期转化为datetime64格式，
# 然后以一年的日期为横坐标对TOA进行稳定性分析，制作散点图B26波段
# **************************************


input_file=r'H:\00data\toa\MODIS\snowwatercloud\2019\dh_dingbiao2019_modis.xlsx'
output_file=r'H:\00data\toa\MODIS\snowwatercloud\2019\dh_dingbiao2019_modis_dropna.xlsx'
output_fig=r'H:\00data\toa\MODIS\snowwatercloud\2019\toa2019_modis_B26.png'
# *****************************Excel文件数据处理（去除NAN）*****************************
df = pd.read_excel(input_file,header=None)  # From an Excel file
df.dropna(inplace = True)

# 清除0值
for x in df.index:
    for y in range(6,28):
        if df.loc[x,y] == 0 :
            df.drop(x,inplace = True)
            break

# 清除B26波段小于0的值
for x in df.index:
  if df.loc[x,27] < 0 :
    df.drop(x,inplace = True)


# ****************已知年份和一年中的第几天(20210010720)，计算具体对应的年月日(MODIS数据处理)****
date_region=df[0].values.ravel()

data = []
for date in date_region:
    year = str(date)[0:4]
    day = str(date)[4:7]
    hour = str(date)[7:11]
    time =timereolace.date_conversation(year, day, hour)
    data.append(time)

df[0]=data


# 将日期转化为datatime64格式（numpy.datetime64('2021-01-01T07:20:00.000000')）
dates=[]
for date in data:
    d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    date64=np.datetime64(d)
    dates.append(date64)
df[28]=dates

# 以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）
fig, ax = plt.subplots(1, 1, figsize=(7,5), constrained_layout=True)
fontdict1 = {"size": 17, "color": "k", 'family': 'Times New Roman'}
ax.set_xlabel('Date', fontdict=fontdict1)
ax.set_ylabel('TOA Reflectance', fontdict=fontdict1)

ax.plot_date(df[28], df[27], fmt='k+',markersize=10)

#设置主刻度的定位
ax.xaxis.set_major_locator(mdates.MonthLocator())
# 设置主刻度的显示格式
# ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
#设置次刻度的定位
# ax.xaxis.set_minor_locator(mdates.MonthLocator())
ax.set_ylim((0, 0.6))
ax.set_yticks(np.arange(0, 0.6, step=0.1))
# ax.set_ylim((0, 0.1))
# ax.set_yticks(np.arange(0, 0.1, step=0.02))

ax.grid(False)
#设置刻度字体
labels=ax.get_xticklabels()+ax.get_yticklabels()
[label.set_fontname('Times New Roman') for label in labels]
#设置边框线的颜色
for spine in ['top','bottom','left','right']:
    ax.spines[spine].set_color('k')
    ax.spines[spine].set_linewidth(3)


# 更改刻度、刻度标签的外观。
ax.tick_params(left=True,bottom=True,top=True,right=True,direction='in',labelsize=14,width=2,length=4)
# ax.format_xdata = mdates.DateFormatter('% Y')
xlabels = ax.get_xticklabels()
for label in ax.get_xticklabels(which='major'):
    label.set(rotation=30, horizontalalignment='right')
# 隐藏最后一个刻度标签
xlabels[len(xlabels) - 1].set_visible(False)
# 添加题目
titlefontdict = {"size": 20, "color": "k", 'family': 'Times New Roman'}
ax.set_title('B26', titlefontdict, pad=20)
# 旋转和右对齐x标签，并向上移动轴的底部以给它们腾出空间
# fig.autofmt_xdate()

# plt.savefig(output_fig,dpi=900,bbox_inches='tight')
plt.show()

# df.to_excel(excel_writer=output_file,index=False,header = False)

