function e(n,e)for t,n in ipairs(n)do if(n==e)return true
end return false end n={}n.__index=n function n.new()local n=setmetatable({items={},head=1,tail=1},n)return n end function n:enqueue_unique(n)if(not e(self.items,n))self.items[self.tail]=n self.tail=self.tail+1
end function n:dequeue()if(self:isempty())return nil
local n=self.items[self.head]self.items[self.head]=nil self.head=self.head+1return n end function n:isempty()return self.head==self.tail end function r(r)local n=t()return function()local e=t()if(e-n>=r)n=e return true
return false end end function u(n,e)return max(n-e,0)end function f(n,e,t)return n+(e-n)*t end