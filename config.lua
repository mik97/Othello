config = {}

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


function config:set(origin_x, origin_y, dimension, columns)
  config.x = origin_x
  config.y = origin_y
  config.dim = dimension
  config.col = columns
  config.circle_x = origin_x + dimension/2
  config.circle_y = origin_y + dimension/2
  config.circleDim = dim/2.5
end