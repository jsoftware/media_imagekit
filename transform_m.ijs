NB. Transform Images with distortion correction and
NB. mouse operations using the image3 addon
NB. Cliff Reiter, March 2003
NB. modified for J8.04, February 2016 using imagekit
NB. 
NB. One can load an image via:
NB. transform_image d
NB. where d is an image filename, or an array representing an image

NB. locale for imagekit addon
coinsert 'mkit'
coinsert 'jgl2'
coclass 'mkit'

NB. default margin wh in pixels
WIN_wh =: 1000 1000  NB. max window size

NB. path to the imagekit addon library needs to be correct.
dir_sep=: '/'             NB. directory separator
addon_path=: jpath '~addons/media/imagekit/'
require addon_path,'imagekit.ijs'
require 'gl2'

TRANSFORMIMAGE=: 0 : 0
pc transformimage;
menupop "&File";
menu open "&Open" "Ctrl+o" "" "";
menu save "&Save..." "Ctrl+s" "" "";
menusep;
menu close "&Close" "" "" "";
menupopz;
menupop "&Transform";
menu rotateh "Rotate to &Horizontal" "" "" "";
menu rotatev "Rotate to &Vertical" "" "" "";
menu rotated "Rotate by &Degrees..." "" "" "";
menusep;
menu unbarrel "Remove &Barrel Distortion" "" "" "";
menu unbarrelc "Remove Barrel Distortion by &Coef..." "" "" "";
menu tiltr "Ti&lt to Rectangle" "" "" "";
menu balanceh "Balance Horizontal" "" "" "";
menu balancev "Balance Vertical" "" "" "";
menusep;
menu trim "&Trim" "" "" "";
menu resize "Resi&ze..." "" "" "";
menu rescale "Rescale..." "" "" "";
menupopz;
menupop "&View";
menu vselpts "&Selected Points" "" "" "";
menu vrotated "&Rotate Degrees" "" "" "";
menu vunbarrelc "&Unbarrel Coefficient" "" "" "";
menusep;
menu refresh "Re&fresh Selected Points" "" "" "";
menu clearpts "&Clear Selection" "" "" "";
menupopz;
menupop "&History";
menu back "&Back" "Ctrl+b" "" "";
menu forward "&Forward" "Ctrl+f" "" "";
menusep;
menu clearhist "&Clear History" "" "" "";
menupopz;
menupop "Hel&p";
rem menu help "Hel&p" "F1" "" "";
menusep;
menu about "&About" "" "" "";
menupopz;
)


transformimage_run=: 3 : 0
'transform_image' transformimage_run y
:
y=.image_to_i y
tr_image_list_mkit_=:i.0
image_to_hist y
tr_draw_image y
)

display_wh=:3 : 0
whav=.WIN_wh
if. y *./ . <: WIN_wh
  do. y
  else. <.y*<./WIN_wh%y end.
)

tr_draw_image=: 3 : 0
SEL_pts_mkit_=:i.0 2
mouserect=:i.0
wh=.1 0{$y
WH=.display_wh wh
y=.WH resize_image y
xywh=.0 0,1 0{$y
NB. y=.i_to_rgb y
y=.,y
wd :: 0: 'psel transformimage;'
wd :: 0: 'pclose;'
wd TRANSFORMIMAGE  
wd 'pn "Transform Image wh: ',(":wh),'";'
wd 'minwh ',(":WH),';'
wd 'cc win isidraw;'
wd 'pshow;'
glclear''
glpixels ZZ=:xywh,y
glcursor IDC_CROSS
glpaintx ''
wh
)

tr_refresh_image=:3 : 0
t=.SEL_pts_mkit_
wh=.1 0{$&>{.tr_image_list_mkit_
glclear ''
tr_draw_image image_from_hist ''
for_xy. t do.
  SEL_pts_mkit_=:SEL_pts_mkit_,xy
  draw_sel_cross xy,wh
end.
glpaintx ''
)

transformimage_refresh_button=:tr_refresh_image

transformimage_clearpts_button=:3 : 0
SEL_pts_mkit_=:i.0 2
tr_refresh_image''
)

transformimage_open_button=:3 : 0
fi=.wd 'mb open1 "Open Image" "" ""  "Bmp(*.bmp);Jpeg(*.jpg);Png(*.png)|*.bmp;*.jpg;*.png|All Files(*.*)|*.*"'
b=.read_image_raw fi
if. -. _1 -: b do. 
  image_to_hist b
  tr_draw_image b
  end.
)

transformimage_octrl_fkey=:transformimage_open_button

transformimage_vselpts_button=:3 : 0
wd 'mb info "Selected Points" "',(,LF,.~ ": SEL_pts_mkit_ ),'"'
)

image_to_hist=: 3 : 0
tr_image_list_mkit_=:(<y),tr_image_list_mkit_
)

image_from_hist=:3 : 0
>{.tr_image_list_mkit_
)

NB. Back button
transformimage_back_button=:3 : 0
tr_image_list_mkit_=:1|.tr_image_list_mkit_
tr_draw_image image_from_hist ''
)
transformimage_bctrl_fkey=:transformimage_back_button

