# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# **************************************
# 对FY3D和MODIS数据整合到一张图中
# 以一年的日期为横坐标对TOA进行稳定性分析，制作散点图
# **************************************

# input_file=r'H:\00data\toa\FY3D\snowwatercloud\Yang(tbb)\2019\dh_toa2019_fy3d_removecsw.xlsx'
input_file_fy3d=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\2021\QA_no\dh_toa2021_fy3d_003_NAN_dropna.xlsx'
# input_file_modis=r'C:\Users\lenovo\Desktop\toa\MODIS\snowwatercloud\2019\dh_dingbiao2019_modis_dropna.xlsx'
input_file_modis=r'H:\00data\TOA\MODIS\snowwatercloud\2021\003\QA_no\dh_dingbiao2021_modis_003_dropna.xlsx'
output_fig=r'H:\00data\TOA\3D_MODIS_HY1C\FY3D_MODIS\2021\003_MODIS_65533\fy3dcloudpro\QA_no\vz60'+'\\'
# *****************************Excel文件数据读取*****************************
df_fy3d_base = pd.read_excel(input_file_fy3d,header=None)  # From an Excel file
df_modis_base = pd.read_excel(input_file_modis,header=None)  # From an Excel file

# df_fy3d=df_fy3d_base
# df_modis=df_modis_base

# 观测天顶角的筛选
vz=60
df_fy3d=df_fy3d_base[df_fy3d_base[5]<vz]
df_modis=df_modis_base[df_modis_base[5]<vz]


modis_band=[9,10,7,8,28,12,13]
# 以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B19
for band in range(7,14):
    # figname = output_fig + 'toa2021_fy3d_modis_B{index}.png'.format(index=band - 6)
    figname = output_fig + 'toa2021_fy3d_modis_B{index}_vzlt{value}.png'.format(index=band - 6,value=vz)
    fig, ax = plt.subplots(1, 1, figsize=(7,5), constrained_layout=True)
    fontdict1 = {"size": 17, "color": "k", 'family': 'Times New Roman'}
    ax.set_xlabel('Date', fontdict=fontdict1)
    ax.set_ylabel('TOA Reflectance', fontdict=fontdict1)
    ax.plot_date(df_fy3d[1], df_fy3d[band], fmt='b+',markersize=10,label='FY3D')
    ax.plot_date(df_modis[1], df_modis[modis_band[band-7]], fmt='r+', markersize=10,label='MODIS')
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
    ax.set_title('B{b}'.format(b=band-6), titlefontdict, pad=20)
    # 旋转和右对齐x标签，并向上移动轴的底部以给它们腾出空间
    # fig.autofmt_xdate()

    legendfontdict = {"size": 10, "color": "k", 'family': 'Times New Roman'}
    plt.legend(loc="upper right", fontsize=10)

    plt.savefig(figname,dpi=900,bbox_inches='tight')
    plt.show()
# df.to_excel(excel_writer=output_file,index=False,header = False)