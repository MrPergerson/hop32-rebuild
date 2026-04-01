y=false no=false n=false o=0eg=0k=0c={mainMenu=0,playerSelect=1,game=2,gameover=3,complete=4}h=c.mainMenu L={tournament=0,freeplay=1}j=L.tournament i=0a=0nd=0nl=0M=1em=0nj=7nz=1.5nF=8function ek(n)nd=a nl=n M=0end B=5.9z=0N=15F=3g={}m={}nt=0nf=0s=0D=0C={}eb=1function E(n)if(n>s)n=s
D=n end u={}w={}r={}nD={}ni={GREEN_LANDS=0,CLOUD_KINGDOM=10}n1=-1x=0na=0W=false O=4b={NONE=0,GRASS=2,GROUND=3,WALL=4,SAND_1=93,SAND_2=94,SAND_3=95,MOUNTAIN_1=96,MOUNTAIN_2=97,MOUNTAIN_3=99,SNOW_1=99,SNOW_2=100,SNOW_3=101,ORELAND_1=102,ORELAND_2=103,ORELAND_3=104,HELL_1=105,HELL_2=106,HELL_3=107,CLOUD_1=89,CLOUD_2=90,CLOUD_3=91,CLOUD_4=92,GLITCH=88}f={GRASS=48,DESERT=96,MOUNTAIN=144,SNOW=192,CITY=240,VOID=336,KINGDOM=384}nc=23nq=24G={}nA=128nB=129nC=130function e(n,e)for o,n in ipairs(n)do if(n==e)return true
end return false end v={}v.__index=v function v.new()local n=setmetatable({items={},head=1,tail=1},v)return n end function v:enqueue_unique(n)if(not e(self.items,n))self.items[self.tail]=n self.tail=self.tail+1
end function v:dequeue()if(self:isempty())return nil
local n=self.items[self.head]self.items[self.head]=nil self.head=self.head+1return n end function v:isempty()return self.head==self.tail end function nE(o)local n=t()return function()local e=t()if(e-n>=o)n=e return true
return false end end function P(n,e)return max(n-e,0)end function Q(n,e,o)return n+(e-n)*o end function n0(n)local o,e=flr(n/60),flr(n%60)local n=tostr(e)if(e<10)n="0"..n
return o..":"..n end function R(n,t,d)local l=0for e=1,#n do local o=e+1if(o>#n)o=1
if(d<n[e].y~=(d<n[o].y)and t<n[e].x+(d-n[e].y)/(n[o].y-n[e].y)*(n[o].x-n[e].x))l+=1
end return not(l%2==0)end function nG(n,e,o,d)local l,t,f,i=n+rnd(o),n+rnd(o),e+rnd(d),e+rnd(d)return{{x=l,y=e},{x=n+o,y=i},{x=t,y=e+d},{x=n,y=f}}end function l(n)line()for e=1,#n do line(n[e].x,n[e].y,11)end line(n[1].x,n[1].y,11)end function ep(n,e,o)line()line(n.x,n.y,n.x+e.x*100,n.y+e.y*100,o)end nH={["a"]=33,["b"]=34,["c"]=35,["d"]=36,["e"]=37,["f"]=38,["g"]=39,["h"]=40,["i"]=41,["j"]=42,["k"]=43,["l"]=26,["m"]=27,["n"]=22,["o"]=20,["q"]=48,["r"]=49,["s"]=50,["t"]=51,["u"]=52,["v"]=53,["w"]=54,["x"]=55,["y"]=56,["z"]=57,["1"]=58,["2"]=59,["3"]=27,["4"]=24,["5"]=23,["6"]=21,["7"]=64,["8"]=65}poke(24365,1)ey={}nI=48d=16X=0H=32local o,e=128,0Y={}nJ=11function nK()X=f.VOID e=flr(rnd(128))end function nL(n)local e={x=n,y=0,tiles={},surface_tiles={}}for n=n,n+d-1do e.tiles[n]={}for o=0,H-1do if n<f.GRASS do e.tiles[n][o]={x=n,y=o,sprite=b.GROUND}elseif n<f.DESERT do e.tiles[n][o]={x=n,y=o,sprite=b.SAND_1}elseif n<f.MOUNTAIN do e.tiles[n][o]={x=n,y=o,sprite=b.MOUNTAIN_2}elseif n<f.SNOW do e.tiles[n][o]={x=n,y=o,sprite=b.SNOW_2}elseif n<f.CITY do e.tiles[n][o]={x=n,y=o,sprite=b.ORELAND_1}elseif n<f.VOID do e.tiles[n][o]={x=n,y=o,sprite=b.HELL_2}else e.tiles[n][o]={x=n,y=o,sprite=b.GROUND}end end end for n=n,n+d-1do for o=0,H-1do local d=nM(n)+0if(o-nJ<d)e.tiles[n][o].sprite=b.NONE
end end if n==x*16and h==c.playerSelect do else if(n>0and n<X-nI and rnd(1)>=.5)local o=flr(rnd(d-2-1))local n=n+o+1for n=n,n+2,1do for o=0,H-1,1do e.tiles[n][o].sprite=b.NONE end end
end for n=n,n+d-1do for o=1,H-1do local d,o=e.tiles[n][o-1],e.tiles[n][o]if(d.sprite==b.NONE and o.sprite~=b.NONE)add(e.surface_tiles,o)if n<f.GRASS do o.sprite=b.GRASS elseif n<f.DESERT do elseif n<f.MOUNTAIN do o.sprite=b.MOUNTAIN_1 elseif n<f.SNOW do end
end end return e end function nN(e,o)local n={x=e,y=o,tiles={},surface_tiles={}}for e=e,e+15do n.tiles[e]={}for o=o,o+15do n.tiles[e][o]={x=e,y=o,sprite=b.NONE}end end local l,t,d=0,0,true for f=e,e+15do if(l==4)d,l=not d,0
l+=1t=flr(rnd(4))-2for e=o,o+15do if d and e==10+t do n.tiles[f][e].sprite=b.ORELAND_3 elseif d and e>9+t do n.tiles[f][e].sprite=b.ORELAND_1 end if(e>14)n.tiles[f][e].sprite=b.ORELAND_2
end end for e=e,e+15do for o=o+1,o+15do local d,e=n.tiles[e][o-1],n.tiles[e][o]if(d.sprite==b.NONE and e.sprite~=b.NONE)add(n.surface_tiles,e)
end end return n end function nO(n,e,l)local o={x=n,y=e,tiles={},surface_tiles={}}for n=n,n+15do o.tiles[n]={}for e=e,e+15do o.tiles[n][e]={x=n,y=e,sprite=b.NONE}end end local d,l=0,l for t=1,3do local f=d d=d+4+flr(rnd(2))local d,i,a=flr(rnd(8))+7,flr(rnd(2)),flr(rnd(2))nP(l,n+f+i,e+d+a,n,e,o.tiles)if(t&2==0)l=max(3,l-1)
end nr(o,n,e,88)return o end function nQ(n,e)local o={x=n,y=e,tiles={},surface_tiles={}}for n=n,n+15do o.tiles[n]={}for e=e,e+15do o.tiles[n][e]={x=n,y=e,sprite=b.CLOUD_1}end end for n=n,n+15do for e=e,e+15do if(e<sin((n-1)/8)+13and e>sin((n-5)/8)+2)o.tiles[n][e].sprite=b.NONE
end end nr(o,n,e,-1)return o end function nP(o,n,e,t,l,d)n,e=min(n,t+14-o),min(e,l+14-o+1)local l=nG(n*8,e*8,o*8,o*8)add(Y,l)local f=0for t=0,o-1,1do for o=0,o-1,1do local n,e,o=n+t,e+o,0if(R(l,n*8,e*8))o+=1
if(R(l,(n+1)*8,e*8))o+=1
if(R(l,(n+1)*8,(e+1)*8))o+=1
if(R(l,n*8,(e+1)*8))o+=1
if(o>=2)d[n][e].sprite=88f+=1
end end if f==0do d[n][e].sprite=88if(n+1==t+15+o-1)d[n-1][e].sprite=88else d[n+1][e].sprite=88
d[n][e+1].sprite=88end end function nM(n)if n<=f.GRASS do return sin((n-1+e)/16)elseif n<=f.DESERT do return sin((n-1+e)/8)elseif n<=f.MOUNTAIN do return sin((n-1+e)/16)+4*sin((n-1+e)/16*1.5)elseif n<=f.SNOW do return sin((n-1+e)/16)else return sin((n-1+e)/16)end end function nr(n,e,o,d)for e=e,e+15do for o=o+1,o+15do local l,e=n.tiles[e][o-1],n.tiles[e][o]if l.sprite==b.NONE and e.sprite~=b.NONE do if(d>0)e.sprite=d
add(n.surface_tiles,e)end end end end function nR(n)return n[flr(rnd(#n))+1]end function ev(n)local n=flr(n/8)for e=1,15do local o,n=p(n,e-1),p(n,e)if(o.tile==b.NONE and n.tile~=b.NONE)return n
end end function nS()for e,n in ipairs(Y)do l(n)end end local e,n,d,l={},0,0,8function nT(o)e,l={},8Y={}n,d=o*16,0Z()Z()end function nU(d)local n=Z(n,0)add(e,n)o+=1local n=n for e in all(e)do if(e.x<n.x)n=e
end del(e,n)end function Z()local o if n>=f.VOID do o=nQ(n,d)if(n==f.VOID+16)nV()_(3008,40)W=true
elseif n>=f.CITY do o=nO(n,d,l)l-=1elseif n>=f.SNOW do o=nN(n,d)if(n==f.SNOW+16)nW()_((f.SNOW+16)*8,8)
else o=nL(n)if(o.x~=x*16or h~=c.playerSelect)local n=nR(o.surface_tiles)q(w,-1,n.x*8,(n.y-1)*8)
if(n==64)_(512,16)
end add(e,o)n+=16return o end function nX()for n in all(e)do for e=n.x,n.x+16-1do for o=n.y,n.y+16-1do local n=n.tiles[e][o]if n.sprite>0do spr(n.sprite,n.x*8,n.y*8)if(y)rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,9)
else if(y)rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,2)
end end end end end function p(n,o)local d,l=e[1],e[#e]if n<d.x or n>=l.x+16or o<d.y or o>=d.y+H do return{tile=-1}else local d={tile=-1}n,o=flr(n),flr(o)for e in all(e)do if(n>=e.x and n<e.x+16)d=e break
end if(d.tile==-1)printh("("..n..","..o..") tile not found")return d
return d.tiles[n][o]end end function nY(n)local o,n={tile=-1},flr(n/8)for e in all(e)do if(n>=e.x and n<e.x+16)o=e break
end local e=o.surface_tiles for o,e in ipairs(e)do if(e.x==n)return e
end end function nh(t,o,d,i,a)local e,n,d,l,c,f=t/8,o/8,d/8,i/8,false,false local r,h,u,l,s,g,m,k,d=p(e,l),p(e,l+.999),p(e+1,l),p(e+1,l+.999),p(d,n),p(d+.999,n),p(d,n+1),p(d+.999,n+1),0if r and h and(r.sprite~=b.NONE or h.sprite~=b.NONE)do if(not a)e=flr(e)+1
f=true elseif u and l and(u.sprite~=b.NONE or l.sprite~=b.NONE)do e=flr(e)d+=1f=true end if s and g and(s.sprite~=b.NONE or g.sprite~=b.NONE)do if(o>0or not a)n=flr(n)+1
d+=1elseif m and k and(m.sprite~=b.NONE or k.sprite~=b.NONE)do n,c=flr(n),true end if(d==2)if(o>i)n=n-1
t,o=e*8,n*8return{x=t,y=o,onGround=c,hit_wall=f}end local o=20function I(n,e,o)for n=1,n do e[n]=nZ(o,n)end end function nZ(n,e)local n={id=e,type=n.type,enabled=false,inputDisabled=false,xpos=-8,ypos=-8,startPosition=0,boundsOffsetX=0,boundsOffsetY=0,vx=0,vy=0,move_dir=-1,width=n.width,height=n.height,onGround=false,bounce_charge=0,jump_height=1.5,jump_distance=1.5,jump_gravity=0,fall_gravity=50,sprite=n.sprite,sprite2=n.sprite2,disabledCount=0,ai_enabled=false,state=1,totalTimeEnabled=0,reviveCount=0,last_enabled_time=0,won=false,timer_1=0,capture_tracker={},tracker_beam={xpos=0,ypos=0,width=16,height=32,boundsOffsetX=4,boundsOffsetY=28}}return n end function q(o,e,d,l)local n if e==-1do for o,e in pairs(o)do if(not e.enabled)n=e break
end if(not n)printh"no more actors available"return
else n=o[e]if(not n)printh("can't find actor with id "..e)return
end n.enabled=true n.last_enabled_time=time()n.ai_enabled=true n.inputDisabled=false n.state=1n.search_timer=5+flr(rnd(5))n.ypos=l n.xpos=d n.bounce_charge=0return n end function S(n)n.enabled=false n.ai_enabled=false n.disabledCount+=1n.totalTimeEnabled+=time()-n.last_enabled_time n.vx=0n.vy=0end function nu(n,e)if(n.vy>=0)o=n.fall_gravity*8else o=n.jump_gravity*8
local d,l=n.xpos+n.vx*e+5*e*e,n.ypos+n.vy*e+.5*o*e*e n.vx+=10*e n.vy+=o*e n.vy=min(n.vy,200)return{xpos=d,ypos=l}end function n2(n)if(n.onGround and not n.won)local e,o=n.jump_distance*.6,n.jump_distance*.4local d=-2*n.jump_height*4/e n.jump_gravity=2*n.jump_height*4*4/(e*e)n.fall_gravity=2*n.jump_height*4*4/(o*o)n.vx=32n.vy=d*8n.bounce_charge=0sfx(nc)
end function n8(n,e)n.vx=n.move_dir*e if n.xpos<i+8do n.move_dir=abs(n.move_dir)n.xpos=i+8elseif n.xpos>i+110do n.move_dir=-abs(n.move_dir)n.xpos=i+110end end function ns(n)return n.xpos+8<i-16or n.ypos>a+200end function n6(n)for e,n in pairs(n)do spr(n.sprite,n.xpos,n.ypos)end end function T(n,e)local n,e=A(n),A(e)return n.left<e.right and n.right>e.left and n.top<e.bottom and n.bottom>e.top end function n_(n,e)local o,d=A(n),A(e)return o.bottom>d.top and n.ypos<e.ypos and n.vy>0end function A(n)local e,o,d,n=n.xpos+n.boundsOffsetX,n.ypos+n.boundsOffsetY,n.width/2,n.height/2return{left=e-d,right=e+d,top=o-n,bottom=o+n}end function en(n)w={}I(n,w,{type="zombie",width=1,height=1,sprite=108,sprite2=0})end function ew(n,e)end function n3(e)for o,n in ipairs(w)do if n.enabled and n.ai_enabled do if(ns(n))S(n)break
n.vx=n.move_dir*5local e=nu(n,e)local e=nh(e.xpos,e.ypos,n.xpos,n.ypos,false)n.onGround=e.onGround if(n.onGround)n.vx=0n.vy=0if(e.hit_wall)n2(n)
n.xpos=e.x n.ypos=e.y end end end function ee()u={}I(1,u,{type="ufo",width=8,height=8,sprite=109,sprite2=110})end function nV()u={}O=max(s,3)I(1,u,{type="king",width=16,height=16,sprite=12,sprite2=122})u[1].boundsOffsetX=8u[1].boundsOffsetY=8end function nW()u={}I(1,u,{type="vulture",width=16,height=16,sprite=14,sprite2=126})u[1].boundsOffsetX=8u[1].boundsOffsetY=8u[1].tracker_beam.width=8u[1].tracker_beam.height=8u[1].tracker_beam.boundsOffsetX=4u[1].tracker_beam.boundsOffsetY=6end function _(n,e)local o=q(u,1,n,e)n4(o,n,e)return o end function n5(e)local n=u[1]if n.enabled and n.ai_enabled do if n.state==1do n8(n,50)if(n.type=="king")if n.timer_1==0do q(w,-1,n.xpos,n.ypos)n.timer_1=5elseif O<=0do n.state=4end else if(n.timer_1==0and n.xpos>i+70)n.vx=0n.state=2
n.timer_1=P(n.timer_1,e)elseif n.state==2do if n.type=="ufo"do local e=nY(n.xpos)if(e)if(n.ypos<(e.y-4)*8)n.vy=30else n.vy=0n.state=3n.timer_1=5sfx(3,1)else n.state=1
elseif n.type=="vulture"do n8(n,65)if(n.ypos<56)n.vy=10n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos else n.vy=-10n.state=4n9(n)
end elseif n.state==3do n.timer_1=P(n.timer_1,e)n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos if(n.timer_1==0)n9(n)n.state=4
elseif n.state==4do n.ypos-=65*e if(n.ypos+8<=a-32)if(n.type=="vulture"and n.disabledCount<0)n.disabledCount=n.disabledCount+1n4(n,i+8,8)else S(n)
end if(n.type=="vulture")for o,e in pairs(n.capture_tracker)do e.player.xpos=n.xpos+4e.player.ypos=n.ypos+4end
if(n.type=="ufo")eo(e)
n.xpos+=n.vx*e n.ypos+=n.vy*e end end function n4(n,e,o)n.xpos=e n.ypos=o n.vx=0n.vy=0n.state=1n.timer_1=5+flr(rnd(5))n.capture_tracker={}end function n9(n)for e,n in pairs(n.capture_tracker)do n.player.xpos=-8n.player.ypos=-8end end function ed(n)local e=u[1]if(not e.capture_tracker[n.id])e.capture_tracker[n.id]={player=n,t=0}S(n)E(D+1)
end function eo(o)local e=u[1]for d,n in pairs(e.capture_tracker)do n.player.xpos=n.player.xpos+(e.xpos-n.player.xpos)*min(n.t,.2)n.player.ypos=n.player.ypos+(e.ypos+8-n.player.ypos)*min(n.t,.2)n.t+=.1*o if(n.t>=.2)n.player.xpos=-8n.player.ypos=-8
end end function el()local n=u[1]if n and n.enabled do if(n.type~="ufo")spr(n.sprite,n.xpos,n.ypos,2,2)else spr(n.sprite,n.xpos,n.ypos,1,1)
if n.state==3or n.state==4or n.type=="vulture"and n.state==2do if(n.type=="vulture")spr(n.sprite2,n.xpos,n.ypos+4)else spr(n.sprite2,n.xpos,n.ypos+6)
if(y)local n=A(n.tracker_beam)rect(n.left,n.top,n.right,n.bottom,8)
end if(n.type=="king")et(O)
if(y)local n=A(n)rect(n.left,n.top,n.right,n.bottom,8)
end end function et(n)local e,n=ceil(n*10/128),n for o=1,e do local d,t,l=i+4,a+4+10*(o-1),12if(o==e)l=n
for e=1,l do spr(8,d,t)n-=1d+=10end end end local n,e=v.new(),{}nn=nil function n7()n,e=v.new(),{}nn=nil end function ef(e)n:enqueue_unique({bird={xpos=-8,ypos=-8,width=8,height=16,boundsOffsetX=0,boundsOffsetY=4,sprite=1},playerKey=e})end function ei()local n=n:dequeue()local o,d,l,t=r[n.playerKey],n.bird,i+128,a+20+flr(rnd(10))d.xpos=l d.ypos=t o.xpos=l o.ypos=t+8add(e,n)end function e1()if(nn()and not n:isempty())ei()
local o=nil for e,n in ipairs(e)do local e=n.bird.xpos-.8n.bird.xpos=e local d=r[n.playerKey]d.xpos=e if(e<i-8)o=n
end if(not(o==nil))n:enqueue_unique(o)del(e,o)
end function ea()for e,n in ipairs(e)do spr(n.bird.sprite,n.bird.xpos,n.bird.ypos)end end poke(24365,1)local t,l,n,o,d,f=0,10,0,0,0,1function ec()local n=nil for o,e in pairs(r)do if(e.enabled)if(n==nil or e.xpos>n.xpos)n=e
end return n end function e0()r={}C={}s,t=0,0n7()E(0)n,o,d,f=0,16,0,1I(32,r,{type="player",width=8,height=8,sprite=0,sprite2=0})end function ng(n,e)add(G,{n.xpos,n.ypos,3,n.sprite,e})ef(n.id)S(n)E(D+1)end function ex(n)q(r,n.key,n.xpos,n.ypos)E(D-1)end function nm(l,t,e)local d=nil if(k==0or k==2)local n={32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63}d=n[s+1]else d=nH[e]
if(d==nil)return nil
s=s+1local n=nil if k==2do for e=6,32do if(r[e]~=nil and r[e].enabled==false)n,r[e]=r[e],nil break
end else n,r[s]=r[s],nil end if(n==nil)return nil
n.id=e n.sprite=d n.xpos=l n.ypos=t r[e]=n q(r,e,l,o)add(C,e)return n end function er(t,f,i,e)local function l(e)B=5.9local e=nm(n+t,o+f,e)if(e==nil)return nil
e.startPosition=o n=n+9if(n>=100)d=d>=8and 0or d+2n=d o=o+9
return e end if k~=2do if e and stat(30)do local n=stat(31)if not(n==" ")and not(n=="\r")and not(n=="p")and s<32do if(not r[n])if(l(n)==nil)return
r[n].ypos=r[n].startPosition-2end if(n==" "and s>0)return true
end else if(e)for n=0,5do local e=r[n]~=nil and r[n].enabled==true if btnp(n,0)and not e and s<6do l(n)elseif e do r[n].ypos=r[n].startPosition-2end end
end for e,n in pairs(r)do if(n.ypos<n.startPosition)n.ypos=min(n.startPosition,n.ypos+20*i)
end return false end function nk(t,n,o)for d,n in pairs(r)do if n.enabled and not n.inputDisabled do if(not(n.vx==0))l=0else l=0
local d=nu(n,o)local d=nh(d.xpos,d.ypos,n.xpos,n.ypos,true)n.onGround=d.onGround if(n.onGround)n.vx=0n.vy=0n.bounce_charge=min(n.bounce_charge+o,4)local e=n.bounce_charge/4n.jump_height=Q(1.5,12,e)n.jump_distance=Q(1.5,8,e)
n.xpos=min(d.x,t+128-n.width)n.ypos=d.y if(ns(n))ng(n,n.xpos+8<i)n.xpos=-8n.ypos=-8break
for d,o in ipairs(e)do if(T(n,o.bird))q(r,o.playerKey,n.xpos,n.ypos)E(D-1)del(e,o)n.reviveCount=n.reviveCount+1break
end for o,e in ipairs(w)do if(T(n,e))ng(n)n.xpos=-8n.ypos=-8sfx(nq)break
end for d,e in ipairs(u)do if T(n,e)do if n_(n,e)do sfx(nc)if(e.type=="king")O-=1
n.ypos=e.ypos-8n.vy=-100end end if((e.state==3or e.type=="vulture"and e.state==2)and T(n,e.tracker_beam))ed(n,o)
end end end end function nb(e)local n=r[e]if not(n==nil)and not n.inputDisabled and n.enabled do n2(n)elseif n==nil and j==L.freeplay and s<32do nm(i+64,a,e)np()end end function np()local n=Q(10,1,s/32)nn=nE(n)end local e,o={main=1,settings=2,credits=3},nil local d,n,l={[e.main]={[1]={text="start",color=6,action=function()U(e.settings)end},[2]={text="credits",color=6,action=function()U(e.credits)end}},[e.settings]={[1]={text="play",color=6,action=function()o()end},[2]={text="gamemode",color=6,action=function()ny()end},[3]={text="input mode",color=6,action=function()eh()end},[4]={text="back",color=6,action=function()U(e.main)end}},[e.credits]={[1]={text="back",color=6,action=function()U(e.main)end}}},e.main,1function eu(d)n=e.main V(1)o=d end function e2(e)if(btnp(5))d[n][l].action()
if btnp(2)do local e=l-1if(e<1)e=#d[n]
V(e)end if btnp(3)do local e=l+1if(e>#d[n])e=1
V(e)end if z>0do?ne().title,i+32
z=max(0,z-e)end end function e8()local o=60if n==e.main do?"⁶w⁶thop32",46,16,7
elseif n==e.settings do?"⁶w⁶thop32",46,16,7
if l==2do J=ne()?J.title,60,o+10,6
?J.description,60,o+20,6
elseif l==3do J=es()?J.title,60,o+20,6
?J.description,60,o+30,6
end elseif n==e.credits do?"⁶w⁶tcredits",46,16,6
?"cole pergerson",16,o+10,6
?"james morgan",16,o+20,6
?"shahbaz mansahia",16,o+30,6
?"frank dominguez",16,o+40,6
end for e=1,#d[n]do?d[n][e].text,16,o,d[n][e].color
o+=10end?"menu controls: ⬆️⬇️ and ❎",12,120,6
end function V(e,o)local o=o or n d[o][l].color=6d[n][e].color,l=7,e end function U(e)local o=n n=e V(1,o)end function ny()j=(j+1)%2if(j==c.playerSelect or j==c.game)z=3
end function eh()k=(k+1)%3end function ne()if j==L.tournament do return{title="tournament",description="players cannot \njoin once the game \nhas started."}elseif j==L.freeplay do return{title="freeplay",description="players are free \nto join after the game \nhas started."}end end function es()if k==0do return{title="any key",description="characters can be \nassigned to \nany key."}elseif k==1do return{title="strict",description="characters are \nassigned to \nspecific keys."}elseif k==2do return{title="gamepad",description="each button is\nassigned to a\nunique player."}end end function e6()if F>0do if h==c.complete do?"⁶w⁶tyou win!",i+30,a+60,10
else?"⁶w⁶tnext time...",i+20,a+60,10
end else rectfill(i,a,i+128,a+128,12)e3(i,a)end end function e3(n,e)local o="time: "..n0(nf)?o,n+flr((128-#o*4)/2),e+2,10
?"most revives",n+40,e+9,7
local o={n+16,n+56,n+96}for n=1,3do if(m[n]and m[n][2]>0)local o=o[n]spr(m[n][1],o,e+15)local n=tostr(m[n][2])local o=o+4-#n*2?n,o,e+24,10
end?"leaderboard",n+42,e+30,7
local o={n+16,n+56,n+96}for n=1,3do if g[n]do local o=o[n]spr(g[n][1],o,e+36)?tostr(n)..".",o,e+45,7
?n0(g[n][3]),o,e+52,10
end end if#g>3do for o=4,#g do local d=o-4local l,d=d%13,flr(d/13)local l,n=n+6+l*9,e+68+d*8if(n<e+110)spr(g[o][1],l,n)
end end local o="continue in "..flr(N)local d=#o*4?o,n+flr((128-d)/2),e+120,10
end function ej()local n={}for o,e in ipairs(C)do local e=r[e]if(e and e.enabled==false)add(n,{e.sprite,e.disabledCount,e.totalTimeEnabled})
end local e=#n for o=1,e-1do for e=1,e-o do local o,d=n[e],n[e+1]if(o[2]>d[2]or o[2]==d[2]and o[3]<d[3])n[e],n[e+1]=n[e+1],n[e]
end end for e=1,#n do add(g,n[e])end end function e4()nf=time()-nt for e,n in pairs(r)do if(n.enabled==true)n.totalTimeEnabled=n.totalTimeEnabled+(time()-n.last_enabled_time)
end g={}for e,n in ipairs(C)do local n=r[n]if(n)add(g,{n.sprite,n.disabledCount,n.totalTimeEnabled,n.reviveCount})
end local n=#g for e=1,n-1do for n=1,n-e do if(g[n][3]<g[n+1][3])g[n],g[n+1]=g[n+1],g[n]
end end m={}for e,n in ipairs(C)do local n=r[n]if(n)add(m,{n.sprite,n.reviveCount})
end local n=#m for e=1,n-1do for n=1,n-e do if(m[n][2]<m[n+1][2])m[n],m[n+1]=m[n+1],m[n]
end end end poke(24365,1)local e,o,d,l,t,n,f=0,0,0,0,0function e5(e)local o,d,n=ec(),i+nF*e if(o~=nil)n=o.xpos-(128-nj*8)else n=d
n=max(n,d)i=i+(n-i)*min(nz*e,1)end function _init()n,f,e=0,0,0if(h==c.complete or h==c.gameover)h=c.playerSelect else h=c.mainMenu
K(h)end function nv()cls()_init()end function K(n)h=n if h==c.mainMenu do i=0a=0eu(function()K(c.playerSelect)end)music(0,1000,1)elseif h==c.playerSelect do x=0na=0d=(x+1)*128i=x*16*8a=na*16*8W=false ee()en(5)n7()nK()nT(x)ez=X*8-128+80e0()g={}G,o={},.4menuitem(2,"set gamemode",ny)N=15nD={[1]=r,[2]=w}music(-1,1000,1)music(4,1000,2)elseif h==c.game do music(-1,1000,2)music(6,1000,3)np()nt=time()elseif h==c.complete or h==c.gameover do F=3music(0,2000)e4()end end function _update()local l=time()n,f=l-f,l if h==c.mainMenu do e2(n)elseif h==c.playerSelect do local e=er(i,a,n,o==0)if(o>0)stat(31)
o=max(0,o-n)if(s>0)B=max(0,B-n)if(B==0)e=true
if(e)K(c.game)
elseif h==c.game do if y do e9()if(no)eF()
else if(e<1.5)e+=n else e5(n)
if(n1~=ni.CLOUD_KINGDOM)n1=ni.CLOUD_KINGDOM else if(W and not u[1].enabled)K(c.complete)
if(D==s)K(c.gameover)e=0
n5(n)nk(i,a,n)n3(n)e1()for e in all(G)do e[3]-=n if(e[3]<=0)del(G,e)
end if(M<1)M=(i-(d-128))/128a=Q(nd,nl,min(M,1))
end if(i>=d)x+=1d+=128nU(x)
if k~=2do while stat(30)do nw=stat(31)if(nw=="れ")e7()
nb(nw)end else for n=0,5do if(btnp(n,0))nb(n)
end end elseif h==c.gameover do n5(n)nk(i,a,n)n3(n)nx()F=P(F,n)elseif h==c.complete do nx()F=P(F,n)end end function _draw()cls()camera(i,a)map(0,0,0,a,128,16)map(0,0,1024,a,128,16)map(0,0,2048,a,128,16)map(0,0,3072,a,128,16)nX()el()ea()n6(w)n6(r)local d=a+112for n in all(G)do local o,e=mid(n[1],i,i+112),mid(n[2],a,a+112)if(n[5])e,d=d,d-16
spr(n[4],o,e)spr(nA,o,e-8)if(n[5])spr(nC,o-8,e)else spr(nB,o,e+8)
end if h==c.mainMenu do e8()elseif h==c.playerSelect do rectfill(i,0,i+128,a+5,a)?"press any button to join",i+4,a,7
if(s>0)?"starting in "..flr(B),i+4,a+8,7
?"⁶w⁶thop"..s,i+46,a+56,7
elseif h==c.game do elseif h==c.complete or h==c.gameover do e6()end if h==c.game or h==c.playerSelect do if z>0do rectfill(i,0,i+128,a+5,a)?"set gamemode to "..ne().title,i+16,a,7
z=max(0,z-n)end end if y do nS()rect(i,a,i+127,a+127,7)?i/8 ..","..a/8,i+4,a+4
?i/8+16 ..","..a/8+16,i+128+4,a+128+4
l=stat(32)+i t=stat(33)+a rect(l,t,l+2,t+2)end end function nx()if(e<2)e+=n else N-=n if N<=0do nv()elseif stat(30)and stat(31)==" "do nv()end
end function e7()y=not y if(y)menuitem(2,"toggle fast travel",eD)menuitem(3,"toggle pcannon",eq)else menuitem(2)menuitem(3)
end function e9()if(btn(0))i-=10
if(btn(1))if(no)i+=10else i=min(i+10,d-1)
if(btn(2))a-=10
if(btn(3))a+=10
if(stat(34)==1)printh(flr(l/8)..", "..flr(t/8))
end