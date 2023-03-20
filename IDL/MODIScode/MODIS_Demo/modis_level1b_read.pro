PRO MODIS_LEVEL1B_READ, FILENAME, BAND, IMAGE, $
  RAW=RAW, CORRECTED=CORRECTED, REFLECTANCE=REFLECTANCE, TEMPERATURE=TEMPERATURE, $
  AREA=AREA, UNITS=UNITS, PARAMETER=PARAMETER, $
  SCANTIME=SCANTIME, LATITUDE=LATITUDE, LONGITUDE=LONGITUDE, $
  VALID_INDEX=VALID_INDEX, VALID_COUNT=VALID_COUNT, $
  INVALID_INDEX=INVALID_INDEX, INVALID_COUNT=INVALID_COUNT, $
  RANGE=RANGE

  ;+
  ; NAME:
  ;    MODIS_LEVEL1B_READ
  ;
  ; PURPOSE:
  ;    Read a single band from a MODIS Level 1B HDF product file at
  ;    1000, 500, or 250 m resolution.
  ;
  ;    The output image is available in the following units (Radiance is default):
  ;    RAW DATA:    Raw data values as they appear in the HDF file
  ;    CORRECTED:   Corrected counts
  ;    RADIANCE:    Radiance (Watts per square meter per steradian per micron)
  ;    REFLECTANCE: Reflectance (Bands 1-19 and 26; *without* solar zenith correction)
  ;    TEMPERATURE: Brightness Temperature (Bands 20-25 and 27-36, Kelvin)
  ;
  ;    This procedure uses only HDF calls (it does *not* use HDF-EOS),
  ;    and only reads from SDS and Vdata arrays (it does *not* read ECS metadata).
  ;
  ; CATEGORY:
  ;    MODIS utilities.
  ;
  ; CALLING SEQUENCE:
  ;    MODIS_LEVEL1B_READ, FILENAME, BAND, IMAGE
  ;
  ; INPUTS:
  ;    FILENAME       Name of MODIS Level 1B HDF file
  ;    BAND           Band number to be read
  ;                   (1-36 for 1000 m, 1-7 for 500 m, 1-2 for 250m)
  ;                   (Use 13, 13.5, 14, 14.5 for 13lo, 13hi, 14lo, 14hi)
  ;
  ; OPTIONAL INPUTS:
  ;    None.
  ;
  ; KEYWORD PARAMETERS:
  ;    RAW            If set, image data are returned as raw HDF values
  ;                   (default is to return image data as radiance).
  ;    CORRECTED      If set, image data are returned as corrected counts
  ;                   (default is to return image data as radiance).
  ;    REFLECTANCE    If set, image data for bands 1-19 and 26 only are
  ;                   returned as reflectance *without* solar zenith angle correction
  ;                   (default is to return image data as radiance).
  ;    TEMPERATURE    If set, image data for bands 20-25 and 27-36 only are
  ;                   returned as brightness temperature
  ;                   (default is to return image data as radiance).
  ;    AREA           A four element vector specifying the area to be read,
  ;                   in the format [X0,Y0,NX,NY]
  ;                   (default is to read the entire image).
  ;    UNITS          On return, a string describing the image units.
  ;    PARAMETER      On return, a string describing the image (e.g. 'Radiance').
  ;    SCANTIME       On return, a vector containing the start time of each scan
  ;                   (SDPTK TAI seconds).
  ;    LATITUDE       On return, an array containing the reduced resolution latitude
  ;                   data for the entire granule (degrees, every 5th line and pixel).
  ;    LONGITUDE      On return, an array containing the reduced resolution longitude
  ;                   data for the entire granule (degrees, every 5th line and pixel).
  ;    VALID_INDEX    On return, a vector containing the 1D indexes of pixels which
  ;                   are within the 'valid_range' attribute values.
  ;    VALID_COUNT    On return, the number of pixels which
  ;                   are within the 'valid_range' attribute values.
  ;    INVALID_INDEX  On return, a vector containing the 1D indexes of pixels which
  ;                   are not within the 'valid_range' attribute values.
  ;    INVALID_COUNT  On return, the number of pixels which
  ;                   are not within the 'valid_range' attribute values.
  ;    RANGE          On return, a 2-element vector containing the minimum and
  ;                   maximum data values within the 'valid range'.
  ;
  ; OUTPUTS:
  ;    IMAGE          A two dimensional array of image data in the requested units.
  ;
  ; OPTIONAL OUTPUTS:
  ;    None.
  ;
  ; COMMON BLOCKS:
  ;    None
  ;
  ; SIDE EFFECTS:
  ;    None.
  ;
  ; RESTRICTIONS:
  ;    Requires IDL 5.0 or higher (square bracket array syntax).
  ;
  ;    Requires the following HDF procedures by Liam.Gumley@ssec.wisc.edu:
  ;    HDF_SD_ATTINFO      Get information about an attribute
  ;    HDF_SD_ATTLIST      Get list of attribute names
  ;    HDF_SD_VARINFO      Get information about an SDS variable
  ;    HDF_SD_VARLIST      Get a list of SDS variable names
  ;    HDF_SD_VARREAD      Read an SDS variable
  ;    HDF_VD_VDATAINFO    Get information about a Vdata
  ;    HDF_VD_VDATALIST    Get list of Vdata names
  ;    HDF_VD_VDATAREAD    Read a Vdata field
  ;
  ;    Requires the following Planck procedures by Liam.Gumley@ssec.wisc.edu:
  ;    MODIS_BRIGHT        Compute MODIS brightness temperature
  ;    MODIS_PLANCK        Compute MODIS Planck radiance
  ;    BRIGHT_M            Compute brightness temperature (EOS radiance units)
  ;    BRITE_M             Compute brightness temperature (UW-SSEC radiance units)
  ;    PLANCK_M            Compute monochromatic Planck radiance (EOS units)
  ;    PLANC_M             Compute monochromatic Planck radiance (UW-SSEC units)
  ;
  ; EXAMPLES:
  ;
  ;; These examples require the IMDISP image display procedure, available from
  ;; http://cimss.ssec.wisc.edu/~gumley/imdisp.html
  ;
  ;; Read band 1 in radiance units from a 1000 m resolution file
  ;file = 'MOD021KM.A2000062.1020.002.2000066023928.hdf'
  ;modis_level1b_read, file, 1, band01
  ;imdisp, band01, margin=0, order=1
  ;
  ;; Read band 31 in temperature units from a 1000 m resolution file
  ;file = 'MOD021KM.A2000062.1020.002.2000066023928.hdf'
  ;modis_level1b_read, file, 31, band31, /temperature
  ;imdisp, band31, margin=0, order=1, range=[285, 320]
  ;
  ;; Read a band 1 subset in reflectance units from a 500 m resolution file
  ;file = 'MOD02HKM.A2000062.1020.002.2000066023928.hdf'
  ;modis_level1b_read, file, 1, band01, /reflectance, area=[1000, 1000, 700, 700]
  ;imdisp, band01, margin=0, order=1
  ;
  ;; Read band 6 in reflectance units from a 1000 m resolution file,
  ;; and screen out invalid data when scaling
  ;file = 'MOD021KM.A2000062.1020.002.2000066023928.hdf'
  ;modis_level1b_read, file, 6, band06, /reflectance, valid_index=valid_index
  ;range = [min(band06[valid_index]), max(band06[valid_index])]
  ;imdisp, band06, margin=0, order=1, range=range
  ;
  ; MODIFICATION HISTORY:
  ; Liam.Gumley@ssec.wisc.edu
  ; http://cimss.ssec.wisc.edu/~gumley
  ; $Id: modis_level1b_read.pro,v 1.2 2000/10/21 01:00:14 haran Exp $
  ;
  ; Copyright (C) 1999, 2000 Liam E. Gumley
  ;
  ; This program is free software; you can redistribute it and/or
  ; modify it under the terms of the GNU General Public License
  ; as published by the Free Software Foundation; either version 2
  ; of the License, or (at your option) any later version.
  ;
  ; This program is distributed in the hope that it will be useful,
  ; but WITHOUT ANY WARRANTY; without even the implied warranty of
  ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ; GNU General Public License for more details.
  ;
  ; You should have received a copy of the GNU General Public License
  ; along with this program; if not, write to the Free Software
  ; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  ;-

  rcs_id = '$Id: modis_level1b_read.pro,v 1.2 2000/10/21 01:00:14 haran Exp $'

    ;-------------------------------------------------------------------------------
    ;- CHECK INPUT
    ;-------------------------------------------------------------------------------

    ;- Check arguments
    IF (n_params() NE 3) THEN $
    MESSAGE, 'Usage: MODIS_LEVEL1B_READ, FILENAME, BAND, IMAGE'

  IF (N_ELEMENTS(filename) EQ 0) THEN $
    MESSAGE, 'Argument FILENAME is undefined'

  IF (N_ELEMENTS(band) EQ 0) THEN $
    MESSAGE, 'Argument BAND is undefined'

  IF (ARG_PRESENT(image) NE 1) THEN $
    MESSAGE, 'Argument IMAGE cannot be modified'

  IF (N_ELEMENTS(area) GT 0) THEN BEGIN
    IF (N_ELEMENTS(area) NE 4) THEN $
      MESSAGE, 'AREA must be a 4-element vector of the form [X0,Y0,NX,NY]'
  ENDIF

  ;-------------------------------------------------------------------------------
  ;- CHECK FOR VALID MODIS L1B HDF FILE, AND GET FILE TYPE (1km, 500 m, or 250 m)
  ;-------------------------------------------------------------------------------

  ;- Check that file exists
  IF ((findfile(filename))[0] EQ '') THEN $
    MESSAGE, 'FILENAME was not found => ' + filename

  ;- Get expanded filename
  OPENR, lun, filename, /get_lun
  fileinfo = FSTAT(lun)
  FREE_LUN, lun

  ;- Check that file is HDF
  IF (HDF_ISHDF(fileinfo.NAME) NE 1) THEN $
    MESSAGE, 'FILENAME is not HDF => ' + fileinfo.NAME

  ;- Get list of SDS arrays
  sd_id = HDF_SD_START(fileinfo.NAME)
  varlist = hdf_sd_varlist(sd_id)
  HDF_SD_END, sd_id

  ;- Locate image arrays
  index = WHERE(varlist.VARNAMES EQ 'EV_1KM_Emissive', count_1km)
  index = WHERE(varlist.VARNAMES EQ 'EV_500_RefSB',    count_500)
  index = WHERE(varlist.VARNAMES EQ 'EV_250_RefSB',    count_250)
  CASE 1 OF
    (count_1km EQ 1) : filetype = 'MOD021KM'
    (count_500 EQ 1) : filetype = 'MOD02HKM'
    (count_250 EQ 1) : filetype = 'MOD02QKM'
    ELSE : MESSAGE, 'FILENAME is not MODIS Level 1B HDF => ' + fileinfo.NAME
  ENDCASE

  ;-------------------------------------------------------------------------------
  ;- CHECK BAND NUMBER, AND KEYWORDS WHICH DEPEND ON BAND NUMBER
  ;-------------------------------------------------------------------------------

  ;- Check band number
  CASE filetype OF
    'MOD021KM' : IF (band LT 1) OR (band GT 36) THEN $
      MESSAGE, 'BAND range is 1-36 for this MODIS type => ' + filetype
    'MOD02HKM' : IF (band LT 1) OR (band GT 7) THEN $
      MESSAGE, 'BAND range is 1-7 for this MODIS type => ' + filetype
    'MOD02QKM' : IF (band LT 1) OR (band GT 2) THEN $
      MESSAGE, 'BAND range is 1-2 for this MODIS type => ' + filetype
  ENDCASE

  ;- Check for invalid request for reflectance units
  IF ((band GE 20) AND (band NE 26)) AND KEYWORD_SET(reflectance) THEN $
    MESSAGE, 'REFLECTANCE units valid for bands 1-19, 26 only'

  ;- Check for invalid request for temperature units
  IF ((band LE 19) OR (band EQ 26)) AND KEYWORD_SET(temperature) THEN $
    MESSAGE, 'TEMPERATURE units valid for bands 20-25, 27-36 only'

  ;-------------------------------------------------------------------------------
  ;- SET VARIABLE NAME FOR IMAGE DATA
  ;-------------------------------------------------------------------------------

  CASE filetype OF

    ;- 1 km resolution data
    'MOD021KM' : BEGIN
      CASE 1 OF
        (band GE  1 AND band LE  2) : sds_name = 'EV_250_Aggr1km_RefSB'
        (band GE  3 AND band LE  7) : sds_name = 'EV_500_Aggr1km_RefSB'
        (band GE  8 AND band LE 19) : sds_name = 'EV_1KM_RefSB'
        (band EQ 26)                : sds_name = 'EV_Band26'
        (band GE 20 AND band LE 36) : sds_name = 'EV_1KM_Emissive'
      ENDCASE
    END

    ;- 500 m resolution data
    'MOD02HKM' : BEGIN
      CASE 1 OF
        (band GE  1 AND band LE  2) : sds_name = 'EV_250_Aggr500_RefSB'
        (band GE  3 AND band LE  7) : sds_name = 'EV_500_RefSB'
      ENDCASE
    END

    ;- 250 m resolution data
    'MOD02QKM' : sds_name = 'EV_250_RefSB'

  ENDCASE

  ;-------------------------------------------------------------------------------
  ;- SET ATTRIBUTE NAMES FOR IMAGE DATA
  ;-------------------------------------------------------------------------------

  ;- Set names of scale, offset, and units attributes
  CASE 1 OF

    KEYWORD_SET(reflectance) : BEGIN
      scale_name  = 'reflectance_scales'
      offset_name = 'reflectance_offsets'
      units_name  = 'reflectance_units'
      parameter   = 'Reflectance'
    END

    KEYWORD_SET(corrected) : BEGIN
      scale_name  = 'corrected_counts_scales'
      offset_name = 'corrected_counts_offsets'
      units_name  = 'corrected_counts_units'
      parameter   = 'Corrected Counts'
    END

    ELSE : BEGIN
      scale_name  = 'radiance_scales'
      offset_name = 'radiance_offsets'
      units_name  = 'radiance_units'
      parameter   = 'Radiance'
    END

  ENDCASE

  ;-------------------------------------------------------------------------------
  ;- OPEN THE FILE IN SDS MODE
  ;-------------------------------------------------------------------------------

  sd_id = HDF_SD_START(fileinfo.NAME)

  ;-------------------------------------------------------------------------------
  ;- CHECK BAND ORDER AND GET BAND INDEX
  ;-------------------------------------------------------------------------------

  IF (band NE 26) THEN BEGIN

    ;- Get the actual band order
    band_name = 'band_names'
    att_info = hdf_sd_attinfo(sd_id, sds_name, band_name)
    IF (att_info.NAME EQ '') THEN MESSAGE, 'Attribute not found: ' + band_name
    band_data = att_info.DATA

    ;- Set expected band order
    CASE 1 OF
      (band GE  1 AND band LE  2) : $
        band_order = '1,2'
      (band GE  3 AND band LE  7) : $
        band_order = '3,4,5,6,7'
      (band GE  8 AND band LE 19) : $
        band_order = '8,9,10,11,12,13lo,13hi,14lo,14hi,15,16,17,18,19,26'
      (band GE 20 AND band LE 36) : $
        band_order = '20,21,22,23,24,25,27,28,29,30,31,32,33,34,35,36'
    ENDCASE

    ;- Check actual band order against expected band order
    IF (band_data NE band_order) THEN $
      MESSAGE, 'Unexpected band order in image array'

    ;- Get band index
    CASE 1 OF
      (band GE  1 AND band LE  2) : band_index = band -  1
      (band GE  3 AND band LE  7) : band_index = band -  3
      (band GE  8 AND band LE 12) : band_index = band -  8
      (band GE 13 AND band LT 15) : band_index = 2 * band - 21
      (band GE 15 AND band LE 19) : band_index = band -  6
      (band GE 20 AND band LE 25) : band_index = band - 20
      (band GE 27 AND band LE 36) : band_index = band - 21
    ENDCASE

  ENDIF ELSE BEGIN

    band_index = 0

  ENDELSE

  ;-------------------------------------------------------------------------------
  ;- READ IMAGE DATA
  ;-------------------------------------------------------------------------------

  ;- Get information about the image array
  varinfo = hdf_sd_varinfo(sd_id, sds_name)
  IF (varinfo.NAME EQ '') THEN $
    MESSAGE, 'Image array was not found: ' + sds_name
  npixels_across = varinfo.DIMS[0]
  npixels_along  = varinfo.DIMS[1]

  ;- Set start and count values
  start = [0L, 0L, band_index]
  count = [npixels_across, npixels_along, 1L]
  IF (band EQ 26) THEN BEGIN
    start = start[0 : 1]
    count = count[0 : 1]
  ENDIF

  ;- Use AREA keyword if it was supplied
  IF (N_ELEMENTS(area) EQ 4) THEN BEGIN
    start[0] = (LONG(area[0]) > 0L) < (npixels_across - 1L)
    start[1] = (LONG(area[1]) > 0L) < (npixels_along  - 1L)
    count[0] = (LONG(area[2]) > 1L) < (npixels_across - start[0])
    count[1] = (LONG(area[3]) > 1L) < (npixels_along  - start[1])
  ENDIF

  ;- Read the image array (hdf_sd_varread not used because of bug in IDL 5.1)
  var_id = HDF_SD_SELECT(sd_id, HDF_SD_NAMETOINDEX(sd_id, sds_name))
  HDF_SD_GETDATA, var_id, IMAGE, start=start, count=count
  HDF_SD_ENDACCESS, var_id

  ;-------------------------------------------------------------------------------
  ;- READ IMAGE ATTRIBUTES
  ;-------------------------------------------------------------------------------

  ;- Read scale attribute
  att_info = hdf_sd_attinfo(sd_id, sds_name, scale_name)
  IF (att_info.NAME EQ '') THEN MESSAGE, 'Attribute not found: ' + scale_name
  scale = att_info.DATA

  ;- Read offset attribute
  att_info = hdf_sd_attinfo(sd_id, sds_name, offset_name)
  IF (att_info.NAME EQ '') THEN MESSAGE, 'Attribute not found: ' + offset_name
  offset = att_info.DATA

  ;- Read units attribute
  att_info = hdf_sd_attinfo(sd_id, sds_name, units_name)
  IF (att_info.NAME EQ '') THEN MESSAGE, 'Attribute not found: ' + units_name
  units = att_info.DATA

  ;- Read valid range attribute
  valid_name = 'valid_range'
  att_info = hdf_sd_attinfo(sd_id, sds_name, valid_name)
  IF (att_info.NAME EQ '') THEN MESSAGE, 'Attribute not found: ' + valid_name
  valid_range = att_info.DATA

  ;- Read latitude and longitude arrays
  IF ARG_PRESENT(latitude) THEN hdf_sd_varread, sd_id, 'Latitude', latitude
  IF ARG_PRESENT(longitude) THEN hdf_sd_varread, sd_id, 'Longitude', longitude

  ;-------------------------------------------------------------------------------
  ;- CLOSE THE FILE IN SDS MODE
  ;-------------------------------------------------------------------------------

  HDF_SD_END, sd_id

  ;-------------------------------------------------------------------------------
  ;- READ VDATA INFORMATION
  ;-------------------------------------------------------------------------------

  ;- Open the file in vdata mode
  hdfid = HDF_OPEN(fileinfo.NAME)

  ;- Read scan start time (SDPTK TAI seconds)
  vdataname = 'Level 1B Swath Metadata'
  hdf_vd_vdataread, hdfid, vdataname, 'EV Sector Start Time', scantime

  ;- Close the file in vdata mode
  HDF_CLOSE, hdfid

  ;-------------------------------------------------------------------------------
  ;- CONVERT IMAGE TO REQUESTED OUTPUT UNITS
  ;-------------------------------------------------------------------------------

  ; I'VE CHANGED THE BEHAVIOR HERE SO THAT THIS CONVERSION IS ONLY PERFORMED
  ; IF WE DON'T WANT RAW DATA -- TERRY HARAN 10/20/2000

  ;- Convert from unsigned short integer to signed long integer

  IF NOT KEYWORD_SET(raw) THEN BEGIN
    image = TEMPORARY(image) AND 65535L
    valid_range = valid_range AND 65535L
  ENDIF

  ;- Get valid/invalid indexes and counts
  IF ARG_PRESENT(valid_index) OR ARG_PRESENT(valid_count) OR $
    ARG_PRESENT(invalid_index) OR ARG_PRESENT(invalid_count) OR $
    ARG_PRESENT(range) THEN BEGIN
    valid_check = (image GE valid_range[0]) AND (image LE valid_range[1])
    valid_index = WHERE(valid_check EQ 1, valid_count)
    invalid_index = WHERE(valid_check EQ 0, invalid_count)
  ENDIF

  ;- Convert to units requested by caller
  IF KEYWORD_SET(raw) THEN BEGIN

    ;- Leave as HDF values
    units = 'Unsigned 16-bit integers'
    parameter = 'Raw HDF Values'

  ENDIF ELSE BEGIN

    ;- Convert image to unscaled values
    image = scale[band_index] * (TEMPORARY(image) - offset[band_index])
    ;print,[scale[band_index],offset[band_index]]
    ;- Convert radiance to brightness temperature for IR bands
    IF KEYWORD_SET(temperature) THEN BEGIN
      image = modis_bright(TEMPORARY(image), band, 1)
      units = 'Kelvin'
      parameter = 'Brightness Temperature'
    ENDIF

  ENDELSE

  ;- Get data range (min/max of valid image values)
  IF ARG_PRESENT(range) THEN BEGIN
    minval = MIN(image[valid_index], max=maxval)
    range = [minval, maxval]
  ENDIF

END