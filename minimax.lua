-- internal recursive Minimax search
local function minimax(tree, node, depth, maximize, current_player)
  if depth == 0 or tree:isLeaf(node) then
    return tree:heuristic(node)[3][current_player+1]
  end
  local children = tree:children(node)
  if maximize then
    local bestScore = -math.huge
    for i, child in ipairs(children) do
      bScore = math.max(bestScore, minimax(tree, child, depth - 1, false, current_player))
      if tree:parent(child) == 'A' then
        if bestScore < bScore then
          tree:getNode(tree:parent(child)).value = child.value
        end
      end
      bestScore = bScore
    end
    return bestScore
  else
    local bestScore = math.huge
    for i, child in ipairs(children) do
      bScore = math.min(bestScore, minimax(tree, child, depth - 1, true, current_player))
      if tree:parent(child) == 'A' then
        if bestScore > bScore then
          tree:getNode(tree:parent(child)).value = child.value
        end
      end
      bestScore = bScore
    end
    return bestScore
  end
end

-- Performs Minimax search
-- node : the node from where to start the search
-- tree : the search tree
-- depth : the max depth
return function(node, tree, depth, current_player)
  return minimax(tree, node, depth, true, current_player)
end


