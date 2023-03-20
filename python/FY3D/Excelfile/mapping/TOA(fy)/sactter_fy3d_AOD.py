# coding=utf-8
import pandas as pd
import numpy as np
from scipy import optimize
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error,r2_score
import matplotlib.cm as cm
from scipy.stats import linregress

# **************************************
# 绘制高级散点图（数据对比 站点+卫星 aod）
# **************************************

# 读取excel文件
test_data = pd.read_excel(r"H:\00data\toa\removecloud\2021toadata(wuhan).xlsx",header=None)  # From an Excel file
N=len(test_data[6])
x=test_data[6].values.ravel()
y=test_data[7].values.ravel()
C=round(r2_score(x,y),4)
rmse=round(np.sqrt(mean_squared_error(x,y)),3)

#绘制拟合线
x2=np.linspace(-10,10)
y2=x2

slope=linregress(x,y)[0]
intercept=linregress(x,y)[1]
lmfit=(slope*x)+intercept

# def f_1(x,A,B):
#     return A*x+B
# A1,B1=optimize.curve_fit(f_1,x,y)[0]
# y3=A1*x+B1

#开始绘图
fig,ax=plt.subplots(nrows=1,ncols=1,dpi=200,figsize=(7, 5))
dian = plt.scatter(x,y,edgecolors=None,c='k',s=16,marker='s')
ax.plot(x2,y2,color='k',linewidth=1.5,linestyle='--')
ax.plot(x,lmfit,color='r',linewidth=2,linestyle='-')
fontdict1={"size":17,"color":"k",'family':'Times New Roman'}
ax.set_xlabel('True Values',fontdict=fontdict1)
ax.set_ylabel('Estimated Values',fontdict=fontdict1)
ax.grid(False)
ax.set_xlim((0.15,0.5))
ax.set_ylim((0.15,0.5))
ax.set_xticks(np.arange(0.15,0.5,step=0.05))
ax.set_yticks(np.arange(0.15,0.5,step=0.05))
#设置刻度字体
labels=ax.get_xticklabels()+ax.get_yticklabels()
[label.set_fontname('Times New Roman') for label in labels]

#设置边框线的颜色
for spine in ['top','bottom','left','right']:
    ax.spines[spine].set_color('k')

# 更改刻度、刻度标签和网格线的外观
ax.tick_params(left=True,bottom=True,top=True,right=True,direction='in',labelsize=14)

#添加题目
titlefontdict={"size":20,"color":"k",'family':'Times New Roman'}
ax.set_title('timu',titlefontdict,pad=20)

fontdict={"size":16,"color":"k",'family':'Times New Roman'}
ax.text(0.17,0.45,r'$R^2=$'+str(round(C,3)),fontdict=fontdict)
ax.text(0.17,0.40,"RMSE="+str(rmse),fontdict=fontdict)
ax.text(0.17,0.35,r"$y=$"+str(round(A1,3))+'$x$'+"+"+str(round(B1,3)),fontdict=fontdict)
ax.text(0.17,0.30,r"$N=$"+str(N),fontdict=fontdict)

# 设置颜色
nbins = 150
H, xedges, yedges = np.histogram2d(x, y, bins=nbins)
# H needs to be rotated and flipped
H = np.rot90(H)
H = np.flipud(H)
# Mask zeros
Hmasked = np.ma.masked_where(H==0,H) # Mask pixels with a value of zero
#开始绘图
# plt.style.use('seaborn-darkgrid')
plt.pcolormesh(xedges, yedges, Hmasked, cmap=cm.get_cmap('jet'), vmin=0, vmax=40)

colorbarfontdict={"size":13,"color":"k",'family':'Times New Roman'}
cbar = plt.colorbar(ax=ax,ticks=[0,10,20,30,40],drawedges=False)
#cbar.ax.set_ylabel('Frequency',fontdict=colorbarfontdict)
cbar.ax.set_title('Counts',fontdict=colorbarfontdict,pad=8)
cbar.ax.tick_params(labelsize=13,direction='in')
cbar.ax.set_yticklabels(['0','10','20','30','>40'],family='Times New Roman')



# text_font={'family':'Times New Roman','size':'22','weight':'bold','color':'black'}
# ax.text(.9,.9,"(a)",transform=ax.transAxes,fontdict=text_font,zorder=4)
# ax.text(.8,.056,'\nbywang',transform=ax.transAxes,fontdict=text_font,ha='center',va='center',size=10,color='black')

plt.savefig(r'H:\data\toa\removecloud\scatter.png',dpi=900,bbox_inches='tight')   #bbox_inches以英寸为单位的边界框：仅保存图形的给定部分。如果'tight'，试着找出图的tight bbox

plt.show()