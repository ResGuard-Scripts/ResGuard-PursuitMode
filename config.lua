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

--[[ 
    Engine Health Failsafe:
    If vehicle engine health drops below this threshold, pursuit mode automatically resets to Stock.
    1000.0 = Full health | 250.0 = Damaged engine / smoking | 0.0 = Disabled
]]
Config.MinEngineHealth = 250.0

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

--[[ 
    Pursuit Modes Configuration:
    Simple tuning parameters:
    - Name: Display name of the mode
    - Color: RGB color for Xenon headlights and hood purge steam spray { Red, Green, Blue }
    - TopSpeed: Extra top speed in km/h added to vehicle
    - Acceleration: Acceleration power boost in %
    - Braking: Braking power boost in %
    - Handling: Traction and cornering grip boost in %
    (Advanced raw CHandlingData floats are also supported)
]]
Config.Mods = {
    {
        Name = "Sport",
        Color = { 255, 255, 255 }, -- White
        TopSpeed = 30,             -- (+30 km/h)
        Acceleration = 15,          -- (+15%)
        Braking = 15,              -- (+15%)
        Handling = 5,              -- (+5%)
    },
    {
        Name = "Sport+",
        Color = { 255, 255, 0 },   -- Yellow
        TopSpeed = 45,             -- (+45 km/h)
        Acceleration = 25,
        Braking = 25,
        Handling = 8,
    },
    {
        Name = "Touring",
        Color = { 0, 255, 0 },     -- Green
        TopSpeed = 60,             -- (+60 km/h)
        Acceleration = 35,
        Braking = 35,
        Handling = 12,
    },
    {
        Name = "Touring+",
        Color = { 0, 100, 255 },   -- Blue
        TopSpeed = 75,             -- (+75 km/h)
        Acceleration = 45,
        Braking = 45,
        Handling = 16,
    },
    {
        Name = "BeastMode",
        Color = { 255, 0, 0 },     -- Red
        TopSpeed = 90,             -- (+90 km/h)
        Acceleration = 60,
        Braking = 55,
        Handling = 20,
    },
}