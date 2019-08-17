require("board")

function love.load()
  love.window.maximize()
  current_player = 0
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  
  selected = {1,1} --coordinate selected square (column, row)
  
  -- x, y, square dimension, number of columns
  board.initialize(origin_x, origin_y, dim, 8)
  board = board:create()
  board:searchSquares(current_player)
end

function love.update()

end

function love.draw()
  board:draw()
  board:fill()
  board:drawCandidates()
  drawSelected()
end

function love.keypressed(key, scancode, isrepeat)
  if key == "down" then
    selected[1] = selected[1] + 1 
  end
  
  if key == "up" then
    selected[1] = selected[1]- 1
  end
  
  if key == "left" then
    selected[2] = selected[2] - 1
  end
  
  if key == "right" then
    selected[2] = selected[2] + 1
  end
  
  if key == "return" then
    if board:isCandidate(selected) then
      board:addPiece(selected, current_player)
      current_player = (current_player + 1) % 2
      board:searchSquares(current_player)
     end
  end
  
end

function drawSelected()
  love.graphics.setColor(0,1,1)
  love.graphics.rectangle('line', origin_x + 20 + dim*(selected[2]-1), origin_y + 20 + dim*(selected[1]-1), dim -30, dim-30)  
  love.graphics.setColor(1,1,1) --set color to white (default)
end