local framework = LoadFramework()
local Config = require('config.config')


CreateThread(function()
    if Config.saveandcollect then
        debugprint('Initializing claims database table: ' .. Config.claimstable)
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `]]..Config.claimstable..[[` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `identifier` VARCHAR(50) NOT NULL,
                `vehicle_model` VARCHAR(50) NOT NULL,
                `plate` VARCHAR(20) NOT NULL,
                `garage` VARCHAR(100) DEFAULT NULL,
                `claimed_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `identifier_index` (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
        info('Database table "'..Config.claimstable..'" checked/created successfully')
        debugprint('Database initialization complete')
    else
        debugprint('Save and collect is disabled, skipping database initialization')
    end
end)

function AddVehicleToGarage(source, vehicleModel, plate, garage)
    local source = source
    debugprint('AddVehicleToGarage called - Source: ' .. tostring(source) .. ', Model: ' .. tostring(vehicleModel) .. ', Plate: ' .. tostring(plate))
    local citizenid = GetPlayerIdentifier(source)
    local license = GetPlayerLicense(source)
    if not citizenid then 
        debugprint('Failed to get identifier, cannot add vehicle to garage')
        return false 
    end

    local targetGarage = garage or Config.defaultgarage
    debugprint('Adding vehicle to garage: ' .. tostring(targetGarage) .. ' with framework: ' .. tostring(framework))
    
    if framework == 'qb-core' or framework == 'qbx_core' then
        if framework == 'qbx_core' then
            debugprint('Using qbx_vehicles export to create player vehicle')
            local vehicleId, err = exports.qbx_vehicles:CreatePlayerVehicle({
                model = vehicleModel,
                citizenid = citizenid,
                props = {
                    plate = plate
                },
                garage = targetGarage,
            })
            
            if err then
                debugprint('Error creating vehicle: ' .. tostring(err))
                return false
            end
            
            debugprint('Vehicle created successfully with ID: ' .. tostring(vehicleId))
            return true
        else
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                license,
                citizenid,
                vehicleModel,
                joaat(vehicleModel),
                '{}',
                plate,
                targetGarage,
                0
            })
            debugprint('Vehicle added to player_vehicles table (QB-Core)')
            return true
        end
    elseif framework == 'esx' then
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {
            citizenid,
            plate,
            json.encode({model = joaat(vehicleModel), plate = plate}),
            1
        })
        debugprint('Vehicle added to owned_vehicles table (ESX)')
        return true
    end

    debugprint('Unknown framework, vehicle not added')
    return false
end

RegisterNetEvent('s_givecar:processVehicleClaim', function(claimId)
    local src = source
    debugprint('Processing vehicle claim - Source: ' .. tostring(src) .. ', ClaimId: ' .. tostring(claimId))
    local identifier = GetPlayerIdentifier(src)
    
    if not identifier or not claimId then
        debugprint('Invalid claim data - Identifier: ' .. tostring(identifier) .. ', ClaimId: ' .. tostring(claimId))
        lib.notify(src, {
            title = 'Error',
            description = 'Invalid claim',
            type = 'error'
        })
        return
    end

    debugprint('Querying claim with id: ' .. tostring(claimId) .. ' for identifier: ' .. tostring(identifier))
    local claim = MySQL.single.await('SELECT * FROM '..Config.claimstable..' WHERE id = ? AND identifier = ?', {claimId, identifier})
    
    if not claim then
        debugprint('Claim not found or does not belong to player')
        lib.notify(src, {
            title = 'Error',
            description = 'Claim not found or does not belong to you',
            type = 'error'
        })
        return
    end
    debugprint('Claim found - Vehicle: ' .. tostring(claim.vehicle_model or claim.model) .. ', Plate: ' .. tostring(claim.plate))

    local vehicleModel = claim.vehicle_model or claim.model
    local plate = claim.plate
    local garage = claim.garage or Config.defaultgarage
    debugprint('Processing claim - Vehicle: ' .. tostring(vehicleModel) .. ', Plate: ' .. tostring(plate) .. ', Garage: ' .. tostring(garage))

    -- Add vehicle to garage
    local success = AddVehicleToGarage(src, vehicleModel, plate, garage)
    debugprint('AddVehicleToGarage result: ' .. tostring(success))
    
    if success then
        -- Remove the claim from database
        debugprint('Removing claim from database with id: ' .. tostring(claimId))
        MySQL.query('DELETE FROM '..Config.claimstable..' WHERE id = ?', {claimId})
        debugprint('Claim removed successfully')
        
        if Config.notifyplayer then
            lib.notify(src, {
                title = 'Vehicle Claimed',
                description = 'Your '..vehicleModel..' has been added to your garage',
                type = 'success'
            })
            debugprint('Player notified of successful claim')
        end

        SendLog(src, Log.GiveCar, 'Vehicle Claimed', 'success', {
            { key = 'Player ID', value = src },
            { key = 'Vehicle Model', value = vehicleModel },
            { key = 'Plate', value = plate },
            { key = 'Garage', value = garage },
        })
    else
        debugprint('Failed to add vehicle to garage')
        lib.notify(src, {
            title = 'Error',
            description = 'Failed to claim vehicle',
            type = 'error'
        })
    end
    debugprint('processVehicleClaim completed for claimId: ' .. tostring(claimId))
end)


