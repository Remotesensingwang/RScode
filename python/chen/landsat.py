import os.path
from osgeo import gdal_array
from osgeo import gdal
import numpy as np
from os import walk
import math
import os
os.environ['PROJ_LIB'] = r'C:\ProgramData\Anaconda3\envs\houchen\Library\share\proj'
os.environ['GDAL_DATA'] = r'C:\ProgramData\Anaconda3\envs\houchen\Library\share'

'''
def unpacked(image_dir):
    f = []
    for (dirpath, dirnames, filenames) in walk(image_dir):
        f.extend(filenames)
        break
    for word in f:
       #if word.name.endswith('.tiff'):
        filename=image_dir+"\\"+word
        tf=tarfile.open(filename)
        tf.extractall('G:\data31')
'''

class Landsat8Reader(object):
    def __init__(self,filename):
     self.bands = 7
     self.band_file_name = []
     self.filename=\
     filename

    def read(self):
      for band in range(self.bands):
         # band_name =self.filename+"_B" + str(band + 1) + ".TIF"
         band_name = r'E:\RS_Code\python_RS\data\LC08_L1GT_137032_20190819_20190902_01_T2_B1.TIF'
         self.band_file_name.append(band_name)

      ds = gdal.Open(self.band_file_name[0])
      image_dt = ds.GetRasterBand(1).DataType
      image = np.zeros((3,3, self.bands),
                      dtype=\
                       gdal_array.GDALTypeCodeToNumericTypeCode(image_dt))

      for band in range(self.bands):
         ds = gdal.Open(self.band_file_name[band])
         band_image = ds.GetRasterBand(1)
         image[ :, :,band] = band_image.ReadAsArray(0,0,3,3)

      return image
      #print(image)

    def write(self, image, file_path, bands):
        lat = 40.1375
        lon = 94.32083333333334
       # coords = self.lonlat(lon, lat)
       # coords1 = self.rowcol(coords[0], coords[1])
        #row = math.ceil(coords1[0])
        #col = math.ceil(coords1[1])

        ds = gdal.Open(self.band_file_name[0])

        projection = ds.GetProjection()
        geotransform = ds.GetGeoTransform()
        x_size = ds.RasterXSize
        y_size = ds.RasterYSize
        del ds

        driver = gdal.GetDriverByName("GTiff")
        new_ds = driver.Create(file_path, 3, 3, bands, gdal.GDT_Float32)
        new_ds.SetGeoTransform(geotransform)
        new_ds.SetProjection(projection)

        for band in range(self.bands):
            outband=new_ds.GetRasterBand(band + 1)
            outband.WriteArray(image)
            new_ds.FlushCache()
        del new_ds

    def radiometric_calibration(self):
        image = self.read()

        def get_calibration_parameters():
            filename1=self.filename + "_MTL" + ".txt"
            f = open(r'E:\RS_Code\python_RS\LC08_L1GT_137032_20190819_20190902_01_T2_MTL.txt', 'r')
            metadata = f.readlines()
            f.close()
            multi_parameters = []
            add_parameters = []
            sun_e=0
            parameter_start_line = 0

            for lines in metadata:
                test_line = lines.split('=')
                if test_line[0] == '    RADIANCE_MULT_BAND_1 ':
                    break
                else:
                    parameter_start_line = parameter_start_line + 1

            for lines in range(parameter_start_line, parameter_start_line + 11):
                parameter = float(metadata[lines].split("=")[1])
                multi_parameters.append(parameter)

            for lines in range(parameter_start_line + 11, parameter_start_line + 22):
                parameter = float(metadata[lines].split("=")[1])
                add_parameters.append(parameter)

            for lines in metadata:
                test_line = lines.split('=')
                if test_line[0] == '    SUN_ELEVATION ':
                    sun_e=float(test_line[1])

            return multi_parameters, add_parameters, sun_e

        multi_parameters, add_parameters, sun_e = get_calibration_parameters()
        cali_image = np.zeros_like(image,dtype=float)
        toa=np.zeros_like(image,dtype=float)

        for band in range(self.bands):
            gain = multi_parameters[band]
            offset = add_parameters[band]
            cali_image[:, :, band] = image[:, :, band] * gain + offset
            np.seterr(divide='ignore', invalid='ignore')
            toa[:,:,band] = cali_image[:, :, band] /(math.sin(sun_e)*1000)
            print('toa')

if __name__ == "__main__":
    # gdal.AllRegister()
    #image_dir = r"G:\data3"
    #unpacked(image_dir)

    filename=r'E:\RS_Code\python_RS\data\LC08_L1GT_137032_20190819_20190902_01_T2_B1.TIF'
    data = Landsat8Reader(filename)
    image = data.read()
    toa = data.radiometric_calibration()
    file_path = os.path.join(r'G:\LAdata2019\lra',word+'.tif')
    #data.write(toa,file_path,data.bands)
