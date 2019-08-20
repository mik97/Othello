require("board")

function love.load()
  love.window.maximize()
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  -- x, y, square dimension, number of columns
  board.initialize(origin_x, origin_y, dim, 8)
  board = board:create()
end

function love.update()

end

function love.draw()
  board:draw()
  board:fill()
end
