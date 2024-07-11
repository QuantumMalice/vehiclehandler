return {
    ['cleankit'] = {
        label = "Cleaning vehicle",
        duration = math.random(10000, 20000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
    },
    ['tirekit'] = {
        label = "Repairing tires",
        duration = math.random(10000, 20000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            clip = "machinic_loop_mechandplayer",
            flag = 10
        },
    },
    ['smallkit'] = {
        label = "Repairing vehicle",
        duration = math.random(15000, 20000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_player"
        },
    },
    ['bigkit'] = {
        label = "Repairing vehicle",
        duration = math.random(25000, 30000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_player"
        },
    }
}