NB. Forward buttons
transformimage_forward_button=:3 : 0
tr_image_list_mkit_=:_1|.tr_image_list_mkit_
tr_draw_image image_from_hist ''
)

transformimage_fctrl_fkey=:transformimage_forward_button

NB. save button
transformimage_save_button=:3 : 0
fo=.wd 'mb save "Save Image" "" ""  "Bmp(*.bmp);Jpeg(*.jpg);Png(*.png)|*.bmp;*.jpg;*.png|All Files(*.*)|*.*"'
(image_from_hist '') write_image fo
)

NB. clear history button
transformimage_clearhist_button=:3 : 0
tr_image_list_mkit_=:{.tr_image_list_mkit_
)

transformimage_sctrl_fkey=:transformimage_save_button

transformimage_win_mbldown=: 3 : 0
sd=.".sysdata
xy=.2{.sd
if. 1=7{sd do.
  wh=.2 3{sd  
  XY=.(0{sd),-/3 1{sd  NB.
  wh add_sel_pt XY     NB. had been xy
  mousetype=:0
  else.
  glcapture 3
  mousetype=:1,xy
  end.
)

transformimage_win_mblup=: 3 : 0
sd=.".sysdata
if. 1={.mousetype do.
  mouserect=: (}.mousetype),4{.sd
  glrgb tr_sel_color
  glpen 2 1
  fl=.(_1+{:mouserect)&-
  gllines (0 1,0 3,2 3,2 1,0 1){(0&{,fl@(1&{),2&{,fl@(3&{))mouserect
  glcapture 0
NB.   glshow ''
  glpaint ''
  end.
)

mouse_to_dij=:4 : 0
'W H M N'=.x
'x0 y0'=.y
y0=.H-y0+1
sw=. N%W
sh=. M%H
(sh*y0),sw*x0
)

transformimage_trim_button=: 3 : 0
if. 6=#mouserect do.
  'xy XY WH'=:3 2$mouserect  
  b=.image_from_hist ''  
  whmn=.WH,2{.$b
  dxy=.whmn mouse_to_dij"1  xy,:XY
  b=.(>.(>./-<./) dxy){.(<.<./dxy)}.b
  image_to_hist b
  tr_draw_image b
  mouserect=:i.0
end.
)

NB. processes resize input request
NB. input_result_resize=:3 : 0
NB. sz=.". bounds
NB. b=.sz resize_image image_from_hist ''
NB. image_to_hist b
NB. tr_draw_image b
NB. )

transformimage_resize_button=:3 : 0
wd 'pc input'
wd 'cc instruct edit readonly'
wd 'set instruct stylesheet *background-color:#eeeeee'
wd 'set instruct text Input width and height bounds:'
wd 'cc bounds edit;'
wd 'set bounds text 1000 1000'
wd  'bin h;'
wd 'cc ok button;cn "OK"'
wd 'cc cancel button default;cn "Cancel"' 
wd 'pshow;'
)

input_close_button=:3 : 0
wd 'pclose'
)

input_cancel_button=:3 : 0
wd 'pclose'
)

input_ok_button=:3 : 0
b=.(".bounds) resize_image image_from_hist ''
image_to_hist b
tr_draw_image b
wd 'psel input'
wd 'pclose'
)

rescale_image=: 4 : 0
szi=.2{.$y
szo=.|.x
ind=.(<"0 szi%szo) <.@*&.> <@i."0 szo
(<ind){y        
)

transformimage_rescale_button=:3 : 0
wd 'pc input2'
wd 'cc instruct edit readonly'
wd 'set instruct stylesheet *background-color:#eeeeee'
wd 'set instruct text Input width and height bounds:'
wd 'cc bounds edit;'
wd 'set bounds text 1000 1000'
wd  'bin h;'
wd 'cc ok button;cn "OK"'
wd 'cc cancel button default;cn "Cancel"' 
wd 'pshow;'
)
input2_close_button=:3 : 0
wd 'pclose'
)

input2_cancel_button=:3 : 0
wd 'pclose'
)

input2_ok_button=:3 : 0
b=.(". bounds) rescale_image image_from_hist ''
image_to_hist b
tr_draw_image b
wd 'psel input2'
wd 'pclose'
)

NB. selection styles
tr_sel_color=:255 0 255
tr_sel_len=:10
tr_sel_pen=:2 1

NB. marks on image a selected point
draw_sel_cross=: 3 : 0
'x y w h'=.y
glrgb tr_sel_color
glpen tr_sel_pen
if. tr_sel_len <<./x,y,(w-x),h-y  do.
  gllines (,+&(2 0*tr_sel_len))(x-tr_sel_len),h-y
  gllines (,+&(0 2*tr_sel_len))x,(-tr_sel_len)+h-y
NB.   glshow ''
  glpaint ''
  end.
)

add_sel_pt=:4 : 0
d=. >./"1 | y-"1 SEL_pts_mkit_
if. *./ d>tr_sel_len do. 
  SEL_pts_mkit_=:SEL_pts_mkit_,y
  draw_sel_cross y,x
  else.
  i=.d i. <./d
  m0=.i~:i.#d
  oldpt=:(i{SEL_pts_mkit_),x
  SEL_pts_mkit_=:m0#SEL_pts_mkit_
tr_refresh_image ''
end.  
)

NB. process Remove Barrel Distortion request
transformimage_unbarrel_button=:3 : 0
n0=.#SEL_pts_mkit_
if. n0=3 do.
  c=.get_c ''
  z=. c barrel_undistort image_from_hist ''
  image_to_hist z
  tr_draw_image z
  else. wd 'mb info "Unbarrel Error" "Unbarrel Requires 3 Selected Points"'
  end.
)

NB. view unbarrel coefficient 
transformimage_vunbarrelc_button=:3 : 0
if. 3=#SEL_pts_mkit_ do.
  c=.get_c ''
  wd 'mb info "Unbarrel Coefficient" "Coef is: ',(":c),'"'
  else.
  wd 'mb info "Unbarrel Error" "Unbarrel Requires 3 Selected Points"'
  end.
)

NB. close function
transformimage_close=: 3 : 0
wd'pclose'
)

transformimage_close_button=:transformimage_close

NB. launches help file if html browser is configured
NB. and help file is in the expected directory
transformimage_help_button=:3 : 0
require addon_path,'html_gallery.ijs'
open_html addon_path,'help',dir_sep,'transform_m.html'
)

