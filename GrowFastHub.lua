-- Obfuscated Loadstring (Anti-Decompiler)
local _ = function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))() end
local library = _()

-- Services (Obfuscated Names)
local _Plrs = game:GetService("Players")
local _RepStor = game:GetService("ReplicatedStorage")
local _RunSvc = game:GetService("RunService")
local _MktSvc = game:GetService("MarketplaceService")
local _UIS = game:GetService("UserInputService")

-- Local Player Data
local _Ply = _Plrs.LocalPlayer
local _Bckpk = _Ply:WaitForChild("Backpack")
local _LdrStats = _Ply:WaitForChild("leaderstats")
local _Shkls = _LdrStats:WaitForChild("Sheckles")
local _Char = _Ply.Character or _Ply.CharacterAdded:Wait()

-- Remote Events
local _PlntRE = _RepStor:WaitForChild("Plant_RE")
local _HrvstRE = _RepStor:WaitForChild("Harvest_RE")
local _BuySdRE = _RepStor:WaitForChild("BuySeed_RE")
local _FeedPlntRE = _RepStor:WaitForChild("FeedPlant_RE")

-- Workspace References
local _Frm = game.Workspace:WaitForChild("Farm")
local _SdShp = game.Workspace:WaitForChild("SeedShop")
local _HngryPlnt = game.Workspace:WaitForChild("HungryPlant")

-- Anti-Ban Config
local _AntiBan = {
    RateLimit = 0.5, -- Seconds between actions
    RandomDelay = {0.1, 0.3}, -- Random delay range
    FakeLegitChance = 0.2, -- 20% chance to mimic legit action
    MaxActionsPerSec = 2, -- Max events per second
    LastActionTime = tick(),
    ActionCount = 0
}

-- Toggles
local _Tgls = {
    _AG = false, -- Auto Grow
    _ABS = false, -- Auto Buy Seeds
    _AP = false, -- Auto Plant
    _TTP = false, -- Teleport to Plant
    _AFP = false, -- Auto Feed Plant
    _AS = false, -- Auto Sell
    _UICollapsed = false
}

-- UI Setup
local _W = library:CreateWindow({
    Title = "🌱 Grow a Garden Elite",
    Theme = "Dark",
    Accent = Color3.fromRGB(0, 120, 255)
})
local _F = _W:CreateFolder("Controls")
local _Dbg = _W:CreateFolder("Debug")

-- Utility Functions
local function _GetOwnPlt()
    for _, plt in pairs(_Frm:GetChildren()) do
        local imp = plt:FindFirstChild("Important")
        if imp and imp:FindFirstChild("Data") and imp.Data:FindFirstChild("Owner") then
            if imp.Data.Owner.Value == _Ply.Name then
                returnIfValid = plt
                return returnIfValid
            end
        end
    end
    return nil
end

local function _GetEmptyPlt()
    local pltFldr = _GetOwnPlt()
    if not pltFldr then return nil end
    for _, plt in pairs(pltFldr:GetChildren()) do
        if plt:FindFirstChild("Occupied") and not plt.Occupied.Value then
            returnIfValid = plt
            return returnIfValid
        end
    end
    return nil
end

local function _GetSdTool()
    for _, tl in pairs(_Bckpk:GetChildren()) do
        if tl:IsA("Tool") and tl:FindFirstChild("SeedType") then
            returnIfValid = tl
            return returnIfValid
        end
    end
    return nil
end

local function _GetCrpForWght(wght)
    for _, tl in pairs(_Bckpk:GetChildren()) do
        if tl:IsA("Tool") and tl:FindFirstChild("Weight") and tl.Weight.Value >= wght then
            returnIfValid = tl
            return returnIfValid
        end
    end
    return nil
end

-- Anti-Ban Handler
local function _SafeExec(fn)
    if tick() - _AntiBan.LastActionTime < _AntiBan.RateLimit then return end
    if _AntiBan.ActionCount >= _AntiBan.MaxActionsPerSec then return end
    _AntiBan.ActionCount = _AntiBan.ActionCount + 1
    _AntiBan.LastActionTime = tick()
    
    -- Random Delay
    wait(_AntiBan.RandomDelay[1] + math.random() * (_AntiBan.RandomDelay[2] - _AntiBan.RandomDelay[1]))
    
    -- Fake Legit Action
    if math.random() < _AntiBan.FakeLegitChance then
        local hrp = _Char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
        end
    end
    
    -- Execute Function
    xpcall(fn, function(err)
        _Dbg:Label("Error: " .. tostring(err))
    end)
    
    -- Reset Action Count
    spawn(function()
        wait(1)
        _AntiBan.ActionCount = math.max(0, _AntiBan.ActionCount - 1)
    end)
end

-- Feature Functions
local function _AutoGrw()
    local pltFldr = _GetOwnPlt()
    if not pltFldr then return end
    for _, plt in pairs(pltFldr:GetChildren()) do
        if plt:FindFirstChild("Occupied") and plt.Occupied.Value then
            _SafeExec(function()
                _HrvstRE:FireServer(plt.Position)
            end)
        end
    end
end

