if SAM_LOADED then return end

local sam, command = sam, sam.command
local color_player, color_fated = Color(56, 149, 255), Color(255, 192, 75)

local function PlayerIsOnServer(steamid)
    local players = player.GetAll()

    for _, ply in pairs(players) do
        if ply:SteamID() == steamid then
            return true
        end
    end

    return false
end

command.set_category('FatedBans')

command.new('ban')
    :SetPermission('ban', 'admin')
    :AddArg('player')
    :AddArg('length', {optional = true, default = 5})
    :AddArg('text', {hint = 'причина', optional = true, default = 'Не указано'})
    :Help('Забанить нарушителя.')
    :OnExecute(function(ply, targets, time, reason)
        local admin_name = IsValid(ply) and ply:Name() or 'Сервер'

        for _, target in ipairs(targets) do
            banPlayer(target, time * 60, admin_name, reason)
        end

        sam.player.send_message(nil, '{A} забанил {T} на {V} мин. Причина: {V_2}', {
            A = ply, T = targets, V = time, V_2 = reason
        })
    end)
:End()

command.new('banid')
    :SetPermission('banid', 'admin')
    :AddArg('text')
    :AddArg('length', {optional = true, default = 5})
    :AddArg('text', {hint = 'причина', optional = true, default = 'Не указано'})
    :Help('Забанить нарушителя по SteamID.')
    :OnExecute(function(ply, steamid, time, reason)
        local admin_name = IsValid(ply) and ply:Name() or 'Сервер'

        if PlayerIsOnServer(steamid) then
            local target = player.GetBySteamID(steamid)

            banPlayer(target, time * 60, admin_name, reason)

            sam.player.send_message(nil, '{A} забанил по SteamID {V} на {V_1} мин. Причина: {V_2}', {
                A = ply, V = target:SteamID(), V_1 = time, V_2 = reason
            })
        else
            bannedPlayers[steamid] = {
                left_time = time * 60,
                by_admin = admin_name,
                ban_reason = reason
            }

            sam.player.send_message(nil, '{A} забанил по SteamID {V} на {V_1} мин. Причина: {V_2}', {
                A = ply, V = steamid, V_1 = time, V_2 = reason
            })
        end
    end)
:End()

command.new('unban')
    :SetPermission('unban', 'admin')
    :AddArg('player')
    :Help('Разбанить игрока.')
    :OnExecute(function(ply, targets)
        for _, target in ipairs(targets) do
            unbanPlayer(target)
        end

        sam.player.send_message(nil, '{A} разбанил {T}', {
            A = ply, T = targets
        })
    end)
:End()

command.new('unbanid')
    :SetPermission('unbanid', 'admin')
    :AddArg('text')
    :Help('Разбанить игрока по SteamID.')
    :OnExecute(function(ply, steamid)
        local admin_name = IsValid(ply) and ply:Name() or 'Сервер'

        if PlayerIsOnServer(steamid) then
            local target = player.GetBySteamID(steamid)

            unbanPlayer(target)

            sam.player.send_message(nil, '{A} разбанил по SteamID {V}', {
                A = ply, V = target:SteamID()
            })
        else
            bannedPlayers[steamid] = nil

            sam.player.send_message(nil, '{A} разбанил по SteamID {V}', {
                A = ply, V = steamid
            })
        end
    end)
:End()
