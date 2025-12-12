return {
    ---@type boolean
    -- Debug Mode: Set this to true to enable a metric fuck ton of debug prints
    debug = false, -- Default: false - boolean: true/false
    -- Save And Collect: this will store the vehicle in an ox_lib ui, where they can claim their vehicles later
    saveandcollect = true, -- Default: true - boolean: true/false 
    -- Allow Custom Plate Parameters: Allow players to set a custom plate using /givecar [id] [model] [customplate] (max of 8 chars)
    allowcustomplateparam = true, -- Default: true - boolean: true/false 
    -- Notify Player: Notify the player when they receive a vehicle (ox_lib notify)
    notifyplayer = true,          -- Default: true - boolean: true/false


    ---@type string
    -- Pick your framework 
    framework = 'auto', -- Options: 'auto' 'qb-core', 'esx', 'qbx_core'
    -- This is the command to actually give the vehicle
    command = 'givecar',
    -- What ace permissions is the command givecar locked to? 
    restricted = 'group.admin', -- Set to false for everyone to use, or set to a specific ace permission like 'group.admin'
    -- The database table where the vehicles are stored (only used if saveandcollect is true - just leave this as default tbh)
    claimstable = 'claim_vehicles', -- The database table where the vehicles are stored (only used if saveandcollect is true)
        -- The command to open the claims ui (only used if saveandcollect is true)
    claimscommand = 'claims', -- The command to open the claims ui (only used if saveandcollect is true)
    -- The default format for generated plates (only used if allowcustomplateparam is false or the plate param is not provided)
    plateformat = 'AAAA1111',  -- format of the plate (lib.string.random - https://coxdocs.dev/ox_lib/Modules/String/Shared#libstring )
    -- The logging method for vehicle gives
    logs = 'fivemanage', -- Options: false, 'fivemanage', 'discord' (FIVEMANAGE RECOMMENDED)    

    -- blacklistedvehicles: A list of vehicle models that are not allowed to be given
    blacklistedvehicles = {`police`, `police2`, `ambulance`},




    -- Idk if you need this
    
    defaultgarage = 'Legion Square' -- Primarily for jg-advancedgarages users
}