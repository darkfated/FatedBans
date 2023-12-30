local function TimeToMinAndSec(sec)
    local minutes = math.floor(sec / 60)
    local remainingSeconds = sec % 60

    return minutes, remainingSeconds
end

local function Paint()
    local ply = LocalPlayer()

    if !IsValid(ply) then
        return
    end

    if ply:GetNWBool('isBanned') then
        local data = bannedPlayers[ply:SteamID()]

        if data then
            local min_left, sec_left = TimeToMinAndSec(data.left_time)
            local x_pos = ScrW() * 0.5

            draw.SimpleText('Вас забанил ' .. data.by_admin .. ' по причине: ' .. (data.ban_reason != '' and data.ban_reason or 'не указана'), 'Fated.24', x_pos, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText('Осталось: ' .. min_left .. ' мин. ' .. sec_left .. ' сек.', 'Fated.24', x_pos, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText('Время идёт только на сервере', 'Fated.24', x_pos, 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end
end

hook.Add('HUDPaint', 'FatedBans.Hud', Paint)

bannedPlayers = {}

net.Receive('bannedPlayersUpdate', function()
    bannedPlayers = net.ReadTable()
end)
