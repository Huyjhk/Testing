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
local FONT_SIZE = 30 -- CHỈNH SỬA: Tăng kích thước font chữ
local PLACEHOLDER_TEXT = "Script by HuyUnfes" -- CHỈNH SỬA: Định nghĩa chữ mờ

local USERNAME = localPlayer.Name
-- TÊN FILE CONFIG: Lưu theo tên người dùng Roblox (ví dụ: user_name.txt)
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

-- ===============================================
--          CHỨC NĂNG ĐỌC/LƯU FILE
-- ===============================================

-- Hàm đọc nội dung file config
local function readConfig(fileName)
    if readfile then
        local success, content = pcall(readfile, fileName)
        -- Trả về nội dung nếu đọc thành công và không trống
        if success and content and content ~= "" and content ~= PLACEHOLDER_TEXT then
            return content
        end
    end
    -- CHỈNH SỬA: Trả về chữ mờ nếu không tìm thấy config hoặc file trống
    return PLACEHOLDER_TEXT
end

-- Hàm lưu nội dung vào file config
local function saveConfig(fileName, content)
    -- CHỈNH SỬA: Chỉ lưu nếu nội dung KHÔNG phải là chữ mờ
    if content ~= PLACEHOLDER_TEXT and content ~= "" then
        if writefile then
            pcall(writefile, fileName, content)
            print("Đã lưu nội dung vào: " .. fileName)
        else
            warn("Không thể lưu file. Hàm writefile không khả dụng.")
        end
    else
        -- Xóa file nếu nội dung là chữ mờ hoặc trống để không lưu rác
        if delfile then
             pcall(delfile, fileName)
             print("Đã xóa file config trống: " .. fileName)
        end
    end
end

-- ===============================================
--          HÀM CHE TÊN (Obscure Username)
-- ===============================================

-- Hàm che khoảng 60% tên người dùng
local function obscureUsername(username)
    local len = #username
    if len <= 5 then return username end 

    -- Giữ lại khoảng 40% tên (20% đầu và 20% cuối)
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
mainFrame.Size = UDim2.new(0.3, 0, 0.45, 0) -- 30% chiều rộng, 45% chiều cao màn hình
mainFrame.Position = UDim2.new(0.5, 0, 0.4, 0) -- Căn giữa màn hình (40% từ trên xuống)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
mainFrame.BackgroundTransparency = transparencyLevel
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui

-- Thêm Corner Radius vào Frame
local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, outerCornerRadius)
UICornerMain.Parent = mainFrame

-- 3. KHU VỰC GHI CHÚ (NOTE BOX)
local noteScrollingFrame = Instance.new("ScrollingFrame")
noteScrollingFrame.Name = "NoteScroll"
noteScrollingFrame.Size = UDim2.new(1, -borderThickness*2, 1, -borderThickness*2 - 40) -- Kích thước bên trong, trừ Header và Border
noteScrollingFrame.Position = UDim2.new(0, borderThickness, 40, borderThickness) -- Đặt dưới Header
noteScrollingFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
noteScrollingFrame.BackgroundTransparency = 0.1
noteScrollingFrame.BorderSizePixel = 0
noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Sẽ được cập nhật động
noteScrollingFrame.ScrollBarThickness = 6
noteScrollingFrame.Parent = mainFrame

-- Corner Radius cho ScrollFrame
local UICornerScroll = Instance.new("UICorner")
UICornerScroll.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)
UICornerScroll.Parent = noteScrollingFrame

-- Text Box chứa nội dung ghi chú
local noteTextBox = Instance.new("TextBox")
noteTextBox.Name = "NoteContent"
noteTextBox.Parent = noteScrollingFrame
noteTextBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
noteTextBox.Size = UDim2.new(1, 0, 1, 0) -- Kích thước ban đầu, sẽ được cập nhật
noteTextBox.Position = UDim2.new(0, 0, 0, 0)
noteTextBox.TextColor3 = Color3.new(1, 1, 1) -- Màu chữ trắng
noteTextBox.Text = readConfig(CONFIG_FILE_NAME) -- Lấy nội dung đã lưu hoặc chữ mờ

