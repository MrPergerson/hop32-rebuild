function n(n)d={}e(n,d,{type="zombie",width=1,height=1,sprite=108,sprite2=0})end function f(n,e)end function i(e)for d,n in ipairs(d)do if n.enabled and n.ai_enabled do if(o(n))c(n)break
n.vx=n.move_dir*5local e=a(n,e)local e=l(e.xpos,e.ypos,n.xpos,n.ypos,false)n.onGround=e.onGround if(n.onGround)n.vx=0n.vy=0if(e.hit_wall)h(n)
n.xpos=e.x n.ypos=e.y end end end