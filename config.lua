Config = {}

-- Framework: 'auto', 'esx', 'qb', 'qbx'
Config.Framework = 'auto'

-- Default locale: 'en', 'hr', 'de'
Config.Locale = 'en'

-- Toggle system notifications
Config.EnableNotify = true

-- Keybind to cycle modes (default: G, can be rebound in GTA Settings -> Key Mappings -> FiveM)
Config.KeyBind = 'G'
Config.Cooldown = 2000 -- Cooldown between switching modes (ms)

-- Auto-reset: restores stock vehicle handling if engine health drops below threshold
Config.MinEngineHealth = 250.0

-- Authorized jobs and minimum grade required to access pursuit modes
Config.Job = {
    ['police'] = 1,
    ['sheriff'] = 1,
    ['ambulance'] = 3,
}

-- Spawn names of vehicles equipped with pursuit system
Config.AllowedVehicleNames = {
    'POLICE2',
    'polbuffalo6',
    'POLICE3',
    'AMBULANCE'
}

Config.Mods = {
    {
        Name = 'Sport',
        Color = { 255, 255, 255 }, -- White
        TopSpeed = 30,             -- (+30 km/h)
        Acceleration = 15,          
        Braking = 15,              
        Handling = 5,          
    },
    {
        Name = 'Sport+',
        Color = { 255, 255, 0 },   -- Yellow
        TopSpeed = 45,
        Acceleration = 25,
        Braking = 25,
        Handling = 8,
    },
    {
        Name = 'Touring',
        Color = { 0, 255, 0 },     -- Green
        TopSpeed = 60,
        Acceleration = 35,
        Braking = 35,
        Handling = 12,
    },
    {
        Name = 'Touring+',
        Color = { 0, 100, 255 },   -- Blue
        TopSpeed = 75,
        Acceleration = 45,
        Braking = 45,
        Handling = 16,
    },
    {
        Name = 'BeastMode',
        Color = { 255, 0, 0 },     -- Red
        TopSpeed = 90,
        Acceleration = 60,
        Braking = 55,
        Handling = 20,
    },
}