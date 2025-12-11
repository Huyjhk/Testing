-- Lấy dịch vụ Players, LocalPlayer và RunService
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") -- Dùng để đo kích thước chữ chuẩn hơn

local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 24 
local NOTE_FONT_SIZE = 30 -- Font to theo yêu cầu

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
        print("Đã lưu: " .. fileName)
    end
end

-- Hàm che tên
local function obscureUsername(username)
    local len = #username
    if len <= 5 then return username end 
    local obscurePercent = 0.40 
    local keepPercent = (1 - obscurePercent) / 2 
    local startKeep = math.floor(len * keepPercent)
    local endKeep = math.floor(len * keepPercent)
    local obscureLength = len - startKeep - endKeep
    if obscureLength < 0 then obscureLength = 0 end
    return username:sub(1, startKeep) .. string.rep("*", obscureLength) .. username:sub(len - endKeep + 1, len)
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    
    -- 2. Outer Frame
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    outerFrame.Size = UDim2.new(0.5, 0, 0.15, 0) -- Tăng chiều cao tổng thể lên một chút để chứa font to
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
    
    -- 3. Inner Frame (QUAN TRỌNG: ClipsDescendants = true để cắt phần tràn)
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerBlackBackground"
    innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
    innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    innerFrame.BackgroundTransparency = transparencyLevel
    innerFrame.ClipsDescendants = true -- [FIX] Chống tràn ra ngoài khung
    innerFrame.Parent = outerFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5) 
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = innerFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)
    innerCorner.Parent = innerFrame

    -- A. Username Label
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernamePart"
    usernameLabel.Size = UDim2.new(1, 0, 0.2, 0)
    usernameLabel.Text = "Username: " .. obscureUsername(USERNAME) 
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextScaled = false 
    usernameLabel.TextSize = FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Parent = innerFrame

    -- B. Note ScrollingFrame
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Name = "NoteScrollingFrame"
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.7, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 6
    noteScrollingFrame.ClipsDescendants = true -- [FIX] Đảm bảo chữ cuộn bên trong
    noteScrollingFrame.Parent = innerFrame

    -- C. Note TextBox
    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Name = "NoteTextBox"
    
    -- [FIX QUAN TRỌNG] Chiều ngang là (1, -15) để trừ hao thanh cuộn, giúp TextWrapped hoạt động đúng
    noteTextBox.Size = UDim2.new(1, -15, 0, 0) 
    noteTextBox.Position = UDim2.new(0, 5, 0, 0) -- Cách lề trái 5px cho đẹp
    
    local currentNote = readConfig(CONFIG_FILE_NAME)
    noteTextBox.Text = currentNote
    
    -- Placeholder (Chữ mờ)
    noteTextBox.PlaceholderText = "Script by HuyUnfes"
    noteTextBox.PlaceholderColor3 = Color3.new(0.6, 0.6, 0.6)
    
    noteTextBox.TextColor3 = Color3.new(1, 1, 1)
    noteTextBox.TextScaled = false 
    noteTextBox.MultiLine = true    
    noteTextBox.TextWrapped = true -- Bắt buộc có để xuống dòng
    noteTextBox.TextSize = NOTE_FONT_SIZE 
    noteTextBox.Font = Enum.Font.SourceSans
    noteTextBox.BackgroundTransparency = 1
    noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
    noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
    noteTextBox.Parent = noteScrollingFrame
    
    -- HÀM CẬP NHẬT CHUẨN XÁC
    local function updateCanvasSize()
        -- Tính toán chiều cao thực tế của văn bản dựa trên độ rộng hiện tại
        local textBounds = TextService:GetTextSize(
            noteTextBox.Text,
            NOTE_FONT_SIZE,
            Enum.Font.SourceSans,
            Vector2.new(noteScrollingFrame.AbsoluteSize.X - 20, 10000) -- Trừ hao độ rộng để tính toán xuống dòng
        )
        
        local requiredHeight = textBounds.Y + 30 -- Thêm chút khoảng trống dưới cùng
        local frameHeight = noteScrollingFrame.AbsoluteSize.Y

        -- Cập nhật CanvasSize
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(requiredHeight, frameHeight))
        
        -- Cập nhật chiều cao TextBox bằng với Canvas để dễ nhập liệu
        noteTextBox.Size = UDim2.new(1, -15, 0, math.max(requiredHeight, frameHeight))
    end

    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    noteTextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize) -- Cập nhật khi thay đổi kích thước khung
    
    -- Gọi update lần đầu sau 1 khoảng nhỏ để UI load xong
    task.delay(0.1, updateCanvasSize)
    
    -- Logic lưu file
    noteTextBox.FocusLost:Connect(function()
        updateCanvasSize() 
        saveConfig(CONFIG_FILE_NAME, noteTextBox.Text)
    end)
    
    -- 5. Hiệu ứng cầu vồng
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
    
    print("Fix lỗi tràn chữ + Font to + Placeholder hoàn tất.")
end
