require("board")
local minimax = require 'minimax'
local tree = require 'tree'
local t = tree ()
local name = 65
local nodesNumber = {}
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
  local candidates = b:searchSquares(current_player)
  if table.getn(candidates) > 0 then
    calculateFutureScore(candidates, current_player)
    t:addNode(string.char(name),nil,0)
    name = name + 1
    calculateNodes(table.getn(candidates),1)
    local depth = table.getn(nodesNumber) + 2
    buildTree(candidates, table.getn(nodesNumber))
    print(t:getAllNodes())
    print("Node to choose",minimax(t:getNode('A'),t,depth,current_player))
    resetNodesNumber()
    print("NodesNumber",table.getn(nodesNumber))
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
      local candidates = b:searchSquares(current_player)
      if table.getn(candidates) > 0 then
        calculateFutureScore(candidates, current_player)
        t = tree ()
        name = 65
        t:addNode(string.char(name),nil,0)
        name = name + 1
        calculateNodes(table.getn(candidates),1)
        local depth = table.getn(nodesNumber) + 2
        buildTree(candidates, table.getn(nodesNumber))
        print(t:getAllNodes())
        if(table.getn(candidates) == 2) then
          print("Node to choose",minimax(t:getNode('A'),t,depth,current_player))
        else
          print("Node to choose",minimax(t:getNode('A'),t,depth,current_player))
        end
        resetNodesNumber()
        print("NodesNumber",table.getn(nodesNumber))
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

function buildTree(candidates, numNodes)
  local nIndex = 1
  if table.getn(candidates) == nodesNumber[numNodes] then
    for n,candidate in ipairs(candidates) do
       t:addNode(string.char(name) .. n, string.char(name-1), candidate)
    end
  else
    for n=1, nodesNumber[numNodes] do
      if(name-1 == 65) then
        t:addNode(string.char(name) .. n, string.char(name-1), 0)
      else
        t:addNode(string.char(name) .. n, string.char(name-1) .. nIndex, 0)
        if n%2 == 0 and n > 1 then
          nIndex = nIndex+1
        end
      end
    end
    
    name = name + 1
    print("NumNodes",numNodes)
    if numNodes-1 > 0 then
      numNodes = numNodes-1
      buildTree(candidates, numNodes)
    else
      nIndex = 1
      for n, candidate in ipairs(candidates) do
        t:addNode(string.char(name) .. n, string.char(name-1)..nIndex, candidate)
          if n%2 == 0 and n > 1 then
              nIndex = nIndex+1
          end
      end
    end
  end
end

function calculateNodes(num, index)
  local num1,num2 = math.modf(num/2)
  local num3 = (num1 + (num2 > 0.5 and 1 or 0))
  local nodeTotal = num3 + num%2
  
  if nodeTotal ~= 1 then
    nodesNumber[index] = nodeTotal
    calculateNodes(nodeTotal,index+1)
  end
end

function resetNodesNumber()
  for i=2, table.getn(nodesNumber) do
    table.remove(nodesNumber, i)
  end
end

function calculateFutureScore(candidates, color)
  print(table.getn(candidates))
  for i=1, table.getn(candidates) do
    local tempBoard = table.shallow_copy(b)
    print("Candidate ",candidates[i][1],candidates[i][2])
    tempBoard:addPiece({candidates[i][1],candidates[i][2]}, color)
    local score = tempBoard:countPieces()
    print("ScoreN", score[1])
    print("ScoreB", score[2])
    candidates[i][3] = score
    print("Candidate score: ", candidates[i][3][color+1],"\n\n")
    tempBoard:removePiece({candidates[i][1],candidates[i][2]}, (color+1)%2)
  end
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
