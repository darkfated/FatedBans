--[[
    * FatedBans *
    GitHub: https://github.com/darkfated/fatedbans
    Author's discord: darkfated
]]

local function run_scripts()
    local cl = SERVER and AddCSLuaFile or include
    local sv = SERVER and include or function() end

    sv('config.lua')
    
    cl('client.lua')
    sv('server.lua')
end

local function init()
    FatedBansConfig = FatedBansConfig or {}

    run_scripts()
end

init()
