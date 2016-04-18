NB. Image kit
NB. Utilities for working with images
NB. a partial replacement for image3.ijs and view_m.ijs from the image3 addon
NB. Cliff Reiter 2015 with additions by Bill Lam

require 'viewmat'
coinsert 'mkit'
coclass 'mkit'

NB. for j803
IFJA=: (IFJA"_)^:(0=4!:0<'IFJA')0

NB. default jpeg quality
JPEG_QUALITY=:90

NB. dir_sep
dir_sep=:'/'

NB. change to slash
to_slash =:rplc&'\/'

NB. ***************************
NB. ***  General functions  ***
NB. ***************************

NB. change text to lower case
to_lc=:(+32&*@:(e.&(65+i.26)))&.(a.&i.)

NB. get file name extension
fn_ext=: }.~ 1: + i:&'.'

NB. change extension
ch_ext=: ({.~ 1: + i:&'.')@] , [

NB. checks function names are boxed with last axis length two;
NB. otherwise, boxes and/or adjoins default names to trailing axis.
d_fn_ck=:1 : '(;u)&>^:(2: ~: {:@(1:,$))@:(<@deb"1^:(L.=0:))'

NB. gives short file x is levels of path to keep (default x=.0)
NB. drive letter, if any, is stripped
short_fn=:3 : 0                 NB. gives short file names
0 short_fn y
:
Y=.(,~ -.@(e.&'/\')@{. # dir_sep"_)@:(}.~(i:&':')@:(':'&,)) to_slash y
}.;(->:x){.(e.&'/\' <;.1 ])Y
)

NB. gives pathname of file
path_nm=: {.~ 1+i:&'/'@:to_slash

NB. n nfmt nums
NB. gives n-digit formatted interger representation of nums with
NB. leading 0s as necessary. Useful for fileame sequences.
NB. Default it 3-digits
nfmt=: 3&$: : ({&'0123456789'@:(([#10"_)#:]))

NB. "next" file name (when suffix is a number)
NB. nx_fn 'abc001.bmp' is 'abc002.bmp'
NB. nx_fn 'abc999.bmp' is 'abc1000.bmp'
nx_fn=:3 : 0
m0=.i:&'.' y
pre=.m0 {. y
n0=._1+(#-i:&0) e.&'0123456789' pre
fnum=.(-n0){.pre
((-n0)}.pre),(,(n0+0=#fnum-.'9')nfmt >: ". fnum),m0}.y
)

NB. new filename sequence
NB. num new_fn_seq oldfilenameseq is a sequence of length
NB. #oldfilenamesequ with names similar to {.oldfilenameseq
NB. except the numeric suffix is replaced by num and its successors
new_fn_seq=:4 : 0
ffn=.>{.y
m0=.i:&'.' ffn
pre=.m0 {. ffn
n0=._1+(#-i:&0) e.&'0123456789' pre
z=.<"1 ((-n0)}.pre),"1 ((n0 >.#":<:x+#y)nfmt x+i.#y),"1 m0}.ffn
if. +./z e. y do. wd 'mb "Error" "Result sequence overlaps with input sequence"'
  else. z end.
)

NB. gives the numeric suffix, if any, of the given filename
fn_num_suffix=:".@(>:@(i:&0-#)@( e.&'0123456789'){.])@:(i:&'.'{.])

NB. file_selector fseq_adjoin path1;path2[...]
fseq_adjoin=:1 : 0
path1=.>{.y
nn=.1+>./;fn_num_suffix&.> u path1
for_dir. }. y do.
  fseq=.u > dir
  Fmove fseq,. nn&new_fn_seq@:(path1&,@short_fn&.>) fseq
  nn=.nn+#fseq
end.
<:nn
)

NB. finds files of given form in folder given by pathname
NB. (use trailing directory separator in pathname)
NB. e.g.  '*.bmp' files_in '\my_images\'
files_in=:1 : 0
y&,&.>/:~{."1 fdir y,m
)

NB. conditional flip of bytes
set_cflip=: 3 : 0
if. IFJA do. RGBSEQ=. RGBSEQ_j_ else. RGBSEQ=. RGBSEQ_jqtide_ end.
try.
if. RGBSEQ do. cflip=:|."1 else. cflip=:] end.
catch. smoutput IFJA{::'Requires JQT';'Requires JAndroid' end.
' '
)
set_cflip''

NB. h by w integer to h by w by 3 integer 
i_to_rgb=: [: cflip a.i.[:}:"1($,4:)$(2&ic)@,

NB. h by w by 3 integer to packed h by w integer
rgb_to_i=:{.@(_2&ic)@({&a.) @(,&255@cflip)

NB. h by w by 3 from a. to packed h by w integer
rgb_raw_to_i=:{.@(_2&ic)"1 @: (,&(255{a.)@cflip) 

NB. read image each pixel as one integer
read_image_raw=:readimg_jqtide_`readimg_ja_@.IFJA

NB. h by w by 3 integer image array
read_image =: i_to_rgb@:read_image_raw

NB. image in various format to h by w packed integer array
image_to_i=:3 : 0
if. 'boxed'-: datatype y do. 
   if. 2=$y do. 
     'p b'=. y
     if. 'literal'-:datatype b do. b=.a.i.b end.
     y=.b{p end. end.
select. datatype y 
  case. 'integer' do.
    if. (3=#$y)*.3={:$y do. y=. rgb_to_i y end.
  case. 'literal' do.
    if. 1=#$y do. y=.read_image_raw y 
      elseif. (3=#$y)*.3={:$y do. y=. rgb_raw_to_i y end.
end.
y
)

NB. view an image in any of various formats
view_image=: viewrgb@:image_to_i

NB. write an image to file
write_image=: 1 : 0
if. (<to_lc fn_ext y)e. 'jpg';'jpeg' do. 
  JPEG_QUALITY m write_image y
else.
(image_to_i m) writeimg_jqtide_`writeimg_ja_@.IFJA y
fsize y
end.
:
(image_to_i m) writeimg_jqtide_`writeimg_ja_@.IFJA y;'jpeg';'quality';x
fsize y
)

NB. image_wh gives image size without loading image when possible
image_wh=: 3 : 0
select. to_lc fn_ext y  
  case. 'bmp' do. 2{.readbmphdr y
  case. 'png' do. 2{.readpnghdr y
  case.        do. 1 0{$read_image_raw y
end.
)

NB. Hue y
NB. gives a pure hue running through red-yellow-green-cyan-blue-magenta-red
NB. as y runs from 0 to 1
NB. A function with similar facilities is named "hue" in raster5.ijs
NB. and is renamed "Hue" here to avoid name conflicts.
Hue=:<.@(255.9999&*)@((-.,])@(1&|)+/ . *{&(#:7|3^10-i.8)@(0 1&+)@<.)@(6&*)"0

NB. (width_bdd,height_bdd) resize_image image_array
NB. resizes a 2 or 3 dimensional array, preserving
NB. aspect ratio so that it fits in new bounds.
resize_image=: 4 : 0
szi=.2{.$y
szo=.<.szi*<./(|.x)%szi
ind=.(<"0 szi%szo) <.@*&.> <@i."0 szo
(<ind){y
)

NB. Three favorite palettes
NB. default for view_data is P254 which
NB. is white, 254 colors given by hue and black
P254=:255,0,~Hue 5r6*(i.%<:)254

NB. P256 is 256 hues
P256=:Hue 5r6*(i.%<:)256

NB. BW256 is 256 grayscales
BW256=:3#"0 i. 256

NB. num cile v 
NB. Utility for making contour levels with optimal contrast;
NB. num is the number of contour levels to distinguish and v is a matrix
NB. of real data
cile=:$@] $ ((/:@/:@] <.@:* (%#)),)

NB. pal view_data matrix
NB. results in an image of the data given in the matrix
NB. default palette: white is low, hues in between, black is high
NB. use P256 view_data 256 cile data to show the data with
NB. just hues (red low, magenta high) and equal area contours.
view_data =: 3 : 0
P254 view_data y
:
min=.<./,y
max=.>./,y
if. -. (min e. 0 1) *. max e. 254 255 do.
  y=.(255.9999%max-min)*y-min
  end.
view_image x;<.y
)

NB. From 
NB. http://en.literateprograms.org/Median_cut_algorithm_(J)
NB. taken 2/14/2012

mediancut =: dyad : '> mean each step^:(x-1) <y'
mean =: +/%#

step =: monad : '(fmax y) smax y'

fmax =: monad : '{:/: ; bbox each y'
bbox =: monad : '(>./y)-(<./y)'

sbox =: dyad  : '({&y) each chop x rank y'
sfst =: dyad  : '(x sbox >{.y),(}.y)'
smax =: dyad  : '(3|x) sfst (<.x%3) |. y'

rank =: dyad  : '/: x {"1 y'
chop =: monad : '(<.2%~#y) ({.;}.) y'

NB. added by Cliff
quantize_image=: 4 : 0
b=.step^:(x-1) <,/y
i=.(#&>b)#i.x
ind=.((;b)i."_ 1 y){i
pal=.<.@mean&>b
pal;ind
)

coclass 'base'

try=: 0 : 0
fn=:jpath '~addons/media/imagekit/atkiln.jpg'
fn2=:jpath '~addons/media/imagekit/hy_fly_di.png'
$b=:read_image fn
view_image fn
view_image b
view_image |.b
view_image fn2
$b2=:read_image fn2
view_image b2 
b write_image on=:'d:\temp\test.jpg'
view_image on
5 b write_image on=:'d:\temp\test.jpg'
view_image on
b write_image on=:'d:\temp\test.png'
view_image on
b2 write_image on=:'d:\temp\test.png'
view_image on
)
