require("board")
local minimax = require 'minimax'
local tree = require 'tree'
local t = tree ()
local name = 65
local nodesNumber = {}
local standardDepth = 2
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
  b = board:new()
  b:initialize()
  print("Current Player",current_player)
  local candidates = b:searchSquares(current_player)
  nodesNumber[standardDepth] = table.getn(candidates)
  
  if table.getn(candidates) > 0 then
    --calculateFutureScore(candidates, current_player)
    t:addNode(string.char(name),nil,0)
    name = name+1
    buildTree(t:getNode(string.char(name-1)), standardDepth, current_player, candidates, 0)
    t:getAllNodes()
    
  end
end

function love.update()

end

function love.draw()
  b:draw()
  b:fill()
  if drawCandidates then b:drawCandidates(current_player) end
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
    if b:isCandidate(selected) then
      local pieces
      b:addPiece(selected, current_player)
      current_player = (current_player + 1) % 2
      print("Current Player",current_player)
      local candidates = b:searchSquares(current_player)
      nodesNumber[standardDepth] = table.getn(candidates)
      if table.getn(candidates) > 0 then
        t = tree ()
        name = 65
        t:addNode(string.char(name),nil,0)
        name = name + 1
        buildTree(t:getNode(string.char(name-1)), standardDepth, current_player, candidates, 0)
        t:getAllNodes()
        --print("Node to choose",minimax(t:getNode('A'),t,depth,current_player))
      end
     end
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

function drawCounter()
  local pieces = b:countPieces()
  love.graphics.print(("Black pieces: " .. pieces[1]), 50 + 60 * 10, 50)
  love.graphics.print(("White pieces: " .. pieces[2]), 50 + 60 * 10, 70)
end

function drawTurn()
    love.graphics.print((players_colors[current_player + 1] .. ' PLAYER TURN'), 50 + 60 * 10, 100)
end

function showShortcutsInfo()
    love.graphics.print('S: show/unshow possible moves', 50 + 60 * 10, 50 + 60 * 8)
end

-- Build Tree
function buildTree(node, depth, color, candidates, startIndex)
  
  for n, candidate in ipairs(candidates) do
    if depth ~= 1 then
      t:addNode(string.char(name) .. (n+startIndex), node.name, 0)
    else
      t:addNode(string.char(name) .. (n+startIndex), node.name, candidate)
    end
    
    print(t:getAllNodes())
    
    if depth-1 > 0 and n+startIndex ~= 1 then
      calculateFutureScore(string.char(name) .. (n+startIndex), candidate, color, depth, nodesNumber[depth-1])
      name = name - 1
    elseif n+startIndex == 1 and depth-1 ~= 0 then
      print("Current n",n)
      calculateFutureScore(string.char(name) .. n, candidate, color, depth, 0)
      name = name - 1
    end
  end
end

function calculateFutureScore(nodesName, candidate, color, depth, startIndex)
  depth = depth - 1
  name = name + 1
  local tempBoard = table.shallow_copy(b)
  
  tempBoard:addPiece({candidate[1],candidate[2]}, color)
  local candidates = tempBoard:searchSquares((color+1)%2)
  
  if nodesNumber[depth] ~= nil then
    nodesNumber[depth] = nodesNumber[depth]+table.getn(candidates)
    
  else
    nodesNumber[depth] = table.getn(candidates)
  end
  
  buildTree(t:getNode(nodesName), depth, (color+1)%2, candidates, startIndex)
end

function table.shallow_copy(t)
  local t2 = board:new()
  t2:initialize()
  for i=1, 8 do
    for j=1, 8 do
      --print("T2",t2[i][j])
      --print("T",t[i][j])
      t2[1][i][j] = t[1][i][j]
    end
  end
  return t2
end
