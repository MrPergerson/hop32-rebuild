pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
y=false nl=false n=false o=0ek=0k=0c={mainMenu=0,playerSelect=1,game=2,gameover=3,complete=4}h=c.mainMenu E={tournament=0,freeplay=1}w=E.freeplay i=0a=0nt=0nf=0N=1eb=0nF=7nD=1.5ep=8nq=250function ey(n)nt=a nf=n N=0end G=5.9F=0O=15D=3q=0j=0m={}g={}n1=0ni=0s=0A=0P={}ev=1function H(n)if n>s do n=s end A=n end u={}x={}r={}nA={}na={GREEN_LANDS=0,CLOUD_KINGDOM=10}nc=-1z=0n0=0Y=false Q=4b={NONE=0,GRASS=96,GROUND=97,SAND_1=98,SAND_2=99,MOUNTAIN_1=100,MOUNTAIN_2=101,SNOW_1=102,ORELAND_1=104,ORELAND_2=105,ORELAND_3=106,GLITCH=107,CLOUD_1=108}f={GRASS=48,DESERT=96,MOUNTAIN=144,SNOW=192,CITY=240,VOID=336,KINGDOM=384}nr=23nB=24I={}nC=128nE=129nG=130function e(n,e)for o,n in ipairs(n)do if n==e do return true end end return false end v={}v.__index=v function v.new()local n=setmetatable({items={},head=1,tail=1},v)return n end function v:enqueue_unique(n)if not e(self.items,n)do self.items[self.tail]=n self.tail=self.tail+1end end function v:dequeue()if self:isempty()do return nil end local n=self.items[self.head]self.items[self.head]=nil self.head=self.head+1return n end function v:isempty()return self.head==self.tail end function nH(o)local n=t()return function()local e=t()if e-n>=o do n=e return true end return false end end function R(n,e)return max(n-e,0)end function S(n,e,o)return n+(e-n)*o end function nI(n)local o,e=flr(n/60),flr(n%60)local n=tostr(e)if e<10do n="0"..n end return o..":"..n end function T(n,t,d)local l=0for e=1,#n do local o=e+1if o>#n do o=1end if d<n[e].y~=(d<n[o].y)and t<n[e].x+(d-n[e].y)/(n[o].y-n[e].y)*(n[o].x-n[e].x)do l+=1end end return not(l%2==0)end function nJ(n,e,o,d)local l,t,f,i=n+rnd(o),n+rnd(o),e+rnd(d),e+rnd(d)return{{x=l,y=e},{x=n+o,y=i},{x=t,y=e+d},{x=n,y=f}}end function l(n)line()for e=1,#n do line(n[e].x,n[e].y,11)end line(n[1].x,n[1].y,11)end function ew(n,e,o)line()line(n.x,n.y,n.x+e.x*100,n.y+e.y*100,o)end nK={["a"]=1,["b"]=2,["c"]=3,["d"]=4,["e"]=5,["f"]=6,["g"]=7,["h"]=8,["i"]=9,["j"]=10,["k"]=11,["l"]=26,["m"]=25,["n"]=28,["o"]=29,["q"]=12,["r"]=13,["s"]=14,["t"]=15,["u"]=16,["v"]=17,["w"]=18,["x"]=19,["y"]=20,["z"]=21,["1"]=22,["2"]=23,["3"]=27,["4"]=24,["5"]=30,["6"]=31,["7"]=32}poke(24365,1)ex={}nL=48d=16Z=0J=32local o,e=128,0_={}nM=11function nN()Z=f.VOID e=flr(rnd(128))end function nO(n)local e={x=n,y=0,tiles={},surface_tiles={}}for n=n,n+d-1do e.tiles[n]={}for o=0,J-1do if n<f.GRASS do e.tiles[n][o]={x=n,y=o,sprite=b.GROUND}elseif n<f.DESERT do e.tiles[n][o]={x=n,y=o,sprite=b.SAND_1}elseif n<f.MOUNTAIN do e.tiles[n][o]={x=n,y=o,sprite=b.MOUNTAIN_2}elseif n<f.SNOW do e.tiles[n][o]={x=n,y=o,sprite=b.SNOW_1}elseif n<f.CITY do e.tiles[n][o]={x=n,y=o,sprite=b.ORELAND_1}elseif n<f.VOID do e.tiles[n][o]={x=n,y=o,sprite=b.GLITCH}else e.tiles[n][o]={x=n,y=o,sprite=b.GROUND}end end end for n=n,n+d-1do for o=0,J-1do local d=nP(n)+0if o-nM<d do e.tiles[n][o].sprite=b.NONE end end end if n==z*16and h==c.playerSelect do else if n>0and n<Z-nL and rnd(1)>=.5do local o=flr(rnd(d-2-1))local n=n+o+1for n=n,n+2,1do for o=0,J-1,1do e.tiles[n][o].sprite=b.NONE end end end end for n=n,n+d-1do for o=1,J-1do local d,o=e.tiles[n][o-1],e.tiles[n][o]if d.sprite==b.NONE and o.sprite~=b.NONE do add(e.surface_tiles,o)if n<f.GRASS do o.sprite=b.GRASS elseif n<f.DESERT do elseif n<f.MOUNTAIN do o.sprite=b.MOUNTAIN_1 elseif n<f.SNOW do end end end end return e end function nQ(e,o)local n={x=e,y=o,tiles={},surface_tiles={}}for e=e,e+15do n.tiles[e]={}for o=o,o+15do n.tiles[e][o]={x=e,y=o,sprite=b.NONE}end end local l,t,d=0,0,true for f=e,e+15do if l==4do d,l=not d,0end l+=1t=flr(rnd(4))-2for e=o,o+15do if d and e==10+t do n.tiles[f][e].sprite=b.ORELAND_3 elseif d and e>9+t do n.tiles[f][e].sprite=b.ORELAND_1 end if e>14do n.tiles[f][e].sprite=b.ORELAND_2 end end end for e=e,e+15do for o=o+1,o+15do local d,e=n.tiles[e][o-1],n.tiles[e][o]if d.sprite==b.NONE and e.sprite~=b.NONE do add(n.surface_tiles,e)end end end return n end function nR(n,e,l)local o={x=n,y=e,tiles={},surface_tiles={}}for n=n,n+15do o.tiles[n]={}for e=e,e+15do o.tiles[n][e]={x=n,y=e,sprite=b.NONE}end end local d,l=0,l for t=1,3do local f=d d=d+4+flr(rnd(2))local d,i,a=flr(rnd(8))+7,flr(rnd(2)),flr(rnd(2))nS(l,n+f+i,e+d+a,n,e,o.tiles)if t&2==0do l=max(3,l-1)end end nh(o,n,e,b.GLITCH)return o end function nT(n,e)local o={x=n,y=e,tiles={},surface_tiles={}}for n=n,n+15do o.tiles[n]={}for e=e,e+15do o.tiles[n][e]={x=n,y=e,sprite=b.CLOUD_1}end end for n=n,n+15do for e=e,e+15do if e<sin((n-1)/8)+13and e>sin((n-5)/8)+2do o.tiles[n][e].sprite=b.NONE end end end nh(o,n,e,-1)return o end function nS(o,n,e,t,l,d)n,e=min(n,t+14-o),min(e,l+14-o+1)local l=nJ(n*8,e*8,o*8,o*8)add(_,l)local f=0for t=0,o-1,1do for o=0,o-1,1do local n,e,o=n+t,e+o,0if T(l,n*8,e*8)do o+=1end if T(l,(n+1)*8,e*8)do o+=1end if T(l,(n+1)*8,(e+1)*8)do o+=1end if T(l,n*8,(e+1)*8)do o+=1end if o>=2do d[n][e].sprite=b.GLITCH f+=1end end end if f==0do d[n][e].sprite=b.GLITCH if n+1==t+15+o-1do d[n-1][e].sprite=b.GLITCH else d[n+1][e].sprite=b.GLITCH end d[n][e+1].sprite=b.GLITCH end end function nP(n)if n<=f.GRASS do return sin((n-1+e)/16)elseif n<=f.DESERT do return sin((n-1+e)/8)elseif n<=f.MOUNTAIN do return sin((n-1+e)/16)+4*sin((n-1+e)/16*1.5)elseif n<=f.SNOW do return sin((n-1+e)/16)else return sin((n-1+e)/16)end end function nh(n,e,o,d)for e=e,e+15do for o=o+1,o+15do local l,e=n.tiles[e][o-1],n.tiles[e][o]if l.sprite==b.NONE and e.sprite~=b.NONE do if d>0do e.sprite=d end add(n.surface_tiles,e)end end end end function nU(n)return n[flr(rnd(#n))+1]end function ej(n)local n=flr(n/8)for e=1,15do local o,n=p(n,e-1),p(n,e)if o.tile==b.NONE and n.tile~=b.NONE do return n end end end function nV()for e,n in ipairs(_)do l(n)end end local e,n,d,l={},0,0,8function nW(o)e,l={},8_={}n,d=o*16,0nn()nn()end function nX(d)local n=nn(n,0)add(e,n)o+=1local n=n for e in all(e)do if e.x<n.x do n=e end end del(e,n)end function nn()local o if n>=f.VOID do o=nT(n,d)if n==f.VOID+16do nY()ne(3008,40)Y=true end elseif n>=f.CITY do o=nR(n,d,l)l-=1elseif n>=f.SNOW do o=nQ(n,d)if n==f.SNOW+16do nZ()ne((f.SNOW+16)*8,8)end else o=nO(n)if o.x~=z*16or h~=c.playerSelect do local n=nU(o.surface_tiles)B(x,-1,n.x*8,(n.y-1)*8)end if n==64do ne(512,16)end end add(e,o)n+=16return o end function n_()for n in all(e)do for e=n.x,n.x+16-1do for o=n.y,n.y+16-1do local n=n.tiles[e][o]if n.sprite>0do spr(n.sprite,n.x*8,n.y*8)if y do rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,9)end else if y do rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,2)end end end end end end function p(n,o)local d,l=e[1],e[#e]if n<d.x or n>=l.x+16or o<d.y or o>=d.y+J do return{tile=-1}else local d={tile=-1}n,o=flr(n),flr(o)for e in all(e)do if n>=e.x and n<e.x+16do d=e break end end if d.tile==-1do printh("("..n..","..o..") tile not found")return d end return d.tiles[n][o]end end function en(n)local o,n={tile=-1},flr(n/8)for e in all(e)do if n>=e.x and n<e.x+16do o=e break end end local e=o.surface_tiles for o,e in ipairs(e)do if e.x==n do return e end end end function nu(t,o,d,i,a)local e,n,d,l,c,f=t/8,o/8,d/8,i/8,false,false local r,h,u,l,s,m,g,k,d=p(e,l),p(e,l+.999),p(e+1,l),p(e+1,l+.999),p(d,n),p(d+.999,n),p(d,n+1),p(d+.999,n+1),0if r and h and(r.sprite~=b.NONE or h.sprite~=b.NONE)do if not a do e=flr(e)+1end f=true elseif u and l and(u.sprite~=b.NONE or l.sprite~=b.NONE)do e=flr(e)d+=1f=true end if s and m and(s.sprite~=b.NONE or m.sprite~=b.NONE)do if o>0or not a do n=flr(n)+1end d+=1elseif g and k and(g.sprite~=b.NONE or k.sprite~=b.NONE)do n,c=flr(n),true end if d==2do if o>i do n=n-1end end t,o=e*8,n*8return{x=t,y=o,onGround=c,hit_wall=f}end local o=20function K(n,e,o)for n=1,n do e[n]=ee(o,n)end end function ee(n,e)local n={id=e,type=n.type,enabled=false,inputDisabled=false,xpos=-8,ypos=-8,startPosition=0,boundsOffsetX=0,boundsOffsetY=0,vx=0,vy=0,move_dir=-1,width=n.width,height=n.height,onGround=false,bounce_charge=0,jump_height=1.5,jump_distance=1.5,jump_gravity=0,fall_gravity=50,sprite=n.sprite,sprite2=n.sprite2,disabledCount=0,ai_enabled=false,state=1,totalTimeEnabled=0,reviveCount=0,kingHits=0,last_enabled_time=0,won=false,timer_1=0,capture_tracker={},tracker_beam={xpos=0,ypos=0,width=16,height=32,boundsOffsetX=4,boundsOffsetY=28}}return n end function B(o,e,d,l)local n if e==-1do for o,e in pairs(o)do if not e.enabled do n=e break end end if not n do printh"no more actors available"return end else n=o[e]if not n do printh("can't find actor with id "..e)return end end n.enabled=true n.last_enabled_time=time()n.ai_enabled=true n.inputDisabled=false n.state=1n.search_timer=5+flr(rnd(5))n.ypos=l n.xpos=d n.bounce_charge=0n.jump_gravity=15return n end function U(n)n.enabled=false n.ai_enabled=false n.disabledCount+=1n.totalTimeEnabled+=time()-n.last_enabled_time n.vx=0n.vy=0end function n2(n,e)if n.vy>=0do o=n.fall_gravity*8else o=n.jump_gravity*8end local d,l=n.xpos+n.vx*e+5*e*e,n.ypos+n.vy*e+.5*o*e*e n.vx+=10*e n.vy+=o*e n.vy=min(n.vy,200)return{xpos=d,ypos=l}end function n8(n)if n.onGround and not n.won do local e,o=n.jump_distance*.6,n.jump_distance*.4local d=-2*n.jump_height*4/e n.jump_gravity=2*n.jump_height*4*4/(e*e)n.fall_gravity=2*n.jump_height*4*4/(o*o)n.vx=32n.vy=d*8n.bounce_charge=0sfx(nr)end end function ns(n,e)n.vx=n.move_dir*e if n.xpos<i+8do n.move_dir=abs(n.move_dir)n.xpos=i+8elseif n.xpos>i+110do n.move_dir=-abs(n.move_dir)n.xpos=i+110end end function n6(n)return n.xpos+8<i-16or n.ypos>a+200or n.ypos<a-64end function n3(n)for e,n in pairs(n)do spr(n.sprite,n.xpos,n.ypos)end end function V(n,e)local n,e=C(n),C(e)return n.left<e.right and n.right>e.left and n.top<e.bottom and n.bottom>e.top end function eo(n,e)local o,d=C(n),C(e)return o.bottom>d.top and n.ypos<e.ypos and n.vy>0end function C(n)local e,o,d,n=n.xpos+n.boundsOffsetX,n.ypos+n.boundsOffsetY,n.width/2,n.height/2return{left=e-d,right=e+d,top=o-n,bottom=o+n}end function ed(n)x={}K(n,x,{type="zombie",width=1,height=1,sprite=135,sprite2=0})end function ez(n,e)end function n4(e)for o,n in ipairs(x)do if n.enabled and n.ai_enabled do if n6(n)do U(n)break end n.vx=n.move_dir*5local e=n2(n,e)local e=nu(e.xpos,e.ypos,n.xpos,n.ypos,false)n.onGround=e.onGround if n.onGround do n.vx=0n.vy=0if e.hit_wall do n8(n)end end n.xpos=e.x n.ypos=e.y end end end function el()u={}K(1,u,{type="ufo",width=8,height=8,sprite=133,sprite2=134})end function nY()u={}Q=max(s,3)K(1,u,{type="king",width=16,height=16,sprite=34,sprite2=139})u[1].boundsOffsetX=8u[1].boundsOffsetY=8end function nZ()u={}K(1,u,{type="vulture",width=16,height=16,sprite=36,sprite2=137})u[1].boundsOffsetX=8u[1].boundsOffsetY=8u[1].tracker_beam.width=8u[1].tracker_beam.height=8u[1].tracker_beam.boundsOffsetX=4u[1].tracker_beam.boundsOffsetY=6end function ne(n,e)local o=B(u,1,n,e)n5(o,n,e)return o end function n9(e)local n=u[1]if n.enabled and n.ai_enabled do if n.state==1do ns(n,50)if n.type=="king"do if n.timer_1==0do B(x,-1,n.xpos,n.ypos)n.timer_1=5elseif Q<=0do n.state=4end else if n.timer_1==0and n.xpos>i+70do n.vx=0n.state=2end end n.timer_1=R(n.timer_1,e)elseif n.state==2do if n.type=="ufo"do local e=en(n.xpos)if e do if n.ypos<(e.y-4)*8do n.vy=30else n.vy=0n.state=3n.timer_1=5sfx(3,1)end else n.state=1end elseif n.type=="vulture"do ns(n,65)if n.ypos<56do n.vy=10n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos else n.vy=-10n.state=4n7(n)end end elseif n.state==3do n.timer_1=R(n.timer_1,e)n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos if n.timer_1==0do n7(n)n.state=4end elseif n.state==4do n.ypos-=65*e if n.ypos+8<=a-32do if n.type=="vulture"and n.disabledCount<0do n.disabledCount=n.disabledCount+1n5(n,i+8,8)else U(n)end end end if n.type=="vulture"do for o,e in pairs(n.capture_tracker)do e.player.xpos=n.xpos+4e.player.ypos=n.ypos+4end end if n.type=="ufo"do et(e)end n.xpos+=n.vx*e n.ypos+=n.vy*e end end function n5(n,e,o)n.xpos=e n.ypos=o n.vx=0n.vy=0n.state=1n.timer_1=5+flr(rnd(5))n.capture_tracker={}end function n7(n)for e,n in pairs(n.capture_tracker)do n.player.xpos=-8n.player.ypos=-8nm(n.player.id)end end function ef(n)local e=u[1]if not e.capture_tracker[n.id]do e.capture_tracker[n.id]={player=n,t=0}U(n)H(A+1)end end function et(o)local e=u[1]for d,n in pairs(e.capture_tracker)do n.player.xpos=n.player.xpos+(e.xpos-n.player.xpos)*min(n.t,.2)n.player.ypos=n.player.ypos+(e.ypos+8-n.player.ypos)*min(n.t,.2)n.t+=.1*o if n.t>=.2do n.player.xpos=-8n.player.ypos=-8end end end function e1()local n=u[1]if n and n.enabled do if n.type~="ufo"do spr(n.sprite,n.xpos,n.ypos,2,2)else spr(n.sprite,n.xpos,n.ypos,1,1)end if n.state==3or n.state==4or n.type=="vulture"and n.state==2do if n.type=="vulture"do spr(n.sprite2,n.xpos,n.ypos+4)else spr(n.sprite2,n.xpos,n.ypos+6)end if y do local n=C(n.tracker_beam)rect(n.left,n.top,n.right,n.bottom,8)end end if n.type=="king"do ei(Q)end if y do local n=C(n)rect(n.left,n.top,n.right,n.bottom,8)end end end function ei(n)local e,n=ceil(n*10/128),n for o=1,e do local d,t,l=i+4,a+4+10*(o-1),12if o==e do l=n end for e=1,l do spr(131,d,t)n-=1d+=10end end end local n,e=v.new(),{}no=nil function ng()n,e=v.new(),{}no=nil end function nm(e)n:enqueue_unique({bird={xpos=-8,ypos=-8,width=8,height=16,boundsOffsetX=0,boundsOffsetY=4,sprite=132},playerKey=e})end function ea()local n=n:dequeue()local o,d,l,t=r[n.playerKey],n.bird,i+128,a+20+flr(rnd(10))d.xpos=l d.ypos=t o.xpos=l o.ypos=t+8add(e,n)end function ec()if no()and not n:isempty()do ea()end local o=nil for e,n in ipairs(e)do local e=n.bird.xpos-.8n.bird.xpos=e local d=r[n.playerKey]d.xpos=e if e<i-8do o=n end end if not(o==nil)do n:enqueue_unique(o)del(e,o)end end function e0()for e,n in ipairs(e)do spr(n.bird.sprite,n.bird.xpos,n.bird.ypos)end end poke(24365,1)local t,l,n,o,d,f=0,10,0,0,0,1function er()local n=nil for o,e in pairs(r)do if e.enabled do if n==nil or e.xpos>n.xpos do n=e end end end return n end function eh()r={}P={}s,t=0,0ng()H(0)n,o,d,f=0,16,0,1K(32,r,{type="player",width=8,height=8,sprite=0,sprite2=0})end function nk(n,e)add(I,{n.xpos,n.ypos,3,n.sprite,e})nm(n.id)U(n)H(A+1)end function eF(n)B(r,n.key,n.xpos,n.ypos)H(A-1)end function nb(l,t,e)local d=nil if k==0or k==2do local n={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32}d=n[s+1]else d=nK[e]end if d==nil do return nil end s=s+1local n=nil if k==2do for e=6,32do if r[e]~=nil and r[e].enabled==false do n,r[e]=r[e],nil break end end else n,r[s]=r[s],nil end if n==nil do return nil end n.id=e n.sprite=d n.xpos=l n.ypos=t r[e]=n B(r,e,l,o)add(P,e)return n end function eu(t,f,i,e)local function l(e)G=5.9local e=nb(n+t,o+f,e)if e==nil do return nil end e.startPosition=o n=n+9if n>=100do d=d>=8and 0or d+2n=d o=o+9end return e end if k~=2do if e and stat(30)do local n=stat(31)if not(n==" ")and not(n=="\r")and not(n=="p")and s<32do if not r[n]do if l(n)==nil do return end end r[n].ypos=r[n].startPosition-2end if n==" "and s>0do return true end end else if e do for n=0,5do local e=r[n]~=nil and r[n].enabled==true if btnp(n,0)and not e and s<6do l(n)elseif e do r[n].ypos=r[n].startPosition-2end end end end for e,n in pairs(r)do if n.ypos<n.startPosition do n.ypos=min(n.startPosition,n.ypos+20*i)end end return false end function np(t,n,o)for d,n in pairs(r)do if n.enabled and not n.inputDisabled do if not(n.vx==0)do l=0else l=0end local d=n2(n,o)local d=nu(d.xpos,d.ypos,n.xpos,n.ypos,true)n.onGround=d.onGround if n.onGround do n.vx=0n.vy=0n.bounce_charge=min(n.bounce_charge+o,4)local e=n.bounce_charge/4n.jump_height=S(1.5,12,e)n.jump_distance=S(1.5,8,e)end n.xpos=min(d.x,t+128-n.width)n.ypos=d.y if n6(n)do nk(n,n.xpos+8<i)n.xpos=-8n.ypos=-8break end for d,o in ipairs(e)do if V(n,o.bird)do B(r,o.playerKey,n.xpos,n.ypos)H(A-1)del(e,o)n.reviveCount=n.reviveCount+1break end end for o,e in ipairs(x)do if V(n,e)do nk(n)n.xpos=-8n.ypos=-8sfx(nB)break end end for d,e in ipairs(u)do if V(n,e)do if eo(n,e)do sfx(nr)if e.type=="king"do Q-=1n.kingHits+=1end n.ypos=e.ypos-8n.vx=50n.vy=-100end end if(e.state==3or e.type=="vulture"and e.state==2)and V(n,e.tracker_beam)do ef(n,o)end end end end end function ny(e)local n=r[e]if not(n==nil)and not n.inputDisabled and n.enabled do n8(n)elseif n==nil and w==E.freeplay and s<32do nb(i+64,a,e)nv()end end function nv()local n=S(10,1,s/32)no=nH(n)end local e,o={main=1,settings=2,credits=3},nil local d,n,l={[e.main]={[1]={text="start",color=6,action=function()W(e.settings)end},[2]={text="credits",color=6,action=function()W(e.credits)end}},[e.settings]={[1]={text="play",color=6,action=function()o()end},[2]={text="gamemode",color=6,action=function()nw()end},[3]={text="input mode",color=6,action=function()e2()end},[4]={text="back",color=6,action=function()W(e.main)end}},[e.credits]={[1]={text="back",color=6,action=function()W(e.main)end}}},e.main,1function e8(d)n=e.main X(1)o=d end function es(e)if btnp(5)do d[n][l].action()end if btnp(2)do local e=l-1if e<1do e=#d[n]end X(e)end if btnp(3)do local e=l+1if e>#d[n]do e=1end X(e)end if F>0do?nd().title,i+32
F=max(0,F-e)end end function e6()local o=60if n==e.main do?"⁶w⁶thop32",46,16,7
elseif n==e.settings do?"⁶w⁶thop32",46,16,7
if l==2do L=nd()?L.title,60,o+10,6
?L.description,60,o+20,6
elseif l==3do L=e3()?L.title,60,o+20,6
?L.description,60,o+30,6
end elseif n==e.credits do?"⁶w⁶tcredits",46,16,6
?"cole pergerson",16,o+10,6
?"james morgan",16,o+20,6
?"shahbaz mansahia",16,o+30,6
?"frank dominguez",16,o+40,6
end for e=1,#d[n]do?d[n][e].text,16,o,d[n][e].color
o+=10end?"menu controls: ⬆️⬇️ and ❎",12,120,6
end function X(e,o)local o=o or n d[o][l].color=6d[n][e].color,l=7,e end function W(e)local o=n n=e X(1,o)end function nw()w=(w+1)%2if w==c.playerSelect or w==c.game do F=3end end function e2()k=(k+1)%3end function nd()if w==E.tournament do return{title="tournament",description="auto scrolling \ncamera. \nplayers cannot \njoin after the \ngame has started."}elseif w==E.freeplay do return{title="freeplay",description="camera follows \nplayers. \nplayers can \njoin after the \ngame has started."}end end function e3()if k==0do return{title="any key",description="characters can be \nassigned to \nany key."}elseif k==1do return{title="strict",description="characters are \nassigned to \nspecific keys."}elseif k==2do return{title="gamepad",description="each button is\nassigned to a\nunique player."}end end function e4(n)if D>0do if h==c.complete do?"⁶w⁶tyou win!",i+30,a+60,10
else?"⁶w⁶tnext time...",i+20,a+60,10
end else rectfill(i,a,i+128,a+128,0)e5(i,a,n)end end function e5(n,e,d)local o="time: "..nI(ni)?o,n+flr((128-#o*4)/2),e+2,10
?"most revives",n+40,e+9,7
local o={n+16,n+56,n+96}for n=1,3do if g[n]and g[n][2]>0do local o=o[n]spr(g[n][1],o,e+15)local n=tostr(g[n][2])local o=o+4-#n*2?n,o,e+24,10
end end q+=d?"leaderboard",n+42,e+30,7
clip(0,36,128,80)local o=#m*8-80if o>0do if j>=o do j=o if q>2do j=0q=0end elseif q>4do j+=20*d if j>=o do j=o q=0end end end local o=m[1]and#tostr(m[1][3])*4or 4local o=88+o local o=n+flr((128-o)/2)for n=1,#m do local e=e+36+(n-1)*8-j spr(m[n][1],o,e)?"...................",o+10,e+1,5
?m[n][3],o+88,e+1,10
end clip()local o="continue in "..flr(O)local d=#o*4?o,n+flr((128-d)/2),e+120,10
end function e9()ni=time()-n1 q=0j=0for e,n in pairs(r)do if n.enabled==true do n.totalTimeEnabled=n.totalTimeEnabled+(time()-n.last_enabled_time)end end m={}for e,n in ipairs(P)do local n=r[n]if n do local e=flr(n.totalTimeEnabled)*10+n.reviveCount*100+n.kingHits*50add(m,{n.sprite,n.disabledCount,e,n.reviveCount})end end local n=#m for e=1,n-1do for n=1,n-e do if m[n][3]<m[n+1][3]do m[n],m[n+1]=m[n+1],m[n]end end end g={}for e,n in ipairs(P)do local n=r[n]if n do add(g,{n.sprite,n.reviveCount})end end local n=#g for e=1,n-1do for n=1,n-e do if g[n][2]<g[n+1][2]do g[n],g[n+1]=g[n+1],g[n]end end end end poke(24365,1)local e,o,d,l,t,n,f=0,0,0,0,0function e7(e)local o,d,n=er(),i+nq*e if o~=nil do n=o.xpos-(128-nF*8)else n=d end if w==E.tournament do n=max(n,d)else n=max(n,0)end i=i+(n-i)*min(nD*e,1)end function _init()n,f,e=0,0,0if h==c.complete or h==c.gameover do h=c.playerSelect else h=c.mainMenu end M(h)end function nx()cls()_init()end function M(n)h=n if h==c.mainMenu do i=0a=0e8(function()M(c.playerSelect)end)music(0,1000,1)elseif h==c.playerSelect do z=0n0=0d=(z+1)*128i=z*16*8a=n0*16*8Y=false el()ed(5)ng()nN()nW(z)eD=Z*8-128+80eh()m={}I,o={},.4menuitem(2,"set gamemode",nw)O=15nA={[1]=r,[2]=x}music(-1,1000,1)music(4,1000,2)elseif h==c.game do music(-1,1000,2)music(6,1000,3)nv()n1=time()elseif h==c.complete or h==c.gameover do D=3music(0,2000)e9()end end function _update()local l=time()n,f=l-f,l if h==c.mainMenu do es(n)elseif h==c.playerSelect do local e=eu(i,a,n,o==0)if o>0do stat(31)end o=max(0,o-n)if s>0do G=max(0,G-n)if G==0do e=true end end if e do M(c.game)end elseif h==c.game do if y do em()if nl do eq()end else if e<1.5do e+=n else e7(n)end if nc~=na.CLOUD_KINGDOM do nc=na.CLOUD_KINGDOM else if Y and not u[1].enabled do M(c.complete)end end if A==s do M(c.gameover)e=0end n9(n)np(i,a,n)n4(n)ec()for e in all(I)do e[3]-=n if e[3]<=0do del(I,e)end end if N<1do N=(i-(d-128))/128a=S(nt,nf,min(N,1))end end if i>=d do z+=1d+=128nX(z)end if k~=2do while stat(30)do nj=stat(31)if nj=="れ"do eg()end ny(nj)end else for n=0,5do if btnp(n,0)do ny(n)end end end elseif h==c.gameover do n9(n)np(i,a,n)n4(n)nz()D=R(D,n)elseif h==c.complete do nz()D=R(D,n)end end function _draw()cls()camera(i,a)map(0,0,0,a,128,16)map(0,0,1024,a,128,16)map(0,0,2048,a,128,16)map(0,0,3072,a,128,16)n_()e1()e0()n3(x)n3(r)local d=a+112for n in all(I)do local o,e=mid(n[1],i,i+112),mid(n[2],a,a+112)if n[5]do e,d=d,d-16end spr(n[4],o,e-8)spr(nC,o,e-16)if n[5]do spr(nG,o-8,e-8)else spr(nE,o,e)end end if h==c.mainMenu do e6()elseif h==c.playerSelect do rectfill(i,0,i+128,a+5,a)?"press any button to join",i+4,a,7
if s>0do?"starting in "..flr(G),i+4,a+8,7
end?"⁶w⁶thop"..s,i+46,a+56,7
elseif h==c.game do elseif h==c.complete or h==c.gameover do e4(n)end if h==c.game or h==c.playerSelect do if F>0do rectfill(i,0,i+128,a+5,a)?"set gamemode to "..nd().title,i+16,a,7
F=max(0,F-n)end end if y do nV()rect(i,a,i+127,a+127,7)?i/8 ..","..a/8,i+4,a+4
?i/8+16 ..","..a/8+16,i+128+4,a+128+4
l=stat(32)+i t=stat(33)+a rect(l,t,l+2,t+2)end end function nz()if e<2do e+=n else O-=n if O<=0do nx()elseif stat(30)and stat(31)==" "do nx()end end end function eg()y=not y if y do menuitem(2,"toggle fast travel",eA)menuitem(3,"toggle pcannon",eB)else menuitem(2)menuitem(3)end end function em()if btn(0)do i-=10end if btn(1)do if nl do i+=10else i=min(i+10,d-1)end end if btn(2)do a-=10end if btn(3)do a+=10end if stat(34)==1do printh(flr(l/8)..", "..flr(t/8))end end
__gfx__
000000000008e0000011110001cccc0000444400000000000000aa008000000800000000000dd000000000000008000000003300000000000000000000000000
00000000008eee00011cccc1001cccc004040440004470000000aa0008000080000cc000000dd00000aaaaa0008aaaa0033bbb30004000400009990007777770
00700700008eeee0011c7c7100aaaaaa44444402004750000000a9900088880000c66c000dddddd00aaaaa0008aaaa803bbbbbb3044000400009990007c55c70
0007700008eeeee0001c7c71000ffff044044042007770000aaaaa00088888800cccccc00d6dd6d00aaaa0000aaaa000bbbbbbb3044774000009990007555570
0007700008e1e1e00011ccc1000f5f50444444420009000000aaaa00088558800c6cc6c00dddddd00aaaa0000aaaa000bb5bbb53004444000000900007777770
0070070000eeee0e001cc110000ffff0404004120009970000aaaa0008888880cccccccc00d55d000aaaaa000aaaaa803bbbbbb3004004000088888000077000
000000000eee0e00001c110000f1111f04444420000100000009000008000080c6c66c6c0d0dd0d000aaaaa000aaaaa00bbbbbb0004004000000800000700700
000000000e0e0ee00111000000010010002222000010100000099000008008000c0000c0d000000d0000000000000000033333300000000000cc0cc000000000
00dd0000885588550000000000000000000000000004300000000000000000000000000000000000008880000aaaaaa0000066006666666655515555767d6777
00dd00008855885500046600006600000044700000044400000c00000000000000046660066666600089088000aaaa0006666660655555565451555577454777
099d0000558855880005460006666660044750000004000000cd0000000000000005466006c66c600449990000aaaa00065665606575575655d66d5477424777
00ddddd0558855880004440000066000047770000004400000cd0000000ccc00000444600656656008c9c880000aa0000656656065755756556666557745e777
00dddd00885588550000200000066000040b0000000444000dccc0000cccccc0000022660666666008c8c890000550000666666065555556555ddd5577d5d777
00dddd00885588550042200000066660040bb700004444000ccccc0008cccca000422200067a776000ccc0000005500006555560657777565456655477d5d777
00009000558855880000100006600000040b0000040400000ccccc000c5cc5c0000022000666666000c0c0000005500006666660655555565545544577d5d777
0009900055885588000101000000000040b0b0000004400000ccc00044444444000222220000000004404400000550000066660066666666124ef42176667777
00000000800000080a00a00aa00a00a0000000005500000000000000000000008000000000008888000000000000000080000000000088880000000000000000
00000000080000800aaaaaaaaaaaaaa0000000055550000000000000000000000800000000088000000000000000000008000000000880000000000000000000
cccccccc008008000aabbbbaabbbbaa0000000057caa00000000ccccccc0000000880000000800000000ccccccc0000000880000000800000000ccccccc00000
eeeeeeee000880000abbbbbbbbbbbba055000005e5500055000cc000000ccc000008800000880000000cc000000ccc000008800000880000000cc000000ccc00
777777770008800000b7777bb7777b00055550055e50055000cc000000000cc0000088000880000000cc000000000cc0000088000880000000cc000000000cc0
eeeeeeee0080080000b7007bb7007b00007eeeee550eee0000c00000000000c0000008808800000000c00000000000c0000008808800000000c00000000000c0
cccccccc0800008000bbbbbbbbbbbb00555557775577755500c00000000000c0000000888000000000c00000000000c0000000888000000000c00000000000c0
00000000800000080b3bb000000bb3b0007ee111111eee0000c00000000000c0000000088000000000c00000000000c0000000088000000000c00000000000c0
8000000880000008bb3b0aaaaaa0b3bb55555777557755550cc00000000000c000000088880000000cc00000000000c000000088880000000cc00000000000c0
0800008008000080bb3bbaaaaaabb3bb0000eee5555ee0000c000000000000c000000880080000000c000000000000c000000880080000000c000000000000c0
00800800008008000b77ba777a7bb37000555005ee5000000c000000000000c000008000008800000c000000000000c000008000008800000c000000000000c0
0008800000088000b776b7666a6737b705500005ee5000000cc00000000000c000080000000800000cc00000000000c000080000000800000cc00000000000c0
00088000000880007777766aab77777700000055ee55500000ccc00000000cc0008800000008800000ccc00000000cc0008800000008800000ccc00000000cc0
008008000080080077777777b777777700000555e0a055000000cccc000ccc0008800000000008000000cccc000ccc0008800000000008000000cccc000ccc00
080000800800008007667766776666700000550a000a05000000000ccccc000088000000000000800000000ccccc000088000000000000800000000ccccc0000
80000008800000080006600660066000000000a0a0a0a00000000000000000008000000000000088000000000000000080000000000000880000000000000000
00000000bbbbbbbb0171000000aa0a00000000000000000000c77c00000b3000002bb20066666666000000000000000000000000000000000000000000000000
88888888b4bbbbbb016710000a9900a000000000000990000cccccc000b3330000bbbb0088888888000000000000000000000000000000000000000000000000
99999999b42bb4b201677100a909000a00bb0b0000077000cb7bb77b00bb330000bbbb0099999999000000000000000000000000000000000000000000000000
aaaaaaaa4422442201677710a99990000b00b0b000999900b73c73bb0bb3b330b03bb30baaaaaaaa000000000000000000000000000000000000000000000000
bbbbbbbb2244224401677771a999999a0000b00000777700bcccbbbb0b3333300bbbbbb0bbbbbbbb000000000000000000000000000000000000000000000000
cccccccc2244224401677777a990099a0244444007777770bbc77bccbbbb3333003bb300cccccccc000000000000000000000000000000000000000000000000
1111111144224422016667110a0990a002444440099999900cccccc00005500000bbbb0011111111000000000000000000000000000000000000000000000000
00000000442244220161167100aaaa00002444009999999900777700000550000bb33bb066666666000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb22442244aaaaaaaa99999999777777775555555577777777666666665555555577777777777777770123012377677677000000000000000000000000
b4bbbbbb22442244aa9aaaa999999999666666665555555577777777666666665555555575777757555555552201456766777766000000000000000000001000
b42bb4b244224422aaaaaaaa9999999966666666555555557777777766666666550000550557505555555555400123ab77677677000000000000000000012100
4422442244224422a9aa9aa99999999966666666555555556767676766666666550000555055050555000055234567ef77766777000000000000000000122210
22442244224422449a9aaa9a99999999666666665555555576767676666666665500005505005055550000554089ab2377677677000000000000000000012100
2244224422442244a9a9a9a9999999995666565655555555666666666666666655000055505005005500005524bdef6776777767000000000000000000001000
44224422442244229a9a9a9a9999999965656565555555556767676766666666550000550005505055000055589a89ab67677676000000000000000000000000
442244224422442299a999a999999999555655565555555566666666666666660000000000000000000000009cdecdef77766777000000000000000000000000
00000000000000000000000000000000011121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000000000000000000000000111100011221200011200000000000000000000002000000000000000000000000000000000000000000000000000000000000
222000000000c0000000000011122120111221200012211200000000000000000012200000000000000000000000000000000000000000000000000000000000
02000000000ccc000010000011222220111222200012112200021120000000000012200000000000000000000000000000000000000000000000000000000000
000000000000c0000000000012222200112222200012112201211120000000000001000000000000000000000000000000000000000000000000000000000000
00000200000000000000000022222200122222000000122001111120001111000111110000000000000000000000000000000000000000000000000000000000
00002220000000000000000022000000022000000000000002211220001112000111220000000000000000000000000000000000000000000000000000000000
00000200000000000000000000000000000000000000000000222220011222000012200000000000000000000000000000000000000000000000000000000000
82000028000000000008800000000000000000000000000000000000033330000bb00bb00ccccc000077700000000000007777000777700000aaaa00001c1000
2820028200000000008880000880088000000000000cc0000000000036333300b70bb07bc00000c0000070000007770006677770076777700a1111a001c9c100
028228202222222208888000888888880aaaaaa000cccc000bb33bb036333300b0bbbb0b00ccc00c77777777777776770666777776766767a100071a1c9a9c10
00288200288888828888800088888888000a000000cccc000b3333b0333333330bb00bb00c000c0c77077077776677670666070777676676a107001ac9aaa9c0
002882000288882088888000888888880ccaaa0a06666660bb3333bb033ccccc077bb770c0000c0c70077007766777670666777776767667a1c0701a1c9a9c10
028228200028820008888000088888800caaaaaa666aa666b333333b00c33ccc12277221c00cc00c70777707077676770067777767676766a110001a01c9c100
2820028200022000008880000088880000a00a0006000060b333333b0000cccc122772210c0000c0007777000007770000060606676700000a1111a0001c1000
820000280000000000088000000880000aaaaaa06000000600000000000111110127721000cccc000070070000000000000707076700000000aaaa0000000000
000000000000bb000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000b00b00077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c000000b00b00777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cac000b0b0b0b07070770000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c000b0b000b00777777000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b0000000077777700000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b000000007777770000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000007070700000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000003000000030000000003000000000000000000000000000000000003000
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000003000000030000000003000000000000000000000000000000000003000
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000003000000030000000003000000000000000000000000000000000003000
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000000000000030000000003000000000000000000000000000000000000000
00000000000000000000003030000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000020
00000000200000000000000030000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000000000000000
30000000000000000000000000000000000020000000000000000000000000000000000000000000200000000020000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000000000
00000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000400000000000000000
00000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000040000000000000000000000000000000
00000000000000000000400000000000000000000000000000000000400000000040000000000000000000000000000000000000000000400000000040000000
004000000000000000000000000000d0d0d000000000000000400000000040000000000000000000000000000000000040000000004000000000000000000000
00000000000000000000400000000040000000000020202020202020202020202020202020200000000000000000000020202020202020202020202020202020
2020202020209090b0b0b0b0a0909000000020202020202020202020202020202020209090b0b0b0b020202020202020202020202020202020209090b0b0b0b0
a0909020202020202020202020202020202020209030303030303030303030303030303030302020202090202020209030303030303030303030303030303030
__label__
00007770777007700770000077707700707000007070777070700000777007700000777077007700000077700000777070007770707077707770000000000000
07707070700070007000000070707070707000007070700070700000070070700000707070707070000070700000707070007070707070007070000000000000
70707700770077707770000077707070777000007700770077700000070070700000777070707070000077700000777070007770777077007700000000000000
77707070700000700070000070707070007000007070700000700000070070700000707070707070000070700000700070007070007070007070000000000000
70007070777077007700000070707070777000007070777077700000070077000000707077707770000070700000700077707070777077707070000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770000777700777777007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770000777700777777007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770077007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770077007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007777770077007700777777007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007777770077007700777777007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770000007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770000007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077770000770000007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077770000770000007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbb00000000bbbbbbbb0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbb00000000bbbbbbbb0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000bbbbbbbb00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000bbbbbbbb00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000000000000000000000000000bbbbbbbb000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000000000000000000000000000bbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
6777777667777776677777766777777667777776bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
7666666776666667766666677666666776666667bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
67777776677777766777777667777776677777764444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000070000000710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070000078000071000000000000007100000000000070000000000070000000000000006f0000000000000000000000006f0000000000000000000000000000000000006f6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007100727300737574007000007874007000000000000000000000000000006f0000000000006f00006f00000000000000000000000000006f0000000000000000000000006f6f00000000710000000000000000000000007100710000000000006f6f0000000000000000007100006f00007000000000000000000070000000
006f00000000006f0000000074740000000000710000000070000078770077006f00000000000000006f0000700000007100007000000000710000006f00000000007000006f00710000006f00700000000070006f00000000006f0000000000000000000000000000006f000000000000000000000000700000000000007000
00000000007000000000006f000000000000000000000000000000000075000071000000006f00000000000000000000000000000000000000000000000000006f0000000000000000006f0000000000000000000000700000000000006f6f0000000000000000000000000000006f0000000000000000000000000070000000
0000007000000000720000007200000072000000000000000000000000000000000000000000000000000000000000706f000000000000000070000000000000000000707100006f6f0000007100000000000000000000710000000000006f000000006f006f00000000000000007171000000006f0000000000000000000000
0000007200720000007000000000720070000072000000000000006f000000000000006f000000000000000000000000000000006f0071006f000000006f00000000007100000000006f000071006f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000
007200007000000000007200000000000000000000000070000000700000006f00006f000000000000710000006f00000000000000000000000000000071000000000000000000000000707100000000006f0000000000006f6f0071000000000000000000000000000000000000000000000071007171000000000000000000
00000000000000000000007200007000000000000000006f000000000000000000706f00000000006f000000006f000070000000000000000000006f00000000006f000000006f7100000000000000000000000000000000000000000000000000000000000000000000006f0000000000000000000070000000710000000070
00000000000072000072000000000000000072000000000000000000000070000000000000006f00000000700000000000000000006f000000006f000000007000700000000000000000000000000000000000006f00000000000000007100006f000000000000006f0000000000000000000000000000000000000000000000
000072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f0000000000000000000000000000006f000000000000000000000000716f0000000000000000000070000000006f0000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000070000000000000000000006f00000000000000000000000000007000000000000070000000006f000000000000000070006f000000007000000000000000000000006f00000000710000000000000000000000006f000000700000000000000000000000007000
00000000000000000000000000000000000000007000000000000000710000000071006f007000000000006f00000000007100000000006f0000000000000000000000006f000000000000000000000000006f00710000007000000000006f00006f000000007100000000000000000000000000000000700000000000000000
0000000000000000000000000000000000000000006f000000000000000000006f000000000000000000000000000000000000000000000000000000006f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000006f0000000000000000000000006f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
911e00002353423534235342353424e1224e122453424534245342453424e1224e122353423534235342353424e1224e122153421534215342153424e1224e121f5341f5341f5341f53424e1224e1224e1224e12
951e00000c0350c03524e12130351303524e1224e12170301703024e12150351303524e1210030100301003024e1224e120c0350c03524e120c0350c0350c03024e1224e120c0350c03524e120c0350c03524e12
d71e000024e1224e1224e1224e1224e122d1102d1102d1102b1102b11028110281102a1102a1102b1102b1102b1102b1102a1102a1102a1102811028110281102811028110281102811028110231102311023110
911e00001f5341f5341f5341f53424e1224e121e5341e5341e5341e53424e1224e121f5341f5341f5341f53424e1224e121e5341e5341e5341e53424e1224e121c5341c5341c5341c53424e1224e1224e1224e12
d71e0000211102111021110231102311023110241102411024110241102311023110231102311024e1224e1224e1224e121c1101c1101c1101e1101e1101e1101f1101f1101f1101f1101e1101e1101e1101e110
911e00001c5341c5341c5341c53424e1224e122153421534215342153424e1224e121c5341c5341c5341c53424e1224e121a5341a5341a5341a53424e1224e121853418534185341853424e1224e1224e1224e12
011e000024e1224e1200000000000000024e1524e1524e1524e1524e1524e1524e1524e150ce150c5150c5150c5140c5140c5140c5140c5140c5140c5140c5140c5140c5140c5340c5340c5340c5340c5340c534
970d00000cf300cf30225320700007f30225320af300af300cf300cf30225320700007f30225320af300af300cf300cf30225320700007f30225320af300af300cf300cf30225320700007f30225320af300af30
910d0000166000c6001b5321f600226001b5321b6001f60022600186001b53213000130001b5321c4001d4001e4001f4001b5321b0001b0001b5321f6002260018000180001b53218000180001b5321800000000
910d00000c74300000185321360013645185320c7430c7000c74300000185321360013645185320c743000000c74300700185321360013645185320c743000000c74300000185321360013645185320c7430c700
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
b70d0000274222742224422244221f4221f4221b4221b4221842218422184221842218422184220040200402004020040200402004021640216402164221642218422184221b4221b4221b4221b4221b4221b422
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
b70d00001b4221b4221b4221b4221b4221b4221b42224422234222242221422204221f4221e4221d4221c4221b4221b4221b4221b4221b4221b4221b40200402004020040218422184221a4221a4221b4221b422
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d000011030110301b532000000c0301b5320f0300f03011030110301b532050000c0301b5320f0300f03011030110301b5320c0000c0301b5320f0300f03011030110301b5320c0000c0301b5320f0300f030
b70d000020422204221d4221d4221842218422144221442211422114221142211422114221142200402004020040200402004020040200402004020f4220f42211422114220c4020c40211422114220000200000
910d00000000000000205320050000500205320050000500005000050020532185001850020532185001850018500185002053218500185002053218500185001850018500205321850018500205321800000000
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
0001000000000000000000000000000000000000000120401c0401e040200402204023040240401e0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000855008550045500655006550025500155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01050300
00 01020300
00 01040300
02 01050300
00 0a430809
00 0a430809
01 0b0c0809
00 0d0e0809
00 0f420809
00 100c0809
00 110e0809
00 12420809
00 13141509
02 16420809
00 57575757

