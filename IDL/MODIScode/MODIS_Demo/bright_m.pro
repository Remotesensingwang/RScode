FUNCTION BRIGHT_M, W, R

  ;+
  ; DESCRIPTION:
  ;    Compute brightness temperature given monochromatic Planck radiance.
  ;
  ; USAGE:
  ;    RESULT = BRIGHT_M(W, R)
  ;
  ; INPUT PARAMETERS:
  ;    W           Wavelength (microns)
  ;    R           Planck radiance (Watts per square meter per steradian
  ;                per micron)
  ;
  ; OUTPUT PARAMETERS:
  ;    BRIGHT_M    Brightness temperature (Kelvin)
  ;
  ; MODIFICATION HISTORY:
  ; Liam.Gumley@ssec.wisc.edu
  ; http://cimss.ssec.wisc.edu/~gumley
  ; $Id: bright_m.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
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

  rcs_id = '$Id: bright_m.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

    ;- Constants are from "The Fundamental Physical Constants",
    ;- Cohen, E. R. and B. N. Taylor, Physics Today, August 1993.

    ;- Planck constant (Joule second)
    h = 6.6260755e-34

  ;- Speed of light in vacuum (meters per second)
  c = 2.9979246e+8
;  c1=1.1910427e-5   ;c1=1.191066e-5
;  c2=1.4387752   ;c2=1.438833  ;
  ;- Boltzmann constant (Joules per Kelvin)
  k = 1.380658e-23

  ;- Derived constants
  c1 = 2.0 * h * c * c
  c2 = (h * c) / k
;  280.640      281.479      282.494      282.856      285.099      281.664
;  280.931      281.697      280.049      279.789      282.456      283.001
;  280.271      279.383      282.316      282.494      281.150      283.468
;  283.821      282.856      281.990      282.240      282.926      282.926
;  281.735      281.588      281.697      281.952      281.260      281.227
;  281.773      281.626      282.169      282.748      282.710      282.462
;  281.517      281.079      281.735      282.207      282.678      283.179
;  282.748      282.926      283.682      282.462      281.914      282.023
;  281.844      282.386      282.786      283.682      283.928      283.179
;  282.964      282.818      282.640      282.640      282.678      282.856
;  283.645      284.215      284.072      284.465      284.146      284.391
;  284.359      284.040      283.933      283.933      284.072      284.215
;  284.322      284.284      284.040      283.933      284.072      284.178
;  284.002      284.040      284.925      285.557      287.472      289.562
;  291.985      292.814      292.780      291.916      290.243      287.478
;  284.962      284.677      284.428      284.396      284.396      284.252
;  284.359      284.322      284.322      284.428
  ;- Convert wavelength to meters
  ws = 1.0e-6 * w

  ;- Compute brightness temperature
  s=c2 / (ws * alog(c1 / (1.0e+6 * r * ws^5) + 1.0))
  c=1304.413871/alog(1+729.541636/r)
  return, c2 / (ws * alog(c1 / (1.0e+6 * r * ws^5) + 1.0))
 ; Te_data=(c2*mersi_equivmid_wn_data[layer_i])/(alog(1+c1*mersi_equivmid_wn_data[layer_i]^3/Rad_data))

END