![Main Banner](https://i.imgur.com/hryKQ1w.png)

## __Features:__
➢ Tire loss on impact <br>
➢ Reduces torque based on current health <br>
➢ Prevents crazy handling from low fuel <br>
➢ Disables vehicle after heavy collisions <br>
➢ Disables controls while airborne/flipped <br>
➢ Repair/Wash item integration (clean, tire, engine) <br>

## __Dependencies:__
* [ox_lib](https://github.com/CommunityOx/ox_lib)
* [ox_inventory](https://github.com/CommunityOx/ox_inventory) *(Optional)*

## ***ox_inventory***:
```lua
    ["cleaningkit"] = {
        label = "Cleaning Kit",
        weight = 250,
        stack = true,
        close = true,
        description = "A microfiber cloth with some soap will let your car sparkle again!",
        client = {
            image = "cleaningkit.png",
        },
        server = {
            export = 'vehiclehandler.cleaningkit'
        }
    },

    ["tirekit"] = {
        label = "Tire Kit",
        weight = 250,
        stack = true,
        close = true,
        description = "A nice toolbox with stuff to repair your tire",
        client = {
            image = "tirekit.png",
        },
        server = {
            export = 'vehiclehandler.tirekit'
        }
    },

    ["repairkit"] = {
        label = "Repairkit",
        weight = 2500,
        stack = true,
        close = true,
        description = "A nice toolbox with stuff to repair your vehicle",
        client = {
            image = "repairkit.png",
        },
        server = {
            export = 'vehiclehandler.repairkit',
        }
    },

    ["advancedrepairkit"] = {
        label = "Advanced Repairkit",
        weight = 5000,
        stack = true,
        close = true,
        description = "A nice toolbox with stuff to repair your vehicle",
        client = {
            image = "advancedrepairkit.png",
        },
        server = {
            export = 'vehiclehandler.advancedrepairkit',
        }
    },
```
