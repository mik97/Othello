require("config")

-- nil empty,  0 black, 1 white

--matrix[col][row]
board = {}

--candidate squares
candidates = {}

squares = {}

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
  for i=1,config.dim do
    self[i] = {} --rows
  end
    self[4][4] = 0
    self[5][5] = 0
    self[5][4] = 1
    self[4][5] = 1
    return self
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
    if self[coor[1]][coor[2]]~= nil then --black
        love.graphics.circle(graphicalColor[self[coor[1]][coor[2]] + 1], config.circle_x + config.dim*(coor[1]-1), config.circle_y + config.dim*(coor[2]-1), config.circleDim)
      end
    end
end


-- candidate square searching
function board:searchSquares(color)
  candidates = {} --vuoto
  
  for _, coor in ipairs(squares) do
    if self[coor[1]][coor[2]] == color then
      for k, v in pairs(directions) do
      -- pass the next square for direction
      board:searchForDirection(coor[1] + directions[k][1], coor[2] + directions[k][2], color, k)
      end
    end
  end
end



function board:searchForDirection( cell_x, cell_y, color, dir)
  local oppositeColor = (color + 1) % 2
  local isValid = false

  while checkSquare(cell_x, cell_y) and (self[cell_x][cell_y] == oppositeColor) do
    isValid = true  
    cell_x = cell_x + directions[dir][1] 
    cell_y = cell_y + directions[dir][2]
  end
  
  if isValid == true then
    if self[cell_x][cell_y] == nil and checkSquare(cell_x, cell_y) then
      if contains(candidates, {cell_x, cell_y}) == false then
        table.insert(candidates, {cell_x, cell_y})
      end
    end
  end
end



-- draw candidate squares on the board

function board:drawCandidates(color)
  --black: red color, white: green color
  if color == 0 then love.graphics.setColor(1,0,0) else love.graphics.setColor(0,1,0)
  end

  for _, v in ipairs(candidates) do
  love.graphics.rectangle('line', config.x + 10 + config.dim*(v[1]-1), config.y + 10 + config.dim*(v[2]-1), config.dim -20, config.dim-20)  
  end
  
  love.graphics.setColor(1,1,1) --set color to white (default)
end

--coordinates are {x, y} aka {columns, row}

function board:addPiece( coor, color)
  self[coor[1]][coor[2]] = color
  board:revertPieces(coor, color)
end


function board:isCandidate(coor)
  for k, v in ipairs(candidates) do
    if (v[1] == coor[1] and v[2] == coor[2]) then return true end
  end
  return false
end


--coor = coordinata della square dove si vuole inserire il pezzo

function board:revertPieces (coor, color)
  for k, v in pairs(directions) do
    board:revertForDirection(coor[1]+ v[1], coor[2]+ v[2], color, v)
  end
end


function board:revertForDirection( cell_x, cell_y, color, dir)
  local oppositeColor = (color + 1) % 2
  local toRevert = {}
  
  while checkSquare(cell_x, cell_y) and (self[cell_x][cell_y] == oppositeColor) do
   table.insert(toRevert, {cell_x, cell_y})
    -- calculate position next square
    cell_x = cell_x + dir[1]
    cell_y = cell_y + dir[2]
  end

  if checkSquare(cell_x, cell_y) and self[cell_x][cell_y] == color then
    for _ , k in ipairs(toRevert) do
      self[k[1]][k[2]] = color
    end
  end
end

function board:countPieces()
  local pieces= {0, 0}
  for i=1, config.col do
    for j=1, config.col do
      if self[i][j] ~= nil then
        pieces[self[i][j] + 1] =  pieces[self[i][j] + 1] + 1
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


