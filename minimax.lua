local function minimax(tree, node, depth, maximize, bestScore)
  if depth == 0 or tree:isLeaf(node) then
    return tree:heuristic(node)
  end
  local children = tree:children(node)
  if maximize then
    bestScore = -math.huge
    for i, child in ipairs(children) do
      bestScore = math.max(bestScore, minimax(tree, child, depth-1, false))
    end
    return bestScore
  else
    bestScore = math.huge
    for i, child in ipairs(children) do
      bestScore = math.min(bestScore, minimax(tree, child, depth - 1, true))
    end
    return bestScore
  end
end

return function(node, tree, depth)
  local bestScore
  return minimax(tree, node, depth, true, bestScore)
end