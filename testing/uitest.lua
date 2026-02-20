local hearts = 32

function _init()

end

function _update()
    if (btn(0)) hearts-=1
    if (btn(1)) hearts+=1
    if (btn(2)) hearts-=1
    if (btn(3)) hearts+=1 
end

function _draw()
    cls()
    camera(camera_x, camera_y)
    map(0,0,0,camera_y,128,16)

    drawHearts(hearts)
end

