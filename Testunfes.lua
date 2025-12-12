getgenv().ShowFPS = true 
getgenv().HideLeaderboard = true -- Bật true để che tên trên Tab Leaderboard

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 

local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 24 
local NOTE_FONT_SIZE = 30 

-- HÀM CHE TÊN (Giữ lại đầu và đuôi, che giữa)
local function generateMaskedName(str)
    local len = #str
    if len <= 3 then return str end 
    local obscureLength = math.ceil(len / 2) -- Che 50%
    local visibleLen = len - obscureLength
    local startLen = math.ceil(visibleLen / 2)
    local endLen = visibleLen - startLen
    
    return str:sub(1, startLen) .. string.rep("*", obscureLength) .. str:sub(len - endLen + 1, len)
end

local USERNAME = localPlayer.Name
local MASKED_USERNAME = generateMaskedName(USERNAME)
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

-- Đọc/Lưu file
local function readConfig(fileName)
    if readfile then
        local success, content = pcall(readfile, fileName)
        if success and content and content ~= "" then return content end
    end
    return "" 
end
local function saveConfig(fileName, content)
    if writefile then pcall(writefile, fileName, content) end
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    -- 1. SETUP GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    -- Chiều rộng để 0.8 (80% màn hình) là rất rộng rồi, 1.15 sẽ bị tràn ra ngoài màn hình
    outerFrame.Size = UDim2.new(0.8, 0, 0.15, 0) 
    outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
    outerFrame.AnchorPoint = Vector2.new(0.5, 0)
    outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    outerFrame.BackgroundTransparency = transparencyLevel
    outerFrame.Active = true 
    outerFrame.Draggable = true 
    outerFrame.Parent = screenGui
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, outerCornerRadius)
    outerCorner.Parent = outerFrame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Parent = outerFrame
    
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerBlackBackground"
    innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
    innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    innerFrame.BackgroundTransparency = transparencyLevel
    innerFrame.ClipsDescendants = true 
    innerFrame.Parent = outerFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5) 
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = innerFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)
    innerCorner.Parent = innerFrame

    -- HEADER: USERNAME + FPS
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, -20, 0.25, 0)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = innerFrame

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(0.7, 0, 1, 0)
    usernameLabel.Text = "User: " .. MASKED_USERNAME 
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextScaled = false
    usernameLabel.TextSize = FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left 
    usernameLabel.Parent = headerFrame

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0.3, 0, 1, 0)
    fpsLabel.Position = UDim2.new(1, 0, 0, 0)
    fpsLabel.AnchorPoint = Vector2.new(1, 0)
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127) 
    fpsLabel.TextScaled = false
    fpsLabel.TextSize = FONT_SIZE
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right 
    fpsLabel.Parent = headerFrame

    -- NOTE AREA
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.65, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 6
    noteScrollingFrame.ClipsDescendants = true 
    noteScrollingFrame.Parent = innerFrame

    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Size = UDim2.new(1, -15, 0, 0) 
    noteTextBox.Position = UDim2.new(0, 5, 0, 0) 
    noteTextBox.Text = readConfig(CONFIG_FILE_NAME)
    noteTextBox.PlaceholderText = "Script by HuyUnfes"
    noteTextBox.PlaceholderColor3 = Color3.new(0.6, 0.6, 0.6)
    noteTextBox.TextColor3 = Color3.new(1, 1, 1)
    noteTextBox.TextScaled = false 
    noteTextBox.MultiLine = true    
    noteTextBox.TextWrapped = true 
    noteTextBox.TextSize = NOTE_FONT_SIZE 
    noteTextBox.Font = Enum.Font.SourceSans
    noteTextBox.BackgroundTransparency = 1
    noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
    noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
    noteTextBox.Parent = noteScrollingFrame
    
    local function updateCanvasSize()
        local textBounds = TextService:GetTextSize(noteTextBox.Text, NOTE_FONT_SIZE, Enum.Font.SourceSans, Vector2.new(noteScrollingFrame.AbsoluteSize.X - 20, 10000))
        local h = math.max(textBounds.Y + 30, noteScrollingFrame.AbsoluteSize.Y)
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, h)
        noteTextBox.Size = UDim2.new(1, -15, 0, h)
    end
    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    noteTextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize) 
    task.delay(0.1, updateCanvasSize)
    noteTextBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteTextBox.Text) end)

    -- UPDATE FPS
    task.spawn(function()
        local lastUpdate = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            if tick() - lastUpdate >= 0.5 then
                lastUpdate = tick()
                if getgenv().ShowFPS then
                    fpsLabel.Text = "FPS: " .. math.floor(1 / deltaTime)
                else
                    fpsLabel.Text = ""
                end
            end
        end)
    end)

    -- [SỬA LẠI] LOGIC CHE TÊN TAB LEADERBOARD (Chỉ đổi DisplayName)
    if getgenv().HideLeaderboard then
        task.spawn(function()
            local function maskPlayer(player)
                -- Không che tên bản thân nếu không muốn, hoặc che luôn tùy bạn
                -- if player == localPlayer then return end 
                
                local originalName = player.Name
                local masked = generateMaskedName(originalName)
                
                -- Đổi tên hiển thị (Cách này tự động cập nhật Leaderboard và Tên trên đầu)
                -- Mà không ảnh hưởng UI game
                pcall(function()
                    player.DisplayName = masked
                end)
                
                -- Lắng nghe nếu game tự đổi lại thì mình đổi tiếp
                player:GetPropertyChangedSignal("DisplayName"):Connect(function()
                    if player.DisplayName ~= masked then
                        player.DisplayName = masked
                    end
                end)
            end

            -- Áp dụng cho người chơi hiện tại
            for _, p in pairs(Players:GetPlayers()) do
                maskPlayer(p)
            end
            
            -- Áp dụng cho người chơi mới vào
            Players.PlayerAdded:Connect(maskPlayer)
        end)
    end
    
    -- RAINBOW
    local function animateRainbowBorder()
        local h = 0 
        while true do
            h = (h + 0.01) % 1
            uiGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
            })
            RunService.RenderStepped:Wait() 
        end
    end
    task.spawn(animateRainbowBorder)
    
    print([[
|     |  |\    |  |''''  |''''  /''''\
|     |  | \   |  |___   |___   \____
|     |  |  \  |  |      |           \
\_____/  |   \ |  |      |____  \____/
    ]])
end
-- hi