local function _AutoBuySds()
    local stck = _SdShp:FindFirstChild("Stock")
    if not stck then return end
    for _, sd in pairs(stck:GetChildren()) do
        if sd:IsA("StringValue") and sd:FindFirstChild("Price") and _Shkls.Value >= sd.Price.Value then
            _SafeExec(function()
                _BuySdRE:FireServer(sd.Name)
            end)
        end
    end
end

local function _AutoPlnt()
    local plt = _GetEmptyPlt()
    local sdTl = _GetSdTool()
    if plt and sdTl then
        _SafeExec(function()
            _PlntRE:FireServer(plt.Position, sdTl.SeedType.Value)
        end)
    end
end

local function _TprtToPlnt()
    local pltFldr = _GetOwnPlt()
    if not pltFldr then return end
    for _, plt in pairs(pltFldr:GetChildren()) do
        if plt:FindFirstChild("Occupied") and plt.Occupied.Value then
            _SafeExec(function()
                local hrp = _Char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(plt.Position + Vector3.new(0, 5, 0))
                end
            end)
            break
        end
    end
end

local function _AutoFdPlnt()
    local prmpt = _HngryPlnt:FindFirstChildOfClass("ProximityPrompt")
    local reqWght = _HngryPlnt:FindFirstChild("RequestedWeight")
    if prmpt and reqWght then
        local crp = _GetCrpForWght(reqWght.Value)
        if crp then
            _SafeExec(function()
                crp.Parent = _Char
                wait(0.1)
                _FeedPlntRE:FireServer(crp.Name, reqWght.Value)
                fireproximityprompt(prmpt, 1, true)
            end)
        end
    end
end

local function _AutoSll()
    for _, tl in pairs(_Bckpk:GetChildren()) do
        if tl:IsA("Tool") and tl:FindFirstChild("Item_String") then
            _SafeExec(function()
                _HrvstRE:FireServer(tl.Name)
            end)
        end
    end
end

-- UI Elements
_F:Toggle({
    Text = "Auto Grow",
    Callback = function(val) _Tgls._AG = val end,
    Style = "Gradient",
    Color = Color3.fromRGB(0, 200, 0)
})

_F:Toggle({
    Text = "Auto Buy Seeds",
    Callback = function(val) _Tgls._ABS = val end,
    Style = "Gradient",
    Color = Color3.fromRGB(255, 165, 0)
})

_F:Toggle({
    Text = "Auto Plant",
    Callback = function(val) _Tgls._AP = val end,
    Style = "Gradient",
    Color = Color3.fromRGB(139, 69, 19)
})

_F:Toggle({
    Text = "Teleport to Plant",
    Callback = function(val) _Tgls._TTP = val end,
    Style = "Gradient",
    Color = Color3.fromRGB(0, 191, 255)
})

_F:Toggle({
    Text = "Auto Feed Hungry Plant",
    Callback = function(val) _Tgls._AFP = val end,
    Style = "Gradient",
    Color = Color3.fromRGB(255, 0, 255)
})

_F:Toggle({
    Text = "Auto Sell",
    Callback = function(val) _Tgls._AS = val end,
    Style = "Gradient",
    Color = Color3.fromRGB(255, 215, 0)
})

_F:Button({
    Text = _Tgls._UICollapsed and "Expand UI" or "Collapse UI",
    Callback = function()
        _Tgls._UICollapsed = not _Tgls._UICollapsed
        _W:SetVisible(not _Tgls._UICollapsed)
        _F:Button({
            Text = _Tgls._UICollapsed and "Expand UI" or "Collapse UI",
            Callback = function()
                _Tgls._UICollapsed = not _Tgls._UICollapsed
                _W:SetVisible(not _Tgls._UICollapsed)
            end
        })
    end,
    Style = "Outline",
    Color = Color3.fromRGB(255, 255, 255)
})

_Dbg:Label("Status: Running")
_Dbg:Label("Sheckles: " .. _Shkls.Value)
ShklsChangedConnection = _Shkls.Changed:Connect(function(val)
    _Dbg:Label("Sheckles: " .. val)
end)

-- Main Loop
local _Cn = _RunSvc.Heartbeat:Connect(function()
    if _Tgls._AG then task.spawn(_AutoGrw) end
    if _Tgls._ABS then task.spawn(_AutoBuySds) end
    if _Tgls._AP then task.spawn(_AutoPlnt) end
    if _Tgls._TTP then task.spawn(_TprtToPlnt) end
    if _Tgls._AFP then task.spawn(_AutoFdPlnt) end
    if _Tgls._AS then task.spawn(_AutoSll) end
end)

-- Anti-Exploit Detection
local function _ChkAntiCheat()
    local hum = _Char:FindFirstChildOfClass("Humanoid")
    if hum and (hum.WalkSpeed > 50 or hum.JumpPower > 100) then
        _Dbg:Label("Warning: Possible anti-cheat detection!")
        _Cn:Disconnect()
        _W:Destroy()
    end
end
_RunSvc.Stepped:Connect(_ChkAntiCheat)

-- Character Reset Handling
_Ply.CharacterAdded:Connect(function(newChar)
    _Char = newChar
end)

-- Cleanup
game:BindToClose(function()
    _Cn:Disconnect()
    ShklsChangedConnection:Disconnect()
end)

-- Startup
xpcall(function()
    _Dbg:Label("Elite Script Loaded!")
end, function(err)
    _Dbg:Label("Error: " .. tostring(err))
end)
