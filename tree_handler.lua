local PATH = (...):gsub('tree_handler$','')
local class = require (PATH .. 'class')

local tree = class()

function tree:initialize()
  self.nodes = {}
end

function tree:addNode(name, parent, value)
  assert(not self.nodes[name], 'node already exist')
  local node = {
    name = name, value = value,
    parent = parent, children = {}
  }
  if parent then
      parent = self:getNode(parent)
      assert(parent, 'parent not found')
      table.insert(parent.children, node)
  end
  if not self.head then self.head = node end
  table.insert(parent.children, node)
end

function tree:getNode(name)
  for i, node in ipairs(self.nodes) do
    if node.name == name then return node end
  end
end

function tree:isLeaf(node)
  return #node.children == 0
end

function tree:heuristic(node)
  return node.value
end

function tree:children(node)
  return node.children
end

return tree