local MessagePack = require 'common/lib/MessagePack'
local enet = require 'enet'

local MessageType = require 'common/message_type'

-- Simple OO embedded in this file
local Channel = leaf.Object:extend()

local MAX_PEERS = 64
local CHANNEL_TYPE = {
  UNRELIABLE = 0,
  RELIABLE = 1
}
local NUM_CHANNELS = 2

-- Assembles the basic message structure which is returned to the channel client
function createMessage(type, data)
  return {
    type=type,
    data=data,
  }
end


-- You should call listen() or connect() to act as a server or client, respectively
function Channel:init()
  self.host = nil
  self.peer = nil
  self._msg_queue = {}
  self._reliable_msg_queue = {}
end

function Channel:listen(address)
  self.host = enet.host_create(address, MAX_PEERS, NUM_CHANNELS)
end

function Channel:connect(address)
  self.host = enet.host_create()
  self.peer = self.host:connect(address, NUM_CHANNELS)
end

function Channel:queueMessage(type, data)
  table.insert(self._msg_queue, {type, data})
end

function Channel:queueReliableMessage(type, data)
  table.insert(self._reliable_msg_queue, {type, data})
end

-- Transmit all pending reliable and unreliable messages to peer
function Channel:sendMessages()
  if #self._msg_queue > 0 then
    self:_transmit(self._msg_queue, CHANNEL_TYPE.UNRELIABLE, 'unreliable')
    self._msg_queue = {}
  end
  if #self._reliable_msg_queue > 0 then
    self:_transmit(self._reliable_msg_queue, CHANNEL_TYPE.RELIABLE, 'reliable')
    self._reliable_msg_queue = {}
  end
end

-- Reads all pending data on socket and returns a list of assembled messages in the format {type=type, data=data}
function Channel:readMessages()
  local messages = {}

  -- Read everything on socket
  while true do
    local event = self.host:service()
    if not event then break end

    -- Handle enet events first
    if event.type == 'connect' then
      table.insert(messages, createMessage(MessageType.CHANNEL_CONNECT))
    elseif event.type == 'disconnect' then
      table.insert(messages, createMessage(MessageType.CHANNEL_DISCONNECT))

    -- Handle user messages
    elseif event.type == 'receive' then
      for i, raw_message in ipairs(MessagePack.unpack(event.data)) do
        table.insert(messages, createMessage(raw_message[1], raw_message[2]))
      end
    end
  end

  return messages
end

-- Send a list of messages to a channel
function Channel:_transmit(queue, channel, flag)
  local data = MessagePack.pack(queue)

  -- Simple determination of client/server by self.peer
  if self.peer then
    self.peer:send(data, channel, flag)
  else
    self.host:broadcast(data, channel, flag)
  end
end




return Channel
