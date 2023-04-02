
pro test
  a=1
  print,a
  refSB_band_data=findgen(5,5)+1
  ss=refSB_band_data gt 5 and refSB_band_data le 20
  imagedata=(refSB_band_data gt 5 and refSB_band_data le 20)*refSB_band_data
  dd=ss*refSB_band_data
  print,dd
  print,'1111'
end