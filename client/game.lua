local Channel = require 'common/channel'
local MessageType = require 'common/message_type'
local utils = require 'common/utils'

local Game = leaf.Context:extend()

function Game:init()
  self.channel = Channel()
  self.channel:connect(utils.getWANAddress())
  console:write "Game initializied"
end

function Game:update(dt)
  for i, message in ipairs(self.channel:readMessages()) do
    if message.type == MessageType.SERVER_CHAT then
      console:write("Received chat:", message.data)
    else    
      console:write(message.type, message.data)
    end
  end

  self.channel:sendMessages()
end

function Game:draw()
  console:drawLog()
end

function Game:keypressed(key, unicode)
  self.channel:queueReliableMessage(MessageType.CLIENT_CHAT, key)
end


return Game