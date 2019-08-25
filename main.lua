require("board")
local minimax = require 'minimax'
local tree = require 'tree'
local t = tree ()
require("config")

function love.load()
  love.window.maximize()
  drawCandidates = true
  
  current_player = 0
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  
  players_colors = {'BLACK', 'WHITE'}
  -- selected = {x, y}: x is the column and y the row
  selected = {1,1}
  
  config:set(origin_x, origin_y, dim, 8)
  board = board:new()
  board:initialize()
  
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
  if drawCandidates then board:drawCandidates(current_player) end
  drawSelected()
  drawCounter()
  drawTurn()
  showShortcutsInfo()
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
      local pieces
      board:addPiece(selected, current_player)
      current_player = (current_player + 1) % 2
      local candidates = board:searchSquares(current_player)
      t = tree ()
      t:addNode('A',nil,0)
      buildTree(table.getn(candidates), candidates)
     end
     print(t:getAllNodes())
  end
  
  if key == "s" then
    drawCandidates = not drawCandidates 
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

function drawCounter()
  local pieces = board:countPieces()
  love.graphics.print(("Black pieces: " .. pieces[1]), 50 + 60 * 10, 50)
  love.graphics.print(("White pieces: " .. pieces[2]), 50 + 60 * 10, 70)
end

function drawTurn()
    love.graphics.print((players_colors[current_player + 1] .. ' PLAYER TURN'), 50 + 60 * 10, 100)
end

function showShortcutsInfo()
    love.graphics.print('S: show/unshow possible moves', 50 + 60 * 10, 50 + 60 * 8)
end
