local PATH = (...):gsub('tree$','')
local class = require (PATH .. 'class')

local tree = class ()

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
  table.insert(self.nodes, node)
end

-- Get the node by its name
function tree:getNode(name)
  for i, node in ipairs(self.nodes) do
    if node.name == name then return node end
  end
end

function getChildParent(name)
  for i, node in ipairs(self.nodes) do
    for i, child in ipairs(node.children) do
      if child.name == name then return child end
    end
  end
end

-- Checks if a given node is terminal (leaf) in the search tree
function tree:isLeaf(node)
  return #node.children == 0
end

-- Returns the node value
function tree:heuristic(node)
  return node.value
end

-- Returns the node's children
function tree:children(node)
  return node.children
end

-- Returns the node's parent
function tree:parent(node)
  return node.parent
end

function tree:getAllNodes()
  for i, node in ipairs(self.nodes) do
    for i, child in ipairs(node.children) do
      if child.value ~= 0 then
        print("Name --> ", node.name, " Child --> ", child.name," Value --> x ", child.value[1], " y ", child.value[2])
      else
        print("Name --> ", node.name, " Child --> ", child.name," Value -->", child.value)
      end
    end
  end
end

function tree:isEmpty()
  if self.nodes == {} then
    return true
  else
    return false
  end
  
end

return tree
