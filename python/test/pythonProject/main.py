# 导入所需的库
import os
import shutil
import pandas as pd
import numpy as np

def Classify(path):
    #设置当前的工作路径
    os.chdir(path)
    os.getcwd()
    Total_File = os.listdir(path)
    # 取出命名中的年份信息 即i[-10:-6],用这个特征来进行分年份存放对应的文件
    for i in Total_File:
        year = i[-10:-6]
        #将当前文件夹路径与对应年份相黏贴，构成每个年份文件夹的完整路径
        year_Path = path+'\\'+year
         #检查当前文件下有没有对应年份的文件夹，若没有的话即创建
        if not os.path.exists(year_Path):
            os.mkdir(year_Path)
        #如果已经存在对应年份的文件夹，则根据文件的年份信息进行分类
        if(year == year_Path[-4:]):
            # shutil.move(源文件，指定路径):递归移动一个文件
            shutil.move(i,year_Path)

def ChinaDayTMPPRE(path,year,out):
    """
    path:读取的文件夹路径
    year:需要处理的年份
    out:需要保存的文件路径
    """
    os.chdir(out)
    if not os.path.exists('day'):
        os.mkdir('day')
    if not os.path.exists('month'):
        os.mkdir('month')
    if not os.path.exists('year'):
        os.mkdir('year')
    # 读取某个年份的文件夹进行单年份数据处理
    file_Path = path +'\\'+str(year)
    l = os.listdir(file_Path)
    # 设置一个列表来存放当前年份的十二个月份数据
    Day_list = []
    for y in range(len(l)):
        file = file_Path+'\\'+l[y]
        #将数据添加进列表中
        col = ['站号','纬度','经度','年','月','日','日平均气温','20时-20时降水量']
        Day_list.append(pd.read_csv(file,sep='\s+',names= col))

    # 根据第十一列的质量控制码，筛选出正确的数据,索引从0开始
    # for i in range(len(Day_list)):
    #     Day_list[i] = Day_list[i][Day_list[i]['20-20时累计降水量控制码'].isin([0])]
    # # 检查累计降水量该列是否全为正确数据
    # for i in range(len(Day_list)):
    #     if Day_list[i]['20-20时累计降水量控制码'].max() == 0:
    #         flag = True
#     print(flag)

    # 异常值和经纬度处理
    # 备份一份数据，保存异常值处理之前的list
    Day_process = Day_list
    # 写一个转换函数
    def dfToDu(data):
            D = data.astype(int)
            F = (data - D)*100/60
            F = round(F,2)
            data = D+F
            return data
    for i in range(len(Day_process)):
        Day_process[i].loc[Day_process[i]['20-20累计降水量'] == 32766,'20-20累计降水量'] = -999
        Day_process[i].loc[Day_process[i]['20-20累计降水量'] == 32700,'20-20累计降水量'] = 0
        Day_process[i].loc[(Day_process[i]['20-20累计降水量'] >= 30000) & (Day_process[i]['20-20累计降水量'] < 31000),'20-20累计降水量']= Day_process[i]['20-20累计降水量']-30000
        Day_process[i].loc[(Day_process[i]['20-20累计降水量'] >= 31000) & (Day_process[i]['20-20累计降水量'] < 32000),'20-20累计降水量'] = Day_process[i]['20-20累计降水量']-31000
        Day_process[i].loc[(Day_process[i]['20-20累计降水量'] >= 32000) & (Day_process[i]['20-20累计降水量'] < 33000),'20-20累计降水量'] = Day_process[i]['20-20累计降水量']-32000
        Day_process[i]['20-20累计降水量'] = Day_process[i]['20-20累计降水量']*0.1
        #经纬度处理
        # 经纬度除以100后，小数前两位是度，可以用i取整的方法提取出来，小数后两位是分，可以乘回100得到正常的值
        Day_process[i]['经度'] = Day_process[i]['经度']*0.01
        Day_process[i]['纬度'] = Day_process[i]['纬度']*0.01
        Day_process[i]['经度'] = dfToDu(Day_process[i]['经度'])
        Day_process[i]['纬度'] = dfToDu(Day_process[i]['纬度'])

    # 去除一些冗余的列，保留站点的信息和累计降水量
    daily = Day_process[0][['站号','纬度','经度','年','月','日','日平均气温','20-20累计降水量']]
    for i in range(1,12):
       daily = pd.concat([daily,Day_process[i][['站号','纬度','经度','年','月','日','日平均气温','20-20累计降水量']]],join='inner',axis = 0)
    # 日值降水量数据
    OutDaily = out+'/day/'+str(year)+'_day.csv'
    daily.to_csv(OutDaily,encoding='gbk',index = False)

    # 处理成月累计数据
    month_data = daily.groupby(['站号','月']).agg({'20-20累计降水量':np.sum,'日平均气温':np.mean,'年':np.mean,'纬度':np.mean,'经度':np.mean})
    #导出月度累计数据
    OutMonth = out+'/month/'+str(year)+'_month.csv'
    month_data.to_csv(OutMonth,encoding='gbk')

    #年度数据合成
    year_data=month_data.groupby(['站号']).agg({'20-20累计降水量':np.sum,'日平均气温':np.mean,'年':np.mean,'纬度':np.mean,'经度':np.mean})
    #导出年度数据
    OutYear = out + '/year/'+str(year)+'_year.csv'
    year_data.to_csv(OutYear,encoding='gbk')

#修改为数据集的文件夹
path = r'H:\数据\长江流域站点\气温降水'
#修改输出的文件路径
outpath = 'H:\数据\长江流域站点\降水处理'
#先对未处理的数据进行分类
Classify(path)
#分类后对所有年份进行批量处理
for year in range(1979,2019):
    ChinaDayTMPPRE(path,year,outpath)
print('Successful!')

