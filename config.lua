Config = {}

--[[ Locale setting for language localization ('en', 'hr', 'de') ]]
Config.Locale = "en"

--[[ Toggle in-game notifications when changing pursuit modes ]]
Config.EnableNotify = true

--[[ Chat command to switch pursuit modes ]]
Config.Command = "pursuitmode"

--[[ Default keyboard key to switch pursuit modes ]]
Config.KeyBind = "G"

--[[ Cooldown in milliseconds between mode changes ]]
Config.Cooldown = 2000

--[[ Authorized jobs and minimum grades required to use pursuit modes ]]
Config.Job = {
    ["police"] = 1,
    ["sheriff"] = 1,
    ["ambulance"] = 3,
}

--[[ Spawn names of whitelisted vehicles equipped with the pursuit system ]]
Config.AllowedVehicleNames = {
    "POLICE2",
    "polbuffalo6",
    "POLICE3",
    "AMBULANCE",
}

Config.Mods = {
    {
        Name = 'Sport',
        Color = { 255, 255, 255 }, -- White
        TopSpeed = 30,             -- Extra top speed (+30 km/h)
        Acceleration = 15,         -- Acceleration & engine power boost (+15%)
        Braking = 15,              -- Braking force boost (+15%)
        Handling = 5,              -- Traction & cornering grip boost (+5%)
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