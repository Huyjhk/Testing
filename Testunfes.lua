-- ===============================================
--          HuyUnfess Custom Note Box GUI
-- ===============================================

-- Lấy dịch vụ Players, LocalPlayer và RunService
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") -- Dùng để tính toán kích thước văn bản

-- CẤU HÌNH GIAO DIỆN
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 30 -- Kích thước font chữ đã tăng
local PLACEHOLDER_TEXT = "Script by HuyUnfes" -- Chữ mờ yêu cầu

local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

-- Màu chữ mặc định và chữ mờ
local DefaultTextColor = Color3.new(1, 1, 1) -- Màu trắng
local PlaceholderColor = Color3.new(0.5, 0.5, 0.5) -- Màu xám mờ

-- ===============================================
--          CHỨC NĂNG ĐỌC/LƯU FILE
-- ===============================================

local function readConfig(fileName)
    if readfile then
        local success, content = pcall(readfile, fileName)
        if success and content and content ~= "" and content ~= PLACEHOLDER_TEXT then
            return content
        end
    end
    return PLACEHOLDER_TEXT
end

local function saveConfig(fileName, content)
    -- Chỉ lưu nếu nội dung KHÔNG phải là chữ mờ và không trống
    if content ~= PLACEHOLDER_TEXT and content ~= "" then
        if writefile then
            pcall(writefile, fileName, content)
            print("Đã lưu nội dung vào: " .. fileName)
        else
            warn("Không thể lưu file. Hàm writefile không khả dụng.")
        end
    else
        -- Xóa file nếu nội dung là chữ mờ hoặc trống
        if delfile then
             pcall(delfile, fileName)
             print("Đã xóa file config trống: " .. fileName)
        end
    end
end

-- HÀM CHE TÊN (Obscure Username)
local function obscureUsername(username)
    local len = #username
    if len <= 5 then return username end 

    local obscurePercent = 0.60 
    local keepLength = math.floor(len * (1 - obscurePercent))
    local startKeep = math.floor(keepLength / 2)
    local endKeep = len - math.ceil(keepLength / 2)

    local prefix = username:sub(1, startKeep)
    local suffix = username:sub(endKeep + 1)
    local obscurePart = string.rep("*", len - startKeep - (len - endKeep))
    
    return prefix .. obscurePart .. suffix
end

-- ===============================================
--          KHỞI TẠO GIAO DIỆN (GUI)
-- ===============================================

-- 1. TẠO SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HuyUnfesNoteBoxGUI"
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- 2. KHUNG CHÍNH (FRAME)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "NoteBoxFrame"
mainFrame.Size = UDim2.new(0.3, 0, 0.45, 0) 
mainFrame.Position = UDim2.new(0.5, 0, 0.4, 0) 
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
mainFrame.BackgroundTransparency = transparencyLevel
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, outerCornerRadius)
UICornerMain.Parent = mainFrame

-- 3. KHU VỰC GHI CHÚ (NOTE BOX)
local noteScrollingFrame = Instance.new("ScrollingFrame")
noteScrollingFrame.Name = "NoteScroll"
noteScrollingFrame.Size = UDim2.new(1, -borderThickness*2, 1, -borderThickness*2 - 40) 
noteScrollingFrame.Position = UDim2.new(0, borderThickness, 40, borderThickness) 
noteScrollingFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
noteScrollingFrame.BackgroundTransparency = 0.1
noteScrollingFrame.BorderSizePixel = 0
noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
noteScrollingFrame.ScrollBarThickness = 6
noteScrollingFrame.Parent = mainFrame

local UICornerScroll = Instance.new("UICorner")
UICornerScroll.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)
UICornerScroll.Parent = noteScrollingFrame

-- Text Box chứa nội dung ghi chú
local noteTextBox = Instance.new("TextBox")
noteTextBox.Name = "NoteContent"
noteTextBox.Parent = noteScrollingFrame
noteTextBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
noteTextBox.Size = UDim2.new(1, 0, 1, 0) 
noteTextBox.Position = UDim2.new(0, 0, 0, 0)
noteTextBox.Text = readConfig(CONFIG_FILE_NAME) 

noteTextBox.PlaceholderText = PLACEHOLDER_TEXT 
noteTextBox.PlaceholderColor3 = PlaceholderColor 
noteTextBox.TextSize = FONT_SIZE 
noteTextBox.Font = Enum.Font.Code 
noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
noteTextBox.MultiLine = true
noteTextBox.TextWrapped = true 
noteTextBox.ClearTextOnFocus = false 