-- CHỈNH SỬA: Cấu hình Placeholder và Font Size
noteTextBox.PlaceholderText = PLACEHOLDER_TEXT -- Chữ mờ
noteTextBox.PlaceholderColor3 = Color3.new(0.5, 0.5, 0.5) -- Màu xám mờ
noteTextBox.TextSize = FONT_SIZE -- Sử dụng FONT_SIZE mới
noteTextBox.Font = Enum.Font.Code -- Font code dễ đọc hơn
noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
noteTextBox.MultiLine = true
noteTextBox.TextWrapped = true -- Đảm bảo văn bản được gói lại
noteTextBox.ClearTextOnFocus = false -- Quan trọng: Cần tắt để tự quản lý Placeholder

-- 4. TIÊU ĐỀ (HEADER)
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 40) -- Chiều cao cố định 40px
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
headerText.Text = "📝 Note Box - User: " .. obscureUsername(USERNAME) -- Sử dụng tên người dùng bị che
headerText.Parent = headerFrame

-- ===============================================
--          LOGIC TƯƠNG TÁC
-- ===============================================

-- HÀM CẬP NHẬT KÍCH THƯỚC CANVAS ĐỂ CUỘN (SCROLLING)
local function updateCanvasSize()
    local text = noteTextBox.Text
    local frameWidth = noteScrollingFrame.AbsoluteSize.X
    local frameHeight = noteScrollingFrame.AbsoluteSize.Y

    -- Dùng GetTextSize để tính toán chiều cao cần thiết của văn bản
    local textBounds = TextService:GetTextSize(
        text,
        FONT_SIZE, -- Sử dụng FONT_SIZE đã tăng
        noteTextBox.Font,
        Vector2.new(frameWidth, 10000) -- Chiều rộng cố định, chiều cao rất lớn
    )

    local requiredHeight = textBounds.Y + 10 -- Cộng thêm padding nhỏ

    -- Đảm bảo CanvasSize đủ lớn để cuộn
    if requiredHeight > frameHeight then
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, requiredHeight)
    else
         -- Nếu không cần cuộn, chỉ cần bằng kích thước Frame
         noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, frameHeight)
    end
    
    -- Cập nhật Size của TextBox bằng với CanvasSize height (hoặc tối thiểu là Frame height)
    noteTextBox.Size = UDim2.new(1, 0, 0, math.max(frameHeight, requiredHeight))
end

-- KẾT NỐI SỰ KIỆN

-- CHỈNH SỬA: Xử lý khi người dùng Focus vào TextBox (Xóa chữ mờ)
noteTextBox.Focused:Connect(function()
    if noteTextBox.Text == PLACEHOLDER_TEXT then
        noteTextBox.Text = "" -- Xóa chữ mờ khi bắt đầu nhập
    end
end)

-- CHỈNH SỬA: Xử lý khi người dùng Focus Lost (Khôi phục chữ mờ và Lưu file)
noteTextBox.FocusLost:Connect(function()
    if noteTextBox.Text == "" then
        noteTextBox.Text = PLACEHOLDER_TEXT -- Khôi phục chữ mờ nếu không có nội dung
    end
    
    updateCanvasSize() -- Cập nhật lần cuối trước khi lưu
    local contentToSave = noteTextBox.Text
    saveConfig(CONFIG_FILE_NAME, contentToSave) -- Hàm saveConfig sẽ xử lý việc không lưu chữ mờ
end)

-- Kết nối sự kiện thay đổi Text và chạy lần đầu
noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
-- Cần đợi 1 frame để kích thước AbsoluteSize được tính toán
RunService.Heartbeat:Wait() 
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
        
        -- Tạo dải màu cầu vồng (Gradient)
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
