local Channel = require 'common/channel'

local Game = leaf.Object:extend()

function Game:init()
  self.channel = Channel()
end


return Game