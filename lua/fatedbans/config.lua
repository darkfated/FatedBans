hook.Add('OnGamemodeLoaded', 'FatedBans.config', function()
    // Какая профессия выдаётся при бане
    FatedBansConfig.job_ban = JOB_BAN

    // Какая профессия выдаётся после бана
    FatedBansConfig.job_standart = JOB_STUDENT
end)

// Список энтити, которые удаляются
FatedBansConfig.remove_props = {
    'prop_physics',
    'keypad',
    'gb_rp_sign',
    'sammyservers_textscreen',
    'gmod_cameraprop',
    'uni_keypad',
    'image_sticker'
}

// Получаемое оружие при бане (выбирается одно по рандому). Чтобы не выдавалось - оставьте поле пустым
FatedBansConfig.ban_weapons = {
    'tfa_nmrih_fireaxe',
    'tfa_nmrih_lpipe',
    'tfa_nmrih_sledge',
    'tfa_nmrih_pickaxe',
    'tfa_nmrih_bat',
    'tfa_tfre_nunchucks',
    'weapon_dumbbell'
}
