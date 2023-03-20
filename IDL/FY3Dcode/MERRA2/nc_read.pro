;coding=utf-8

pro nc_read
 
 

 
 
  filepath='E:\MERRA2\MERRA2_400.tavg1_2d_slv_Nx.20220921.nc4'
  nc_id = ncdf_open(filepath,/nowrite)
  file_info = ncdf_inquire(nc_id)
  print,file_info
;    for varid=0, file_info.nvars-1 do begin
;      ; inquire about the variable; returns structure
;      var = ncdf_varinq( nc_id, varid )
;      print,var
;      print,'========================'
;      ;read all attributes
;      for var_att_id=0,var.natts -1 do begin
;        att_name = ncdf_attname( nc_id, varid, var_att_id )
;        print,att_name
;        ncdf_attget, nc_id, varid, att_name, tematt
;        print,string(tematt)
;      endfor
;    endfor
  
  var_id = ncdf_varid(nc_id,'TO3')
  ncdf_varget,nc_id,var_id,datase
  ;print,datase
  ncdf_close,nc_id
  c=134217728
  s=BYTE(c)
  print,string(s)
end