require("board")
require("config")

local minimax = require 'minimax'
local tree = require 'tree'
local t = tree ()
local name = 65
local nodesNumber = {}
local score
local standardDepth = 3

local finished = false
local selected

player_types = {'HUMAN', 'PC'}
players_colors = {'BLACK', 'WHITE'}

local players = {}

local turnHandler

function parseArgs(args)
  for i , arg in pairs(args) do
    if arg == "-debug"  then require("mobdebug").on(); require("mobdebug").coro(); require("mobdebug").start()
    elseif arg == "-PCvPC"  then
      player_types = {'PC', 'PC'}
    elseif arg == "-PLvPL"  then
      player_types = {'HUMAN', 'HUMAN'}
    elseif arg == "-PLvPC" or arg == "-PCvPL" then
      player_types = {'HUMAN', 'PC'}
    elseif arg == "-d" then
      standardDepth = tonumber(args[i+1])
      if standardDepth < 2 then exit('Minimum Difficult: 2') end
      if standardDepth > 3 then print('WARNING: Computation could be very slow') end
    end
  end
end

function exit(exitError)
  print(exitError or '')
  os.exit(exitError and -1 or 0)
end

function love.load(args)
  parseArgs(args)
  print(unpack(player_types))
  love.window.maximize()
  drawCandidates = true
  
  current_player = 0
  origin_x = 50
  origin_y = 50
  
  dim =70
 
  -- selected = {x, y}: x is the column and y the row
  selected = {1,1}
  
  config:set(origin_x, origin_y, dim, 8)
  
  b = board:new()
  b:initialize()
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
gameStarted = false
function love.keypressed(key, scancode, isrepeat)
  if gameStarted then
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
      b:addPiece(selected, current_player)
      coroutine.resume(turnHandler)    
      end
    end
    
    if player_types[1] == 'HUMAN' and player_types[current_player+1] == 'PC' or player_types[1] == "PC" and key == "a" then
        b:addPiece(chosen, current_player)
        coroutine.resume(turnHandler)
    end
    
    if key == "s" then
      drawCandidates = not drawCandidates 
    end
  end
  if key == "g" then
    gameStarted = true
    startGame()
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
  if finished == false then
    love.graphics.print((players_colors[current_player + 1] .. ' PLAYER TURN'), 50 + 60 * 10, 100)
  else
    local pieces = b:countPieces()
    if pieces[1] == pieces[2] then
      love.graphics.print('DRAW', 50 + 60 * 10, 100)
    else
      local winners
      if pieces[1] > pieces[2] then
        winner = players_colors[1] 
      else
        winner = players_colors[2]
      end
      love.graphics.print((winner .. ' PLAYER WINS'), 50 + 60 * 10, 100)
      started = false
    end
  end
end

function showShortcutsInfo()
  love.graphics.print('G: start game', 50 + 60 * 10, 50 + 60 * 7.5)
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
    --print("Candidate",table.getn(candidates))
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
      t2[1][i][j] = t[1][i][j]
    end
  end
  return t2
end

function startGame()
  turnHandler = coroutine.create(
    function()
      while finished ~= true do
        if player_types[current_player+1] == 'HUMAN' then
          players[current_player+1] = humanTurnHandler()
          coroutine.resume(players[current_player+1])
        else
          players[current_player+1] = pcTurnHandler()
          coroutine.resume(players[current_player+1])
        end
        coroutine.yield()
        current_player = (current_player+1) % 2
      end
    end)
  coroutine.resume(turnHandler)
end

function pcTurnHandler()
    return coroutine.create(
      function()
        local candidates = b:searchSquares(current_player)
        
        if table.getn(candidates) > 1 then
          nodesNumber[standardDepth] = table.getn(candidates)
          name = 65          
          t = tree ()
          t:addNode(string.char(name),nil,0)
          name = name + 1
          local tempBoard = table.shallow_copy(b)
          buildTree(t:getNode(string.char(name-1)), standardDepth, tempBoard, current_player, candidates, 0)
          minimax(t:getNode('A'), t, standardDepth, current_player)
          chosen = {t:getNode('A').value[1], t:getNode('A').value[2] }
          nodesNumber={}
        elseif table.getn(candidates) == 1 then
          chosen = {candidates[1][1] , candidates[1][2] }
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
        else
          finished = true
      end
    end)
end