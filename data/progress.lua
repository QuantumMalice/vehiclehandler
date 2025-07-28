return {
    ['cleankit'] = {
        label = locale('progress.cleankit'),
        duration = 15000,
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
        label = locale('progress.tirekit'),
        duration = 15000,
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
        label = locale('progress.smallkit'),
        duration = 20000,
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
        label = locale('progress.bigkit'),
        duration = 30000,
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