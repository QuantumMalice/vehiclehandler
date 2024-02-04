return {
    units = 'kmh' ,         -- (mph, kmh)
    threshold = {
        health = 50.0,      -- Health difference needed to break off wheel (LastHealth - CurrentHealth)
        speed = 50.0,       -- Speed difference needed to trigger collision events (LastSpeed - CurrentSpeed)
        heavy = 90.0,       -- Speed difference needed for a heavy collision event (LastSpeed - CurrentSpeed)
    },
    globalmultiplier = 20.0,
    classmultiplier = {
        [0] =   1.0,		--	0: Compacts
                1.0,		--	1: Sedans
                1.0,		--	2: SUVs
                0.95,		--	3: Coupes
                1.0,		--	4: Muscle
                0.95,		--	5: Sports Classics
                0.95,		--	6: Sports
                0.95,		--	7: Super
                0.47,		--	8: Motorcycles
                0.7,		--	9: Off-road
                0.25,		--	10: Industrial
                0.35,		--	11: Utility
                0.85,		--	12: Vans
                1.0,		--	13: Cycles
                0.4,		--	14: Boats
                0.7,		--	15: Helicopters
                0.7,		--	16: Planes
                0.75,		--	17: Service
                0.35,		--	18: Emergency
                0.27,		--	19: Military
                0.43,		--	20: Commercial
                0.1		    --	21: Trains
    },
    regulated = {
        [0] =   true,       -- compacts
                true,       -- sedans
                true,       -- SUV's
                true,       -- coupes
                true,       -- muscle
                true,       -- sport classic
                true,       -- sport
                true,       -- super
                false,      -- motorcycle
                true,       -- offroad
                true,       -- industrial
                true,       -- utility
                true,       -- vans
                false,      -- bicycles
                false,      -- boats
                false,      -- helicopter
                false,      -- plane
                true,       -- service
                true,       -- emergency
                false,      -- military
                true,       -- commercial
                false,      -- trains
                true,       -- open wheel
    },
}