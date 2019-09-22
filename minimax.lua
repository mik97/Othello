-- Minimax search implementation
-- See: http://en.wikipedia.org/wiki/Minimax

-- Internal recursive Minimax search
local function minimax(tree, node, depth, maximize, current_player, bestScore)
  if depth == 0 or tree:isLeaf(node) then
    return tree:heuristic(node)[3][current_player+1]
  end
  local children = tree:children(node)
  if maximize then
    bestScore = -math.huge
    for i, child in ipairs(children) do
      bestScore = math.max(bestScore, minimax(tree, child, depth - 1, false, current_player))
    end
    return bestScore
  else
    bestScore = math.huge
    for i, child in ipairs(children) do
      bestScore = math.min(bestScore, minimax(tree, child, depth - 1, true, current_player))
    end
    return bestScore
  end
end

-- Performs Minimax search
-- node : the node from where to start the search, usually the head node
-- tree : the search tree
-- depth : the maximum depth of search
return function(node, tree, depth, current_player)
  local bestScore
  return minimax(tree, node, depth, true, current_player, bestScore)
end


