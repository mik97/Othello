require("board")
require("config")
require("mobdebug").on()
require("mobdebug").coro()
require("mobdebug").start()

local minimax = require 'minimax'
local tree = require 'tree'
local t = tree ()
local name = 65
local nodesNumber = {}
local score
local standardDepth = 2

local finished = false
local selected

local player_types = {'PC', 'HUMAN'}
local players_colors = {'BLACK', 'WHITE'}

local players
local turnHandler

function love.load()
  love.window.maximize()
  drawCandidates = true
  
  current_player = 0
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  
 
  -- selected = {x, y}: x is the column and y the row
  selected = {1,1}
  
  config:set(origin_x, origin_y, dim, 8)
  
  b = board:new()
  
  b:initialize()
  
  players = {humanTurnHandler(), humanTurnHandler()}
  
  startGame()
end

function love.update()

end

function love.draw()
  b:draw()
  b:drawPieces()
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
  if key == "return" and player_types[current_player+1] == 'HUMAN' then
    if b:isCandidate(selected) then
     coroutine.resume(players[current_player+1])
     coroutine.resume(turnHandler)
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
function buildTree(node, depth, tempBoard, color, candidates, startIndex)
  
  for n, candidate in ipairs(candidates) do
    if depth ~= 1 then
      t:addNode(string.char(name) .. (n+startIndex), node.name, candidate)
    else
      table.insert(candidate, score)
      t:addNode(string.char(name) .. (n+startIndex), node.name, candidate)
    end
    
    if depth-1 > 0 and n+startIndex ~= 1 then
      calculateFutureScore(string.char(name) .. (n+startIndex), candidate, color, depth, tempBoard, nodesNumber[depth-1])
      name = name - 1
    elseif n+startIndex == 1 and depth-1 ~= 0 then
      calculateFutureScore(string.char(name) .. n, candidate, color, depth, tempBoard, 0)
      name = name - 1
    end
  end
end

function calculateFutureScore(nodesName, candidate, color, depth, tempBoard, startIndex)
  depth = depth - 1
  name = name + 1
  
  local tBoard = table.shallow_copy(tempBoard)
  tBoard:addPiece({candidate[1],candidate[2]}, color)
  if depth == 1 then
    score = tBoard:countPieces()
    candidate[3] = score
  end
  
  candidates = tBoard:searchSquares((color+1)%2)
  
  if depth == 1 then
    print("Candidate",table.getn(candidates))
  end
  
  if nodesNumber[depth] ~= nil then
    nodesNumber[depth] = nodesNumber[depth]+table.getn(candidates)
    
  else
    nodesNumber[depth] = table.getn(candidates)
  end
  
  buildTree(t:getNode(nodesName), depth, tBoard, (color+1)%2, candidates, startIndex)
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

function startGame()
  --coroutine.resume(players[1]) --inizia il nero
  turnHandler = coroutine.create(
    function()
      while finished ~= true do
      --procedo creando una routine in base al tipo
        if player_types[current_player+1] == 'HUMAN' then
          players[current_player+1] = humanTurnHandler()
          coroutine.resume(players[current_player+1]) --quando si stoppa si ferma anche il turno
          coroutine.yield()
        else
          players[current_player+1] = pcTurnHandler()
          coroutine.resume(players[current_player+1])
        end
        
      end
    end)
    coroutine.resume(turnHandler)
end

function pcTurnHandler()
    return coroutine.create(
      function()
        local candidates = b:searchSquares(current_player)
        if table.getn(candidates) > 0 then
          print('i am a robot')
          nodesNumber[standardDepth] = table.getn(candidates)
          t = tree ()
          name = 65
          t:addNode(string.char(name),nil,0)
          name = name + 1
          local tempBoard = table.shallow_copy(b)
          buildTree(t:getNode(string.char(name-1)), standardDepth, tempBoard, current_player, candidates, 0)
          --t:getAllNodes()
          minimax(t:getNode('A'), t, standardDepth, current_player)
          print("\nNode to choose x:\n",t:getNode('A').value[1],"y:",t:getNode('A').value[2])
          b:addPiece({t:getNode('A').value[1], t:getNode('A').value[2] },  current_player)
          nodesNumber={}
          current_player = (current_player+1) % 2
        else
        finished = true
      end
      end
      )
  end

function humanTurnHandler()
    return coroutine.create(
      function()
        local candidates = b:searchSquares(current_player)
        if table.getn(candidates) > 0 then
        print('i am a human')
        coroutine.yield()
        b:addPiece(selected, current_player)
        current_player = (current_player+1)%2
        else
        finished = true
      end
    end )
end