-- Quản lý màu chữ ban đầu
if noteTextBox.Text == PLACEHOLDER_TEXT then
    noteTextBox.TextColor3 = PlaceholderColor
else
    noteTextBox.TextColor3 = DefaultTextColor
end

-- 4. TIÊU ĐỀ (HEADER)
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 40) 
headerFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
headerFrame.BackgroundTransparency = transparencyLevel / 2
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerText = Instance.new("TextLabel")
headerText.Name = "Title"
headerText.Size = UDim2.new(1, 0, 1, 0)
headerText.BackgroundTransparency = 1
headerText.Font = Enum.Font.SourceSansBold
headerText.TextSize = 20
headerText.TextColor3 = Color3.new(1, 1, 1)
headerText.Text = "📝 Note Box - User: " .. obscureUsername(USERNAME) 
headerText.Parent = headerFrame

-- ===============================================
--          LOGIC TƯƠNG TÁC
-- ===============================================

-- HÀM CẬP NHẬT KÍCH THƯỚC CANVAS ĐỂ CUỘN (SCROLLING)
local function updateCanvasSize()
    
    -- SỬA LỖI KHỞI TẠO: Kiểm tra an toàn trước khi truy cập kích thước tuyệt đối
    if noteScrollingFrame.AbsoluteSize.X == 0 then
        return 
    end
    
    local text = noteTextBox.Text
    local frameWidth = noteScrollingFrame.AbsoluteSize.X
    local frameHeight = noteScrollingFrame.AbsoluteSize.Y
    
    -- Thiết lập chiều cao tối thiểu là chiều cao của Frame
    local requiredHeight = frameHeight 

    -- Nếu có nội dung (bao gồm cả chữ mờ)
    if text ~= "" then
        
        -- Sử dụng GetTextSize để tính toán chiều cao cần thiết
        local textBounds = TextService:GetTextSize(
            text,
            FONT_SIZE, 
            noteTextBox.Font,
            Vector2.new(frameWidth - 6, 10000) -- Trừ padding/scrollbar nhỏ
        )
        
        requiredHeight = textBounds.Y + 10 
    end
    
    -- HỢP NHẤT LOGIC CẬP NHẬT (Sửa lỗi logic tính toán Dòng 185)
    
    -- Đảm bảo CanvasSize và TextBox Size tối thiểu là Frame Height
    local finalCanvasHeight = math.max(frameHeight, requiredHeight)
    
    -- 1. Cập nhật CanvasSize để cho phép cuộn
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, finalCanvasHeight)

    -- 2. Cập nhật Size của TextBox bằng với CanvasSize height
    noteTextBox.Size = UDim2.new(1, 0, 0, finalCanvasHeight)
end

-- KẾT NỐI SỰ KIỆN

noteTextBox.Focused:Connect(function()
    if noteTextBox.Text == PLACEHOLDER_TEXT then
        noteTextBox.Text = "" -- Xóa chữ mờ
        noteTextBox.TextColor3 = DefaultTextColor -- Đổi sang màu trắng
    end
end)

noteTextBox.FocusLost:Connect(function()
    if noteTextBox.Text == "" then
        noteTextBox.Text = PLACEHOLDER_TEXT -- Khôi phục chữ mờ
        noteTextBox.TextColor3 = PlaceholderColor -- Đổi sang màu xám mờ
    else
        noteTextBox.TextColor3 = DefaultTextColor -- Đảm bảo là màu trắng
    end
    
    updateCanvasSize() 
    local contentToSave = noteTextBox.Text
    saveConfig(CONFIG_FILE_NAME, contentToSave) 
end)

-- Kết nối sự kiện thay đổi Text
noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)

-- Khắc phục lỗi khởi tạo (Sửa lỗi Dòng 170)
task.wait(0.1) 
updateCanvasSize() 
    
print("Đã tải config cá nhân (" .. CONFIG_FILE_NAME .. "). Giao diện đã sẵn sàng.")

-- 5. HÀM TẠO HIỆU ỨNG CẦU VỒNG LIÊN TỤC (RAINBOW BORDER)
local function animateRainbowBorder()
    local h = 0 
    local speed = 0.02
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = headerFrame

    while mainFrame.Parent do
        h = h + speed
        if h > 1 then 
            h = 0 
        end
        
        local colorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(math.fmod(h + 0.5, 1), 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
        })
        
        UIGradient.Color = colorSequence
        UIGradient.Rotation = 90
        
        RunService.Heartbeat:Wait()
    end
end

-- Chạy hiệu ứng cầu vồng
spawn(animateRainbowBorder)
