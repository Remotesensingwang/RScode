# coding=utf-8
import pandas as pd
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from scipy import optimize

# **************************************
# 对FY3D和MODIS数据整合到一张图中
# 首先需要对excel文件的FY3D和MODIS日期转化为datatime64格式（numpy.datetime64('2021-01-01T07:20:00.000000')）
# 以一年的日期为横坐标对TOA进行稳定性分析，制作散点图
# **************************************

input_file=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\dh-fy3-modis-1km.xlsx'
output_fig=r'H:\00data\TOA\FY3D\removecloud\fycloudpro\1kmstd\plot'+'\\'

# *****************************Excel文件数据读取*****************************
df_base = pd.read_excel(input_file, sheet_name="Sheet2")  # From an Excel file

modis_band=['MODIS_B3','MODIS_B4','MODIS_B1','MODIS_B2','MODIS_B26','MODIS_B6','MODIS_B7']
fy_band=['FY_B1','FY_B2','FY_B3','FY_B4','FY_B5','FY_B6','FY_B7']

# *****************************将日期转化为datatime64格式（numpy.datetime64('2021-01-01T07:20:00.000000')）*****************************
fy_date=df_base['FY_Date']
modis_date=df_base['MODIS_Date']

fy_dates=[]
modis_dates=[]
for date in fy_date:
    d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    date64=np.datetime64(d)
    fy_dates.append(date64)

df_base['FY_Date']=fy_dates

for date in modis_date:
    d=datetime.datetime.strptime(str(date),'%Y%m%d%H%M')
    date64=np.datetime64(d)
    modis_dates.append(date64)

df_base['MODIS_Date']=modis_dates

# *****************************计算趋势拟合线（Y=A * x + B）*****************************
def f_1(x, A, B):
    return A * x + B

# 存放文字的横坐标位置
d=datetime.datetime.strptime(str(20190201),'%Y%m%d')
date64=np.datetime64(d)

# *****************************#以一年的日期为横坐标散点图制作（横坐标以月份为单位显示）B1-B7*****************************
band=5
# figname = output_fig + 'toa2021_fy3d_modis_B{index}.png'.format(index=band - 6)

# 计算日期总数，FY3D和MODIS数据的拟合趋势线系数
N = len(df_base['FY_Date'].values)
X_FYdata=range(0,N)  #FY3D线性方程的X
Y_FYdata=df_base[fy_band[band]].values #FY3D线性方程的Y
Y_MODISdata=df_base[modis_band[band]].values #MODIS线性方程的Y(MODIS线性方程的X与FY3D一样)
# 系数计算 A,B  (Y=A*X+B)
A_FYdata, B_FYdata = optimize.curve_fit(f_1, X_FYdata,Y_FYdata)[0]
A_MODISdata, B_MODISdata = optimize.curve_fit(f_1, X_FYdata, Y_MODISdata)[0]
y_fy = A_FYdata * X_FYdata + B_FYdata
y_modis = A_MODISdata * X_FYdata + B_MODISdata

# 制图
figname = output_fig + 'toa_fy3d_B{index}.png'.format(index=band+1)
fig, ax = plt.subplots(1, 1, figsize=(10,6), constrained_layout=True)
fontdict1 = {"size": 17, "color": "k", 'family': 'Times New Roman'}
ax.set_xlabel('Date', fontdict=fontdict1)
ax.set_ylabel('TOA Reflectance', fontdict=fontdict1)
ax.plot_date(df_base['FY_Date'], df_base[fy_band[band]], fmt='b+',markersize=13,label='FY3D')
ax.plot_date(df_base['MODIS_Date'], df_base[modis_band[band]], fmt='r+', markersize=13,label='MODIS')
ax.plot(df_base['FY_Date'], y_fy, color='b', linewidth=3, linestyle='--')
ax.plot(df_base['MODIS_Date'], y_modis, color='r', linewidth=3, linestyle='--')
fontdict = {"size": 16, "color": "k", 'family': 'Times New Roman'}
# ax.text(0.17, 0.45, r'$R^2=$' + str(round(C, 3)), fontdict=fontdict)
# ax.text(0.17, 0.40, "RMSE=" + str(rmse), fontdict=fontdict)
ax.text(date64, 0.42, r"$FY3D:  y=$" +'{:.3e}'.format(A_FYdata) + '$x$' + "+" + str(round(B_FYdata, 3)), fontdict=fontdict)
ax.text(date64, 0.48, r"$MODIS: y=$" + '{:.3e}'.format(A_MODISdata) + '$x$' + "+" + str(round(B_MODISdata, 3)), fontdict=fontdict)
ax.text(date64, 0.54, r"$N=$" + str(N), fontdict=fontdict)

#设置主刻度的定位
# ax.xaxis.set_major_locator(mdates.YearLocator())
ax.xaxis.set_major_locator(mdates.MonthLocator(bymonthday=1,interval=3))
# 设置主刻度的显示格式

# ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
#设置次刻度的定位
# ax.xaxis.set_minor_locator(mdates.MonthLocator())

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
xlabels[len(xlabels)-1].set_visible(True)
# 添加题目
titlefontdict = {"size": 20, "color": "k", 'family': 'Times New Roman'}
ax.set_title('B{b}-FY3D'.format(b=band+1), titlefontdict, pad=20)
# 旋转和右对齐x标签，并向上移动轴的底部以给它们腾出空间
# fig.autofmt_xdate()

legendfontdict = {"size": 10, "color": "k", 'family': 'Times New Roman'}
plt.legend(loc="upper right", fontsize=10)

# plt.savefig(figname,dpi=900,bbox_inches='tight')
plt.show()
# df.to_excel(excel_writer=output_file,index=False,header = False)