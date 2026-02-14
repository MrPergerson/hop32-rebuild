local e,n,o,d={},0,0,8function l(l)e={}d=8r={}n=l*16o=0i()i()end function h(l)local n=i(n,0)add(e,n)u+=1local n=n for e in all(e)do if(e.x<n.x)n=e
end del(e,n)end function i()local l={}if n>=a.VOID do l=s(n,o)if(n==a.VOID+16)b()f(3008,40)k=true
elseif n>=a.CITY do l=m(n,o,d)d-=1elseif n>=a.SNOW do l=p(n,o)if(n==a.SNOW+16)q()f((a.SNOW+16)*8,8)
else l=v(n)if l.x==w*16and x==y.playerSelect do else local n=z(l.surface_tiles)A(B,-1,n.x*8,(n.y-1)*8)end if(n==64)printh(#C)local n=f(512,16)printh(n.xpos)
end add(e,l)n+=16return l end function D()for n in all(e)do for e=n.x,n.x+16-1do for l=n.y,n.y+16-1do local n=n.tiles[e][l]if n.sprite>0do spr(n.sprite,n.x*8,n.y*8)if(c)rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,9)
else if(c)rect(n.x*8,n.y*8,n.x*8+8,n.y*8+8,2)
end end end end end function g(n,l)local o,d=e[1],e[#e]if n<o.x or n>=d.x+16or l<o.y or l>=o.y+E do return{tile=-1}else local o={tile=-1}n=flr(n)l=flr(l)for e in all(e)do if(n>=e.x and n<e.x+16)o=e break
end if(o.tile==-1)printh("("..n..","..l..") tile not found")return o
return o.tiles[n][l]end end function F(n)local l,n={tile=-1},flr(n/8)for e in all(e)do if(n>=e.x and n<e.x+16)l=e break
end local e=l.surface_tiles for l,e in ipairs(e)do if(e.x==n)return e
end end function G(a,l,o,f,t)local e,n,o,d,c,i=a/8,l/8,o/8,f/8,false,false local r,h,u,d,s,b,k,g,o=g(e,d),g(e,d+.999),g(e+1,d),g(e+1,d+.999),g(o,n),g(o+.999,n),g(o,n+1),g(o+.999,n+1),0if r~=nil and h~=nil and(r.sprite~=j.NONE or h.sprite~=j.NONE)do if(t==false)e=flr(e)+1
i=true elseif u~=nil and d~=nil and(u.sprite~=j.NONE or d.sprite~=j.NONE)do e=flr(e)o+=1i=true end if s~=nil and b~=nil and(s.sprite~=j.NONE or b.sprite~=j.NONE)do if(l>0or t==false)n=flr(n)+1
o+=1elseif k~=nil and g~=nil and(k.sprite~=j.NONE or g.sprite~=j.NONE)do n=flr(n)c=true end if(o==2)if(l>f)n=n-1
a=e*8l=n*8return{x=a,y=l,onGround=c,hit_wall=i}end