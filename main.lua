require("board")
local minimax = require 'minimax'
local tree = require 'tree'
local t = tree ()

function love.load()
  love.window.maximize()
  current_player = 0
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  
  -- selected = {x, y}: x is the column and y the row
  selected = {1,1}
  
  board.initialize(origin_x, origin_y, dim, 8)
  board = board:create()
  
  local candidates = board:searchSquares(current_player)
  t:addNode('A',nil,0)
  buildTree(table.getn(candidates), candidates)
  print(t:getAllNodes())
end

function love.update()

end

function love.draw()
  board:draw()
  board:fill()
  board:drawCandidates(current_player)
  drawSelected()
end

function love.keypressed(key, scancode, isrepeat)
   
  if key == "left" then
    if selected[1] > 1 then
      selected[1] = selected[1] - 1
    end
  end
  
  if key == "right" then
    if selected[1] < 8 then
      selected[1] = selected[1] + 1
    end
  end
  if key == "down" then
    if selected[2] < 8 then
      selected[2] = selected[2] + 1 
    end
  end
  
  if key == "up" then
    if selected[2] > 1 then
      selected[2] = selected[2] - 1
    end
  end
 
  
  if key == "return" then
    if board:isCandidate(selected) then
      board:addPiece(selected, current_player)
      current_player = (current_player + 1) % 2
      local candidates = board:searchSquares(current_player)
      t = tree ()
      t:addNode('A',nil,0)
      buildTree(table.getn(candidates), candidates)
     end
     print(t:getAllNodes())
  end
  
end

function drawSelected()
  love.graphics.setColor(0,1,1)
  love.graphics.rectangle('line', origin_x + 20 + dim*(selected[1]-1), origin_y + 20 + dim*(selected[2]-1), dim - 40, dim - 40)  
  love.graphics.setColor(1,1,1) --set color to white (default)
end

function buildTree(num, candidates)  
  if num%2 == 0 then
    if num/2 <= 1 then
      for i, candidate in ipairs(candidates) do
        if i <= 2 then
          t:addNode('C' .. candidate[1], 'B1', candidate)
        else
          t:addNode('C' .. candidate[1], 'B2', candidate)
        end
      end
    else
      num = num/2
      for n = 1,num do
        t:addNode('B' .. n, 'A', 0)
      end
      
      buildTree(num, candidates)
    end
  else
    if num/2 <= 1 then
      for i, candidate in ipairs(candidates) do
        if i <= 2 then
          t:addNode('C' .. candidate[1], 'B1', candidate)
        else
          t:addNode('C' .. candidate[1], 'B2', candidate)
        end
      end
    else
      num = num/2
      for n = 1,num+1 do
        t:addNode('B' .. n, 'A', 0)
      end
    
      buildTree(num, candidates)
    end
  end
end
