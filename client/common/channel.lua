local MessagePack = require 'common/lib/MessagePack'
local enet = require 'enet'

-- Simple OO embedded in this file
local Channel = leaf.Object:extend()

local MAX_PEERS = 64
local CHANNEL_TYPE = {
  UNRELIABLE = 0,
  RELIABLE = 1
}

local function createMessage(type, data)
  return { type, data }
end


-- You should call listen() or connect() to act as a server or client, respectively
function Channel:init()
  self.host = nil
  self.peer = nil
  self._msg_queue = {}
  self._reliable_msg_queue = {}
end

function Channel:listen(address)
  self.host = enet.host_create(address, MAX_PEERS, #CHANNEL_TYPE)
end

function Channel:connect(address)
  self.host = enet.host_create()
  self.peer = self.host:connect(address)
end

function Channel:queueMessage(type, data)
  table.insert(self._msg_queue, createMessage(type, data))
end

function Channel:queueReliableMessage(type, data)
  table.insert(self._reliable_msg_queue, createMessage(type, data))
end

-- Transmit all pending reliable and unreliable messages to peer
function Channel:sendMessages()
  self._transmit(self._msg_queue, CHANNEL_TYPE.UNRELIABLE)
  self._transmit(self._msg_queue_reliable, CHANNEL_TYPE.RELIABLE)
end

-- Read socket and return a list of assembled messages in the format {type=type, data=data}
function channel:readMessages()
  local event = self.host:service(0)
  if event and event.type == 'receive' then
    return MessagePack.unpack(event.data)
  end
end

-- Send a list of messages to a channel
function Channel:_transmit(queue, channel)
  local data = MessagePack.pack(queue)

  -- Simple determination of client/server by self.peer
  if self.peer then
    self.peer:send(data, channel)
  else
    self.host:broadcast(data, channel)
  end
end




return Channel