# coding=utf-8
import pandas as pd
import os
basepath=r'D:\02FY3D\111'

# 获取文件夹下的所有文件（只保留文件名，不包括文件绝对路径）
def getListFiles(path):
    filelist = []
    for root, dirs, files in os.walk(path):
        for filespath in files:
            #filelist.append(os.path.join(root, filespath))
            if filespath.endswith('1000M_MS.HDF'):
                filelist.append(filespath)
    return filelist

def main():
    df_file=pd.read_csv(r'D:\02FY3D\AERONETData\Beijing-CAMS(20190328_20190402)\file_timematching.csv')
    filename=df_file['filename'].values
    files=getListFiles(basepath)
    num=0
    for file in files:
        if file not in filename:
            os.remove(os.path.join(basepath,file))
            geofile=file.replace("1000M_MS", "GEO1K_MS")
            os.remove(os.path.join(basepath,geofile))
            print(file+'删除成功')
            print(geofile+'删除成功')
            num+=1
    print('删除主文件个数:%d' % num)

if __name__ == '__main__':
    main()