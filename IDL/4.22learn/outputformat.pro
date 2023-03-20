;coding=GB2312
pro outputformat
  arr = findgen(5)
  help,arr
  print,arr,format='(5f6.3)'
  print,arr,format='(5(f6.3,","))'
  print,arr,format='(5(f6.3,:,","))'

  ;arr.ToDouble()
  ;arr.ToInteger()
  ;print,arr.ToString("(F9.7)" )  ;9和7差两个
  s= arr.ToString("('Pi=',F7.5)") ;7和5差两个
  print,s
  help,s
end