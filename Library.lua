local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("Jello") then
    return
end

local Jello = {}
local AllTabs = {}
local TabCount = 0
local ActiveModules = {}
local ActiveNotifications = {}

local GUIVisible = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Jello"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local TabsFolder = Instance.new("Folder")
TabsFolder.Parent = ScreenGui

local TabsContainer = Instance.new("Frame")
TabsContainer.Parent = TabsFolder
TabsContainer.BackgroundTransparency = 1
TabsContainer.Size = UDim2.new(1, 0, 1, 0)
TabsContainer.Visible = false

local ArrayListFolder = Instance.new("Folder")
ArrayListFolder.Parent = ScreenGui

local ArrayListContainer = Instance.new("Frame")
ArrayListContainer.Parent = ArrayListFolder
ArrayListContainer.AnchorPoint = Vector2.new(1, 0)
ArrayListContainer.AutomaticSize = Enum.AutomaticSize.Y
ArrayListContainer.BackgroundTransparency = 1
ArrayListContainer.Position = UDim2.new(1, -5, 0, -55)
ArrayListContainer.Size = UDim2.new(0, 250, 0, 0)
ArrayListContainer.Visible = false

local ArrayListHeader = Instance.new("Frame")
ArrayListHeader.Parent = ArrayListContainer
ArrayListHeader.BackgroundColor3 = Color3.new(0, 0, 0)
ArrayListHeader.BackgroundTransparency = 0.25
ArrayListHeader.BorderSizePixel = 0
ArrayListHeader.Position = UDim2.new(0, 0, 0, 0)
ArrayListHeader.Size = UDim2.new(1, 0, 0, 25)

local ArrayListHeaderText = Instance.new("TextLabel")
ArrayListHeaderText.Parent = ArrayListHeader
ArrayListHeaderText.BackgroundTransparency = 1
ArrayListHeaderText.Font = Enum.Font.Sarpanch
ArrayListHeaderText.Size = UDim2.new(1, 0, 1, 0)
ArrayListHeaderText.Text = "ArrayList"
ArrayListHeaderText.TextColor3 = Color3.new(1, 1, 1)
ArrayListHeaderText.TextSize = 20

local ArrayListDisplay = Instance.new("Frame")
ArrayListDisplay.Parent = ArrayListContainer
ArrayListDisplay.AutomaticSize = Enum.AutomaticSize.Y
ArrayListDisplay.BackgroundTransparency = 1
ArrayListDisplay.Position = UDim2.new(0, 0, 0, 25)
ArrayListDisplay.Size = UDim2.new(0, 250, 0, 0)
ArrayListDisplay.ZIndex = 10

local ArrayListLayout = Instance.new("UIListLayout")
ArrayListLayout.Parent = ArrayListDisplay
ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayListLayout.Padding = UDim.new(0, 0)
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder

function GetTextWidthAdvanced(Text, FontSize, Font, WrapWidth)
    FontSize = FontSize or 25
    Font = Font or Enum.Font.Sarpanch
    WrapWidth = WrapWidth or math.huge

    return TextService:GetTextSize(Text, FontSize, Font, Vector2.new(WrapWidth, math.huge)).X
end

