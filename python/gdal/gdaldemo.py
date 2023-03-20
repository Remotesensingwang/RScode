# coding=utf-8
from osgeo import gdal
import numpy as np

# gdal默认读写tif的数据格式均为BIP(interleave='band')，但是也可以读取BSQ格式，二者结果相同。
def raster2array(rasterfn):
    raster = gdal.Open(rasterfn)
    # band = raster.GetRasterBand(1)
    return raster.ReadAsArray()   #返回为BSQ
rasterfn  = r'D:\02FY3D\A202203090585162088\out\FY3D_MERSI_GBAL_L1_20190329_0440_1000M_MS_TOA.tif'
rasterfn1=r'D:\02FY3D\A202203090585162088\out\FY3D_MERSI_GBAL_L1_20190329_1835_1000M_MS_TOA.tif'

# 将 Raster 转换为数组
rasterArray  =  raster2array ( rasterfn )
rasterArray1 =  raster2array ( rasterfn1 )
aod = np.ndarray(shape=(2,5,13,13), dtype=np.float64) + np.nan
aod[0,:,:,:]=rasterArray
aod[1,:,:,:]=rasterArray1
# print(type(rasterArray))
# print(rasterArray.shape)
# print(rasterArray)
s=rasterArray.transpose(1,2,0)  #为BSQ类型
print(aod.shape)
print(aod)