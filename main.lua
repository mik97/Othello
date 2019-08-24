require("board")
local minimax = require 'minimax'
local tree = require 'tree'

function love.load()
  love.window.maximize()
  current_player = 0
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  
  -- selected = {x, y}: x is the column and y the row
  selected = {2,4}
  
  board.initialize(origin_x, origin_y, dim, 8)
  board = board:create()
  
  local candidates = board:searchSquares(current_player)
  
  buildTree(table.getn(candidates), candidates)
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
   
  if key == "left" then
    selected[1] = selected[1] - 1
  end
  
  if key == "right" then
    selected[1] = selected[1] + 1
    
  end
  if key == "down" then
    selected[2] = selected[2] + 1 
  end
  
  if key == "up" then
    selected[2] = selected[2] - 1
  end
 
  
  if key == "return" then
    if board:isCandidate(selected) then
      board:addPiece(selected, current_player)
      current_player = (current_player + 1) % 2
      local candidates = board:searchSquares(current_player)
      buildTree(table.getn(candidates), candidates)
     end
  end
  
end

function drawSelected()
  love.graphics.setColor(0,1,1)
  love.graphics.rectangle('line', origin_x + 20 + dim*(selected[1]-1), origin_y + 20 + dim*(selected[2]-1), dim - 40, dim - 40)  
  love.graphics.setColor(1,1,1) --set color to white (default)
end

function buildTree(num, candidates)
  local t = tree ()
  
  t:addNode('A',nil,0)
  
  if num%2 == 0 then
    print('ok')
    if num/2 == 1 then
      print('ok')
      for i, candidate in ipairs(candidates) do
        t:addNode('B' .. i, 'A', candidate)
        print(t:getNode('B' .. i))
      end
    else
      print('ok')
      num = num/2
      buildTree(num, candidates)
    end
  end
end
