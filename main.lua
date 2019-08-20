require("board")
local minimax = require 'minimax'

local total, pass = 0, 0

local function dec(str, len)
  return #str < len
     and str .. (('.'):rep(len-#str))
      or str:sub(1,len)
end

local function run(message, f)
  total = total + 1
  local ok, err = pcall(f)
  if ok then pass = pass + 1 end
  local status = ok and 'PASSED' or 'FAILED'
  print(('%02d. %68s: %s'):format(total, dec(message,68), status))
end

run('Testing Minimax', function()
    local tree = require 'tree_handler'
    
    local t = tree()
    t:addNode('A',nil,8)
    t:addNode('B1','A',3)
    t:addNode('B2','A',4)
    t:addNode('B3','A',5)
    
    t:addNode('C1','B1',4)
    t:addNode('C2','B1',12)
    t:addNode('C3','B1',7)
    
    t:addNode('C4','B2',10)
    t:addNode('C5','B2',5)
    t:addNode('C6','B2',6)
    
    t:addNode('C7','B3',1)
    t:addNode('C8','B3',2)
    t:addNode('C9','B3',3)
    
    
    local head = t:getNode('A')
    assert(minimax(head, t, 3) == 5)
  end)

print(('-'):rep(80))
print(('Total : %02d - Failed : %02d - Success: %.2f %%')
  :format(total, pass, total-pass, (pass*100/total)))

function love.load()
  love.window.maximize()
  origin_x = 50;
  origin_y = 50;
  dim = 70;
  -- x, y, square dimension, number of columns
  board.initialize(origin_x, origin_y, dim, 8)
  board = board:create()  
end

function love.update()

end

function love.draw()
  board:draw()
  board:fill()
end
