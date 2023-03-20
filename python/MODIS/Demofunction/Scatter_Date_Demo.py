# coding=utf-8
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


# **************************************
# 以日期为横坐标制作散点图，x刻度显示格式为(2021-01)
# **************************************


def Scatter_Date(x1_data,y1_data,x_label,y_label,titie,figname):
    # figname = output_fig + 'toa2019_modis_B{index}.png'.format(index=band - 5)
    fig, ax = plt.subplots(1, 1, figsize=(7,5), constrained_layout=True)
    fontdict1 = {"size": 17, "color": "k", 'family': 'Times New Roman'}
    ax.set_xlabel(x_label, fontdict=fontdict1)
    ax.set_ylabel(y_label, fontdict=fontdict1)
    ax.plot_date(x1_data, y1_data, fmt='k+',markersize=10)
    # ax.plot_date(x2_data, y2_data, fmt='k+', markersize=10)
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
    # 隐藏最后一个刻度标签
    xlabels[len(xlabels)-1].set_visible(False)
    # 添加题目
    titlefontdict = {"size": 20, "color": "k", 'family': 'Times New Roman'}
    ax.set_title(titie, titlefontdict, pad=20)
    # 旋转和右对齐x标签，并向上移动轴的底部以给它们腾出空间
    # fig.autofmt_xdate()
    # plt.savefig(figname,dpi=900,bbox_inches='tight')
    plt.show()