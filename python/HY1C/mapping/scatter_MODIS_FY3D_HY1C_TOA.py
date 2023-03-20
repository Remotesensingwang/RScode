# coding=utf-8
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# **************************************
# 对HY1C、FY3D和MODIS数据整合到一张图中
# 以一年的日期为横坐标对TOA进行稳定性分析，制作散点图
# 对观测天顶角VZ进行筛选
# **************************************

# input_file=r'H:\00data\toa\FY3D\snowwatercloud\Yang(tbb)\2019\dh_toa2019_fy3d_removecsw.xlsx'
input_file_FY3D=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\2021\QA_3D\dh_toa2021_fy3d_003_QA_dropna.xlsx'
input_file_MODIS=r'H:\00data\TOA\MODIS\snowwatercloud\2021\003\QA_MODIS\dh_dingbiao2021_modis_003_QA_dropna.xlsx'
input_file_HY1C=r'H:\00data\TOA\HY1C\2021_003\dh_toa2021_HY1C_dropna.xlsx'

# *****************************Excel文件数据处理（去除NAN）*****************************
df_fy3d_base = pd.read_excel(input_file_FY3D,header=None)  # From an Excel file
df_modis_base = pd.read_excel(input_file_MODIS,header=None)  # From an Excel file
df_hy1c_base = pd.read_excel(input_file_HY1C,header=None)  # From an Excel file

# df_fy3d=df_fy3d_base
# df_modis=df_modis_base
# df_hy1c=df_hy1c_base

# 观测天顶角的筛选
vz=60
df_fy3d=df_fy3d_base[df_fy3d_base[5]<vz]
df_modis=df_modis_base[df_modis_base[5]<vz]
df_hy1c=df_hy1c_base[df_hy1c_base[5]<vz]


df_fy3d_band=[13,14,15,16,17,19,20]
modis_band=[14,15,16,18,19,23,24]

# 以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B19
# output_fig=r'H:\00data\TOA\3D_MODIS_HY1C\FY3D_MODIS_HY1C\2021\003_MODIS65533_FY3Dcloudpro\QA_3D_MODIS\basepng'+'\\'
output_fig=r'H:\00data\TOA\3D_MODIS_HY1C\FY3D_MODIS_HY1C\2021\003_MODIS65533_FY3Dcloudpro\QA_3D_MODIS\vz{value}'.format(value=vz)+'\\'
for band in range(7,14):
    # figname = output_fig + 'toa2021_HY1C_fy3d_modis_B{index}.png'.format(index=band - 6)
    figname = output_fig + 'toa2021_HY1C_fy3d_modis_vzlt{value}_B{index}.png'.format(value=vz,index=band - 6)
    if band >=10:
        # figname = output_fig + 'toa2021_HY1C_fy3d_modis_B{index}.png'.format(index=band - 5)
        figname = output_fig + 'toa2021_HY1C_fy3d_modis_vzlt{value}_B{index}.png'.format(value=vz,index=band - 5)
    fig, ax = plt.subplots(1, 1, figsize=(7,5), constrained_layout=True)
    fontdict1 = {"size": 17, "color": "k", 'family': 'Times New Roman'}
    ax.set_xlabel('Date', fontdict=fontdict1)
    ax.set_ylabel('TOA Reflectance', fontdict=fontdict1)
    ax.plot_date(df_hy1c[1], df_hy1c[band], fmt='k+', markersize=10, label='HY1C')
    ax.plot_date(df_fy3d[1], df_fy3d[df_fy3d_band[band-7]], fmt='b+',markersize=10,label='FY3D')
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
    title_band='B{b}'.format(b=band-6)
    if band>=10:
        title_band = 'B{b}'.format(b=band - 5)
    ax.set_title(title_band, titlefontdict, pad=20)
    # 旋转和右对齐x标签，并向上移动轴的底部以给它们腾出空间
    # fig.autofmt_xdate()

    legendfontdict = {"size": 10, "color": "k", 'family': 'Times New Roman'}
    plt.legend(loc="upper right", fontsize=10)

    plt.savefig(figname,dpi=900,bbox_inches='tight')
    plt.show()
# df.to_excel(excel_writer=output_file,index=False,header = False)