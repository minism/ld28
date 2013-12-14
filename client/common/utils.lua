local constants = require 'common/constants'

local utils = {}

function utils.getLANAddress()
  return constants.LAN_ADDRESS .. ":" .. constants.PORT
end

function utils.getWANAddress()
  return constants.WAN_ADDRESS .. ":" .. constants.PORT
end


return utils