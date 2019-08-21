require("board")
local minimax = require 'minimax'
local tree = require 'tree'

run('Testing Minimax', function()

  local t = tree()
  t:addNode('A',nil,0)
  t:addNode('B1','A',0)
  t:addNode('B2','A',0)
  t:addNode('B3','A',0)

  t:addNode('C1','B1',4)
  t:addNode('C2','B1',12)
  t:addNode('C3','B1',7)

  t:addNode('C4','B2',10)
  t:addNode('C5','B2',5)
  t:addNode('C6','B2',6)

  t:addNode('C7','B3',1)
  t:addNode('C8','B3',2)
  t:addNode('C9','B3',3)

  local head = t:getNode('A')
  assert(minimax(head, t, 3) == 5)
end)

print(('-'):rep(80))
print(('Total : %02d: Pass: %02d - Failed : %02d - Success: %.2f %%')
  :format(total, pass, total-pass, (pass*100/total)))

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
      board:searchSquares(current_player)
     end
  end
  
end

function drawSelected()
  love.graphics.setColor(0,1,1)
  love.graphics.rectangle('line', origin_x + 20 + dim*(selected[1]-1), origin_y + 20 + dim*(selected[2]-1), dim - 40, dim - 40)  
  love.graphics.setColor(1,1,1) --set color to white (default)
end