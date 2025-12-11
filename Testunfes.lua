-- Lấy dịch vụ Players, LocalPlayer và RunService
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH GIAO DIỆN
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local TITLE_FONT_SIZE = 24 -- Kích thước font cho Username
local NOTE_FONT_SIZE = 32  -- Kích thước font cho Note (ĐÃ TĂNG LÊN TO HƠN)
local CREDIT_FONT_SIZE = 14 -- Kích thước chữ by HuyUnfes

local USERNAME = localPlayer.Name
-- TÊN FILE CONFIG: Lưu theo tên người dùng Roblox
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

-- Hàm giả định để đọc nội dung file
local function readConfig(fileName)
    if readfile and isfile and isfile(fileName) then
        local success, content = pcall(readfile, fileName)
        if success and content then
            -- Xóa chữ "Note:" cũ nếu lỡ bị lưu vào file để tránh bị lặp
            content = content:gsub("^Note:\n", ""):gsub("^Note:", "")
            return content
        end
    end
    return "Nhập nội dung ghi chú tùy chỉnh của bạn ở đây!" 
end

-- Hàm lưu nội dung file (Tự động lọc bỏ chữ Note:)
local function saveConfig(fileName, content)
    if writefile then
        -- Loại bỏ dòng "Note:" ở đầu trước khi lưu
        local cleanContent = content:gsub("^Note:\n", ""):gsub("^Note:", "")
        pcall(writefile, fileName, cleanContent)
        print("Đã lưu nội dung vào: " .. fileName)
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
    return username:sub(1, startKeep) .. string.rep("*", obscureLength) .. username:sub(len - endKeep + 1, len)
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    -- Xóa UI cũ nếu có để tránh trùng lặp
    if playerGui:FindFirstChild("AnimatedRainbowBorderGUI") then
        playerGui.AnimatedRainbowBorderGUI:Destroy()
    end

    -- 1. Cấu hình ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    
    -- 2. TẠO FRAME NGOÀI (OUTER FRAME - VIỀN CẦU VỒNG)
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    outerFrame.Size = UDim2.new(0.5, 0, 0.4, 0) -- Tăng chiều cao lên chút để chứa font to
    outerFrame.Position = UDim2.new(0.5, 0, 0.2, 0) 
    outerFrame.AnchorPoint = Vector2.new(0.5, 0)
    outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    outerFrame.BorderSizePixel = 0
    outerFrame.BackgroundTransparency = transparencyLevel
    outerFrame.Parent = screenGui
    outerFrame.Active = true 
    outerFrame.Draggable = true 

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, outerCornerRadius)
    outerCorner.Parent = outerFrame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Parent = outerFrame
    
    -- 3. TẠO FRAME TRONG (INNER FRAME - NỀN ĐEN)
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
    innerCorner.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness) 
    innerCorner.Parent = innerFrame

    -- === THÊM PHẦN CREDIT: "by HuyUnfes" ===
    -- Đặt trong OuterFrame để dễ canh chỉnh góc phải trên cùng và không bị list layout làm lệch
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Name = "CreditLabel"
    creditLabel.Text = "by HuyUnfes"
    creditLabel.Size = UDim2.new(0, 100, 0, 20)
    -- Vị trí: Góc phải (1), Trên (0). Canh lề AnchorPoint (1, 0)
    creditLabel.Position = UDim2.new(1, -10, 0, 5) 
    creditLabel.AnchorPoint = Vector2.new(1, 0)
    creditLabel.BackgroundTransparency = 1
    creditLabel.Font = Enum.Font.FredokaOne -- Font đậm đẹp
    creditLabel.TextSize = CREDIT_FONT_SIZE
    creditLabel.ZIndex = 10 -- Luôn nổi lên trên
    creditLabel.Parent = outerFrame -- Parent vào OuterFrame để nằm đè lên viền hoặc góc

    -- A. PHẦN USERNAME
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernamePart"
    usernameLabel.Size = UDim2.new(1, 0, 0.15, 0)
    usernameLabel.Text = "Username: " .. obscureUsername(USERNAME) 
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextScaled = false 
    usernameLabel.TextSize = TITLE_FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Parent = innerFrame

    -- B. PHẦN NOTE (SCROLLINGFRAME)
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Name = "NoteScrollingFrame"
    noteScrollingFrame.Size = UDim2.new(1, -10, 0.8, 0) -- Trừ 10px để không dính mép
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 6
    noteScrollingFrame.Parent = innerFrame

    -- TEXTBOX NHẬP LIỆU
    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Name = "NoteTextBox"
    noteTextBox.Size = UDim2.new(1, 0, 1, 0) 
    
    -- XỬ LÝ LOAD TEXT
    local currentNote = readConfig(CONFIG_FILE_NAME)
    noteTextBox.Text = "Note:\n" .. currentNote -- Luôn đảm bảo format đúng
    
    noteTextBox.TextColor3 = Color3.new(1, 1, 1)
    noteTextBox.TextScaled = false 
    noteTextBox.MultiLine = true    
    noteTextBox.TextWrapped = true 
    noteTextBox.TextSize = NOTE_FONT_SIZE -- FONT TO (32)
    noteTextBox.Font = Enum.Font.SourceSans
    noteTextBox.BackgroundTransparency = 1
    noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
    noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
    noteTextBox.Parent = noteScrollingFrame
    
    -- HÀM CẬP NHẬT KÍCH THƯỚC THANH CUỘN (SCROLL)
    local function updateCanvasSize()
        -- Tính toán độ cao văn bản dựa trên font to
        local params = Instance.new("GetTextBoundsParams")
        params.Text = noteTextBox.Text
        params.Size = 32 -- Size của font
        params.Width = noteTextBox.AbsoluteSize.X
        params.Font = noteTextBox.Font
        
        -- Dùng TextBounds cơ bản (tương thích tốt hơn)
        local textSizeY = noteTextBox.TextBounds.Y
        
        -- Tăng chiều cao nếu text dài
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, textSizeY + 50)
        noteTextBox.Size = UDim2.new(1, 0, 0, math.max(noteScrollingFrame.AbsoluteSize.Y, textSizeY + 50))
    end

    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    noteTextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
    
    -- LƯU FILE KHI MẤT TIÊU ĐIỂM (BẤM RA NGOÀI)
    noteTextBox.FocusLost:Connect(function()
        updateCanvasSize() 
        saveConfig(CONFIG_FILE_NAME, noteTextBox.Text)
    end)
    
    -- Đợi 1 chút để UI load xong rồi update size lần đầu
    task.wait(0.1)
    updateCanvasSize()

    print("UI Loaded. Font size: " .. NOTE_FONT_SIZE)

    -- 5. HÀM ANIMATION CẦU VỒNG (CHO VIỀN VÀ CHỮ HUYUNFES)
    local function animateRainbow()
        local h = 0 
        local speed = 0.005 -- Tốc độ đổi màu

        while screenGui.Parent do -- Chỉ chạy khi GUI còn tồn tại
            h = h + speed
            if h > 1 then h = 0 end
            
            -- Màu hiện tại
            local color = Color3.fromHSV(h, 1, 1)

            -- 1. Update màu viền (Gradient)
            local colorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.5) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.2) % 1, 1, 1))
            })
            uiGradient.Color = colorSequence
            
            -- 2. Update màu chữ "by HuyUnfes" (Cầu vồng)
            creditLabel.TextColor3 = color

            RunService.RenderStepped:Wait() 
        end
    end
    
    task.spawn(animateRainbow)
end