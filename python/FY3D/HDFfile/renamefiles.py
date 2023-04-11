# coding=utf-8
# **************************************
# 文件的重命名
# **************************************

import os
from glob import glob

src_dir=r'E:\MYD03'
src_file_list = glob(str(src_dir + '\\') + 'MYD03*')  # glob获得路径下所有文件，可根据需要修改
# print(src_dirfilepath_list)
ss='MYD021KM.A2019001.0740.061.2019001192534.hdf'
dd='MYD03.A2019001.0600.061.2019001153201.hdf'
aa=ss[0:26]
bb=dd[0:23]
for file  in src_file_list:
    fpath, fname = os.path.split(file)  # 分离文件名和路径
    refname=fname[0:23]+'.hdf'
    # print(src_file_list)
    refile=os.path.join(fpath,refname)
    os.rename(file,refile)
    print(refname+'重命名完成')