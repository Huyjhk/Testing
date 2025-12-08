-- Lấy dịch vụ Players, LocalPlayer và RunService
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 24 -- Kích thước font cố định (đồng nhất cho cả hai phần)

local USERNAME = localPlayer.Name
-- TÊN FILE CONFIG: Lưu theo tên người dùng Roblox (ví dụ: user_name.txt)
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

    if obscureLength < 0 then
        obscureLength = 0
    end
    
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
    outerFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Đã sửa lỗi viền trắng: Nền đen
    outerFrame.BorderSizePixel = 0
    outerFrame.BackgroundTransparency = 0 -- Đã sửa lỗi viền trắng: Bỏ trong suốt
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
    
    -- 3. TẠO FRAME TRONG (INNER FRAME) - NỀN ĐEN VÀ BỐ CỤC CHÍNH
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerBlackBackground"
    innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
    innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    innerFrame.BorderSizePixel = 0
    innerFrame.BackgroundTransparency = transparencyLevel
    innerFrame.Parent = outerFrame
    
    -- UIListLayout ĐỂ SẮP XẾP CÁC PHẦN DỌC (USERNAME trên, NOTE dưới)
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5) 
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = innerFrame

    local innerCorner = Instance.new("UICorner")
    local innerRadius = outerCornerRadius - borderThickness
    innerCorner.CornerRadius = UDim.new(0, innerRadius) 
    innerCorner.Parent = innerFrame

    -- A. PHẦN USERNAME (TEXTLABEL)
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

    -- B. PHẦN NOTE (SCROLLINGFRAME)
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Name = "NoteScrollingFrame"
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.75, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 6
    noteScrollingFrame.Parent = innerFrame

    -- TẠO TEXTBOX BÊN TRONG SCROLLING FRAME
    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Name = "NoteTextBox"
    noteTextBox.Size = UDim2.new(1, 0, 2, 0) 
    
    -- Tải nội dung đã lưu và thêm tiền tố "Note:\n"
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
    
    -- HÀM CẬP NHẬT KÍCH THƯỚC VẢI (CANVAS SIZE) ĐỂ CHO PHÉP CUỘN
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
    
    -- THÊM LOGIC LƯU FILE KHI NGƯỜI DÙNG KẾT THÚC NHẬP (Unfocused)
    noteTextBox.FocusLost:Connect(function()
        updateCanvasSize() 
        local contentToSave = noteTextBox.Text:gsub("^Note:\n", "")
        saveConfig(CONFIG_FILE_NAME, contentToSave)
    end)
    
    
    --- PHẦN 6: THÊM CHỮ KÝ (BY HUYUNFES) ---
    local signatureLabel = Instance.new("TextLabel")
    signatureLabel.Name = "SignatureLabel"
    signatureLabel.Text = "By HuyUnfes"
    signatureLabel.TextColor3 = Color3.new(1, 1, 1) -- Màu trắng
    signatureLabel.TextScaled = false
    signatureLabel.TextSize = 18 -- Kích thước chữ nhỏ
    signatureLabel.Font = Enum.Font.SourceSans
    signatureLabel.BackgroundTransparency = 1
    
    -- Đặt vị trí dựa trên outerFrame.Position và Size
    -- Position: Lấy vị trí Neo (0.5, 0.05) của outerFrame (ở giữa, sát trên)
    -- Sau đó đẩy label sang phải bằng nửa chiều rộng của outerFrame
    local frameWidthScale = outerFrame.Size.X.Scale
    local framePositionX = outerFrame.Position.X.Scale
    local framePositionY = outerFrame.Position.Y.Scale
    
    -- Vị trí: Ở góc trên bên phải của outerFrame
    signatureLabel.Position = UDim2.new(framePositionX + frameWidthScale / 2, -5, framePositionY, 0) -- -5 offset để dịch vào 1 chút
    signatureLabel.Size = UDim2.new(0, 100, 0, 20) -- Kích thước cố định (dài 100, cao 20)
    signatureLabel.AnchorPoint = Vector2.new(1, 0) -- Neo ở góc trên bên phải của label
    signatureLabel.TextXAlignment = Enum.TextXAlignment.Right -- Căn lề phải
    signatureLabel.Parent = screenGui
    
    
    print("Đã thêm chữ ký 'By HuyUnfes' ở góc trên bên phải.")

    -- 7. HÀM TẠO HIỆU ỨNG CẦU VỒNG LIÊN TỤC
    local function animateRainbowBorder()
        local h = 0 
        local speed = 0.02

        while true do
            h = h + speed
            if h > 1 then 
                h = 0 
            end
            
            local colorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
            })

            uiGradient.Color = colorSequence
            
            RunService.RenderStepped:Wait() 
        end
    end
    
    task.spawn(animateRainbowBorder)
end
