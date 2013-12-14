require 'leaf/init'
require 'common/lib/strict'
local Channel = require 'common/channel'
local MessageType = require 'common/message_type'

local function log(...)
  print(table.concat(arg, ' '))
end


local channel = Channel()
address = '0.0.0.0:10004'
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

