getgenv().ShowFPS = true -- Bật/Tắt hiển thị FPS
getgenv().HideLeaderboard = true -- [MỚI] Bật/Tắt che tên trên bảng xếp hạng (50%)

-- Lấy dịch vụ
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 

-- CẤU HÌNH GIAO DIỆN
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 24 
local NOTE_FONT_SIZE = 30 

-- [UPDATE] Hàm che tên (Xử lý cho cả UI và Leaderboard)
local function obscureString(str, percent)
    local len = #str
    if len <= 3 then return str end -- Tên quá ngắn thì không che
    
    local obscurePercent = percent or 0.50 -- Mặc định che 50%
    local keepPercent = (1 - obscurePercent) / 2 
    
    local startKeep = math.floor(len * keepPercent)
    local endKeep = math.floor(len * keepPercent)
    
    -- Đảm bảo ít nhất lộ 1 ký tự đầu/cuối
    if startKeep < 1 then startKeep = 1 end
    if endKeep < 1 then endKeep = 1 end
    
    local obscureLength = len - startKeep - endKeep
    if obscureLength < 1 then obscureLength = 1 end
    
    local startPart = str:sub(1, startKeep)
    local endPart = str:sub(len - endKeep + 1, len)
    local obscurePart = string.rep("*", obscureLength)
    
    return startPart .. obscurePart .. endPart
end

local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

-- Hàm đọc/lưu file
local function readConfig(fileName)
    if readfile then
        local success, content = pcall(readfile, fileName)
        if success and content and content ~= "" then
            return content
        end
    end
    return "" 
end

local function saveConfig(fileName, content)
    if writefile then
        pcall(writefile, fileName, content)
    end
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    
    -- 2. Outer Frame (Khung ngoài)
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    
    -- [UPDATE] Chiều rộng tăng lên 0.7 (70% màn hình) cho rộng rãi
    -- Nếu bạn muốn to hơn nữa, chỉnh số 0.7 thành số khác (Max là 1.0)
    outerFrame.Size = UDim2.new(0.7, 0, 0.15, 0) 
    
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
    
    -- 3. Inner Frame 
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

    -- A. Username Label (Giữ vị trí cũ)
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernamePart"
    usernameLabel.Size = UDim2.new(1, 0, 0.2, 0) 
    usernameLabel.Text = "Username: " .. obscureString(USERNAME, 0.5) -- Che 50%
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextScaled = false 
    usernameLabel.TextSize = FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Center 
    usernameLabel.Parent = innerFrame

    -- [FPS] Nằm đè lên UsernameLabel nhưng dính sát lề phải
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0, 100, 1, 0) 
    fpsLabel.Position = UDim2.new(1, -15, 0, 0) -- Cách lề phải 15px
    fpsLabel.AnchorPoint = Vector2.new(1, 0) 
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127) 
    fpsLabel.TextScaled = false
    fpsLabel.TextSize = FONT_SIZE
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right 
    fpsLabel.Parent = usernameLabel 

    -- B. Note ScrollingFrame
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Name = "NoteScrollingFrame"
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.7, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 6
    noteScrollingFrame.ClipsDescendants = true 
    noteScrollingFrame.Parent = innerFrame

    -- C. Note TextBox
    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Name = "NoteTextBox"
    noteTextBox.Size = UDim2.new(1, -15, 0, 0) 
    noteTextBox.Position = UDim2.new(0, 5, 0, 0) 
    
    local currentNote = readConfig(CONFIG_FILE_NAME)
    noteTextBox.Text = currentNote
    
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
        local textBounds = TextService:GetTextSize(
            noteTextBox.Text,
            NOTE_FONT_SIZE,
            Enum.Font.SourceSans,
            Vector2.new(noteScrollingFrame.AbsoluteSize.X - 20, 10000) 
        )
        local requiredHeight = textBounds.Y + 30 
        local frameHeight = noteScrollingFrame.AbsoluteSize.Y
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(requiredHeight, frameHeight))
        noteTextBox.Size = UDim2.new(1, -15, 0, math.max(requiredHeight, frameHeight))
    end

    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    noteTextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize) 
    
    task.delay(0.1, updateCanvasSize)
    
    noteTextBox.FocusLost:Connect(function()
        updateCanvasSize() 
        saveConfig(CONFIG_FILE_NAME, noteTextBox.Text)
    end)

    -- LOGIC 1: FPS
    task.spawn(function()
        local lastUpdate = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            if tick() - lastUpdate >= 0.5 then
                lastUpdate = tick()
                if getgenv().ShowFPS then
                    local fps = math.floor(1 / deltaTime)
                    fpsLabel.Text = "FPS: " .. fps
                    fpsLabel.Visible = true
                else
                    fpsLabel.Visible = false
                end
            end
        end)
    end)

    -- LOGIC 2: ẨN TÊN TRÊN LEADERBOARD (DisplayName)
    if getgenv().HideLeaderboard then
        task.spawn(function()
            -- Hàm đổi tên hiển thị local
            local function maskPlayer(player)
                if player then
                    -- Chỉ đổi DisplayName (Tên hiển thị trên đầu và Tablist)
                    -- Che 50% tên gốc
                    local masked = obscureString(player.Name, 0.50) 
                    player.DisplayName = masked
                end
            end

            -- Quét danh sách người chơi liên tục mỗi 2 giây để cập nhật người mới vào
            while task.wait(2) do
                for _, p in pairs(Players:GetPlayers()) do
                    maskPlayer(p)
                end
            end
        end)
    end
    
    -- LOGIC 3: HIỆU ỨNG CẦU VỒNG
    local function animateRainbowBorder()
        local h = 0 
        local speed = 0.02
        while true do
            h = h + speed
            if h > 1 then h = 0 end
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