NB. set F1 to lauch help
transformimage_f1_fkey=:transformimage_help_button

NB. The about button
transformimage_about_button=:3 : 0
z=.'Transform_m.ijs is a J script'
z=.z,:'for use with the ImageKit Addon'
z=.z,'It is used to transform images in a few ways.'
z=.z,'by Cliff Reiter'
z=.z,'Lafayette College'
z=.z,'Updated February 2016'
wd 'mb info "About Transform_m" "',(,z,"1 CRLF),'"'
)

NB. transform_image d
NB. where d is an image filename, or an array representing an image
transform_image =: transformimage_run

NB. ***********************
NB. Utilities for rotations
NB. ***********************

NB. apply rotation to seminormal coordinates 
sn_rot=: 4 : 0
'r t'=.10 12 o./ j./"1 y
t=. t+x
+. r r. t
)

NB. get angle from two points in range _1r2p1 to 1r2p1 
get_sel_pts_angle=:3 : '12 o. j./(**@{.)-/SEL_pts_mkit_'

NB. radians rotate_raw_image image
rotate_raw_image=: 4 : 0
i0=.rgb_to_i 255 255 255
wh=.|.hw=.2{.$y
y=.(y,i0),"_1 i0
cor=.,/>{;/0 0,.<:wh
x=.2p1&|&.(+&1p1) x
if. 1r2p1>:|x do. t=.|x else. t=.|1p1-|x end.
tcor=.wh sn_to_pix t sn_rot wh pix_to_sn cor
'dw dh'=.2 1{,cor-tcor
z=.(hw+2*dh,dw)$i0
for_k. (-dh)+i.({.hw)+2*dh do.
  w=.j./"1 hw pix_to_sn k,.(-dw)+i. (2*dw)+{:hw
  t=.x+12 o. w
  r=.10 o. w
  in=.;/_1 >. hw <."1 hw sn_to_pix +.r r. t 
  z=.(in{y)(dh+k)}z
  end.
z
)

NB. process rotate to horizontal request
transformimage_rotateh_button=:3 : 0
if. 2~:#SEL_pts_mkit_ do. rotateh_err ''
  else.
  t=.get_sel_pts_angle ''
  z=.t rotate_raw_image image_from_hist ''
  image_to_hist z
  tr_draw_image z
  end.
)

NB. process rotate to vertical request
transformimage_rotatev_button=:3 : 0
if. 2~:#SEL_pts_mkit_ do. rotate_err ''
  else.
  t=.get_sel_pts_angle ''
  t=.t-1r2p1**t
  z=.t rotate_raw_image image_from_hist ''
  image_to_hist z
  tr_draw_image z
  end.
)

NB. process Request to view line angle
transformimage_vrotated_button=:3 : 0
if. 2=#SEL_pts_mkit_ do.
  a=.get_sel_pts_angle ''
  wd 'mb info "Rotation Angle" "Rotation Angle is: ',( ":<.0.5+a*360%2p1),' degrees"'
  else.
  rotate_err ''
  end.
)

rotate_err=:3 : 0
wd 'mb info "Rotate Error" "Two Points Should be Selected for Rotation to Vertical/Horizontal"'
)

