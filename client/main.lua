require 'math'
require 'os'

-- Setup globals
require 'leaf'

-- Use strict, no more globals after this point
require 'lib/strict'

local Game = require 'game'


function love.load()
  -- Seed randomness
  math.randomseed(os.time()); math.random()
  local app = leaf.App()
  app:bind()
  app:pushContext(Game())
end
