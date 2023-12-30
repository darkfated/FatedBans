local function CleanPropsPly(target_ply)
    for _, class in ipairs(FatedBansConfig.remove_props) do
        for k, v in pairs(ents.FindByClass(class)) do
            if (v.Owner and v.Owner == target_ply) or (v:CPPIGetOwner() and v:CPPIGetOwner() == target_ply) then
                v:Remove()
            end
        end
    end
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

    timer.Simple(1, function()
        ply:changeTeam(FatedBansConfig.job_ban, true, true, true)
        ply:Spawn()
    end)

    ply:SetNWBool('isBanned', true)
    ply.jailed = true

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
        ply:changeTeam(FatedBansConfig.job_standart, true, true, true)
        ply:ChatPrint('Наказание закончилось! Пожалуйста, соблюдайте правила!')
        ply:StripWeapon(ply.ban_wep)

        timer.Simple(1, function()
            ply:Spawn()
        end)

        ply:SetNWBool('isBanned', false)
        ply.jailed = false

        bannedPlayers[ply:SteamID()] = nil

        timer.Remove('banTimer_' .. ply:SteamID())
    end
end

hook.Add('Initialize', 'DarkFated.StartDataban', function()
    if file.Exists('banned.txt', 'DATA') then
        bannedPlayers = util.JSONToTable(file.Read('banned.txt', 'DATA'))
    else
        bannedPlayers = {}
    end
end)

hook.Add('ShutDown', 'DarkFated.SaveDataServerOff', function()
    file.Write('banned.txt', util.TableToJSON(bannedPlayers))
end)

hook.Add('PlayerInitialSpawn', 'CheckbanOnSpawn', function(ply)
    if bannedPlayers[ply:SteamID()] then
        local data = bannedPlayers[ply:SteamID()]

        banPlayer(ply, data.left_time, data.by_admin, data.ban_reason)
        SendBannedPlayersUpdate(ply)
    end
end)

hook.Add('PlayerDisconnected', 'ban.PlyLeave', function(pl)
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
hook.Add('PlayerSpawn', 'give_weapon_ban', function(ply)
    if ply.jailed == true then
        timer.Simple(0, function()
            ply:StripWeapons()

            local wep = table.Random(FatedBansConfig.ban_weapons)

            ply:Give(wep)
            ply.ban_wep = wep
        end)
    end
end)

hook.Add('CanPlayerSuicide', 'ulxSuicedeCheck', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerSpawnProp', 'ulxBlockSpawnIfInJail', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerCanPickupItem', 'ulxPickUpRest', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerUse', 'ulxRemove_Use', function (ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('CanTool', 'ulxRemoveTool', function (listener, ply)
    if ply.jailed == true then
        return false
    end
end)

hook.Add('PlayerSay', 'ulxRemoveSay', function (ply)
    if ply.jailed == true then
        return ''
    end
end)

hook.Add('playerCanChangeTeam', 'jobcanchange', function(ply, t)
    if ply.jailed == true and RPExtraTeams[t] != FatedBansConfig.job_ban then
        return false
    end
end)