NB. processes rotate by degrees request
degrees_ok_button=:3 : 0
sz=.1r180p1* ". angle
b=.sz rotate_raw_image image_from_hist ''
image_to_hist b
tr_draw_image b
wd 'psel degrees'
wd 'pclose'
)

transformimage_unbarrelc_button=:3 : 0
load 'jinput'
a=.conew 'jinput'
input_result=:input_result_unbarrelc
t=.'Enter Unbarrel Coefficient',CRLF
t=.t,'Typical Value 0.1, Interesting Range _0.3 to 0.3'
if. 3=#SEL_pts_mkit_ do. c=.": get_c '' else. c=.'_0.08' end.
a_run__a t;c;'Unbarrel by Coefficient'
)

transformimage_rotated_button=:3 : 0
wd 'pc degrees'
wd 'cc instruct editm readonly'
wd 'set instruct stylesheet *background-color:#eeeeee'
wd 'set instruct text Enter Degrees to Rotate Clockwise:'
wd 'cc angle edit;'
wd 'set angle text 45'
wd  'bin h;'
wd 'cc ok button;cn "OK"'
wd 'cc cancel button default;cn "Cancel"' 
wd 'pshow;'
)

degrees_close_button=:3 : 0
wd 'pclose'
)

degrees_cancel_button=:3 : 0
wd 'pclose'
)


NB. ******************************************
NB. Utilities for correcting barrel distortion
NB. ******************************************

