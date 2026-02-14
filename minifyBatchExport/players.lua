poke(24365,1)x={}n=1a=0local n=0i=0local l,e,d,t,o=10,0,0,0,1function p()f={}a=0n=0y()i=0e=0d=16t=0o=1k(32,f,{type="player",width=8,height=8,sprite=0,sprite2=0})end function h(n)g(n.id)v(n)i=i+1end function b(n)r(f,n.key,n.xpos,n.ypos)i=i-1end function u(l,o,e)local t=nil if(j==1)local n={32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63}t=n[a+1]else t=m[e]
if(t==nil)return nil
a=a+1local n=f[a]n.id=e n.sprite=t n.xpos=l n.ypos=o f[a]=nil f[e]=n r(f,e,l,d)add(x,e)return n end function q(l,o,i,n)if n and stat(30)do local n=stat(31)if not(n==" ")and not(n=="\r")and not(n=="p")and a<32do if not f[n]do w=5.9local n=u(e+l,d+o,n)if(n==nil)return
n.startPosition=d e=e+9if e>=100do if(t>=8)t=0else t=t+2
e=t d=d+9end end f[n].ypos=f[n].startPosition-2end if(n==" "and a>0)return true
end for e,n in pairs(f)do if(n.ypos<n.startPosition)n.ypos=min(n.startPosition,n.ypos+20*i)
end return false end function z(t,n,d)for e,n in pairs(f)do if n.enabled and not n.inputDisabled do if(not(n.vx==0))l=0else l=0
local e=A(n,d)local e=B(e.xpos,e.ypos,n.xpos,n.ypos,true)n.onGround=e.onGround if(n.onGround)n.vx=0n.vy=0n.bounce_charge=min(n.bounce_charge+d,4)local e=n.bounce_charge/4n.jump_height=s(1.5,12,e)n.jump_distance=s(1.5,8,e)
n.xpos=min(e.x,t+128-n.width)n.ypos=e.y if(C(n))h(n)n.xpos=-8n.ypos=-8
for d,e in ipairs(F)do if(c(n,e.bird))r(f,e.playerKey,n.xpos,n.ypos)i=i-1del(F,e)
end for d,e in ipairs(E)do if(c(n,e))h(n)n.xpos=-8n.ypos=-8sfx(1)
end for t,e in ipairs(G)do if c(n,e)do if H(n,e)do sfx(2)if(e.type=="king")I-=1
n.ypos=e.ypos-8n.vy=-100end end if((e.state==3or e.type=="vulture"and e.state==2)and c(n,e.tracker_beam))J(n,d)
end end end end function K(e)local n=f[e]if not(n==nil)and not n.inputDisabled do L(n)elseif M==N.freeplay and a<32do u(O+64,P,e)D()end end function D()local n=s(10,1,a/32)Q=R(n)end