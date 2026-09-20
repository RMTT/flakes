-- ~/.hammerspoon/easy_move_resize.lua
local EasyMoveResize   = {}
EasyMoveResize.__index = EasyMoveResize

local events           = hs.eventtap.event.types
local props            = hs.eventtap.event.properties

-- Match modifier keys safely while ignoring hardware flags (e.g., fn, capslock)
local function matchModifiers(currentFlags, expectedMods)
    local expectedMap = {}
    for _, mod in ipairs(expectedMods) do
        expectedMap[mod] = true
    end

    for _, mod in ipairs({ "cmd", "ctrl", "alt", "shift" }) do
        local isExpected = expectedMap[mod] or false
        local isPressed  = currentFlags[mod] or false
        if isExpected ~= isPressed then
            return false
        end
    end
    return true
end

function EasyMoveResize:new(options)
    local obj           = setmetatable({}, self)
    options             = options or {}

    obj.moveModifiers   = options.moveModifiers or { "cmd", "ctrl" }
    obj.resizeModifiers = options.resizeModifiers or { "cmd", "ctrl" }
    obj.bringToFront    = options.bringToFront ~= false
    obj.minSize         = options.minSize or { w = 150, h = 100 }
    obj.disabledApps    = {}

    for _, app in ipairs(options.disabledApps or {}) do
        obj.disabledApps[app] = true
    end

    obj._state = nil
    hs.window.animationDuration = 0 -- Match modifier keys safely while ignoring hardware flags (e.g., fn, capslock)

    obj:_initWatchers()
    return obj
end

function EasyMoveResize:_initWatchers()
    -- Watch mouse down events to initiate drag
    self._downWatcher = hs.eventtap.new({ events.leftMouseDown, events.rightMouseDown }, function(e)
        return self:_handleMouseDown(e)
    end)

    -- Watch drag and movement events while dragging is active
    self._dragWatcher = hs.eventtap.new({
        events.leftMouseDragged,
        events.rightMouseDragged,
        events.mouseMoved
    }, function(e)
        return self:_handleDrag(e)
    end)

    -- Watch mouse up events to finalize drag
    self._upWatcher = hs.eventtap.new({ events.leftMouseUp, events.rightMouseUp }, function(e)
        return self:_handleMouseUp(e)
    end)
end

function EasyMoveResize:start()
    if not hs.accessibilityState() then
        hs.alert.show("Hammerspoon requires Accessibility permissions!")
        hs.accessibilityState(true)
        return self
    end

    if self._downWatcher then self._downWatcher:start() end
    return self
end

function EasyMoveResize:stop()
    self:_cancelDrag()
    if self._downWatcher then self._downWatcher:stop() end
    return self
end

-- Find the topmost standard window under the cursor
function EasyMoveResize:_getTargetWindow()
    local pos = hs.geometry.new(hs.mouse.absolutePosition())
    for _, w in ipairs(hs.window.orderedWindows()) do
        if w:isStandard() and w:isVisible() and not w:isMinimized() then
            local f = w:frame()
            if f and pos:inside(f) then
                return w
            end
        end
    end
    return nil
end

-- Determine resize direction (-1: left/top, 1: right/bottom, 0: center) using a 3x3 grid
function EasyMoveResize:_getResizeDirection(mousePos, frame)
    local rx = (mousePos.x - frame.x) / frame.w
    local ry = (mousePos.y - frame.y) / frame.h

    local dx = (rx < 0.33 and -1) or (rx > 0.66 and 1) or 0
    local dy = (ry < 0.33 and -1) or (ry > 0.66 and 1) or 0

    if dx == 0 and dy == 0 then
        dx = (rx >= 0.5) and 1 or -1
        dy = (ry >= 0.5) and 1 or -1
    end
    return dx, dy
end

function EasyMoveResize:_handleMouseDown(event)
    local flags    = event:getFlags()
    local btn      = event:getProperty(props.mouseEventButtonNumber)

    local isMove   = matchModifiers(flags, self.moveModifiers) and (btn == 0)
    local isResize = matchModifiers(flags, self.resizeModifiers) and (btn == 1)

    if not (isMove or isResize) then return false end

    local win = self:_getTargetWindow()
    if not win then return false end

    local app = win:application()
    if app and self.disabledApps[app:name()] then return false end

    if self.bringToFront then win:focus() end

    local mousePos   = hs.mouse.absolutePosition()
    local frame      = win:frame()
    local dirX, dirY = self:_getResizeDirection(mousePos, frame)

    self._state      = {
        mode = isMove and "move" or "resize",
        win  = win,
        dirX = dirX,
        dirY = dirY
    }

    self._dragWatcher:start()
    self._upWatcher:start()
    return true -- Swallow event to prevent text selection or context menus
end

function EasyMoveResize:_handleDrag(event)
    if not self._state or not self._state.win then return false end

    -- Retrieve per-frame relative delta from hardware event
    local dx = event:getProperty(props.mouseEventDeltaX) or 0
    local dy = event:getProperty(props.mouseEventDeltaY) or 0

    if dx == 0 and dy == 0 then return true end

    local win = self._state.win

    if self._state.mode == "move" then
        -- Smooth relative window displacement
        win:move({ dx, dy }, nil, false, 0)
    elseif self._state.mode == "resize" then
        local f = win:frame()
        local newX, newY = f.x, f.y
        local newW, newH = f.w, f.h

        -- Adjust width and horizontal position
        if self._state.dirX == 1 then
            newW = math.max(self.minSize.w, f.w + dx)
        elseif self._state.dirX == -1 then
            newW = math.max(self.minSize.w, f.w - dx)
            newX = f.x + (f.w - newW)
        end

        -- Adjust height and vertical position
        if self._state.dirY == 1 then
            newH = math.max(self.minSize.h, f.h + dy)
        elseif self._state.dirY == -1 then
            newH = math.max(self.minSize.h, f.h - dy)
            newY = f.y + (f.h - newH)
        end

        win:setFrame({ x = newX, y = newY, w = newW, h = newH })
    end

    return true
end

function EasyMoveResize:_handleMouseUp(event)
    if self._state then
        self:_cancelDrag()
        return true
    end
    return false
end

function EasyMoveResize:_cancelDrag()
    self._state = nil
    if self._dragWatcher then self._dragWatcher:stop() end
    if self._upWatcher then self._upWatcher:stop() end
end

return EasyMoveResize
