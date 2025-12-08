-- Lấy dịch vụ Players, LocalPlayer và RunService
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 24 -- Kích thước font cố định

local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

-- Hàm giả định để đọc/lưu nội dung file
local function readConfig(fileName)
    if readfile then
        local success, content = pcall(readfile, fileName)
        if success and content and content ~= "" then
            return content
        end
    end
    return "Nhập nội dung ghi chú tùy chỉnh của bạn ở đây!" 
end

local function saveConfig(fileName, content)
    if writefile then
        pcall(writefile, fileName, content)
        print("Đã lưu nội dung vào: " .. fileName)
    else
        warn("Không thể lưu file. Hàm writefile không khả dụng.")
    end
end

-- HÀM CHE 60% TÊN
local function obscureUsername(username)
    local len = #username
    if len <= 5 then return username end 

    local obscurePercent = 0.40 
    local keepPercent = (1 - obscurePercent) / 2 

    local startKeep = math.floor(len * keepPercent)
    local endKeep = math.floor(len * keepPercent)
    local obscureLength = len - startKeep - endKeep

    if obscureLength < 0 then obscureLength = 0 end
    
    local startPart = username:sub(1, startKeep)
    local endPart = username:sub(len - endKeep + 1, len)
    local obscureString = string.rep("*", obscureLength)

    return startPart .. obscureString .. endPart
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    -- 1. Cấu hình ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    
    -- 2. TẠO FRAME NGOÀI (OUTER FRAME)
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    outerFrame.Size = UDim2.new(0.5, 0, 0.125, 0) 
    outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
    outerFrame.AnchorPoint = Vector2.new(0.5, 0)
    outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    outerFrame.BorderSizePixel = 0
    outerFrame.BackgroundTransparency = transparencyLevel
    outerFrame.ClipsDescendants = false -- Quan trọng: Để chữ hiển thị được bên ngoài khung
    outerFrame.Parent = screenGui
    
    -- KÉO THẢ (DRAGGABLE)
    outerFrame.Active = true 
    outerFrame.Draggable = true 

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, outerCornerRadius)
    outerCorner.Parent = outerFrame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Rotation = 0
    uiGradient.Parent = outerFrame
    
    -- === [MỚI] TEXT CREDIT: SCRIPT BY HUYUNFES ===
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Name = "CreditLabel"
    creditLabel.Text = "Script by HuyUnfes"
    creditLabel.BackgroundTransparency = 1
    creditLabel.TextSize = 14 -- Font nhỏ
    creditLabel.Font = Enum.Font.SourceSansBold -- Font đậm
    creditLabel.TextColor3 = Color3.new(1, 1, 1) -- Màu trắng cơ bản (sẽ bị gradient ghi đè)
    creditLabel.Size = UDim2.new(0, 0, 0, 20) -- Chiều cao cố định
    creditLabel.AutomaticSize = Enum.AutomaticSize.X -- Tự động chỉnh chiều ngang theo độ dài tên
    
    -- Căn chỉnh vị trí: Góc dưới phải của label neo vào góc trên phải của khung
    creditLabel.AnchorPoint = Vector2.new(1, 1) 
    creditLabel.Position = UDim2.new(1, 0, 0, -3) -- Nằm ngay mép phải, cách mép trên 3 pixel
    creditLabel.Parent = outerFrame -- Làm con của outerFrame để di chuyển cùng khi kéo thả

    -- Tạo Gradient cho chữ để có màu cầu vồng
    local creditGradient = Instance.new("UIGradient")
    creditGradient.Rotation = 0
    creditGradient.Parent = creditLabel
    -- =============================================

    -- 3. TẠO FRAME TRONG (INNER FRAME)
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerBlackBackground"
    innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
    innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    innerFrame.BorderSizePixel = 0
    innerFrame.BackgroundTransparency = transparencyLevel
    innerFrame.Parent = outerFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5) 
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = innerFrame

    local innerCorner = Instance.new("UICorner")
    local innerRadius = outerCornerRadius - borderThickness
    innerCorner.CornerRadius = UDim.new(0, innerRadius) 
    innerCorner.Parent = innerFrame

    -- A. PHẦN USERNAME
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernamePart"
    usernameLabel.Size = UDim2.new(1, 0, 0.2, 0)
    usernameLabel.Text = "Username: " .. obscureUsername(USERNAME) 
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextScaled = false 
    usernameLabel.TextSize = FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextYAlignment = Enum.TextYAlignment.Top 
    usernameLabel.Parent = innerFrame

    -- B. PHẦN NOTE
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Name = "NoteScrollingFrame"
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.75, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 6
    noteScrollingFrame.Parent = innerFrame

    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Name = "NoteTextBox"
    noteTextBox.Size = UDim2.new(1, 0, 2, 0) 
    
    local currentNote = readConfig(CONFIG_FILE_NAME)
    noteTextBox.Text = "Note:\n" .. currentNote
    
    noteTextBox.TextColor3 = Color3.new(1, 1, 1)
    noteTextBox.TextScaled = false 
    noteTextBox.MultiLine = true    
    noteTextBox.TextWrapped = true 
    noteTextBox.TextSize = FONT_SIZE 
    noteTextBox.Font = Enum.Font.SourceSans
    noteTextBox.BackgroundTransparency = 1
    noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
    noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
    noteTextBox.Parent = noteScrollingFrame
    
    local function updateCanvasSize()
        local textSize = noteTextBox.TextBounds.Y
        local requiredHeight = textSize + 20 
        local frameHeight = noteScrollingFrame.AbsoluteSize.Y

        if requiredHeight > frameHeight then
             noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, requiredHeight)
        else
             noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, frameHeight)
        end
        noteTextBox.Size = UDim2.new(1, 0, 0, math.max(frameHeight, requiredHeight))
    end

    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    updateCanvasSize()
    
    noteTextBox.FocusLost:Connect(function()
        updateCanvasSize() 
        local contentToSave = noteTextBox.Text:gsub("^Note:\n", "")
        saveConfig(CONFIG_FILE_NAME, contentToSave)
    end)
    
    print("Đã tải config cá nhân (" .. CONFIG_FILE_NAME .. "). UI đã được di chuyển lên cao hơn.")

    -- 5. HÀM TẠO HIỆU ỨNG CẦU VỒNG LIÊN TỤC
    local function animateRainbowBorder()
        local h = 0 
        local speed = 0.02

        while true do
            h = h + speed
            if h > 1 then h = 0 end
            
            local colorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
            })

            -- Cập nhật màu cho cả viền và chữ Credit
            uiGradient.Color = colorSequence
            creditGradient.Color = colorSequence -- [MỚI] Cập nhật màu cho chữ
            
            RunService.RenderStepped:Wait() 
        end
    end
    
    task.spawn(animateRainbowBorder)
end
