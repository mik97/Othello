require("board")

function love.load(s)
  origin_x = 50;
  origin_y = 50;
  dim = 50;
end

function love.update()

end

function love.draw()
  board:draw(origin_x, origin_y, dim)
end


board:create()