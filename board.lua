-- nil empty, 0 white, 1 black
board = {}

--initialize board (all boards)
function board.initialize(origin_x, origin_y, dimension, columns)
  --square
  x = origin_x;
  y = origin_y;
  dim = dimension
  col = columns
  
  --circle (it represent the piece)
  circle_x = x + dimension/2
  circle_y = y + dimension/2
  circleDim = dim/2.5
end

--create board with 4 central pieces
--N B
--B N
function board.create(self)
  for i=1,dim do
    self[i] = {}
  end
    self[4][4] = 1
    self[5][5] = 1
    self[4][5] = 0
    self[5][4] = 0
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

--add pieces to the board
function board.fill(self)
  for i=1,dim do
    for j=1,dim do
      if self[i][j] == 0 then
          love.graphics.circle('fill', circle_x + dim*(i-1), circle_y + dim*(j-1), circleDim)
      elseif self[i][j] == 1 then
          love.graphics.circle('line', circle_x + dim*(i-1), circle_y + dim*(j-1), circleDim)
      end
    end
  end
end
  