local function RefreshArrayList()
    for _, v in pairs(ArrayListDisplay:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end

    table.sort(ActiveModules, function(A, B)
        local WidthA = GetTextWidthAdvanced(A, 20, Enum.Font.Sarpanch)
        local WidthB = GetTextWidthAdvanced(B, 20, Enum.Font.Sarpanch)

        if WidthA ~= WidthB then
            return WidthA > WidthB
        else
            return A < B
        end
    end)

    local IsArrayListOnRight = (ArrayListContainer.AbsolutePosition.X + ArrayListContainer.AbsoluteSize.X / 2) > (ScreenGui.AbsoluteSize.X / 2)

    if IsArrayListOnRight then
        ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    else
        ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    end

    for _, ModuleName in ipairs(ActiveModules) do
        local ActiveModule = Instance.new("TextLabel")
        ActiveModule.Parent = ArrayListDisplay
        ActiveModule.AutomaticSize = Enum.AutomaticSize.X
        ActiveModule.BackgroundColor3 = Color3.new(0, 0, 0)
        ActiveModule.BackgroundTransparency = 0.5
        ActiveModule.BorderSizePixel = 0
        ActiveModule.Font = Enum.Font.Sarpanch
        ActiveModule.Size = UDim2.new(0, 0, 0, 20)
        ActiveModule.Text = ModuleName
        ActiveModule.TextColor3 = Color3.new(1, 1, 1)
        ActiveModule.TextSize = 20
        ActiveModule.TextStrokeTransparency = 0.5
        ActiveModule.TextWrapped = false

        if IsArrayListOnRight then
            ActiveModule.TextXAlignment = Enum.TextXAlignment.Right
        else
            ActiveModule.TextXAlignment = Enum.TextXAlignment.Left
        end

        local TextPadding = Instance.new("UIPadding")
        TextPadding.Parent = ActiveModule
        TextPadding.PaddingLeft = UDim.new(0, 5)
        TextPadding.PaddingRight = UDim.new(0, 5)
    end
end

local NotificationsFolder = Instance.new("Folder")
NotificationsFolder.Parent = ScreenGui

local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.Parent = NotificationsFolder
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.Size = UDim2.new(1, 0, 1, 0)
NotificationsContainer.Visible = true

local function RepositionNotifications()
    for i, Data in ipairs(ActiveNotifications) do
        local y = -100 - ((i - 1) * 65)
        Data.y = y
        Data.frame:TweenPosition(UDim2.new(1, -10, 1, y), "Out", "Quad", 0.25, true)
    end
end

local function SendNotification(Title, Message, Duration)
    Duration = Duration or 3
    local y = -100 - (#ActiveNotifications * 65)

    local Notification = Instance.new("Frame")
    Notification.Parent = NotificationsContainer
    Notification.AnchorPoint = Vector2.new(1, 1)
    Notification.BackgroundColor3 = Color3.new(0, 0, 0)
    Notification.BackgroundTransparency = 0.25
    Notification.BorderSizePixel = 0
    Notification.Position = UDim2.new(1, 500, 1, y)
    Notification.Size = UDim2.new(0, 300, 0, 60)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Notification
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Sarpanch
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Size = UDim2.new(1, 0, 0, 25)
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TitleLabelPadding = Instance.new("UIPadding")
    TitleLabelPadding.Parent = TitleLabel
    TitleLabelPadding.PaddingTop = UDim.new(0, 5)
    TitleLabelPadding.PaddingLeft = UDim.new(0, 10)

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Parent = Notification
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Font = Enum.Font.Sarpanch
    MessageLabel.Position = UDim2.new(0, 0, 0, 25)
    MessageLabel.Size = UDim2.new(1, 0, 0, 25)
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Color3.new(1, 1, 1)
    MessageLabel.TextSize = 20
    MessageLabel.TextTransparency = 0.25
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left

    local MessageLabelPadding = Instance.new("UIPadding")
    MessageLabelPadding.Parent = MessageLabel
    MessageLabelPadding.PaddingLeft = UDim.new(0, 10)

    local DurationBarBackground = Instance.new("Frame")
    DurationBarBackground.Parent = Notification
    DurationBarBackground.BackgroundColor3 = Color3.new(1, 1, 1)
    DurationBarBackground.BackgroundTransparency = 0.75
    DurationBarBackground.BorderSizePixel = 0
    DurationBarBackground.Position = UDim2.new(0, 5, 1, -5)
    DurationBarBackground.Size = UDim2.new(1, -10, 0, 2)

    local DurationBar = Instance.new("Frame")
    DurationBar.Parent = DurationBarBackground
    DurationBar.BackgroundColor3 = Color3.new(1, 1, 1)
    DurationBar.BackgroundTransparency = 0
    DurationBar.BorderSizePixel = 0
    DurationBar.Position = UDim2.new(0, 0, 0, 0)
    DurationBar.Size = UDim2.new(1, 0, 1, 0)

    local Data = { frame = Notification, y = y }
    table.insert(ActiveNotifications, Data)

    Notification:TweenPosition(UDim2.new(1, -10, 1, y), "Out", "Quad", 0.3, true)

    local BarTweenInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local BarTween = TweenService:Create(DurationBar, BarTweenInfo, { Size = UDim2.new(0, 0, 1, 0) })
    BarTween:Play()

    task.delay(Duration, function()
        if Notification and Notification.Parent then
            local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local Tween = TweenService:Create(Notification, TweenInfo, { Position = UDim2.new(1, 500, 1, Data.y) })
            Tween:Play()
            Tween.Completed:Wait()
            if Notification then
                Notification:Destroy()
                for i, v in ipairs(ActiveNotifications) do
                    if v == Data then
                        table.remove(ActiveNotifications, i)
                        break
                    end
                end
                RepositionNotifications()
            end
        end
    end)
end

local TargetHUDFolder = Instance.new("Folder")
TargetHUDFolder.Parent = ScreenGui

local TargetHUDContainer = Instance.new("Frame")
TargetHUDContainer.Parent = TargetHUDFolder
TargetHUDContainer.BackgroundTransparency = 1
TargetHUDContainer.Position = UDim2.new(0.5, -125, 0, 775)
TargetHUDContainer.Size = UDim2.new(0, 250, 0, 75 + 25)
TargetHUDContainer.Visible = false

local TargetHUDHeader = Instance.new("Frame")
TargetHUDHeader.Parent = TargetHUDContainer
TargetHUDHeader.BackgroundColor3 = Color3.new(0, 0, 0)
TargetHUDHeader.BackgroundTransparency = 0.25
TargetHUDHeader.BorderSizePixel = 0
TargetHUDHeader.Position = UDim2.new(0, 0, 0, 0)
TargetHUDHeader.Size = UDim2.new(1, 0, 0, 25)

local TargetHUDHeaderText = Instance.new("TextLabel")
TargetHUDHeaderText.Parent = TargetHUDHeader
TargetHUDHeaderText.BackgroundTransparency = 1
TargetHUDHeaderText.Font = Enum.Font.Sarpanch
TargetHUDHeaderText.Size = UDim2.new(1, 0, 1, 0)
TargetHUDHeaderText.Text = "Target"
TargetHUDHeaderText.TextColor3 = Color3.new(1, 1, 1)
TargetHUDHeaderText.TextSize = 20

local TargetHUD = Instance.new("Frame")
TargetHUD.Parent = TargetHUDContainer
TargetHUD.BackgroundColor3 = Color3.new(0, 0, 0)
TargetHUD.BackgroundTransparency = 0.5
TargetHUD.BorderSizePixel = 0
TargetHUD.Position = UDim2.new(0, 0, 0, 25)
TargetHUD.Size = UDim2.new(0, 250, 0, 75)

local TargetPhoto = Instance.new("ImageLabel")
TargetPhoto.Parent = TargetHUD
TargetPhoto.BackgroundTransparency = 1
TargetPhoto.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
TargetPhoto.Position = UDim2.new(0, 10, 0, 12)
TargetPhoto.Size = UDim2.new(0, 50, 0, 50)

local TargetName = Instance.new("TextLabel")
TargetName.Parent = TargetHUD
TargetName.BackgroundTransparency = 1
TargetName.Font = Enum.Font.Sarpanch
TargetName.Position = UDim2.new(0.275, 0, 0.15, 0)
TargetName.Size = UDim2.new(0, 150, 0, 25)
TargetName.Text = "Roblox"
TargetName.TextColor3 = Color3.new(1, 1, 1)
TargetName.TextSize = 20
TargetName.TextXAlignment = Enum.TextXAlignment.Left

local HPBG = Instance.new("Frame")
HPBG.Parent = TargetHUD
HPBG.BackgroundColor3 = Color3.new(1, 1, 1)
HPBG.BackgroundTransparency = 0.85
HPBG.BorderSizePixel = 0
HPBG.Position = UDim2.new(0.275, 0, 0.5, 0)
HPBG.Size = UDim2.new(0, 150, 0, 10)

local HPBar = Instance.new("Frame")
HPBar.Parent = HPBG
HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
HPBar.BorderSizePixel = 0
HPBar.Position = UDim2.new(0, 0, 0, 0)
HPBar.Size = UDim2.new(0, 0, 1, 0)

local Typing = false

UIS.TextBoxFocused:Connect(function()
    Typing = true
end)

UIS.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

local function MakeDraggable(UIElement, DragHandle)
    local Dragging = false
    local DragStart, StartPosition
    local InputChangedConnection
    local InputEndedConnection

    DragHandle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if (DragHandle == TargetHUDHeader or DragHandle == ArrayListHeader) and not GUIVisible then
                return
            end

            Dragging = true
            DragStart = Input.Position
            StartPosition = UIElement.Position

            InputChangedConnection = UIS.InputChanged:Connect(function(InputChanged)
                if Dragging and InputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = InputChanged.Position - DragStart
                    UIElement.Position = UDim2.new(
                        StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                        StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
                    )
                    if UIElement == ArrayListContainer then
                        RefreshArrayList()
                    end
                end
            end)

            InputEndedConnection = UIS.InputEnded:Connect(function(InputEnded)
                if InputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    if InputChangedConnection then InputChangedConnection:Disconnect() end
                    if InputEndedConnection then InputEndedConnection:Disconnect() end
                end
            end)
        end
    end)
end

MakeDraggable(TargetHUDContainer, TargetHUDHeader)
MakeDraggable(ArrayListContainer, ArrayListHeader)

local MaxDistance = 15
local TargetHUDEnabled = false
local TargetHUDThread = nil

local function GetHealthColor(HealthPercent)
    local R = math.clamp(1 - HealthPercent, 0, 1)
    local G = math.clamp(HealthPercent, 0, 1)
    return Color3.new(R, G, 0)
end

local function IsAlive(Player)
    return Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.Humanoid.Health > 0
end

local function IsEnemy(Player)
    return Player and Player ~= LocalPlayer and (Player.Neutral or Player.Team ~= LocalPlayer.Team)
end

local function GetClosestPlayer()
    local ClosestPlayer, ClosestDistance = nil, MaxDistance
    for _, Player in ipairs(Players:GetPlayers()) do
        if IsAlive(LocalPlayer) and IsAlive(Player) and IsEnemy(Player) then
            local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if Distance < ClosestDistance then
                ClosestPlayer = Player
                ClosestDistance = Distance
            end
        end
    end
    return ClosestPlayer
end

function Jello:ToggleArrayList(State)
    if State == nil then
        ArrayListContainer.Visible = not ArrayListContainer.Visible
    else
        ArrayListContainer.Visible = State
    end
    ArrayListHeader.Visible = ArrayListContainer.Visible and GUIVisible
end

function Jello:ToggleTargetHUD(State)
    if State == nil then
        TargetHUDEnabled = not TargetHUDEnabled
    else
        TargetHUDEnabled = State
    end

    if TargetHUDEnabled then
        if not TargetHUDThread then
            TargetHUDThread = task.spawn(function()
                while TargetHUDEnabled do
                    task.wait()
                    local Target = GetClosestPlayer()
                    local ShouldShow = false

                    if IsAlive(Target) then
                        local Humanoid = Target.Character.Humanoid
                        local HP = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
                        TargetName.Text = Target.Name
                        HPBar.Size = UDim2.new(HP, 0, 1, 0)
                        HPBar.BackgroundColor3 = GetHealthColor(HP)
                        TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Target.UserId .. "&width=420&height=420&format=png"
                        ShouldShow = true
                    elseif GUIVisible then
                        TargetName.Text = "Roblox"
                        HPBar.Size = UDim2.new(1, 0, 1, 0)
                        HPBar.BackgroundColor3 = Color3.new(0, 1, 0)
                        TargetPhoto.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
                        ShouldShow = true
                    end

                    TargetHUDContainer.Visible = ShouldShow
                    TargetHUDHeader.Visible = true
                end
                TargetHUDContainer.Visible = false
                TargetHUDHeader.Visible = true
                TargetHUDThread = nil
            end)
        end
    else
        TargetHUDEnabled = false
        TargetHUDContainer.Visible = false
        TargetHUDHeader.Visible = true
    end
end

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Parent = game.Lighting
BlurEffect.Enabled = false
BlurEffect.Size = 50

local ModalButton = Instance.new("TextButton")
ModalButton.Parent = ScreenGui
ModalButton.BackgroundTransparency = 1
ModalButton.Modal = true
ModalButton.Size = UDim2.new()
ModalButton.Text = ""
ModalButton.Visible = false

UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.RightShift then
        GUIVisible = not GUIVisible
        ArrayListHeader.Visible = GUIVisible
        BlurEffect.Enabled = GUIVisible
        ModalButton.Visible = GUIVisible
        TabsContainer.Visible = GUIVisible
    end
end)

