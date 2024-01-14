local function CleanPropsPly(target_ply)
    for _, class in ipairs(FatedBansConfig.remove_props) do
        for k, v in pairs(ents.FindByClass(class)) do
            if (v.Owner and v.Owner == target_ply) or (v:CPPIGetOwner() and v:CPPIGetOwner() == target_ply) then
                v:Remove()
            end
        end
    end
end

local function SetJob(pl, index)
    timer.Simple(1, function()
        pl:SetTeam(index, true)
        pl:setDarkRPVar('job', pl:getJobTable().name)
        pl:Spawn()
    end)
end

function banPlayer(ply, time, admin_nick, reason)
    if !IsValid(ply) then
        return
    end

    bannedPlayers[ply:SteamID()] = {
        left_time = time,
        by_admin = admin_nick,
        ban_reason = reason
    }

    if IsValid(ply.cWings) then
        ply.cWings:Remove()
    end

    ply:SetNWBool('isBanned', true)
    ply:UnLock()
    ply:sam_set_nwvar('frozen', false)
    ply:sam_set_exclusive(nil)
    ply:sam_set_pdata('unmute_time', 0)
    ply:SetNWBool('gm_muted', true)
    ply.jailed = true

    SetJob(ply, FatedBansConfig.job_ban)
    
    CleanPropsPly(ply)

    timer.Create('banTimer_' .. ply:SteamID(), 1, time, function()
        local data = bannedPlayers[ply:SteamID()]
        data.left_time = data.left_time - 1

        if data.left_time <= 0 then
            unbanPlayer(ply)
        end

        SendBannedPlayersUpdate(ply)
    end)

    SendBannedPlayersUpdate(ply)

    if ply.Disguised then
        ply:SetNetVar('Disguise', false)
        ply:Disguise(nil)
        ply:SetNWBool('Mask', false)
    end
end

function unbanPlayer(ply)
    if !IsValid(ply) then
        return
    end

    local data = bannedPlayers[ply:SteamID()]

    if data then
        ply:ChatPrint('Наказание закончилось! Пожалуйста, соблюдайте правила!')
        ply:StripWeapon(ply.ban_wep)
        ply:SetNWBool('isBanned', false)
        ply:sam_set_pdata('unmute_time', nil)
        ply:SetNWBool('gm_muted', false)
        ply.jailed = false

        SetJob(ply, FatedBansConfig.job_standart)

        bannedPlayers[ply:SteamID()] = nil

        timer.Remove('banTimer_' .. ply:SteamID())
    end
end

hook.Add('Initialize', 'FatedBans.StartDataBan', function()
    if file.Exists('banned.txt', 'DATA') then
        bannedPlayers = util.JSONToTable(file.Read('banned.txt', 'DATA'))
    else
        bannedPlayers = {}
    end
end)

hook.Add('ShutDown', 'FatedBans.SaveDataServerOff', function()
    file.Write('banned.txt', util.TableToJSON(bannedPlayers))
end)

hook.Add('PlayerInitialSpawn', 'FatedBans.CheckBan', function(ply)
    local data = bannedPlayers[ply:SteamID()]

    if data then
        banPlayer(ply, data.left_time, data.by_admin, data.ban_reason)
        SendBannedPlayersUpdate(ply)
    end
end)

hook.Add('PlayerDisconnected', 'FatedBans.Leave', function(pl)
    if timer.Exists('banTimer_' .. pl:SteamID()) then
        timer.Remove('banTimer_' .. pl:SteamID())
    end
end)

// Синхрон для клиента
util.AddNetworkString('bannedPlayersUpdate')

function SendBannedPlayersUpdate(ply)
    net.Start('bannedPlayersUpdate')
        net.WriteTable(bannedPlayers)
    net.Send(ply)
end

// Проверки
hook.Add('PlayerSpawn', 'FatedBans.GiveWeapons', function(ply)
    if ply.jailed == true then
        timer.Simple(0.1, function()
            ply:StripWeapons()

            local wep = table.Random(FatedBansConfig.ban_weapons)

            ply:Give(wep)
            ply.ban_wep = wep
        end)
    end
end)

hook.Add('CanPlayerSuicide', 'FatedBans.RemoveKill', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerSpawnProp', 'FatedBans.RemoveSpawn', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerCanPickupItem', 'FatedBans.RemovePick', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerUse', 'FatedBans.RemoveUse', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('CanTool', 'FatedBans.RemoveTool', function (listener, ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('playerCanChangeTeam', 'FatedBans.RemoveChangeTeam', function(ply, t)
    if ply.jailed == true and RPExtraTeams[t] != FatedBansConfig.job_ban then
        return false
    end
end)

hook.Add('canDropWeapon', 'FatedBans.RemoveDropWeapon', function(ply)
    if ply.jailed == true then
        return false
    end
end)
