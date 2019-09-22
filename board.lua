require("config")

-- nil empty,  0 black, 1 white

--matrix[col][row]
board = {}

--squares
squares = {}

--toRevert = {}

function board:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
  end


--create board with 4 central pieces 
--N B
--B N
function board:initialize()
  getSquares()
  local gameboard = createBoard()
  local toRevert = {}
  local candidates = {}
  table.insert(self, gameboard)
  table.insert(self, toRevert)
  table.insert(self, candidates)
  return self
end

function createBoard()
local b = {}
  for i=1,config.dim do
    b[i] = {} --rows
  end
    b[4][4] = 0
    b[5][5] = 0
    b[5][4] = 1
    b[4][5] = 1
    return b
end

--draw the board
function board:draw()
  local loc_x = config.x;
  local loc_y = config.y;

    for i=1, 8 do
      for j=1, 8 do
        love.graphics.rectangle('line', loc_x, loc_y, config.dim, config.dim)  
        loc_y = loc_y + config.dim
      end
        loc_x = loc_x + config.dim
        loc_y = config.y
    end
end



--draw pieces to the board
function board:fill()
  local graphicalColor = {'line', 'fill'}
  
  for _, coor in ipairs(squares) do
    if self[1][coor[1]][coor[2]]~= nil then --black
        love.graphics.circle(graphicalColor[self[1][coor[1]][coor[2]] + 1], config.circle_x + config.dim*(coor[1]-1), config.circle_y + config.dim*(coor[2]-1), config.circleDim)
      end
    end
end


-- candidate square searching
function board:searchSquares(color)
  self[3] = {} --vuoto
  
  for _, coor in ipairs(squares) do
    if self[1][coor[1]][coor[2]] == color then
      for _, v in pairs(directions) do
      -- pass the next square for direction
      self:searchForDirection(coor[1] + v[1], coor[2] + v[2], color, v)
      end
    end
  end
  
  return self[3]
end

function board:searchForDirection( cell_x, cell_y, color, dir)
  local oppositeColor = (color + 1) % 2
  local isValid = false

  while checkSquare(cell_x, cell_y) and (self[1][cell_x][cell_y] == oppositeColor) do
    isValid = true  
    cell_x = cell_x + dir[1] 
    cell_y = cell_y + dir[2]
  end
  
  if isValid == true then
    if checkSquare(cell_x, cell_y) and self[1][cell_x][cell_y] == nil then
      if contains(self[3], {cell_x, cell_y}) == false then
        table.insert(self[3], {cell_x, cell_y})
      end
    end
  end
end

-- draw candidate squares on the board

function board:drawCandidates(color)
  --black: red color, white: green color
  if color == 0 then love.graphics.setColor(1,0,0) else love.graphics.setColor(0,1,0)
  end

  for _, v in ipairs(self[3]) do
  love.graphics.rectangle('line', config.x + 10 + config.dim*(v[1]-1), config.y + 10 + config.dim*(v[2]-1), config.dim -20, config.dim-20)  
  end
  
  love.graphics.setColor(1,1,1) --set color to white (default)
end

--coordinates are {x, y} aka {columns, row}
function board:addPiece( coor, color)
  self[1][coor[1]][coor[2]] = color
  --for _ , k in ipairs(self[2]) do
  --    print("REVERT",k[1],k[2])
  --end
  self[2]={}
  self:revertPieces(coor, color)
end

function board:removePiece( coor, color)
  self[1][coor[1]][coor[2]] = nil
  
  for _,k in ipairs(self[2]) do
    self[1][k[1]][k[2]] = color
  end
  
end

function board:isCandidate(coor)
  for k, v in ipairs(self[3]) do
    if (v[1] == coor[1] and v[2] == coor[2]) then return true end
  end
  return false
end


--coor = coordinata della square dove si vuole inserire il pezzo

function board:revertPieces (coor, color)
  
  for k, v in pairs(directions) do
    self:revertForDirection(coor[1]+ v[1], coor[2]+ v[2], color, v)
  end
end

function board:revertForDirection( cell_x, cell_y, color, dir)
  local oppositeColor = (color + 1) % 2
  self[2]={}
  
  while checkSquare(cell_x, cell_y) and (self[1][cell_x][cell_y] == oppositeColor) do
   table.insert(self[2], {cell_x, cell_y})
    -- calculate position next square
    cell_x = cell_x + dir[1]
    cell_y = cell_y + dir[2]
  end

  if checkSquare(cell_x, cell_y) and self[1][cell_x][cell_y] == color then
    for _ , k in ipairs(self[2]) do
      self[1][k[1]][k[2]] = color
    end
  end
end

function board:countPieces()
  local pieces= {0, 0}   -- [1] = black, [2] = white
  for i=1, config.col do
    for j=1, config.col do
      if self[1][i][j] ~= nil then
        pieces[self[1][i][j] + 1] =  pieces[self[1][i][j] + 1] + 1
      end
    end
  end
  return pieces
end

function getSquares()
  for i=1, config.col do --cols (x)
      for j= 1, config.col do --rows (y)
        table.insert(squares, {i, j})
      end
  end
end


function contains(tabl, element)
  for _, value in ipairs(tabl) do
    if value[1] == element[1] and value[2] == element[2] then
      return true
    end
  end
  return false
end


function checkSquare(cell_x, cell_y)
  return not (cell_x > 8 or cell_x < 1 or cell_y > 8 or cell_y < 1)
end