NB. radius to barrel distorted radius RD
NB. c R_to_RD y
R_to_RD=: ] + [ * ^&3@]

NB. distorted radius to radius
NB. c RD_to_R y
p1_temp=.1 11 39 51 16&p.
p2_temp=.1 12 48 75 36&p.
RD_to_R=: ]* (p1_temp % p2_temp)@:([**:@]) f.

NB. pixel coordinates to seminormal _1 to 1 coordinates 
NB. preserving aspect ratio
NB. wh pix_to_sn ij
pix_to_sn=: 1 : 0
(y-"1-:m-1)%-:>./m-1
)

NB. seminormal to pixel coordinates
NB. wh sn_to_pix xy
sn_to_pix=: 1 : 0
<.0.5+(-:m-1)+"1 y*"1 -:>./m-1
)
NB. sn_to_pix=: 1 : 0
NB. [:<.@(0.5&+)(-:m-1)"_ +"1 (-:>./m-1)&*"1
NB. )

NB. sn_to_pix =: [: <.@(0.5&+) (-:@<:@[)+"1 ] *"1 -:@(>./)@:<:@[

NB. apply distortion to seminormal coordinates 
sn_dist=: 1 : 0
'r t'=.10 12 o./ j./"1 y
r=.m R_to_RD r
+. r r. t
)

NB. apply undistortion to seminormal coordinates 
sn_undist=: 1 : 0
'r t'=.10 12 o./ j./"1 y
r=.m RD_to_R r
+. r r. t
)

NB. c barrel_undistort raw_image
barrel_undistort=: 4 : 0
i0=.rgb_to_i 255 255 255
wh=.|.hw=.2{.$y
und=.wh sn_to_pix@(x sn_undist)@(wh pix_to_sn)
y=.(y,i0),"_1 i0
if. x<0 do.
'dw dh'=.|und 0 0
else.
'dw dh'=.-<./und -:wh*=i.2
end.
z=.((hw+2*dh,dw))$i0
dsn=. -{.-/hw pix_to_sn 0 0,:1 1
w=.j./"1 hw pix_to_sn (-dh),.(-dw)+i. (2*dw)+{:hw
for_k. (-dh)+i.({.hw)+2*dh do.
  t=.12 o. w
  r=.|10 o. w
  r=.x R_to_RD r
  in=.;/_1 >. hw <."1 hw sn_to_pix +.r r. t 
  z=.(in{y)(dh+k)}z
  w=.w+dsn
  end.
z
)

NB. tries various coefficient for undistrotion and
NB. returns a signed measure of linearity
try_c=: 3 : 0"0
wh=.m_wh ''
-/ . * (}.-"1{.)y sn_undist"1 wh pix_to_sn SEL_pts_mkit_
)

NB. use mouse points to get c
get_c=:3 : 0
c=._0.5
h=.0.1
while. 0.0001<h do.
  t=.c+h*i.11
  i=.1 i:~0>(*{:)try_c t
  c=.i{t
  h=.0.1*h
  end.
c
)

NB. processes remove barrel distrotion request
usec_ok_button=:3 : 0
s=.". coef
b=.s barrel_undistort image_from_hist ''
image_to_hist b
tr_draw_image b
wd 'psel usec'
wd 'pclose'
)

transformimage_unbarrelc_button=:3 : 0
load 'jinput'
a=.conew 'jinput'
input_result=:input_result_unbarrelc
t=.'Enter Unbarrel Coefficient',CRLF
t=.t,'Typical Value 0.1, Interesting Range _0.3 to 0.3'
if. 3=#SEL_pts_mkit_ do. c=.": get_c '' else. c=.'_0.08' end.
a_run__a t;c;'Unbarrel by Coefficient'
)

transformimage_unbarrelc_button=:3 : 0
wd 'pc usec'
wd 'cc instruct editm readonly'
t=.'Enter Unbarrel Coefficient',CRLF
t=.t,'Typical Value 0.1, Interesting Range _0.3 to 0.3'
wd 'set instruct stylesheet *background-color:#eeeeee'
wd 'set instruct text ',t
wd 'cc coef edit;'
wd 'set coef text 0.1'
wd  'bin h;'
wd 'cc ok button;cn "OK"'
wd 'cc cancel button default;cn "Cancel"' 
wd 'pshow;'
)

