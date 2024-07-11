![Main Banner](https://cdn.discordapp.com/attachments/688864735646580762/1178975479861104710/QM-main_2.png?ex=6690e8fa&is=668f977a&hm=fb8c29b6587b5f2571120960f5f85564912b1284f0f0341ca5aef2df3f6c72f2&)

## __Features:__
➢ Tire loss on impact <br>
➢ Reduces torque based on current health <br>
➢ Prevents crazy handling from low fuel <br>
➢ Disables vehicle after heavy collisions <br>
➢ Disables controls while airborne/flipped <br>
➢ Repair/Wash item integration (clean, tire, engine) <br>

*Idle -* `0.0ms` <br>
*Driving -* `0.0ms ~ 0.02ms` <br>

## __Dependencies:__
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory) *(Optional)*

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
            image = "advancedkit.png",
        },
        server = {
            export = 'vehiclehandler.advancedrepairkit',
        }
    },
```
