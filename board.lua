-- nil empty,  0 black, 1 white

--MATRICE[col][row]
board = {}

directions = {
  up = {0, -1},
  down = {0 , 1},
  right = {1 , 0},
  left = {-1, 0 },
  rup = {1, -1},
  lup = {-1, -1},
  rdown = {1, 1},
  ldown = {-1, 1}
}

--square candidates
candidates = {}

--initialize board (all boards)
function board.initialize(origin_x, origin_y, dimension, columns)
  --square
  x = origin_x
  y = origin_y
  dim = dimension
  col = columns
  
  --circle (it represent the piece)
  circle_x = x + dimension/2
  circle_y = y + dimension/2
  circleDim = dim/2.5
end


--create board with 4 central pieces (matrix[column][row])
--N B
--B N
function board.create(self)
  for i=1,dim do
    self[i] = {} --rows
  end
    self[4][4] = 0
    self[5][5] = 0
    self[5][4] = 1
    self[4][5] = 1
    return self
end
--draw the board
function board.draw(self)
  local loc_x = x;
  local loc_y = y;

    for i=1, 8 do
      for j=1, 8 do
        love.graphics.rectangle('line', loc_x, loc_y, dim, dim)  
        loc_y = loc_y + dim
      end
        loc_x = loc_x + dim
        loc_y = y
    end
end

--add pieces to the board (refactored)
function board.fill(self)
  for i=1, col do --columns (x)
    for j= 1, col do --rows (y)
      if self[i][j] == 0 then --black
        love.graphics.circle('line', circle_x + dim*(i-1), circle_y + dim*(j-1), circleDim)
      elseif self[i][j] == 1 then --white
        love.graphics.circle('fill', circle_x + dim*(i-1), circle_y + dim*(j-1), circleDim)
      end
    end
  end
end
-- con ipairs ordine è assicurato (utilizzato quando index sono number), con pairs non è assicurato
function board.searchSquares(self, color)
  candidates = {} --vuoto
  
  for i=1, col do --cols (x)
    for j= 1, col do --rows (y)
      if self[i][j] == color then
        for k, v in pairs(directions) do
          board:searchForDirection(i, j, color, k)
        end
      end
    end
  end
end

function board.searchForDirection(self, cell_x, cell_y, color, dir)
  local oppositeColor = (color + 1) % 2
  local isValid = false;

  cell_x = cell_x + directions[dir][1] 
  cell_y = cell_y + directions[dir][2]
  if cell_x > 8 or cell_x < 1 or cell_y > 8 or cell_y < 1 then return false end
  
  while self[cell_x][cell_y] == oppositeColor do
  isValid = true
  
  cell_x = cell_x + directions[dir][1] 
  cell_y = cell_y + directions[dir][2]
  
  --print(cell_y, cell_x)
  
  --controllo che non sia fuori la board (basta che una delle condizioni sia vera)
    if cell_x > 8 or cell_x < 1 or cell_y > 8 or cell_y <1 then 
      return false
    end
  end
  
  if isValid== true then
      if self[cell_x][cell_y] == nil and cell_y <= 8 and cell_x <=8 then
            table.insert(candidates, {cell_x, cell_y})
      end
    end
end

--draw candidates on the board
function board:drawCandidates(self, color)
  --red color if black, green color if white
  if color == 0 then love.graphics.setColor(1,0,0)
  else love.graphics.setColor(0,1,0) end
  for _, v in ipairs(candidates) do
   love.graphics.rectangle('line', x + 10 + dim*(v[1]-1), y + 10 + dim*(v[2]-1), dim -20, dim-20)  
  end
  love.graphics.setColor(1,1,1) --set color to white (default)
end


function printCandidates(table)
  for _, v  in ipairs(table) do
    print("x=",v[1],"y=",v[2])
  end
end

--le coordinate sono {x, y} aka {columns, row}
function board.addPiece(self, coor, color)
  self[coor[1]][coor[2]] = color
  board:revertPieces(coor, color)
end


function board.isCandidate(self, coor)
  for k, v in ipairs(candidates) do
    if (v[1] == coor[1] and v[2] == coor[2]) then return true end
  end
  return false
end

--coor = coordinata square dove si vuole inserire il pezzo
function board.revertPieces (self, coor, color)
  for k, v in pairs(directions) do
    print(k)
    board:revertForDirection(coor[1], coor[2], color, v)
  end
end

function board.revertForDirection(self, cell_x, cell_y, color, dir)
  local oppositeColor = (color + 1) % 2
  local toRevert = {}
  cell_x = cell_x + dir[1]
  cell_y = cell_y + dir[2] 

  if cell_x > 8 or cell_x < 1 or cell_y > 8 or cell_y < 1 then print("a") return false end

  while self[cell_x][cell_y] == oppositeColor do
    table.insert(toRevert, {cell_x, cell_y})
    --passo alla square successiva in quella direzione
    cell_x = cell_x + dir[1]
    cell_y = cell_y + dir[2]
    if cell_x > 8 or cell_x < 1 or cell_y > 8 or cell_y < 1 then print("a") return false end
  end
  if self[cell_x][cell_y] == color then
    for _ , k in ipairs(toRevert) do
      print("halo", k[1], k[2])
      self[k[1]][k[2]] = color
    end
  end
end