usec_close_button=:3 : 0
wd 'pclose'
)

usec_cancel_button=:3 : 0
wd 'pclose'
)


NB. ***********************************************
NB. Utilities for moving four points to a rectangle
NB. ***********************************************
bal_4=:3 : 0
s=.y /: 2p1|12 o. j./"1 y-"1(+/%#)y
xa=._1|.2#_2 (+/%#)\ {."1 ]1|.s
ya=.2#_2 (+/%#)\ {:"1 s
s,:xa,.ya
)

transformimage_tiltr_button=: 3 : 0
if. 4=#SEL_pts_mkit_ do.
  a=.get_tilt_a |."1 get_tilt_pts ''
  b=.a trans_tilt image_from_hist ''
  image_to_hist b
  tr_draw_image b
else. wd 'mb info "Error on Tilt" "Tilt to Rectangle needs 4 selected points"' 
end.
)

m_wh=: 3 : 0   NB. mouse wh
display_wh|.$&>{.tr_image_list_mkit_
)

sn_flip1=:1 _1&*"1

get_tilt_pts=:3 : 0
wh=.m_wh ''
bal_4 sn_flip1 wh pix_to_sn SEL_pts_mkit_
)

get_tilt_a=:3 : 0
({.y) %. (1:,],*/)"1 {: y
)

NB. coef trans_tilt image
trans_tilt=:4 : 0
i0=.rgb_to_i 255 255 255
to_tilt=:((+/ . * )&x)@:(1:,],*/)"1 
wh=.|.hw=.2{.$y
y=.(y,i0),"_1 i0  NB. pad white edge
dh=.dw=.0
z=.(hw+2*dh,dw)$i0
for_k. (-dh)+i.({.hw)+2*dh do.
  in=.;/_1 >. hw <."1 hw sn_to_pix to_tilt hw pix_to_sn k,.(-dw)+i. (2*dw)+{:hw
  z=.(in{y)(dh+k)}z
  end.
z
)

NB. ***********************************************
NB. Utilities for nonlinear stretching in horz/vert
NB. ***********************************************
bal_horz=:3 : 0
yy=.image_from_hist ''
WH=:1 0{$yy
W=:{.WH
xx=./:~{."1 WH sn_to_pix (m_wh'') pix_to_sn SEL_pts_mkit_
h=.xx +/ . * -:_1 1 _1 1
'x0 x1 x2 x3'=.xx
p=.(xx %.(x0,(x0+h),x2,x2+h)^/i.4)&p.
i=.<.0.5+p (--:W)+i.+:W
i=.((i>:0)*.i<W)#i
i{"1 yy
)

transformimage_balanceh_button=: 3 : 0
if. 4=#SEL_pts_mkit_ do.
  b=.bal_horz ''
  image_to_hist b
  tr_draw_image b
else. wd 'mb info "Error on Tilt" "Balance Horizontal uses 4 selected points on a horizontal line"' 
end.
)

bal_vert=:3 : 0
yy=.image_from_hist ''
WH=:1 0{$yy
H=:{:WH
xx=.(H-1)-/:~{:"1 WH sn_to_pix (m_wh'') pix_to_sn SEL_pts_mkit_
h=.xx +/ . * -:_1 1 _1 1
'x0 x1 x2 x3'=.xx
p=.(xx %.(x0,(x0+h),x2,x2+h)^/i.4)&p.
i=.<.0.5+p (--:H)+i.+:H
i=.((i>:0)*.i<H)#i
i{yy
)

transformimage_balancev_button=: 3 : 0
if. 4=#SEL_pts_mkit_ do.
  b=.bal_vert ''
  image_to_hist b
  tr_draw_image b
else. wd 'mb info "Error on Tilt" "Balance Vertical uses 4 selected points on a vertical line"' 
end.
)


coclass 'base'