function b()d={}n(1,d,{type="ufo",width=8,height=8,sprite=109,sprite2=110})end function j()d={}l=max(m,3)n(1,d,{type="king",width=8,height=8,sprite=121,sprite2=122})end function p()d={}n(1,d,{type="vulture",width=8,height=8,sprite=125,sprite2=126})d[1].tracker_beam.width=8d[1].tracker_beam.height=8d[1].tracker_beam.boundsOffsetX=4d[1].tracker_beam.boundsOffsetY=6end function q(e,l)local n=h(d,1,e,l)n.boundsOffsetX=4n.boundsOffsetY=4f(n,e,l)return n end function w(e)local n=d[1]if n.enabled and n.ai_enabled do if n.state==1do u(n,50)if(n.type=="king")if n.timer_1==0do h(x,-1,n.xpos,n.ypos)n.timer_1=5elseif l<=0do n.state=4end else if(n.timer_1==0and n.xpos>i+70)n.vx=0n.state=2
n.timer_1=c(n.timer_1,e)elseif n.state==2do if n.type=="ufo"do local e=y(n.xpos)if(e)if(n.ypos<(e.y-4)*8)n.vy=30else n.vy=0n.state=3n.timer_1=5sfx(3,1)else n.state=1
elseif n.type=="vulture"do u(n,65)if(n.ypos<56)n.vy=10n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos else n.vy=-10n.state=4o(n)
end elseif n.state==3do n.timer_1=c(n.timer_1,e)n.tracker_beam.xpos=n.xpos n.tracker_beam.ypos=n.ypos if(n.timer_1==0)o(n)n.state=4
elseif n.state==4do n.ypos-=65*e if(n.ypos+8<=a-32)if(n.type=="vulture"and n.disabledCount<0)n.disabledCount=n.disabledCount+1f(n,i+8,8)else r(n)
end if(n.type=="vulture")for l,e in pairs(n.capture_tracker)do e.player.xpos=n.xpos+4e.player.ypos=n.ypos+4end
if(n.type=="ufo")s()
local l,e=n.xpos+n.vx*e,n.ypos+n.vy*e n.xpos=l n.ypos=e end end function f(n,e,l)n.xpos=e n.ypos=l n.vx=0n.vy=0n.state=1n.timer_1=5+flr(rnd(5))n.capture_tracker={}end function o(n)for e,n in pairs(n.capture_tracker)do n.player.xpos=-8n.player.ypos=-8end end function z(n)local e=d[1]if(e.capture_tracker[n.id]==nil)e.capture_tracker[n.id]={player=n,t=0}r(n)v=v+1
end function s()local e=d[1]local n=e.capture_tracker[A.id]for l,n in pairs(e.capture_tracker)do n.player.xpos=n.player.xpos+(e.xpos-n.player.xpos)*min(n.t,.2)n.player.ypos=n.player.ypos+(e.ypos+8-n.player.ypos)*min(n.t,.2)n.t+=.1*B if(n.t>=.2)n.player.xpos=-8n.player.ypos=-8
end end function C()local n=d[1]if n.enabled do spr(n.sprite,n.xpos,n.ypos)if n.state==3or n.state==4or n.type=="vulture"and n.state==2do if(n.type=="vulture")spr(n.sprite2,n.xpos,n.ypos+4)else spr(n.sprite2,n.xpos,n.ypos+6)
if(e)local n=k(n.tracker_beam)rect(n.left,n.top,n.right,n.bottom,8)
end if(n.type=="king")g(l)
if(e)local n=k(n)rect(n.left,n.top,n.right,n.bottom,8)
end end function g(n)local e,n=ceil(n*10/128),n for l=1,e,1do local d,t,f=i+4,a+4+10*(l-1),12if(l==e)f=n
for e=1,f,1do spr(8,d,t)n-=1d+=10end end end