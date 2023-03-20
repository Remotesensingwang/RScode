# coding=utf-8

# **************************************
# 删除日期不符合的文件  需要一个excel文件 有一列名为date的日期数据 例如（202001010700）
# **************************************

import pandas as pd
import os

# 获取文件夹下的所有文件（只保留文件名，不包括文件绝对路径）
def getListFiles(path):
    filelist = []
    for root, dirs, files in os.walk(path):
        for filespath in files:
            #filelist.append(os.path.join(root, filespath))
            if filespath.endswith('1000M_MS.HDF'):
                filelist.append(filespath)
    return filelist

def main(basepath):
    df_file=pd.read_excel(r'C:\Users\Wangxingtao\Desktop\2020toa.xlsx')
    files_date=df_file['date'].values
    files=getListFiles(basepath)
    num=0
    for file in files:
        date=int(file[19:27]+file[28:32])
        if date not in files_date:
            os.remove(os.path.join(basepath,file))
            geofile=file.replace("1000M_MS", "GEO1K_MS")
            os.remove(os.path.join(basepath,geofile))
            print(file+'删除成功')
            print(geofile+'删除成功')
            num+=1
    print('删除主文件个数:%d' % num)

if __name__ == '__main__':
    basepath = r'E:\fy3d1920\data\2020'
    main(basepath)

