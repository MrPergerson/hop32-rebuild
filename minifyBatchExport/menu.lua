local n,a={main=1,settings=2,credits=3},nil local t,e,o={[n.main]={[1]={text="start",active=false,color=6,action=function()c(n.settings)end},[2]={text="credits",active=false,color=6,action=function()c(n.credits)end}},[n.settings]={[1]={text="play",active=false,color=6,action=function()a()end},[2]={text="gamemode",active=false,color=6,action=function()g()end},[3]={text="input mode",active=false,color=6,action=function()k()end},[4]={text="back",active=false,color=6,action=function()c(n.main)end}},[n.credits]={[1]={text="back",active=false,color=6,action=function()c(n.main)end}}},n.main,1function x(t)e=n.main d(1)a=t end function q(n)if btnp(5)do t[e][o].action()end if btnp(2)do local n=o-1if n<1do n=#t[e]end d(n)end if btnp(3)do local n=o+1if n>#t[e]do n=1end d(n)end if u>0do?y().title,i+32
u=max(0,u-n)end end function v()local a,i=16,60if e==n.main do?"⁶w⁶thop32",46,16,6
elseif e==n.settings do a=16if o==2do l=y()?l.title,a+44,i+10,6
?l.description,a+44,i+20,6
elseif o==3do l=b()?l.title,a+44,i+20,6
?l.description,a+44,i+30,6
end elseif e==n.credits do?"⁶w⁶tcredits",46,16,6
?"cole pergerson",a,i+10,6
?"james morgan",a,i+20,6
?"shahbaz mansahia",a,i+30,6
?"frank dominguez",a,i+40,6
end for n=1,#t[e]do?t[e][n].text,a,i,t[e][n].color
i+=10end end function d(n,i)local a=e if i~=nil do a=i end t[a][o].active=false t[a][o].color=6t[e][n].active=true t[e][n].color=7o=n end function c(t)local a=e if t==n.main do e=n.main elseif t==n.settings do e=n.settings elseif t==n.credits do e=n.credits end d(1,a)end function g()local n=f+1if n>1do n=0end f=n if f==m.playerSelect or f==m.game do u=3end end function k()local n=s+1if n>1do n=0end s=n end function y()if f==w.tournament do return{title="tournament",description="players cannot \njoin once the game \nhas started."}elseif f==w.freeplay do return{title="freeplay",description="players are free \nto join after the game \nhas started."}end end function b()if s==0do return{title="strict",description="characters are \nassigned to \nspecific keys."}elseif s==1do return{title="any key",description="characters can be \nassigned to \nany key."}elseif s==2do return{title="controller",description="characters are \nassigned to \ncontroller buttons."}end end function A()if B>0do if C==m.complete do?"⁶w⁶tyou win!",i+30,r+60,10
else?"⁶w⁶tnext time...",i+20,r+60,10
end else rectfill(i,r,i+128,r+128,12)j(i,r)end end function j(e,t)local a,n="",t+16?"players\n",e+45,n,10
n=n+10h=0for t=1,#z do p=h*32spr(z[t][1],e+12+p,n)?tostr(t)..a.."\n",e+4+p,n,10
if h==3do n=n+10end h=(h+1)%4end?"		continue in "..flr(D).."\n",e,t+116,10
end