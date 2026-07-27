v=false nn=false n=false e2=0e8=0k=0h={mainMenu=0,playerSelect=1,game=2,gameover=3,complete=4,biomeTest=5}s=h.mainMenu A={tournament=0,freeplay=1}w=A.freeplay a=0c=0ne=0no=0I=1es=0nj=7nz=1.5e6=8nF=250function e3(n)ne=c no=n I=0end nD=5.9x=0T=15z=3i={}g={}nd=0nl=0m=0F=0C={}e5=1function B(n)if(n>m)n=m
F=n end u={}j={}r={}e4={}nt={GREEN_LANDS=0,CLOUD_KINGDOM=10}nf=-1J=0e9=0n1=false K=4b={NONE=0,GRASS=96,GROUND=97,SAND_1=98,SAND_2=99,MOUNTAIN_1=100,MOUNTAIN_2=101,SNOW_1=102,ORELAND_1=104,ORELAND_2=105,ORELAND_3=106,GLITCH=107,CLOUD_1=108}o=16f={GRASS=o,DESERT=o*2,MOUNTAIN=o*3,SNOW=o*4,CITY=o*5,VOID=o*5+o*2+100,KINGDOM=o*5+o*2+o+32}ni=23nq=24L={}nA=128nB=129nC=130function e(n,e)for o,n in ipairs(n)do if(n==e)return true
end return false end p={}p.__index=p function p.new()local n=setmetatable({items={},head=1,tail=1},p)return n end function p:enqueue_unique(n)if(not e(self.items,n))self.items[self.tail]=n self.tail=self.tail+1
end function p:dequeue()if(self:isempty())return nil
local n=self.items[self.head]self.items[self.head]=nil self.head=self.head+1return n end function p:isempty()return self.head==self.tail end function nE(o)local n=t()return function()local e=t()if(e-n>=o)n=e return true
return false end end function M(n,e)return max(n-e,0)end function N(n,e,o)return n+(e-n)*o end function nG(n)local o,e=flr(n/60),flr(n%60)local n=tostr(e)if(e<10)n="0"..n
return o..":"..n end function O(n,t,d)local l=0for e=1,#n do local o=e+1if(o>#n)o=1
if(d<n[e].y~=(d<n[o].y)and t<n[e].x+(d-n[e].y)/(n[o].y-n[e].y)*(n[o].x-n[e].x))l+=1
end return not(l%2==0)end function nH(n,e,o,d)local l,t,f,i=n+rnd(o),n+rnd(o),e+rnd(d),e+rnd(d)return{{x=l,y=e},{x=n+o,y=i},{x=t,y=e+d},{x=n,y=f}}end function nI(n)line()for e=1,#n do line(n[e].x,n[e].y,11)end line(n[1].x,n[1].y,11)end function e7(n,e,o)line()line(n.x,n.y,n.x+e.x*100,n.y+e.y*100,o)end nJ={["a"]=1,["b"]=2,["c"]=3,["d"]=4,["e"]=5,["f"]=6,["g"]=7,["h"]=8,["i"]=9,["j"]=10,["k"]=11,["l"]=26,["m"]=25,["n"]=28,["o"]=29,["q"]=12,["r"]=13,["s"]=14,["t"]=15,["u"]=16,["v"]=17,["w"]=18,["x"]=19,["y"]=20,["z"]=21,["1"]=22,["2"]=23,["3"]=27,["4"]=24,["5"]=30,["6"]=31,["7"]=32}poke(24365,1)em={}d=16l=0E=32local t,e=128,0U={}nK=11function nL()l=f.VOID e=flr(rnd(128))end function na(n)local e={x=n,y=0,tiles={},surface_tiles={}}for n=n,n+d-1do e.tiles[n]={}for o=0,E-1do if n<f.GRASS do e.tiles[n][o]={x=n,y=o,sprite=b.GROUND}elseif n<f.DESERT do e.tiles[n][o]={x=n,y=o,sprite=b.SAND_1}elseif n<f.MOUNTAIN do e.tiles[n][o]={x=n,y=o,sprite=b.MOUNTAIN_2}elseif n<f.SNOW do e.tiles[n][o]={x=n,y=o,sprite=b.SNOW_1}elseif n<f.CITY do e.tiles[n][o]={x=n,y=o,sprite=b.ORELAND_1}elseif n<f.VOID do e.tiles[n][o]={x=n,y=o,sprite=b.GLITCH}else e.tiles[n][o]={x=n,y=o,sprite=b.GROUND}end end end for n=n,n+d-1do for o=0,E-1do local d=nM(n)+0if(o-nK<d)e.tiles[n][o].sprite=b.NONE
end end if n==J*16and s==h.playerSelect do else if(n>0and n<l-o and rnd(1)>=.5)local o=flr(rnd(d-2-1))local n=n+o+1for n=n,n+2,1do for o=0,E-1,1do e.tiles[n][o].sprite=b.NONE end end
end for n=n,n+d-1do for o=1,E-1do local d,o=e.tiles[n][o-1],e.tiles[n][o]if(d.sprite==b.NONE and o.sprite~=b.NONE)add(e.surface_tiles,o)if n<f.GRASS do o.sprite=b.GRASS elseif n<f.DESERT do elseif n<f.MOUNTAIN do o.sprite=b.MOUNTAIN_1 elseif n<f.SNOW do end
end end return e end function nc(e,o)local n={x=e,y=o,tiles={},surface_tiles={}}for e=e,e+15do n.tiles[e]={}for o=o,o+15do n.tiles[e][o]={x=e,y=o,sprite=b.NONE}end end local l,t,d=0,0,true for f=e,e+15do if(l==4)d,l=not d,0
l+=1t=flr(rnd(4))-2for e=o,o+15do if d and e==10+t do n.tiles[f][e].sprite=b.ORELAND_3 elseif d and e>9+t do n.tiles[f][e].sprite=b.ORELAND_1 end if(e>14)n.tiles[f][e].sprite=b.ORELAND_2
end end for e=e,e+15do for o=o+1,o+15do local d,e=n.tiles[e][o-1],n.tiles[e][o]if(d.sprite==b.NONE and e.sprite~=b.NONE)add(n.surface_tiles,e)
end end return n end function n0(n,e,l)local o={x=n,y=e,tiles={},surface_tiles={}}for n=n,n+15do o.tiles[n]={}for e=e,e+15do o.tiles[n][e]={x=n,y=e,sprite=b.NONE}end end local d,l=0,l for t=1,3do local f=d d=d+4+flr(rnd(2))local d,i,a=flr(rnd(8))+7,flr(rnd(2)),flr(rnd(2))nN(l,n+f+i,e+d+a,n,e,o.tiles)if(t&2==0)l=max(3,l-1)
end nr(o,n,e,b.GLITCH)return o end function nh(n,e)local o={x=n,y=e,tiles={},surface_tiles={}}for n=n,n+15do o.tiles[n]={}for e=e,e+15do o.tiles[n][e]={x=n,y=e,sprite=b.CLOUD_1}end end for n=n,n+15do for e=e,e+15do if(e<sin((n-1)/8)+13and e>sin((n-5)/8)+2)o.tiles[n][e].sprite=b.NONE
end end nr(o,n,e,-1)return o end function nN(o,n,e,t,l,d)n,e=min(n,t+14-o),min(e,l+14-o+1)local l=nH(n*8,e*8,o*8,o*8)add(U,l)local f=0for t=0,o-1,1do for o=0,o-1,1do local n,e,o=n+t,e+o,0if(O(l,n*8,e*8))o+=1
if(O(l,(n+1)*8,e*8))o+=1
if(O(l,(n+1)*8,(e+1)*8))o+=1
if(O(l,n*8,(e+1)*8))o+=1
if(o>=2)d[n][e].sprite=b.GLITCH f+=1
end end if f==0do d[n][e].sprite=b.GLITCH if(n+1==t+15+o-1)d[n-1][e].sprite=b.GLITCH else d[n+1][e].sprite=b.GLITCH
d[n][e+1].sprite=b.GLITCH end end function nM(n)if n<=f.GRASS do return sin((n-1+e)/16)elseif n<=f.DESERT do return sin((n-1+e)/8)elseif n<=f.MOUNTAIN do return sin((n-1+e)/16)+4*sin((n-1+e)/16*1.5)elseif n<=f.SNOW do return sin((n-1+e)/16)else return sin((n-1+e)/16)end end function nr(n,e,o,d)for e=e,e+15do for o=o+1,o+15do local l,e=n.tiles[e][o-1],n.tiles[e][o]if l.sprite==b.NONE and e.sprite~=b.NONE do if(d>0)e.sprite=d
add(n.surface_tiles,e)end end end end function nO(n)return n[flr(rnd(#n))+1]end function eg(n)local n=flr(n/8)for e=1,15do local o,n=y(n,e-1),y(n,e)if(o.tile==b.NONE and n.tile~=b.NONE)return n
end end local o={}function V(n)if(o[n])return o[n]
local e if n>=f.VOID do e=nh(n,0)elseif n>=f.CITY do e=n0(n,0,8)elseif n>=f.SNOW do e=nc(n,0)else e=na(n)end o[n]=e return e end function nP(n)for e=n.x,n.x+15do for o=0,15do local n=n.tiles[e][o]if(n.sprite>0)spr(n.sprite,n.x*8,n.y*8)
end end end function nQ()for e,n in ipairs(U)do nI(n)end end local e,n,d,l={},0,0,8function ek(o)e,l={},8U={}n,d=o*16,0W()W()end function nR(o)local n=W(n,0)add(e,n)t+=1local n=n for e in all(e)do if(e.x<n.x)n=e
end del(e,n)end function W()local o if n>=f.VOID do o=nh(n,d)if(n==f.VOID+16)nS()X(3008,40)n1=true
elseif n>=f.CITY do o=n0(n,d,l)l-=1elseif n>=f.SNOW do o=nc(n,d)if(n==f.SNOW+16)nT()X((f.SNOW+16)*8,8)
else o=na(n)if(o.x~=J*16or s~=h.playerSelect)local n=nO(o.surface_tiles)D(j,-1,n.x*8,(n.y-1)*8)
if(n==64)X(512,16)
end add(e,o)n+=16return o end function nU()for n in all(e)do for e=n.x,n.x+16-1do for o=n.y,n.y+16-1do local n=n.tiles[e][o]if n.sprite>0do spr(n.sprite,n.x*8,n.y*8)if(v)rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,9)
else if(v)rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,2)
end end end end end function y(n,o)local d,l=e[1],e[#e]if n<d.x or n>=l.x+16or o<d.y or o>=d.y+E do return{tile=-1}else local d={tile=-1}n,o=flr(n),flr(o)for e in all(e)do if(n>=e.x and n<e.x+16)d=e break
end if(d.tile==-1)printh("("..n..","..o..") tile not found")return d
return d.tiles[n][o]end end function nV(n)local o,n={tile=-1},flr(n/8)for e in all(e)do if(n>=e.x and n<e.x+16)o=e break
end local e=o.surface_tiles for o,e in ipairs(e)do if(e.x==n)return e
end end function nu(t,o,d,i,a)local e,n,d,l,c,f=t/8,o/8,d/8,i/8,false,false local r,h,u,l,s,m,g,k,d=y(e,l),y(e,l+.999),y(e+1,l),y(e+1,l+.999),y(d,n),y(d+.999,n),y(d,n+1),y(d+.999,n+1),0if r and h and(r.sprite~=b.NONE or h.sprite~=b.NONE)do if(not a)e=flr(e)+1
f=true elseif u and l and(u.sprite~=b.NONE or l.sprite~=b.NONE)do e=flr(e)d+=1f=true end if s and m and(s.sprite~=b.NONE or m.sprite~=b.NONE)do if(o>0or not a)n=flr(n)+1
d+=1elseif g and k and(g.sprite~=b.NONE or k.sprite~=b.NONE)do n,c=flr(n),true end if(d==2)if(o>i)n=n-1
t,o=e*8,n*8return{x=t,y=o,onGround=c,hit_wall=f}end local o=20function G(n,e,o)for n=1,n do e[n]=nW(o,n)end end function nW(n,e)local n={id=e,type=n.type,enabled=false,inputDisabled=false,xpos=-8,ypos=-8,startPosition=0,boundsOffsetX=0,boundsOffsetY=0,vx=0,vy=0,move_dir=-1,width=n.width,height=n.height,onGround=false,bounce_charge=0,jump_height=1.5,jump_distance=1.5,jump_gravity=0,fall_gravity=50,sprite=n.sprite,sprite2=n.sprite2,disabledCount=0,ai_enabled=false,state=1,totalTimeEnabled=0,reviveCount=0,kingHits=0,last_enabled_time=0,won=false,timer_1=0,capture_tracker={},tracker_beam={xpos=0,ypos=0,width=16,height=32,boundsOffsetX=4,boundsOffsetY=28}}return n end function D(o,e,d,l)local n if e==-1do for o,e in pairs(o)do if(not e.enabled)n=e break
end if(not n)printh"no more actors available"return
else n=o[e]if(not n)printh("can't find actor with id "..e)return
end n.enabled=true n.last_enabled_time=time()n.ai_enabled=true n.inputDisabled=false n.state=1n.search_timer=5+flr(rnd(5))n.ypos=l n.xpos=d n.bounce_charge=0n.jump_gravity=15return n end function P(n)n.enabled=false n.ai_enabled=false n.disabledCount+=1n.totalTimeEnabled+=time()-n.last_enabled_time n.vx=0n.vy=0end function n2(n,e)if(n.vy>=0)o=n.fall_gravity*8else o=n.jump_gravity*8
local d,l=n.xpos+n.vx*e+5*e*e,n.ypos+n.vy*e+.5*o*e*e n.vx+=10*e n.vy+=o*e n.vy=min(n.vy,200)return{xpos=d,ypos=l}end function n8(n)if(n.onGround and not n.won)local e,o=n.jump_distance*.6,n.jump_distance*.4local d=-2*n.jump_height*4/e n.jump_gravity=2*n.jump_height*4*4/(e*e)n.fall_gravity=2*n.jump_height*4*4/(o*o)n.vx=32n.vy=d*8n.bounce_charge=0sfx(ni)
end function ns(n,e)n.vx=n.move_dir*e if n.xpos<a+8do n.move_dir=abs(n.move_dir)n.xpos=a+8elseif n.xpos>a+110do n.move_dir=-abs(n.move_dir)n.xpos=a+110end end function n6(n)return n.xpos+8<a-16or n.ypos>c+200or n.ypos<c-64end function n3(n)for e,n in pairs(n)do spr(n.sprite,n.xpos,n.ypos)end end function Q(n,e)local n,e=q(n),q(e)return n.left<e.right and n.right>e.left and n.top<e.bottom and n.bottom>e.top end function nX(n,e)local o,d=q(n),q(e)return o.bottom>d.top and n.ypos<e.ypos and n.vy>0end function q(n)local e,o,d,n=n.xpos+n.boundsOffsetX,n.ypos+n.boundsOffsetY,n.width/2,n.height/2return{left=e-d,right=e+d,top=o-n,bottom=o+n}end function eb(n)j={}G(n,j,{type="zombie",width=1,height=1,sprite=135,sprite2=0})end function ey(n,e)end function n5(e)for o,n in ipairs(j)do if n.enabled and n.ai_enabled do if(n6(n))P(n)break
n.vx=n.move_dir*5local e=n2(n,e)local e=nu(e.xpos,e.ypos,n.xpos,n.ypos,false)n.onGround=e.onGround if(n.onGround)n.vx=0n.vy=0if(e.hit_wall)n8(n)
n.xpos=e.x n.ypos=e.y end end end function ev()u={}G(1,u,{type="ufo",width=8,height=8,sprite=133,sprite2=134})end function nS()u={}K=max(m,3)G(1,u,{type="king",width=16,height=16,sprite=34,sprite2=139})u[1].boundsOffsetX=8u[1].boundsOffsetY=8end function nT()u={}G(1,u,{type="vulture",width=16,height=16,sprite=36,sprite2=137})u[1].boundsOffsetX=8u[1].boundsOffsetY=8u[1].tracker_beam.width=8u[1].tracker_beam.height=8u[1].tracker_beam.boundsOffsetX=4u[1].tracker_beam.boundsOffsetY=6end function X(n,e)local o=D(u,1,n,e)n4(o,n,e)return o end function n9(e)local n=u[1]if n.enabled and n.ai_enabled do if n.state==1do ns(n,50)if(n.type=="king")if n.timer_1==0do D(j,-1,n.xpos,n.ypos)n.timer_1=5elseif K<=0do n.state=4end else if(n.timer_1==0and n.xpos>a+70)n.vx=0n.state=2
n.timer_1=M(n.timer_1,e)elseif n.state==2do if n.type=="ufo"do local e=nV(n.xpos)if(e)if(n.ypos<(e.y-4)*8)n.vy=30else n.vy=0n.state=3n.timer_1=5sfx(3,1)else n.state=1
elseif n.type=="vulture"do ns(n,65)if(n.ypos<56)n.vy=10n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos else n.vy=-10n.state=4n7(n)
end elseif n.state==3do n.timer_1=M(n.timer_1,e)n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos if(n.timer_1==0)n7(n)n.state=4
elseif n.state==4do n.ypos-=65*e if(n.ypos+8<=c-32)if(n.type=="vulture"and n.disabledCount<0)n.disabledCount=n.disabledCount+1n4(n,a+8,8)else P(n)
end if(n.type=="vulture")for o,e in pairs(n.capture_tracker)do e.player.xpos=n.xpos+4e.player.ypos=n.ypos+4end
if(n.type=="ufo")nY(e)
n.xpos+=n.vx*e n.ypos+=n.vy*e end end function n4(n,e,o)n.xpos=e n.ypos=o n.vx=0n.vy=0n.state=1n.timer_1=5+flr(rnd(5))n.capture_tracker={}end function n7(n)for e,n in pairs(n.capture_tracker)do n.player.xpos=-8n.player.ypos=-8nm(n.player.id)end end function nZ(n)local e=u[1]if(not e.capture_tracker[n.id])e.capture_tracker[n.id]={player=n,t=0}P(n)B(F+1)
end function nY(o)local e=u[1]for d,n in pairs(e.capture_tracker)do n.player.xpos=n.player.xpos+(e.xpos-n.player.xpos)*min(n.t,.2)n.player.ypos=n.player.ypos+(e.ypos+8-n.player.ypos)*min(n.t,.2)n.t+=.1*o if(n.t>=.2)n.player.xpos=-8n.player.ypos=-8
end end function n_()local n=u[1]if n and n.enabled do if(n.type~="ufo")spr(n.sprite,n.xpos,n.ypos,2,2)else spr(n.sprite,n.xpos,n.ypos,1,1)
if n.state==3or n.state==4or n.type=="vulture"and n.state==2do if(n.type=="vulture")spr(n.sprite2,n.xpos,n.ypos+4)else spr(n.sprite2,n.xpos,n.ypos+6)
if(v)local n=q(n.tracker_beam)rect(n.left,n.top,n.right,n.bottom,8)
end if(n.type=="king")en(K)
if(v)local n=q(n)rect(n.left,n.top,n.right,n.bottom,8)
end end function en(n)local e,n=ceil(n*10/128),n for o=1,e do local d,t,l=a+4,c+4+10*(o-1),12if(o==e)l=n
for e=1,l do spr(131,d,t)n-=1d+=10end end end local n,e=p.new(),{}Y=nil function ee()n,e=p.new(),{}Y=nil end function nm(e)n:enqueue_unique({bird={xpos=-8,ypos=-8,width=8,height=16,boundsOffsetX=0,boundsOffsetY=4,sprite=132},playerKey=e})end function eo()local n=n:dequeue()local o,d,l,t=r[n.playerKey],n.bird,a+128,c+20+flr(rnd(10))d.xpos=l d.ypos=t o.xpos=l o.ypos=t+8add(e,n)end function ed()if(Y()and not n:isempty())eo()
local o=nil for e,n in ipairs(e)do local e=n.bird.xpos-.8n.bird.xpos=e local d=r[n.playerKey]d.xpos=e if(e<a-8)o=n
end if(not(o==nil))n:enqueue_unique(o)del(e,o)
end function el()for e,n in ipairs(e)do spr(n.bird.sprite,n.bird.xpos,n.bird.ypos)end end poke(24365,1)local t,l,n,o,d,f=0,10,0,0,0,1function et()local n=nil for o,e in pairs(r)do if(e.enabled)if(n==nil or e.xpos>n.xpos)n=e
end return n end function ep()r={}C={}m,t=0,0ee()B(0)n,o,d,f=0,16,0,1G(32,r,{type="player",width=8,height=8,sprite=0,sprite2=0})end function ng(n,e)add(L,{n.xpos,n.ypos,3,n.sprite,e})nm(n.id)P(n)B(F+1)end function ew(n)D(r,n.key,n.xpos,n.ypos)B(F-1)end function nk(l,t,e)local d=nil if(k==0or k==2)local n={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32}d=n[m+1]else d=nJ[e]
if(d==nil)return nil
m=m+1local n=nil if k==2do for e=6,32do if(r[e]~=nil and r[e].enabled==false)n,r[e]=r[e],nil break
end else n,r[m]=r[m],nil end if(n==nil)return nil
n.id=e n.sprite=d n.xpos=l n.ypos=t r[e]=n D(r,e,l,o)add(C,e)return n end function ex(t,f,i,e)local function l(e)nD=5.9local e=nk(n+t,o+f,e)if(e==nil)return nil
e.startPosition=o n=n+9if(n>=100)d=d>=8and 0or d+2n=d o=o+9
return e end if k~=2do if e and stat(30)do local n=stat(31)if not(n==" ")and not(n=="\r")and not(n=="p")and m<32do if(not r[n])if(l(n)==nil)return
r[n].ypos=r[n].startPosition-2end if(n==" "and m>0)return true
end else if(e)for n=0,5do local e=r[n]~=nil and r[n].enabled==true if btnp(n,0)and not e and m<6do l(n)elseif e do r[n].ypos=r[n].startPosition-2end end
end for e,n in pairs(r)do if(n.ypos<n.startPosition)n.ypos=min(n.startPosition,n.ypos+20*i)
end return false end function nb(t,n,o)for d,n in pairs(r)do if n.enabled and not n.inputDisabled do if(not(n.vx==0))l=0else l=0
local d=n2(n,o)local d=nu(d.xpos,d.ypos,n.xpos,n.ypos,true)n.onGround=d.onGround if(n.onGround)n.vx=0n.vy=0n.bounce_charge=min(n.bounce_charge+o,4)local e=n.bounce_charge/4n.jump_height=N(1.5,12,e)n.jump_distance=N(1.5,8,e)
n.xpos=min(d.x,t+128-n.width)n.ypos=d.y if(n6(n))ng(n,n.xpos+8<a)n.xpos=-8n.ypos=-8break
for d,o in ipairs(e)do if(Q(n,o.bird))D(r,o.playerKey,n.xpos,n.ypos)B(F-1)del(e,o)n.reviveCount=n.reviveCount+1break
end for o,e in ipairs(j)do if(Q(n,e))ng(n)n.xpos=-8n.ypos=-8sfx(nq)break
end for d,e in ipairs(u)do if Q(n,e)do if nX(n,e)do sfx(ni)if(e.type=="king")K-=1n.kingHits+=1
n.ypos=e.ypos-8n.vx=50n.vy=-100end end if((e.state==3or e.type=="vulture"and e.state==2)and Q(n,e.tracker_beam))nZ(n,o)
end end end end function ny(e)local n=r[e]if not(n==nil)and not n.inputDisabled and n.enabled do n8(n)elseif n==nil and w==A.freeplay and m<32do nk(a+64,c,e)nv()end end function nv()local n=N(10,1,m/32)Y=nE(n)end local e,o={main=1,settings=2,credits=3},nil local d,n,l={[e.main]={[1]={text="start",color=6,action=function()R(e.settings)end},[2]={text="credits",color=6,action=function()R(e.credits)end}},[e.settings]={[1]={text="play",color=6,action=function()o()end},[2]={text="gamemode",color=6,action=function()ef()end},[3]={text="input mode",color=6,action=function()e1()end},[4]={text="back",color=6,action=function()R(e.main)end}},[e.credits]={[1]={text="back",color=6,action=function()R(e.main)end}}},e.main,1function ej(d)n=e.main S(1)o=d end function ez(e)if(btnp(5))d[n][l].action()
if btnp(2)do local e=l-1if(e<1)e=#d[n]
S(e)end if btnp(3)do local e=l+1if(e>#d[n])e=1
S(e)end if x>0do?Z().title,a+32
x=max(0,x-e)end end function eF()local o=60if n==e.main do elseif n==e.settings do if l==2do H=Z()?H.title,60,o+10,6
?H.description,60,o+20,6
elseif l==3do H=ei()?H.title,60,o+20,6
?H.description,60,o+30,6
end elseif n==e.credits do?"⁶w⁶tcredits",46,16,6
?"cole pergerson",16,o+10,6
?"james morgan",16,o+20,6
?"shahbaz mansahia",16,o+30,6
?"frank dominguez",16,o+40,6
end for e=1,#d[n]do?d[n][e].text,16,o,d[n][e].color
o+=10end?"menu controls: ⬆️⬇️ and ❎",12,120,6
end function S(e,o)local o=o or n d[o][l].color=6d[n][e].color,l=7,e end function R(e)local o=n n=e S(1,o)end function ef()w=(w+1)%2if(w==h.playerSelect or w==h.game)x=3
end function e1()k=(k+1)%3end function Z()if w==A.tournament do return{title="tournament",description="auto scrolling \ncamera. \nplayers cannot \njoin after the \ngame has started."}elseif w==A.freeplay do return{title="freeplay",description="camera follows \nplayers. \nplayers can \njoin after the \ngame has started."}end end function ei()if k==0do return{title="any key",description="characters can be \nassigned to \nany key."}elseif k==1do return{title="strict",description="characters are \nassigned to \nspecific keys."}elseif k==2do return{title="gamepad",description="each button is\nassigned to a\nunique player."}end end function ea()if z>0do if s==h.complete do?"⁶w⁶tyou win!",a+30,c+60,10
else?"⁶w⁶tnext time...",a+20,c+60,10
end else rectfill(a,c,a+128,c+128,12)ec(a,c)end end function ec(n,e)local o="time: "..nG(nl)?o,n+flr((128-#o*4)/2),e+2,10
?"most revives",n+40,e+9,7
local o={n+16,n+56,n+96}for n=1,3do if(g[n]and g[n][2]>0)local o=o[n]spr(g[n][1],o,e+15)local n=tostr(g[n][2])local o=o+4-#n*2?n,o,e+24,10
end?"leaderboard",n+42,e+30,7
local o={n+16,n+56,n+96}for n=1,3do if i[n]do local o=o[n]spr(i[n][1],o,e+36)?tostr(n)..".",o,e+45,7
?i[n][3],o,e+52,10
end end if#i>3do for o=4,#i do local d=o-4local l,d=d%13,flr(d/13)local l,n=n+6+l*9,e+68+d*8if(n<e+110)spr(i[o][1],l,n)
end end local o="continue in "..flr(T)local d=#o*4?o,n+flr((128-d)/2),e+120,10
end function eD()local n={}for o,e in ipairs(C)do local e=r[e]if(e and e.enabled==false)add(n,{e.sprite,e.disabledCount,e.totalTimeEnabled})
end local e=#n for o=1,e-1do for e=1,e-o do local o,d=n[e],n[e+1]if(o[2]>d[2]or o[2]==d[2]and o[3]<d[3])n[e],n[e+1]=n[e+1],n[e]
end end for e=1,#n do add(i,n[e])end end function e0()nl=time()-nd for e,n in pairs(r)do if(n.enabled==true)n.totalTimeEnabled=n.totalTimeEnabled+(time()-n.last_enabled_time)
end i={}for e,n in ipairs(C)do local n=r[n]if(n)local e=flr(n.totalTimeEnabled)*10+n.reviveCount*100+n.kingHits*50add(i,{n.sprite,n.disabledCount,e,n.reviveCount})
end local n=#i for e=1,n-1do for n=1,n-e do if(i[n][3]<i[n+1][3])i[n],i[n+1]=i[n+1],i[n]
end end g={}for e,n in ipairs(C)do local n=r[n]if(n)add(g,{n.sprite,n.reviveCount})
end local n=#g for e=1,n-1do for n=1,n-e do if(g[n][2]<g[n+1][2])g[n],g[n+1]=g[n+1],g[n]
end end end poke(24365,1)local o,d,l,t,e,f,n,i=0,0,0,0,0,nil function er(e)local o,d,n=et(),a+nF*e if(o~=nil)n=o.xpos-(128-nj*8)else n=d
if(w==A.tournament)n=max(n,d)else n=max(n,0)
a=a+(n-a)*min(nz*e,1)end function _init()n,i,o=0,0,0s=h.biomeTest _(s)end function np()cls()_init()end function _(n)s=n if s==h.game do music(-1,1000,2)music(6,1000,3)nv()nd=time()elseif s==h.complete or s==h.gameover do z=3music(0,2000)e0()elseif s==h.biomeTest do a=0c=0nL()e=0f=V(0)end end function _update()local l=time()n,i=l-i,l if s==h.game do if v do eh()if(nn)eq()
else if(o<1.5)o+=n else er(n)
if(nf~=nt.CLOUD_KINGDOM)nf=nt.CLOUD_KINGDOM else if(n1 and not u[1].enabled)_(h.complete)
if(F==m)_(h.gameover)o=0
n9(n)nb(a,c,n)n5(n)ed()for e in all(L)do e[3]-=n if(e[3]<=0)del(L,e)
end if(I<1)I=(a-(d-128))/128c=N(ne,no,min(I,1))
end if(a>=d)J+=1d+=128nR(J)
if k~=2do while stat(30)do nw=stat(31)if(nw=="れ")eu()
ny(nw)end else for n=0,5do if(btnp(n,0))ny(n)
end end elseif s==h.gameover do n9(n)nb(a,c,n)n5(n)nx()z=M(z,n)elseif s==h.complete do nx()z=M(z,n)elseif s==h.biomeTest do if btnp(0)do e=max(0,e-1)a=e*128f=V(e*16)elseif btnp(1)do e+=1a=e*128f=V(e*16)end end end function _draw()if(s==h.biomeTest)cls()camera(a,c)map(0,0,0,c,128,16)map(0,0,1024,c,128,16)map(0,0,2048,c,128,16)map(0,0,3072,c,128,16)nP(f)return
cls()camera(a,c)map(0,0,0,c,128,16)map(0,0,1024,c,128,16)map(0,0,2048,c,128,16)map(0,0,3072,c,128,16)nU()n_()el()n3(j)n3(r)local d=c+112for n in all(L)do local o,e=mid(n[1],a,a+112),mid(n[2],c,c+112)if(n[5])e,d=d,d-16
spr(n[4],o,e-8)spr(nA,o,e-16)if(n[5])spr(nC,o-8,e-8)else spr(nB,o,e)
end if(s==h.complete or s==h.gameover)ea()
if s==h.game do if x>0do rectfill(a,0,a+128,c+5,c)?"set gamemode to "..Z().title,a+16,c,7
x=max(0,x-n)end end if v do nQ()rect(a,c,a+127,c+127,7)?a/8 ..","..c/8,a+4,c+4
?a/8+16 ..","..c/8+16,a+128+4,c+128+4
l=stat(32)+a t=stat(33)+c rect(l,t,l+2,t+2)end end function nx()if(o<2)o+=n else T-=n if T<=0do np()elseif stat(30)and stat(31)==" "do np()end
end function eu()v=not v if(v)menuitem(2,"toggle fast travel",eA)menuitem(3,"toggle pcannon",eB)else menuitem(2)menuitem(3)
end function eh()if(btn(0))a-=10
if(btn(1))if(nn)a+=10else a=min(a+10,d-1)
if(btn(2))c-=10
if(btn(3))c+=10
if(stat(34)==1)printh(flr(l/8)..", "..flr(t/8))
end