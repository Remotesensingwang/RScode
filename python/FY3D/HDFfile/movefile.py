# coding=utf-8
# src_dir 需要复制、移动的文件的根文件夹
# dst_dir  移动之后的路径

# **************************************
# 文件的移动 适用于文件夹下有多个子文件夹，子文件夹下的是文件
# **************************************

import os
import shutil
from glob import glob

# 移动函数
def mymovefile(srcfile, dstpath):
    if not os.path.isfile(srcfile):
        print("%s not exist!" % srcfile)
    else:
        fpath, fname = os.path.split(srcfile)  # 分离文件名和路径
        if not os.path.exists(dstpath):
            os.makedirs(dstpath)  # 创建路径
        shutil.move(srcfile, dstpath + fname)  # 移动文件
        print("move %s -> %s" % (srcfile, dstpath + fname))

# 获取文件夹下的子文件夹的绝对路径
def getDirFilePath(src_dir):
    src_dirfilepath_list = glob(src_dir + '*')
    return src_dirfilepath_list
# getDirFilePath(dirfile,baseimgpath)

if __name__ == '__main__':

    src_dir =r'H:\00data\FY3D\DCC\download'+'\\'   # 原来的文件所在的根路径（该文件夹下有多个子文件夹，子文件夹下的是文件）
    dst_dir = r'H:\00data\FY3D\DCC\L1_data\2020'+'\\'  # 移动之后的路径 记得加斜杠
    src_dirfilepath_list=getDirFilePath(src_dir)
    # print(src_dirfilepath_list)
    for srcdirfilepath in src_dirfilepath_list:
        src_file_list = glob(str(srcdirfilepath+'\\') + '*')  # glob获得路径下所有文件，可根据需要修改
        # print(src_file_list)
        for srcfile in src_file_list:
            mymovefile(srcfile, dst_dir)  # 移动文件
