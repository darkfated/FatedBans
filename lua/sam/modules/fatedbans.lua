if SAM_LOADED then return end

local sam, command = sam, sam.command
local color_player, color_fated = Color(56, 149, 255), Color(255, 192, 75)

command.set_category('FatedBans')

command.new('ban')
    :SetPermission('ban', 'admin')
    :AddArg('player')
    :AddArg('length', {optional = true, default = 5})
    :AddArg('text', {hint = 'причина', optional = true})
    :Help('ban_help')
    :OnExecute(function(ply, targets, time, reason)
        if !time or time <= 0 then
            ply:sam_send_message('ban_invalid_time')

            return
        end

        local admin_name = !ply:IsPlayer() and 'Сервер' or ply:Name()

        for _, target in ipairs(targets) do
            banPlayer(target, time * 60, admin_name, reason)
        end

        sam.player.send_message(nil, '{A} забанил {T} на {V} мин. Причина: {V_2}', {
            A = ply, T = targets, V = time, V_2 = reason
        })
    end)
:End()

command.new('unban')
    :SetPermission('unban', 'admin')
    :AddArg('player')
    :Help('unban_help')
    :OnExecute(function(ply, targets)
        for _, target in ipairs(targets) do
            unbanPlayer(target)
        end

        sam.player.send_message(nil, '{A} разбанил {T}', {
            A = ply, T = targets
        })
    end)
:End()
