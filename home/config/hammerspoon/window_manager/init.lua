require('window_manager/basic')


local EasyMoveResize = require('window_manager/move_resize')

easyWindow = EasyMoveResize:new({
    moveModifiers   = { "cmd", "ctrl" },
    resizeModifiers = { "cmd", "ctrl" },
    bringToFront    = true,
    disabledApps    = {},
}):start()
