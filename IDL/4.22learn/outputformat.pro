;coding=GB2312
pro outputformat
  arr = findgen(5)
  help,arr
  print,arr,format='(5f6.3)'
  print,arr,format='(5(f6.3,","))'
  print,arr,format='(5(f6.3,:,","))'

  ;arr.ToDouble()
  ;arr.ToInteger()
  ;print,arr.ToString("(F9.7)" )  ;9��7������
  s= arr.ToString("('Pi=',F7.5)") ;7��5������
  print,s
  help,s
end