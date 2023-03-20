;coding=GB2312
pro foreachdata
  array = [1, 3, 5, 7, 9, 11, 13, 15]
  ;FOREACH element, array, index do PRINT, 'Index ', index, ' Value = ', element
  FOREACH element, array, index do begin
    PRINT, 'Index ', index, ' Value = ', element
  ENDFOREACH
  arr = fltarr(3,2)
  help,arr
  print,arr
end