function Jello:AddTab(TabName)
    local TabFrame = Instance.new("Frame")
    TabFrame.Parent = TabsContainer
    TabFrame.AutomaticSize = Enum.AutomaticSize.Y
    TabFrame.BackgroundTransparency = 1
    TabFrame.Position = UDim2.new(0, 15 + TabCount * 260, 0, 15)
    TabFrame.Size = UDim2.new(0, 250, 0, 0)
    TabFrame.Visible = true
    TabCount += 1
    table.insert(AllTabs, TabFrame)

    local Header = Instance.new("TextButton")
    Header.Parent = TabFrame
    Header.AutoButtonColor = false
    Header.BackgroundColor3 = Color3.new(0, 0, 0)
    Header.BackgroundTransparency = 0.25
    Header.BorderSizePixel = 0
    Header.Font = Enum.Font.Sarpanch
    Header.Size = UDim2.new(0, 250, 0, 50)
    Header.Text = TabName or "Tab"
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.TextSize = 25
    Header.TextXAlignment = Enum.TextXAlignment.Left

    MakeDraggable(TabFrame, Header)

    local HeaderPadding = Instance.new("UIPadding")
    HeaderPadding.Parent = Header
    HeaderPadding.PaddingLeft = UDim.new(0, 25)

    local Modules = Instance.new("Frame")
    Modules.Parent = TabFrame
    Modules.AutomaticSize = Enum.AutomaticSize.Y
    Modules.BackgroundTransparency = 1
    Modules.Position = UDim2.new(0, 0, 0, 50)
    Modules.Size = UDim2.new(0, 250, 0, 0)
    Modules.Visible = false

    local ModulesListLayout = Instance.new("UIListLayout")
    ModulesListLayout.Parent = Modules
    ModulesListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Header.MouseButton2Click:Connect(function()
        Modules.Visible = not Modules.Visible
    end)

    local Tab = {}

    function Tab:CreateModule(CFG)
        local ModuleName = CFG.Name or "Module"
        local callback = CFG.Function

        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Parent = Modules
        ModuleContainer.AutomaticSize = Enum.AutomaticSize.Y
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Size = UDim2.new(1, 0, 0, 0)

        local ModuleLayout = Instance.new("UIListLayout")
        ModuleLayout.Parent = ModuleContainer
        ModuleLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local ModuleButton = Instance.new("TextButton")
        ModuleButton.Parent = ModuleContainer
        ModuleButton.AutoButtonColor = false
        ModuleButton.BackgroundColor3 = Color3.new(0, 0, 0)
        ModuleButton.BackgroundTransparency = 0.5
        ModuleButton.BorderSizePixel = 0
        ModuleButton.Font = Enum.Font.Sarpanch
        ModuleButton.Size = UDim2.new(1, 0, 0, 50)
        ModuleButton.Text = ModuleName
        ModuleButton.TextColor3 = Color3.new(1, 1, 1)
        ModuleButton.TextSize = 20
        ModuleButton.TextTransparency = 0.5
        ModuleButton.TextXAlignment = Enum.TextXAlignment.Left

        local ModulePadding = Instance.new("UIPadding")
        ModulePadding.Parent = ModuleButton
        ModulePadding.PaddingLeft = UDim.new(0, 25)

        local ModuleOptions = Instance.new("Frame")
        ModuleOptions.Parent = ModuleContainer
        ModuleOptions.AutomaticSize = Enum.AutomaticSize.Y
        ModuleOptions.BackgroundColor3 = Color3.new(0, 0, 0)
        ModuleOptions.BackgroundTransparency = 0.25
        ModuleOptions.BorderSizePixel = 0
        ModuleOptions.ClipsDescendants = true
        ModuleOptions.Size = UDim2.new(1, 0, 0, 0)
        ModuleOptions.Visible = false

        local ModuleOptionsLayout = Instance.new("UIListLayout")
        ModuleOptionsLayout.Parent = ModuleOptions
        ModuleOptionsLayout.Padding = UDim.new(0, 5)
        ModuleOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local ModuleOptionsPadding = Instance.new("UIPadding")
        ModuleOptionsPadding.Parent = ModuleOptions
        ModuleOptionsPadding.PaddingTop = UDim.new(0, 5)
        ModuleOptionsPadding.PaddingBottom = UDim.new(0, 5)

        local Bind = Instance.new("TextButton")
        Bind.Parent = ModuleOptions
        Bind.BackgroundTransparency = 1
        Bind.Font = Enum.Font.Sarpanch
        Bind.Size = UDim2.new(1, 0, 0, 25)
        Bind.Text = "Bind"
        Bind.TextColor3 = Color3.new(1, 1, 1)
        Bind.TextSize = 20
        Bind.TextXAlignment = Enum.TextXAlignment.Left

        local BindPadding = Instance.new("UIPadding")
        BindPadding.Parent = Bind
        BindPadding.PaddingLeft = UDim.new(0, 25)

        local Enabled = false

        local Binding = false
        local CurrentBind = nil
        local InputBeganConnection = nil
        local SkipNextToggle = false

        local Module = {
            Enabled = false
        }

        local function UpdateBindText()
            if CurrentBind then
                Bind.Text = "Bind { " .. CurrentBind.Name .. " }"
            else
                Bind.Text = "Bind"
            end
        end

        local function Toggle()
            Enabled = not Enabled
            Module.Enabled = Enabled
            ModuleButton.TextTransparency = Enabled and 0 or 0.5
            if callback then
                callback(Enabled)
            end
        end

        ModuleButton.MouseButton1Click:Connect(Toggle)

        ModuleButton.MouseButton2Click:Connect(function()
            ModuleOptions.Visible = not ModuleOptions.Visible
        end)

        Bind.MouseButton1Click:Connect(function()
            if Binding then return end
            Binding = true
            Bind.Text = "Press Key"
            if InputBeganConnection then InputBeganConnection:Disconnect() end

            InputBeganConnection = UIS.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard and not Typing then
                    if CurrentBind == Input.KeyCode then
                        CurrentBind = nil
                        Bind.Text = "Bind Removed"
                        task.delay(0.5, function()
                            if not Binding then UpdateBindText() end
                        end)
                    else
                        CurrentBind = Input.KeyCode
                        UpdateBindText()
                        SkipNextToggle = true
                    end
                    Binding = false
                    InputBeganConnection:Disconnect()
                end
            end)
        end)

        UIS.InputBegan:Connect(function(Input)
            if not Binding and CurrentBind and CurrentBind == Input.KeyCode and not Typing then
                if SkipNextToggle then
                    SkipNextToggle = false
                    return
                end
                Toggle()
            end
        end)

        UpdateBindText()

        function Module:CreateToggle(ToggleCFG)
            local ToggleName = ToggleCFG.Name or "Toggle"
            local Default = ToggleCFG.Default or false
            local ToggleCallback = ToggleCFG.Function

            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Parent = ModuleOptions
            ToggleContainer.Size = UDim2.new(1, 0, 0, 25)
            ToggleContainer.BackgroundTransparency = 1

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleContainer
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Font = Enum.Font.Sarpanch
            ToggleLabel.Text = ToggleName
            ToggleLabel.TextColor3 = Color3.new(1, 1, 1)
            ToggleLabel.TextSize = 20
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 25, 0, 0)

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Parent = ToggleContainer
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
            ToggleButton.BackgroundTransparency = 0.5
            ToggleButton.BorderSizePixel = 0
            ToggleButton.AutoButtonColor = false
            ToggleButton.Text = ""

            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.Parent = ToggleButton
            ToggleButtonCorner.CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame")
            Dot.Parent = ToggleButton
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = UDim2.new(0, 2, 0, 2)
            Dot.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            Dot.BorderSizePixel = 0

            local DotCorner = Instance.new("UICorner")
            DotCorner.Parent = Dot
            DotCorner.CornerRadius = UDim.new(1, 0)

            local callback = Default

            local Toggle = {
                Enabled = callback
            }

            local function Update()
                if callback then
                    Dot.Position = UDim2.new(1, -18, 0, 2)
                    Dot.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                else
                    Dot.Position = UDim2.new(0, 2, 0, 2)
                    Dot.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                end
                if ToggleCallback then
                    ToggleCallback(callback)
                end
            end

            ToggleButton.MouseButton1Click:Connect(function()
                callback = not callback
                Toggle.Enabled = callback
                Update()
            end)

            Update()

            return Toggle
        end

        return Module
    end

    return Tab
end

return Jello
