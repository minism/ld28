require 'leaf/init'
require 'common/lib/strict'
local Channel = require 'common/channel'
local constants = require 'common/constants'
local MessageType = require 'common/message_type'
local utils = require 'common/utils'

local function log(...)
  print(table.concat(arg, ' '))
end


local channel = Channel()
local address = utils.getLANAddress()
channel:listen(address)
log("Listening on", address)
while true do
  for i, message in ipairs(channel:readMessages()) do
    log(message.type, message.data)

    if message.type == MessageType.CLIENT_CHAT then
      channel:queueReliableMessage(MessageType.SERVER_CHAT, message.data)
    end
  end

  channel:sendMessages()
end

