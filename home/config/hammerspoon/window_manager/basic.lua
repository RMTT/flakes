local savedFrames = {}
hs.hotkey.bind({ "cmd" }, "m", function()
    local win = hs.window.focusedWindow()
    if not win or not win:isStandard() then return end

    local id = win:id()
    local curFrame = win:frame()
    local maxFrame = win:screen():frame()

    if savedFrames[id] and curFrame:equals(maxFrame) then
        win:setFrame(savedFrames[id])
        savedFrames[id] = nil
    else
        savedFrames[id] = curFrame
        win:setFrame(maxFrame)
    end
end)
