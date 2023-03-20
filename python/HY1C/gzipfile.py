# coding: utf-8

# **************************************
# 压缩文件解压缩，主要格式为（*.tar.gz），即gz格式
# 保存到指定文件夹下的子文件夹*（子文件夹的名称为压缩包的名称，需要自己创建）*
# 文件的移动 适用于文件夹下有多个子文件夹，子文件夹下的是文件 （引用了FY3D.HDFfile.movefile）
# 适用于 HY1C COCTS L1B卫星数据，*注意该压缩包解压后直接是数据，没有文件夹*
# **************************************

import tarfile
from glob import glob
from os import walk
from FY3D.HDFfile.movefile import getDirFilePath, mymovefile

f = []   #保存压缩文件的绝对路径
zippath =r'H:\00data\HY1C\2021L1B\download\download'+'\\'    #对应压缩包文件的路径
src_dir =r'H:\00data\HY1C\2021L1B\file_temp'+'\\'   # 原来的文件所在的根路径（该文件夹下有多个子文件夹，子文件夹下的是文件）
dst_dir = r'H:\00data\HY1C\2021L1B\DATA1'+'\\'  # 移动之后的路径 记得加斜杠
for (dirpath, dirnames, filenames) in walk(zippath):
    f.extend(filenames)
    break

lenth=len(f)

for word in f:
    lenth=lenth-1
    filename = zippath + word
    tf = tarfile.open(filename)
    f_fullname=src_dir+word
    f_name= f_fullname.replace(".tar.gz", "")
    tf.extractall(f_name)
    print(" %s -> %d" % (f_fullname,lenth))


src_dirfilepath_list=getDirFilePath(src_dir)
# print(src_dirfilepath_list)
for srcdirfilepath in src_dirfilepath_list:
    src_file_list = glob(str(srcdirfilepath+'\\') + '*.h5')  # glob 获得路径下后缀名为“h5”格式的文件，可根据需要修改
    # print(src_file_list)
    for srcfile in src_file_list:
        mymovefile(srcfile, dst_dir)  # 移动文件

