return {
    units = 'mph' ,             -- (mph, kmh)
    breaktire = true,           -- Enable/Disable breaking off vehicle wheel on impact
    threshold = {
        health = 50.0,          -- Health difference needed to break off wheel (LastHealth - CurrentHealth)
        speed  = 50.0,          -- Speed difference needed to break off wheel (LastSpeed - CurrentSpeed)
        heavy  = 90.0,          -- Speed difference needed to disable vehicle instantly (LastSpeed - CurrentSpeed)
    },
    globalmultiplier = 10.0,    -- Base damage multiplier for all vehicles (lower value = less damage)
    classmultiplier = {         -- Add-on damage multiplier for vehicle classes
        [0] =   1.0,            -- 0: Compacts
                1.0,            -- 1: Sedans
                1.0,	        -- 2: SUVs
                1.0,	        -- 3: Coupes
                1.0,	        -- 4: Muscle
                1.0,           -- 5: Sports Classics
                1.0,	        -- 6: Sports
                1.0,	        -- 7: Super
                1.0,	        -- 8: Motorcycles
                1.0,	        -- 9: Off-road
                1.0,	        -- 10: Industrial
                1.0,	        -- 11: Utility
                1.0,	        -- 12: Vans
                1.0,	        -- 13: Bicycles
                1.0,	        -- 14: Boats
                1.0,	        -- 15: Helicopters
                1.0,	        -- 16: Planes
                1.0,	        -- 17: Service
                1.0,	        -- 18: Emergency
                1.0,	        -- 19: Military
                1.0,	        -- 20: Commercial
                0.1,	        -- 21: Trains
                1.0,	        -- 22: Open Wheel
    },
    regulated = {               -- Prevent controls for vehicle class while flipped/airborne
        [0] =   true,           -- 0: Compacts
                true,           -- 1: Sedans
                true,           -- 2: SUVs
                true,           -- 3: Coupes
                true,           -- 4: Muscle
                true,           -- 5: Sports Classics
                true,           -- 6: Sports
                true,           -- 7: Super
                false,          -- 8: Motorcycles
                true,           -- 9: Off-road
                true,           -- 10: Industrial
                true,           -- 11: Utility
                true,           -- 12: Vans
                false,          -- 13: Bicycles
                false,          -- 14: Boats
                false,          -- 15: Helicopters
                false,          -- 16: Planes
                true,           -- 17: Service
                true,           -- 18: Emergency
                false,          -- 19: Military
                true,           -- 20: Commercial
                false,          -- 21: Trains
                true,           -- 22: Open Wheel
    },
    exclusions = {              -- Prevent rotation controls for these specific models, even if their class is regulated
        [`deluxo`] = true,
        [`scramjet`] = true,
        [`vigilante`] = true,
    },
    backengine = {
        [`ninef`] = true,
        [`adder`] = true,
        [`vagner`] = true,
        [`t20`] = true,
        [`infernus`] = true,
        [`zentorno`] = true,
        [`reaper`] = true,
        [`comet2`] = true,
        [`jester`] = true,
        [`jester2`] = true,
        [`cheetah`] = true,
        [`cheetah2`] = true,
        [`prototipo`] = true,
        [`turismor`] = true,
        [`pfister811`] = true,
        [`ardent`] = true,
        [`nero`] = true,
        [`nero2`] = true,
        [`tempesta`] = true,
        [`vacca`] = true,
        [`bullet`] = true,
        [`osiris`] = true,
        [`entityxf`] = true,
        [`turismo2`] = true,
        [`fmj`] = true,
        [`re7b`] = true,
        [`tyrus`] = true,
        [`italigtb`] = true,
        [`penetrator`] = true,
        [`monroe`] = true,
        [`ninef2`] = true,
        [`stingergt`] = true,
        [`surfer`] = true,
        [`surfer2`] = true,
        [`comet3`] = true,
    }
}