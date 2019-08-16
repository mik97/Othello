-- nil empty, 0 white, 1 black

-- if the two indices are integers, you can multiply the first one by a constant and then add the second index.
--constant = column number and row number
constant = 8;

board = {}
--initialize board with 4 central pieces
--N B
--B N

function board.create(self)
  self[4 * constant + 4] = 1
  self[5 * constant + 5] = 1
  self[4 * constant + 5] = 0
  self[5 * constant + 4] = 0
end

--draw the board
function board.draw(self, x, or_y, dim)
  local y = or_y;
    for i=1, 8 do
      for j=1, 8 do
        love.graphics.rectangle('line', x, y, dim, dim)  
        y = y + dim
      end
        x = x + dim
        y = or_y
    end
end

  