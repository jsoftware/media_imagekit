NB. Paletted bmp read/write
NB. Modified from old image3 addon
NB. to give minimal paletted image
NB. capabilities to FVJ4
NB. 
coinsert 'mkit'
require 'files'
cocurrent 'mkit'

NB. ***********************
NB. ***  BMP functions  ***
NB. ***********************

NB. little endian integer conversions for bmp's
lic=: 4 : 0"0 1
select. x
case. _1 do. _2 (256&#.@:(a.&i.)@:|.)\ y
case. _2 do. _4 (256&#.@:(a.&i.)@:|.)\ y
case. 1 do.  ,|.@:({&a.)@:(256 256&#:)"0 y
case. 2 do.  ,|.@:({&a.)@:(256 256 256 256&#:)"0 y
end.
)

NB. write h by w by 3 ascii array (x) to bmp file specified by y
NB. (pal;b) write_bmp fn creates an 8-bit image file
pal_write_bmp=:4 : 0
if. 32=(3!:0) x do. NB. (pal;b) paletted input
   bpp=.8
   pal=.(0,"1~|."1 >{.x){a.
   x=.>{:x
   else.
   if. (3=$$x) *. 1={:$x do. x=.,"2 x end. NB. grayscale 3-d array
   if. 2=$$x do. NB. grayscale matrix
     bpp=.8
     pal=.(3#"0 a.),.{.a.
     else.        NB. ordinary 24-bit
     bpp=.24
     pal=.''
     end.
   end.
if. 4=(3!:0) x do. x=.x{a. end.
Bpp=.1,<.bpp%8
xsbmp=.(0 1*4|-sbmp*Bpp)+Bpp*sbmp=.2{.$x
szpal=.4*#pal
hdr=.'BM',2 lic (54+szpal+*/xsbmp),0,(54+szpal),40,|.sbmp
hdr=.hdr,(1 lic 1,bpp),2 lic 0,(*/xsbmp),0 0,(#pal),0
if. bpp=24 do. x=.,"2 |."1 x end.
bmp=.,|. xsbmp{.x
(hdr,(,pal),bmp)fwrite y
)


NB. internal utility for converting bmp file data
NB. into raw palette/index array
de_pal_bmp_data=: 3 : 0
NB.ic=.3!:4"0 1
x0=.y
sbmp=.|.,_2 lic (18+i.2 4){x0
xsbmp=.sbmp+(i.2)*4|-sbmp
biClrUsed=._2 lic (46+i.4){x0   NB. change from image2
if. biClrUsed = 0 do. biClrUsed =. <. 0.25*(#x0)-54+*/xsbmp end.
biOffBits=._2 lic (10+i.4){x0
rpal=. 2 1 0{"1 (biClrUsed,4)$ 54}.(54+4*biClrUsed){.x0
bmp=. a.i.|.sbmp{.xsbmp$biOffBits}.x0
rpal;bmp
)

NB. read *.bmp as a paletted image if possible
pal_read_bmp=:3 : 0
NB.ic=.3!:4"0 1
if. _1-:x=.fread y do. 'file not found' return. end.
biCompression=._2 lic (30+i.4){x
  if. biCompression ~: 0 do. 'compressed bmp files are not supported' return. end.
biBitCount=. _1 lic (28+i.2){x
if. biBitCount = 8 do.
  'rpal bmp'=.de_pal_bmp_data x
  else. 'not a paletted image' return. end.
(a.i. rpal);bmp
)

NB. BMP image width & height
bmp_wh=:3 : 0
NB.ic=.3!:4"0 1
,_2 lic 2 4$1!:11 (;y);18 8
)

NB. bmp_color_depth
bmp_cd=: 3 : '_1 lic 1!:11 y;28 2'

coclass 'base'
