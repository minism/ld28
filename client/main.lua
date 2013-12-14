require 'math'
require 'os'

require 'common/lib/strict'
require 'leaf'

local Game = require 'game'

-- Globals
console = leaf.Console()


function love.load()
  -- Seed randomness
  math.randomseed(os.time()); math.random()
  local app = leaf.App()
  app:bind()
  app:pushContext(Game())
end
