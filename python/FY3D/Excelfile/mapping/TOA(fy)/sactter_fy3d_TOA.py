# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# **************************************
# FY3D数据处理
# 首先将一年的日期转化为datetime64格式，
# 然后以一年的日期为横坐标对TOA进行稳定性分析，制作散点图
# **************************************


input_file=r'H:\00data\TOA\FY3D\snowwatercloud\Yangpro\2021\dh_toa2021_fy3d003.xlsx'
output_file=r'H:\00data\TOA\FY3D\snowwatercloud\Yangpro\2021\dh_toa2021_fy3d003_dropna.xlsx'
output_fig=r'H:\00data\TOA\FY3D\snowwatercloud\Yangpro\2021'+'\\'
# *****************************Excel文件数据处理（去除NAN）*****************************
df = pd.read_excel(input_file,header=None)  # From an Excel file
df.dropna(inplace = True)

# **************************************
# Yang (2019)
# 清除B6波段大于0.4的值
# for x in df.index:
#   if df.loc[x,11] > 0.4 :
#     df.drop(x,inplace = True)
# **************************************


# **************************************
# Yang (2020)
# 清除B7波段小于0.2的值 或者B7大于0.4的值
# for x in df.index:
#   if df.loc[x,12] < 0.2 or df.loc[x,12] > 0.4:
#     df.drop(x,inplace = True)
# **************************************


# **************************************
# Yang (2021)
# 清除B3波段大于0.4的值(2020)、2021(0.45)、2019（）
# for x in df.index:
#   if df.loc[x,8] > 0.4 :
#     df.drop(x,inplace = True)
#
# # 清除B6波段小于0.36的值
# for x in df.index:
#   if df.loc[x,11] > 0.36 :
#     df.drop(x,inplace = True)
# # 清除B7波段小于0.2的值
# for x in df.index:
#   if df.loc[x,12] < 0.2 :
#     df.drop(x,inplace = True)
# **************************************

# 清除负值
for x in df.index:
    for y in range(6,25):
        if df.loc[x,y] <= 0 :
            df.drop(x,inplace = True)
            break

#获取日期数据（202101010625）
date_region=df[0].values.ravel()

# 将日期转化为datatime64格式（numpy.datetime64('2021-01-01T06:25:00.000000')）
dates=[]
for date in date_region:
    d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    date64=np.datetime64(d)
    dates.append(date64)
df[25]=dates

# 以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B19
for band in range(13,21):
    figname = output_fig + 'toa2019_fy3d_B{index}.png'.format(index=band - 5)
    fig, ax = plt.subplots(1, 1, figsize=(7,5), constrained_layout=True)
    fontdict1 = {"size": 17, "color": "k", 'family': 'Times New Roman'}
    ax.set_xlabel('Date', fontdict=fontdict1)
    ax.set_ylabel('TOA Reflectance', fontdict=fontdict1)
    ax.plot_date(df[25], df[band], fmt='k+',markersize=10)
    # ax.plot_date(df[24], df[band], fmt='r+', markersize=10)
    #设置主刻度的定位
    ax.xaxis.set_major_locator(mdates.MonthLocator())
    # 设置主刻度的显示格式
    # ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
    #设置次刻度的定位
    ax.xaxis.set_minor_locator(mdates.MonthLocator())

    ax.set_ylim((0, 0.6))
    ax.set_yticks(np.arange(0, 0.6, step=0.1))
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
    xlabels=ax.get_xticklabels()
    for label in ax.get_xticklabels(which='major'):
        label.set(rotation=30, horizontalalignment='right')
    xlabels[len(xlabels)-1].set_visible(False)
    # 添加题目
    titlefontdict = {"size": 20, "color": "k", 'family': 'Times New Roman'}
    ax.set_title('B{b}'.format(b=band-5), titlefontdict, pad=20)
    # 旋转和右对齐x标签，并向上移动轴的底部以给它们腾出空间
    # fig.autofmt_xdate()
    # figname=output_fig+'toa2019_fy3d_B{index}.png'.format(index=band-5)
    # plt.savefig(figname,dpi=900,bbox_inches='tight')
    plt.show()
df.to_excel(excel_writer=output_file,index=False,header = False)

