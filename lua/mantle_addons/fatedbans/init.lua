--[[
    * FatedBans *
    GitHub: https://github.com/darkfated/FatedBans
    Author's discord: darkfated
]]--

local function run_scripts()
    Mantle.run_sv('config.lua')
    
    Mantle.run_cl('client.lua')
    Mantle.run_sv('server.lua')
end

local function init()
    FatedBansConfig = FatedBansConfig or {}

    run_scripts()
end

init()
