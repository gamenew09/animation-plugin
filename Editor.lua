-----------------------------------------------------

local Plugin = PluginManager():CreatePlugin()
local toolbar = Plugin:CreateToolbar("Animations")
local button = toolbar:CreateButton(
	"", -- The text next to the icon. Leave this blank if the icon is sufficient.
	"Animation Editor", -- hover text
	"http://www.roblox.com/asset/?id=142301226" -- The icon file's name
)

---------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- G E N E R I C    U T I L    C O D E
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

local function Repeat(func)
	local flag = true
	Spawn(function()
		while flag do
			func()
			wait()
		end	
	end)

	return (function()	flag = false end)
end


function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

----------- udim stuff ----------------------------
local function UD(a, b, c, d)
	return UDim2.new(a, b, c, d)
end
local function CenterPos(w, h)
	return UD(0.5, -w/2, 0.5, -h/2)
end
local function ConstSize(w, h)
	return UD(0, w, 0, h)
end

function Make(ty, data)
	local obj = Instance.new(ty)
	for k, v in pairs(data) do
		if type(k) == 'number' then
			v.Parent = obj
		else
			obj[k] = v
		end
	end
	return obj
end

function round(val)
  return math.floor(val + 0.5)
end

function printCFrame(name, cf)
	local anarray = {cf:components()}
	local str = ""
	for i,v in pairs(anarray) do
		str = str .. " " .. i .. "# " .. v
	end 
	print(name .. " " .. str)
end

function printVector(vec)
	print("X " .. vec.x .. " Y " .. vec.y .. " Z " .. vec.z)
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function weldBetween(a, b)
    local weld = Instance.new("Motor6D")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse()*a.CFrame
    weld.Parent = a
    return weld;
end
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- MOUSE EVENT CODE
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

local mouseOnLClick = {}
local mouseOnRClick = {}

local mouseOnLUp = {}
local mouseOnRUp = {}

function safeNil(item)
	if (item == nil) then
		return "NIL"
	else
		return item
	end
end

function isSafeNIL(item)
	return (item == "NIL")
end

function registerOn(event, guiElement, func)
	guiElement = safeNil(guiElement)
	local ord = 1
	if (isSafeNIL(guiElement)) then
		ord = 0
	else 
		local parent = guiElement.Parent
		while (parent ~= nil and parent ~= game.Workspace) do
			ord = ord + 1
			parent = parent.Parent
		end
	end
	local eventInstance = { Element = guiElement, Function = func, Order = ord}
	table.insert(event, eventInstance)
	return eventInstance
end

function unregisterOn(event, guiElement)
	guiElement = safeNil(guiElement)
	local i=1
	while i <= #event do
	    if event[i].Element == guiElement then
	        table.remove(event, i)
	    else
	        i = i + 1
	    end
	end
end

function unregisterEvent(event, eventInstance)
	local i=1
	while i <= #event do
	    if event[i] == eventInstance then
	        table.remove(event, i)
--	        print("Remove " .. eventInstance.Element.Name )
	    else
	        i = i + 1
	    end
	end
end

function clearAllEvents()
	mouseOnLClick = {}
	mouseOnRClick = {}

	mouseOnLUp = {}
	mouseOnRUp = {}
end

function isIn(guiElement, X, Y)
	if (X >= guiElement.AbsolutePosition.X and X <= guiElement.AbsolutePosition.X + guiElement.AbsoluteSize.X and
		Y >= guiElement.AbsolutePosition.Y and Y <= guiElement.AbsolutePosition.Y + guiElement.AbsoluteSize.Y) then
		return true
	else
		return false
	end			
end

function listEvent(event)
	print("Event List --------------------------------------")
	local i=1
	while i <= #event do
		local consume = "false"
		if (event[i].Consume) then
			consume = "true"
		end
		if (isSafeNIL(event[i].Element)) then
			print("Nil " .. event[i].Order )
		else
			print(event[i].Element.Name .. " " .. event[i].Order)
		end
        i = i + 1
	end
end


--------------------------------------------------------------------------------------------
-- GUI Mouse Handlers
--------------------------------------------------------------------------------------------

local function mouseCallbackCheck(list)
	local mouse = Plugin:GetMouse()
	for _,elem in spairs(list, function(t, a, b) return t[a].Order > t[b].Order end) do
		if (isSafeNIL(elem.Element)) then
			if (elem.Function(mouse.X, mouse.Y)) then
				break
			end
		elseif isIn(elem.Element, mouse.X, mouse.Y) then
			if (elem.Function(mouse.X - elem.Element.AbsolutePosition.X, mouse.Y - elem.Element.AbsolutePosition.Y)) then
				break
			end
		end
	end
end

Plugin:GetMouse().Button1Down:connect(function()
		mouseCallbackCheck(mouseOnLClick)
	end
)
Plugin:GetMouse().Button2Down:connect(function()
		mouseCallbackCheck(mouseOnRClick)
	end
)
Plugin:GetMouse().Button1Up:connect(function()
		mouseCallbackCheck(mouseOnLUp)
	end
)
Plugin:GetMouse().Button2Up:connect(function()
		mouseCallbackCheck(mouseOnRUp)
	end
)


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- G L O B A L S
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------


timelineUI = nil
menuUI = nil
saveUI = nil
loadUI = nil
stopAnimUI = nil
timeChangeUI = nil
selectedLine = nil
rotateMoveUI = nil

local timelinemarginSize = 40
local marginSize = 5
local lineSize = 10
local buttonSize = 15
local nameSize = 150
local headerSize = 45
local timelineLength = 0
local tickSeparation = 50
local ticks = 1
local tickSpacing = 0.25
local lineCount = 0
local cursorTime = 0
local timeScale = 0.05 -- Pixels per second of animation

partList = {}
partListByName = {}
partToItemMap = {}
partToLineNumber = {}
rootPart = nil
animationController = nil

partInclude = {}

modal = false
rotateMode = true
partSelection = nil

buttonOnColor = Color3.new(200/255, 200/255, 150/255)
buttonOffColor = Color3.new(50/255, 50/255, 50/255)

dropDownColor = Color3.new(100/255, 100/255, 150/255)



----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- D R O P   D O W N    M E N U
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
dropDownMouseClickEater = nil
dropDownMenuClearEvent = nil

function displayDropDownMenu(parent, choiceList, x, y)
	local retval = nil
	modal = true

	local numButtons = tablelength(choiceList)

	-- create frame
	local dropDownUI = Make('Frame', {
			Parent = parent,
			Name = 'RootFrame',
			Style = 'Custom',
			Position = UD(0, x, 0, y),
			Size = UD(0, 100, 0, (marginSize) + numButtons * (buttonSize + marginSize)),
			BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
			BackgroundTransparency = 0.3,
			ZIndex = 10,
		})

	local waitLock = false
	local buttonIdx = 0
	for idx, value in pairs(choiceList) do

		local button = Make('TextButton', {
			Parent = dropDownUI,
			Name = value ..'Button',
			Font = 'ArialBold',
			FontSize = GuiSettings.TextMed,
			TextColor3 = GuiSettings.TextColor,
			Position = UD(0.05, 0, 0, marginSize + buttonIdx * (buttonSize + marginSize)),
			Size = UD(0.9, 0, 0, buttonSize),
			BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
			BackgroundTransparency = 0,
			Text = value,
			ZIndex = 11,
		})

		button.MouseButton1Click:connect(function()
			waitLock = true
			retval = value
		end)


		buttonIdx = buttonIdx + 1
		
	end

	dropDownMouseClickEater = registerOn(mouseOnLClick, dropDownUI, function(x, y)	return true	end)
	dropDownMenuClearEvent = registerOn(mouseOnLClick, nil, function(x, y)
		waitLock = true
		return true
	end)

	while( not waitLock ) do
		wait()
	end

	dropDownUI.Parent = nil
	unregisterEvent(mouseOnLClick, dropDownMouseClickEater)
	unregisterEvent(mouseOnLClick, dropDownMenuClearEvent)

	modal = false
	return retval
end


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- T E X T   E N T R Y   D I A L O G
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

function showTextExtryDialog(title, default)

	modal = true

	local dialogUI = Make('ScreenGui', 
		{	
			Name = "SaveUI",
			Make('Frame', {
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0.5, -200, 0.5, 0),
				Size = UD(0, 400, 0, marginSize + (lineSize + marginSize) * 5),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.5,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = title,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Make('Frame', {
					Parent = timelineUI,
					Name = 'SaveNameFrame',
					Style = 'Custom',
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * 1),
					Size = UD(0.9, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 100/255),
					BackgroundTransparency = 0.3,
					Make('TextBox', {
						Name = 'SaveNameBox',
						Font = 'ArialBold',
						FontSize = 'Size14',
						TextColor3 = GuiSettings.TextColor,
						Position = UD(0.05, 0, 0, 0),
						Size = UD(0.9, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = default,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				}),

				Make('TextButton', {
					Name = 'OKButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * 3),
					Size = UD(0.4, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = "OK",
				}),
				Make('TextButton', {
					Name = 'CancelButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.55, 0, 0, marginSize + (lineSize + marginSize) * 3),
					Size = UD(0.4, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Cancel",
				}),

			}),
		})

		local retval = default
		local waitLock = false

		dialogUI.RootFrame.OKButton.MouseButton1Click:connect(function()
			retval = dialogUI.RootFrame.SaveNameFrame.SaveNameBox.Text
			waitLock = true
		end)

		dialogUI.RootFrame.CancelButton.MouseButton1Click:connect(function()
			retval = nil
			waitLock = true
		end)


		dialogUI.Parent = game:GetService("CoreGui")


		while( not waitLock ) do
			wait()
		end

		dialogUI.Parent = nil
		modal = false
		return retval

	end




----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- K E Y  F R A M E    C O D E
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
animationPriorityList = { 
	"Core",
	"Idle",
	"Movement",
	"Action"
}

animationPlayID = 0
animationLength = 2.0
keyframeList = {}
loopAnimation = false
animationPriority = "Core"
animationFramerate = 1 / 20
copyPoseList = {}
poseColor =  Color3.new(200/255, 50/255, 150/255)
copyPoseColor = Color3.new(150/255, 150/255, 200/255)


function copyPose(part, pose)

	if (copyPoseList[part.Name] == pose) then
		copyPoseList[part.Name].UI.BackgroundColor3 = poseColor
		copyPoseList[part.Name] = nil
		return
	elseif (copyPoseList[part.Name] ~= nil) then
		copyPoseList[part.Name].UI.BackgroundColor3 = poseColor
	end

	copyPoseList[part.Name] = pose
	pose.UI.BackgroundColor3 = copyPoseColor
end

function resetCopyPoseList()
	for partName, pose in pairs(copyPoseList) do
		pose.UI.BackgroundColor3 = poseColor
	end
	copyPoseList = {}
end

function pastePoses()
	if (tablelength(copyPoseList) <= 0) then
		return
	end

	local keyframe = getKeyframe(cursorTime)
	if (keyframe == nil) then
		keyframe = createKeyframe(cursorTime)
	end

	for partName, pose in pairs(copyPoseList) do
		local item = partListByName[partName]
		if (keyframe.Poses[item.Item] ~= pose) then
			if (keyframe.Poses[item.Item] == nil) then
				keyframe.Poses[item.Item] = initializePose(keyframe, item.Item)
			end
			keyframe.Poses[item.Item].CFrame = pose.CFrame
		end
	end	

	resetCopyPoseList()
	updateCursorPosition()
end

function keyframeTimeClamp(time)
	-- clamp to 20 fps
	time = round(time / animationFramerate)
	time = time * animationFramerate

	return time	
end

function deletePose(keyframe, part)
	local active = partInclude[part.Name]
	if (active and keyframe ~= nil and partToItemMap[part] ~= nil and partToItemMap[part].Motor6D ~= nil and keyframe.Poses[part] ~= nil) then

		-- remove pose if it is currently the copied pose for this part
		if (copyPoseList[part.Name] == keyframe.Poses[part]) then
			copyPoseList[part.Name] = nil
		end

		keyframe.Poses[part] = nil

		local ui = keyframe.UI:FindFirstChild('Pose' .. part.Name)

		if (ui ~= nil) then
			ui.Parent = nil
			unregisterOn(mouseOnRClick, ui)
			unregisterOn(mouseOnLClick, ui)
		else
			print("not found")
		end


		updateCursorPosition()
	end
end

function initializePose(keyframe, part)
	local active = partInclude[part.Name]
	if (not active or keyframe == nil) then
		return nil
	end
	local pose =  keyframe.Poses[part]
	if (pose == nil and partToItemMap[part] ~= nil and partToItemMap[part].Motor6D ~= nil) then
--		print("initializePose")
		resetCopyPoseList()
		local previousPose = getClosestPose(keyframe.Time, part)
		pose = {}
		if (previousPose == nil) then
			pose.CFrame = CFrame.new()
		else
			pose.CFrame = previousPose.CFrame
		end
		pose.Item = partToItemMap[part]
		pose.Time = keyframe.Time
		keyframe.Poses[part] = pose

		newPoseUI = Make('Frame', {
			Parent = keyframe.UI,
			Name = 'Pose' .. part.Name,
			Style = 'Custom',
			Position = UD(0, -lineSize / 4 + 1, 0, (partToLineNumber[part]) * (lineSize + marginSize) + lineSize / 3),
			Size = UD(0, lineSize / 2, 0, lineSize / 2),
			BackgroundColor3 = poseColor,
			BackgroundTransparency = 0,
		})
		pose.UI = newPoseUI

		registerOn(mouseOnRClick, newPoseUI, function(x, y)
			if (keyframe.Time > 0) then
				deletePose(keyframe, part)
			end
			return true
		end)

		registerOn(mouseOnLClick, newPoseUI, function(x, y)
			if (isKeyDown("ctrl")) then
				copyPose(part, pose)
				return true
			end
			return false
		end)


	end
	return pose
end

function deleteKeyframe(time)
	time = keyframeTimeClamp(time)
	local keyframe = keyframeList[time]
	if (keyframe ~= nil) then
		for part, pose in pairs(keyframe.Poses) do
			deletePose(keyframe, pose.Item.Item)
		end
		keyframe.UI.Parent = nil
		keyframe.UI = nil
		keyframeList[time] = nil
	end
end

function createKeyframe(time)
	time = keyframeTimeClamp(time)
	local newKeyframe = keyframeList[time]
	if (newKeyframe == nil) then

--		print("create keyframe " .. time .. " timescale " .. timeScale)

		newKeyframe = {
			Time = time,
			Poses = {},		
			Name = "Keyframe",
			UI = 	Make('Frame', {
						Parent = timelineUI.RootFrame,
						Name = 'Keyframe' .. time,
						Style = 'Custom',
						Position = UD(0, nameSize + marginSize + (time * timeScale), 0, 2 * (lineSize + marginSize)),
						Size = UD(0, 2, 0, (lineSize + marginSize) * (lineCount + 1)),
						BackgroundColor3 = Color3.new(200/255, 50/255, 150/255),
						BackgroundTransparency = 0,
					}),
		}

		if (time <= 0.0) then
			for part,elem in pairs(partList) do
				initializePose(newKeyframe, part)
			end
		end

		keyframeList[time] = newKeyframe
	end
	return newKeyframe
end

function moveKeyframe(keyframe, time)
	if (keyframeList[time] == nil) then
		keyframeList[keyframe.Time] = nil
		keyframe.Time = time
		keyframe.UI.Position = UD(0, nameSize + marginSize + (time * timeScale), 0, 2 * (lineSize + marginSize))
		keyframeList[time] = keyframe
		updateCursorPosition()
		wait()
	end
end

function nudgeView()
	local mainPart = rootPart.Item
	mainPart.CFrame = mainPart.CFrame*CFrame.new(0, 1, 0)
	mainPart.CFrame = mainPart.CFrame*CFrame.new(0, -1, 0)
end

local function findTime(X)
	local time = X / timeScale

	return keyframeTimeClamp(time)
end

function getKeyframe(time)
	time = keyframeTimeClamp(time)
	return keyframeList[time]
end

function getKeyframeData(part, time, createKeyframeIfNil, createPoseIfNil)
	local keyframe = getKeyframe(time)
	if (keyframe == nil and createKeyframeIfNil) then
		keyframe = createKeyframe(cursorTime)
	end

	if (keyframe ~= nil and partToItemMap[part] ~= nil and partToItemMap[part].Motor6D ~= nil) then
		if (keyframe.Poses[part] == nil and createPoseIfNil) then
			initializePose(keyframe, part)
		end
		return keyframe.Poses[part]
	else
		return nil
	end	
end

function getCurrentKeyframeData(part, createIfNil, createPoseIfNil)
	return getKeyframeData(part, cursorTime, createIfNil, createPoseIfNil)
end

function getClosestPose(time, part)
	local bestTime = keyframeTimeClamp(time)
	local pose = nil

	while (pose == nil and bestTime > -animationFramerate / 2) do
		pose =  getKeyframeData(part, bestTime, false, false)
		bestTime = bestTime - animationFramerate
	end

--[[
	if (pose == nil) then
		print("Part " .. part.Name .. "Time " .. bestTime)
	end
--]]

	return pose
end


function getClosestNextPose(time, part)
	local bestTime = keyframeTimeClamp(time)
	local pose = nil

	while (pose == nil and bestTime <= animationLength) do
		pose =  getKeyframeData(part, bestTime, false, false)
		bestTime = bestTime + animationFramerate
	end
	return pose
end

function resetKeyframes()
	resetCopyPoseList()
	
	for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
		deleteKeyframe(time)
	end

	keyframeList = {}
end

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- C U R S O R    C O D E
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
doNotUpdateCursor = false

function updateCursorPosition()

	if (doNotUpdateCursor) then
		return
	end

	-- move UI
	timelineUI.RootFrame.Cursor.Position = UD(0, nameSize + marginSize - (lineSize / 2) + (cursorTime * timeScale), 0, (lineSize + marginSize))
	timelineUI.RootFrame.Cursor.CursorLine.Size = UD(0, 2, 0, (lineSize + marginSize) * (lineCount + 2))

	-- Update the model
	for part,elem in pairs(partList) do
		local active = partInclude[part.Name]

		if (elem.Motor6D ~= nil) then
			if (active) then
				local pose = getClosestPose(cursorTime, part)
				elem.Motor6D.C1 = pose.CFrame * elem.OriginC1
			else
				elem.Motor6D.C1 = elem.OriginC1
			end
			nudgeView()
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- P A R T    S E L E C T I O N     C O D E
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
function selectPartUI(part)
	selectedLine.Parent = timelineUI.RootFrame
	selectedLine.Position = UD(0, marginSize, 0, headerSize - (marginSize / 2) + 1 + ((lineSize + marginSize) * (partToLineNumber[part] - 1)))
end

function unselectPartUI()
	selectedLine.Parent = nil
end
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------
local function MakePartSelectGui(baseItem)



	if (rotateMoveUI == nil) then
		rotateMoveUI = Make('ScreenGui', 
		{	
			Name = "rotateMoveUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0, 15, 1.0, -15 - (lineSize + marginSize*2)),
				Size = UD(0, 100, 0, marginSize + (lineSize + marginSize) * 1),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.5,
				Make('TextButton', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Rotate (R)",
					TextXAlignment = Enum.TextXAlignment.Center,
				}),
			}),
		})
	end

	--selection boxes
	local mHoverBox = Make('SelectionBox', {
		Color = BrickColor.new(21),
		Transparency = 0.85,
		Parent = game.Workspace,
		Archivable = false,
	})

	local mSelectBox = Make('SelectionBox', {
		Color = BrickColor.new(21),
		Transparency = 0.6,
		Parent = game.Workspace,
		Archivable = false,
	})

	local mDragHandles = Make('Handles', {
		Color = BrickColor.new(23),
--		Style = 'Resize',
		Style = 'Movement',
		Parent = game:GetService('CoreGui'),
		Archivable = false,
	})

	local mProxyPart = Make('Part', {
		FormFactor = 'Custom',
--		Size = Vector3.new(0.8,0.8,0.8);
		Size = Vector3.new(0.8,0.8,0.8),
		Name = 'ProxyPart',
		Shape = 'Ball',
		Archivable = false,
		Parent = game.Workspace,
		BrickColor = BrickColor.new(23),
		Anchored = false,
		CanCollide = false,
		Transparency = 1.0,
		TopSurface = 'Smooth',
		BottomSurface = 'Smooth',
	})	

	local mRotateHandles = Make('ArcHandles', {
		Color = BrickColor.new(23),
		Parent = game:GetService('CoreGui'),
		Archivable = false,
	})



	local mHover = nil
	local mCanOffset = nil
	local mShowControls = nil
	local mStartTransformCF = nil
	local mProxyWeld = nil
	-------------

	function displayHandles()
		if (partSelection ~= nil) then
			local item = partSelection

			mProxyPart.Parent = item.Item
			mProxyPart.Size = item.Item.Size + Vector3.new(0.5, 0.5, 0.5)
			mProxyPart.CFrame = item.Item.CFrame
			if (mProxyWeld ~= nil) then
				mProxyWeld:Destroy()
			end
			mProxyWeld = weldBetween(item.Item, mProxyPart)

			if (rotateMode) then
				mRotateHandles.Adornee = mProxyPart
				mDragHandles.Adornee = nil
			else
				mRotateHandles.Adornee = nil
				mDragHandles.Adornee = mProxyPart
			end
		end
	end

	function toggleHandles()
		if (partSelection ~= nil) then
			rotateMode = not rotateMode
			if (rotateMode) then
				rotateMoveUI.RootFrame.TitleBar.Text = "Rotate (R)"
			else
				rotateMoveUI.RootFrame.TitleBar.Text = "Move (R)"
			end
			displayHandles()
		end
	end


	local function setSelection(item, showControls, canoffset)
		partSelection = item
		if item then
			mSelectBox.Adornee = item.Item
			selectPartUI(item.Item)
		else
			mSelectBox.Adornee = nil
			unselectPartUI()
		end
		mDragHandles.Adornee = nil
		mRotateHandles.Adornee = nil
		mProxyPart.Parent = nil
		mCanOffset = canoffset
		mShowControls = showControls
		if showControls then
			if canoffset then
				displayHandles()
			else
				mSelectBox.Adornee = nil
				mRotateHandles.Adornee = mProxyPart
				mProxyPart.Parent = game.Workspace
				if item then
					mProxyPart.CFrame = item.Item.CFrame * item.OriginC1
				end
			end
			rotateMoveUI.Parent = game:GetService("CoreGui")
		else
			rotateMoveUI.Parent = nil
		end
	end

	local function getSelection()
		return partSelection
	end

	function resetHandleSelection()
		setSelection(nil, false, false)
	end


	-------------
	-- used for keyframe settings
	local  mKeyframeData = { 
		CanOffset = true,
	}

	mRotateHandles.MouseDrag:connect(function(axisRaw, relAngle, delRadius)
--		this.onAxisRotate.fire(Vector3.FromAxis(axis), relAngle)
		if (not modal) then

			local item = getSelection()
			local part = item.Item
			local kfd = getCurrentKeyframeData(part, true, true)

			local transform = CFrame.fromAxisAngle(Vector3.FromAxis(axisRaw), -relAngle)
			local partcf = item.Motor6D.Part0.CFrame * item.Motor6D.C0 * 
			               mStartTransformCF * transform:inverse() *
			               item.OriginC1:inverse()
			local cf = partcf:inverse() * 
			           item.Motor6D.Part0.CFrame * item.Motor6D.C0 
			           * item.OriginC1:inverse()

			local A = item.Motor6D.Part0.CFrame
			local B = item.Motor6D.C0 
			local C = transform
			local D = mStartTransformCF
			local E = item.OriginC1
			local F = part.CFrame

			local ARot = item.Motor6D.Part0.CFrame - item.Motor6D.Part0.CFrame.p
			local BRot = item.Motor6D.C0 - item.Motor6D.C0.p
			local ERot = E - E.p
			local ETrans = CFrame.new(E.p)

			kfd.CFrame = ETrans * C * ETrans:inverse() * D
			item.Motor6D.C1 = kfd.CFrame*item.OriginC1

			--[[
			if mKeyframeData.CanOffset then
				kfd.CFrame = CFrame.fromAxisAngle(axis, -relAngle) * mStartTransformCF
				item.Motor6D.C1 = kfd.CFrame * item.OriginC1
			else
				local transform = CFrame.fromAxisAngle(axis, -relAngle)
				local rotPoint = item.Motor6D.Part0.CFrame*item.Motor6D.C0
				--
				local partcf = item.Motor6D.Part0.CFrame * item.Motor6D.C0 * 
				               mStartTransformCF * transform:inverse() *
				               item.OriginC1:inverse()
				local cf = partcf:inverse() * 
				           item.Motor6D.Part0.CFrame * item.Motor6D.C0 * 
				           item.OriginC1:inverse()
				kfd.CFrame = cf
				item.Motor6D.C1 = kfd.CFrame*item.OriginC1
			end
			--]]
			nudgeView()
		end

	end)


	mRotateHandles.MouseButton1Down:connect(function() 
		if (not modal) then
			local item = getSelection()
			local part = item.Item
			local kfd = getCurrentKeyframeData(part, true, true)
			if mKeyframeData.CanOffset then
				mStartTransformCF = kfd.CFrame
			else
				mStartTransformCF = item.Motor6D.C0:inverse() * item.Motor6D.Part0.CFrame:inverse() *
				                    part.CFrame * item.OriginC1
			end
		end
	end)


	mDragHandles.MouseDrag:connect(function(face, dist)
		if (not modal) then
--			print("Distance = " .. dist)
--			this.onAxisMove.fire(Vector3.FromNormalId(face), dist)
			axis = Vector3.FromNormalId(face)
			local item = getSelection()
			local part = item.Item
			local kfd = getCurrentKeyframeData(part, true, true)
			kfd.CFrame = CFrame.new(-axis*dist)*mStartTransformCF
			item.Motor6D.C1 = kfd.CFrame*item.OriginC1
			nudgeView()
		end
	end)

	mDragHandles.MouseButton1Down:connect(function() 
		if (not modal) then
			local item = getSelection()
			local part = item.Item
			local kfd = getCurrentKeyframeData(part, true, true)
			mStartTransformCF = kfd.CFrame
		end
	end)

	local mouse = Plugin:GetMouse()

	MouseTargeterHalt = Repeat(function()
		local t = mouse.Target
		local unitRay = mouse.UnitRay
		local castRay = Ray.new(unitRay.Origin, unitRay.Direction*999)
		local t, at = game.Workspace:FindPartOnRayWithIgnoreList(castRay, {mProxyPart})
		if t ~= mHover then
			mHover = t
			if partList[t] ~= nil and partList[t].Motor6D ~= nil then
				mHoverBox.Adornee = t
			else
				mHoverBox.Adornee = nil
			end
		end
	end)


--[[		
	local mProxyCFrameUpdater = MakeRepeater(function()
		if mSelection and mSelection.OriginC1 and not mCanOffset then
			mProxyPart.CFrame = mSelection.Item.CFrame * mSelection.OriginC1
		end
	end)

	function this.setHover(part)
		mHoverBox.Adornee = part
	end
	function this.setSelection(item, showControls, canoffset)
		mSelection = item
		if item then
			mSelectBox.Adornee = item.Item
		else
			mSelectBox.Adornee = nil
		end
		mDragHandles.Adornee = nil
		mRotateHandles.Adornee = nil
		mProxyPart.Parent = nil
		mCanOffset = canoffset
		mShowControls = showControls
		if showControls then
			if canoffset then
				mDragHandles.Adornee = item.Item
				mRotateHandles.Adornee = item.Item
			else
				mSelectBox.Adornee = nil
				mRotateHandles.Adornee = mProxyPart
				mProxyPart.Parent = game.Workspace
				if item then
					mProxyPart.CFrame = item.Item.CFrame * item.OriginC1
				end
			end
		end
	end
	function this.setCanOffset(canoffset)
		this.setSelection(mSelection, mShowControls, canoffset)
	end
	function this.clearSelection()
		mSelectBox.Adornee = nil
		mSelection = nil
	end
	function this.destroy()
		mSelectBox.Adornee = nil
		mSelectBox.Parent = nil
		mHoverBox.Adornee = nil
		mHoverBox.Parent = nil
		mDragHandles.Adornee = nil
		mDragHandles.Parent = nil
		mRotateHandles.Adornee = nil
		mRotateHandles.Parent = nil
		mProxyPart.Parent = nil
		mMouseTargeter.halt()
		mProxyCFrameUpdater.halt()
	end

	this.onAxisMove = MakeSignal()
	this.onStartAxisMove = MakeSignal()
	this.onAxisRotate = MakeSignal()
	this.onStartAxisRotate = MakeSignal()
--]]

	function destroySelectionBoxes()
		if (mSelectBox) then
			mSelectBox.Adornee = nil
			mSelectBox.Parent = nil
		end
		if (mHoverBox) then
			mHoverBox.Adornee = nil
			mHoverBox.Parent = nil
		end
		if (mDragHandles) then
			mDragHandles.Adornee = nil
			mDragHandles.Parent = nil
		end
		if (mRotateHandles) then
			mRotateHandles.Adornee = nil
			mRotateHandles.Parent = nil
		end
		if (mProxyPart) then
			mProxyPart.Parent = nil 
		end
	end

	registerOn(mouseOnLClick, nil, function()
		if (not modal) then
--			local part = mouse.Target
			local unitRay = mouse.UnitRay
			local castRay = Ray.new(unitRay.Origin, unitRay.Direction*999)
			local part, at = game.Workspace:FindPartOnRayWithIgnoreList(castRay, {mProxyPart})

			if (part ~= nil) then
				local item = partToItemMap[part]
				local active = partInclude[part.Name]

				if (active and item ~= rootPart) then
					if (item ~= nil) then
						setSelection(item, true, true) --select it, (true = with movement controls)
					else
						setSelection(nil, false, false) --select it, (true = with movement controls)
					end
				end
			else
				setSelection(nil, false, false) --select it, (true = with movement controls)
			end
		end
		return false
	end)

	rotateMoveUI.RootFrame.TitleBar.MouseButton1Click:connect(function()
		toggleHandles()
	end)

--[[
	registerOn(registerOn(mouseOnLClick, nil, function()
		local part = mouse.Target

		--clamp the selection to a single 
--		local sel = mKeyframeStrip.getSelection()

		--do selection
		local item = mPartToItemMap[part]
		if item and mKeyframeData.Enabled[item] then
			--ne selection? Pretend we're at frame 1
			if sel.x == 0 then sel.x = 1 end

			--clamp the selection to one x value for editing
			mKeyframeStrip.setSlider(sel.x)
			local kfdata = mKeyframeData[sel.x][item]
			mKeyframeStrip.setItemSelection(item)
			local canoffset = mKeyframeData.CanOffset
			if item.Motor6D and kfdata then
				mPartSelection.setSelection(item, true, canoffset) --select it, (true = with movement controls)
			else
				mPartSelection.setSelection(item, false, canoffset) --it's the root, false => no controls
			end
		end
	end))
--]]

end

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------

GuiSettings = {}
GuiSettings.TextLarge = 'Size24'
GuiSettings.TextMed = 'Size18'
GuiSettings.TextSmall = 'Size14'
GuiSettings.TextColor = Color3.new(221/255, 221/255, 221/255)

guiWindow = nil


local function selectObjectToAnimate()
	-- creating test GUI
	if (guiWindow == nil) then

		guiWindow = Make('ScreenGui', 
		{
			Name = "TestGUI",
			Make('Frame', {
				Parent = guiWindow,
				Name = 'TestFrame',
				Style = 'RobloxRound',
				Position = UD(0.2, 0, 0.2, 0),
				Size = UD(0, 400, 0, 100),
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size10',
					TextColor3 = GuiSettings.TextColor,
					Size = UD(1, 0, 0, 20),
					BackgroundTransparency = 1,
					Text = "Select the base of the object to Animate",
				}),
				Make('TextLabel', {
					Name = 'SelectionText',
					Font = 'Arial',
					FontSize = GuiSettings.TextSmall,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0, 100, 0, 20),
					Size = UD(1, -100, 0, 20),
					BackgroundTransparency = 1,
					---------------------------
					Text = "<none>",
				}),
				------------------------------
				Make('TextButton', {
					Name = 'OkayButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextSmall,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0, 0, 0, 40),
					Size = UD(0.5, 0, 0, 30),
					Style = 'RobloxButton',
					Visible = false,
					--------------------------
					Text = "Okay",
				}),
				Make('TextButton', {
					Name = 'CancelButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextSmall,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.5, 0, 0, 40),
					Size = UD(0.5, 0, 0, 30),
					Style = 'RobloxButton',
					---------------------------
					Text = "Cancel",
				}),
			}),
		})

	end


	--------------------------------
	local mSelectionHoverBox = Make('SelectionBox', {
		Name = 'AnimEdit_SelectionBox',
		Color = BrickColor.new(21),
		Transparency = 0.5,
		Parent = game.Workspace,
	})

	local mSelectionBox = Make('SelectionBox', {
		Name = 'AnimEdit_SelectionBox',
		Color = BrickColor.new(23),
		Parent = game.Workspace,
	})

	local mCurrentSelection = nil
	local mHoverRepeater = nil
	local mOnClickCn
	local waitLock = true

	local mouse = Plugin:GetMouse()



	local halt = Repeat(function() mSelectionHoverBox.Adornee = mouse.Target end)

--[[
	Spawn(function()
		while mFlag do
			mSelectionHoverBox.Adornee = mouse.Target
			wait()
		end	
	end)

	local function halt()
		mFlag = false
	end
--]]

	---------------------------
	local function delete()
		if mOnClickCn then
			mOnClickCn:disconnect()
			mOnClickCn = nil
		end
		mSelectionBox.Adornee = nil
		mSelectionHoverBox.Adornee = nil
		mSelectionBox.Parent = nil
		mSelectionHoverBox.Parent = nil
		halt()
	end

	local function setCurrentSelection(selection)

		if (selection == nil) then
			return
		end

		selection = selection:GetRootPart(selection)
		if not selection then return end

		local tempAnimControl = selection.Parent:FindFirstChild("Humanoid")

		tempAnimControl = selection.Parent:FindFirstChild("Humanoid")
		if (not tempAnimControl) then
			tempAnimControl = selection.Parent:FindFirstChild("AnimationController")
			if (not tempAnimControl) then
				print("ERROR: unable to find animation Controller")
				return
			end
		end

		animationController = tempAnimControl

		mCurrentSelection = selection	
		mSelectionBox.Adornee = selection

		if selection then
			guiWindow.TestFrame.OkayButton.Visible = true
			guiWindow.TestFrame.SelectionText.Text = selection.Name
		else
			guiWindow.TestFrame.OkayButton.Visible = false
			guiWindow.TestFrame.SelectionText.Text = "<none>"
		end

	end

	local function getSelection()
		return mCurrentSelection
	end

	mOnClickCn = mouse.Button1Down:connect(function()
		setCurrentSelection(mouse.Target)
	end)


	guiWindow.TestFrame.OkayButton.MouseButton1Click:connect(function()
		delete()
		waitLock = false
	end)
	guiWindow.TestFrame.CancelButton.MouseButton1Click:connect(function()
		mCurrentSelection = nil
		delete()
		waitLock = false
		exitPlugin()
	end)

	-- reset GUI from previous incarnations
	guiWindow.TestFrame.OkayButton.Visible = false
	guiWindow.TestFrame.SelectionText.Text = "<none>"

	guiWindow.Parent = game:GetService("CoreGui")

	while (waitLock) do
		wait()
	end

	-- clean up selection stuff
	delete()
	guiWindow.Parent = nil
	return mCurrentSelection
end



loadButtonList = {}

function showLoadGame()
	if (loadUI == nil) then
		loadUI = Make('ScreenGui', 
		{	
			Name = "LoadUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0.5, -200, 0.5, 0),
				Size = UD(0, 200, 0, marginSize + (lineSize + marginSize) * 5),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.5,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Load:",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),
		})
	end

	-- clean up old buttons
	for _, part in pairs(loadButtonList) do
		part.Parent = nil
	end

	local humanoid = rootPart.Item.Parent
	local AnimationBlock = humanoid:FindFirstChild("AnimSaves")
	local fileCount = 0

	if (AnimationBlock ~= nil) then
		-- add button for saved games
		for _, childPart in pairs(AnimationBlock:GetChildren()) do
			if (childPart:IsA("StringValue")) then
				local newButton = Make('TextButton', {
					Parent = loadUI.RootFrame,
					Name = childPart.Name,
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * (1 + fileCount * 2)),
					Size = UD(0.9, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = childPart.Name,
				})
				fileCount = fileCount + 1	
				loadButtonList[fileCount] = newButton


				newButton.MouseButton1Click:connect(function()
					loadUI.Parent = nil
					loadCurrentAnimation(childPart.Name)
					modal = false
				end)

			end
		end
	end

	if (fileCount > 0) then
		local newButton = Make('TextButton', {
			Parent = loadUI.RootFrame,
			Name = 'CancelButton',
			Font = 'ArialBold',
			FontSize = GuiSettings.TextMed,
			TextColor3 = GuiSettings.TextColor,
			Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * (1 + fileCount * 2)),
			Size = UD(0.9, 0, 0, lineSize * 2),
			BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
			BackgroundTransparency = 0,
			Text = 'Cancel',
		})
		fileCount = fileCount + 1	
		loadButtonList[fileCount] = newButton

		newButton.MouseButton1Click:connect(function()
			loadUI.Parent = nil
			modal = false
		end)

		loadUI.RootFrame.Size = UD(0, 200, 0, marginSize + (lineSize + marginSize) * (1 + fileCount * 2))
		loadUI.Parent = game:GetService("CoreGui")
	else
		modal = false
	end
end

function showExportAnim()
	-- Update the model to start positions
	local motorOrig = {}
	for part,elem in pairs(partList) do
		if (elem.Motor6D ~= nil) then
			elem.Motor6D.C1 = elem.OriginC1
			nudgeView()
		end
	end

	local kfsp = game:GetService('KeyframeSequenceProvider')

	local kfs = createAnimationFromCurrentData()
	local animID = kfsp:RegisterKeyframeSequence(kfs)
	local dummy = rootPart.Item.Parent

-- EXPORT HERE
--			print("AnimID = " .. animID)

	local AnimationBlock = dummy:FindFirstChild("AnimSaves")
	if AnimationBlock == nil then
		AnimationBlock = Instance.new('Model')
		AnimationBlock.Name = "AnimSaves"
		AnimationBlock.Parent = dummy
	end

	local Animation = AnimationBlock:FindFirstChild("ExportAnim")
	if Animation == nil then
		Animation = Instance.new('Animation')
		Animation.Name = "ExportAnim"
		Animation.Parent = AnimationBlock
	end
	Animation.AnimationId = animID

	local OldKeyframeSqeuence = Animation:FindFirstChild("Test")
	if OldKeyframeSqeuence ~= nil then
		print("Found old sequence")
		OldKeyframeSqeuence.Parent = nil
	end

	kfs.Parent = Animation

	local selectionSet = {}
	table.insert(selectionSet, kfs)

	game.Selection:Set(selectionSet)
	wait()
	Plugin:SaveSelectedToRoblox()

--[[
	local selectionSet = {}
	table.insert(selectionSet, Animation)

	game.Selection:Set(selectionSet)
	wait()
	Plugin:SaveSelectedToRoblox()
--]]

	modal = false
end


function showImportAnim()
	local animPage = 1
	local userID = Plugin:GetStudioUserId()
	local kfsp = game:GetService('KeyframeSequenceProvider')
	local animList = kfsp:GetAnimations(userID, animPage)

	if (loadUI == nil) then
		loadUI = Make('ScreenGui', 
		{	
			Name = "LoadUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0.5, -200, 0.25, 0),
				Size = UD(0, 200, 0, marginSize + (lineSize + marginSize) * 5),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.5,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Load:",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),
		})
	end

	-- clean up old buttons
	for _, part in pairs(loadButtonList) do
		part.Parent = nil
	end

	local humanoid = rootPart.Item.Parent
	local AnimationBlock = humanoid:FindFirstChild("AnimSaves")
	local fileCount = 0
	local rowCount = 0

--[[
	print("Anims Loaded " .. #animList)
	for _, childPart in pairs(animList) do
		print("File - " .. childPart.Name)
	end
--]]
	if (animList ~= nil) then
		-- add button for saved games
		for _, childPart in pairs(animList) do
			local newButton = Make('TextButton', {
				Parent = loadUI.RootFrame,
				Name = childPart.Name,
				Font = 'ArialBold',
				FontSize = GuiSettings.TextMed,
				TextColor3 = GuiSettings.TextColor,
				Position = UD(0, 10 + 200 * rowCount, 0, marginSize + (lineSize + marginSize) * (1 + fileCount * 2)),
				Size = UD(0, 180, 0, lineSize * 2),
				BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
				BackgroundTransparency = 0,
				Text = childPart.Name,
			})
			fileCount = fileCount + 1	
			if (fileCount > 10) then
				fileCount = 0
				rowCount = rowCount + 1
			end
			loadButtonList[fileCount] = newButton


			newButton.MouseButton1Click:connect(function()
				loadUI.Parent = nil
				loadImportAnim(childPart.Id)
				modal = false
			end)
		end
	end

--	print("File Count " .. fileCount)
	if (fileCount > 0 or rowCount > 0) then
		local newButton = Make('TextButton', {
			Parent = loadUI.RootFrame,
			Name = 'CancelButton',
			Font = 'ArialBold',
			FontSize = GuiSettings.TextMed,
			TextColor3 = GuiSettings.TextColor,
			Position = UD(0, 10 + 200 * rowCount, 0, marginSize + (lineSize + marginSize) * (1 + fileCount * 2)),
			Size = UD(0, 180, 0, lineSize * 2),
			BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
			BackgroundTransparency = 0,
			Text = 'Cancel',
		})
		fileCount = fileCount + 1	
		loadButtonList[fileCount] = newButton

		newButton.MouseButton1Click:connect(function()
			loadUI.Parent = nil
			modal = false
		end)

		loadUI.RootFrame.Size = UD(0, 200  * (rowCount + 1), 0, marginSize + (lineSize + marginSize) * (1 + fileCount * 2))
		loadUI.Parent = game:GetService("CoreGui")
	else
		modal = false
	end

end

function importPose(keyframe, pose)
--	print("    Pose " .. pose.Name)
	item = partListByName[pose.Name]

	if (item ~= nil) then
		LocalPose = initializePose(keyframe, item.Item)
		if (LocalPose ~= nil) then
			if (item.OriginC1 ~= nil) then
				LocalPose.CFrame = item.OriginC1*pose.CFrame:inverse()*item.OriginC1:inverse()
			else
				LocalPose.CFrame = pose.CFrame
			end
			if (pose.Parent:IsA('Pose')) then
				importPartInclude[pose.Name] = true
			end
		end
	end

	for id, childPose in pairs(pose:GetChildren()) do
		importPose(keyframe, childPose)
	end
end

importPartInclude = {}

function loadImportAnim(animId)
	if animId > 0 then

		doNotUpdateCursor = true
		resetKeyframes()
		importPartInclude = {}


		local kfsp = game:GetService('KeyframeSequenceProvider')


	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=89289879") -- 
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125749145") -- Walk 
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125750544") -- Idle1 
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125750618") -- Idle2
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125750702") -- Jump
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125750759") -- Fall 
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125750800") -- Climb
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=125750867") -- Tool
	--	local kfs = kfsp:GetKeyframeSequence("http://www.gametest5.robloxlabs.com/asset/?id=92695496") -- Idle
	--	local kfs = kfsp:GetKeyframeSequence("http://www.gametest5.robloxlabs.com/asset/?id=92695503") -- Tool
	--	local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=120642355") -- Climb
		local kfs = kfsp:GetKeyframeSequenceById(animId, false) -- Test 2
--		local kfs = kfsp:GetKeyframeSequence("http://www.roblox.com/asset/?id=" .. animId ) -- Test 2

		local LocalKeyframe = nil
		local maxKeyframe = 0
		for id, keyframe in pairs(kfs:GetChildren()) do
			LocalKeyframe = createKeyframe(keyframe.Time)
			LocalKeyframe.Name = keyframe.Name
			if keyframe.Time > maxKeyframe then
				maxKeyframe = keyframe.Time 
			end
	--		print("KFName : " .. keyframe.Name .. "(" .. keyframe.Time .. ")")
			for id, pose in pairs(keyframe:GetChildren()) do
				importPose(LocalKeyframe, pose)
			end
		end

		-- cull duplication poses
		for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
			if (time > 0) then
				for part, pose in pairs(keyframe.Poses) do
					local previousPose = getClosestPose(time - animationFramerate, part)
					local nextPose = getClosestNextPose(time + animationFramerate, part)

					if (previousPose ~= nil and previousPose.CFrame == pose.CFrame and 
						(nextPose == nil or nextPose.CFrame == pose.CFrame)) then
						deletePose(keyframe, part)
	--[[					print("duplicate " .. part.Name .. " " .. time)
						printCFrame("previousPose " .. previousPose.Time, previousPose.CFrame)
						printCFrame("pose " .. pose.Time, pose.CFrame)
						if (nextPose ~= nil) then
							printCFrame("nextPose " .. nextPose.Time, nextPose.CFrame)
						end
	--]]
					end
				end
			end
		end

		animationLength = maxKeyframe
		updateTimeLabels()
		loopAnimation = kfs.Loop
		animationPriority = kfs.Priority.Name

		-- set proper keyframe locations
		for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
			keyframe.UI.Position = UD(0, nameSize + marginSize + (time * timeScale), 0, 2 * (lineSize + marginSize))
		end

		cursorTime = 0

		for partName, setting in pairs(partInclude) do
			if (importPartInclude[partName] ~= nil) then
				partInclude[partName] = true
			else
				partInclude[partName] = false
			end
		end

		doNotUpdateCursor = false

		updatePartInclude()
		updateCursorPosition()
		nudgeView()
		updateLoopButton()
		updatePriorityLabel()
	end
end


function updatePriorityLabel()
	if (animationPriority == nil) then
		animationPriority = "Core"
	end
	timelineUI.RootFrame.PriorityDisplay.Text = animationPriority
end

function updateLoopButton()
	if (loopAnimation) then
		timelineUI.RootFrame.LoopButton.BackgroundColor3 = buttonOnColor
	else
		timelineUI.RootFrame.LoopButton.BackgroundColor3 = buttonOffColor
	end
end

animationLabelsList = {}

function updateTimeLabels()

	-- delete existing labels
	for _, label in pairs(animationLabelsList) do
		label.Parent = nil
	end
	animationLabelsList = {}

	timelineLength = timelineUI.RootFrame.TimelineFrame.AbsoluteSize.X
	minTickSeparation = 50
	tickSpacing = 0
	tickSeparation = 0
	local tickScale = 0

	while tickSeparation < minTickSeparation do
		tickScale = tickScale + 1
		ticks = math.floor(animationLength / (animationFramerate * tickScale))
		tickSeparation = timelineLength / ticks
		tickSpacing = animationFramerate * tickScale
--		print (timelineLength .. " " .. ticks .. " " .. tickSpacing)
	end

	timeScale =  timelineLength / animationLength

	for tickNum = 0, ticks do		
		local label = Make('TextLabel', {
			Parent = timelineUI.RootFrame,
			Name = 'Tick' .. tickNum,
			Font = 'ArialBold',
			FontSize = 'Size10',
			TextColor3 = GuiSettings.TextColor,
			Position = UD(0, nameSize + marginSize + (tickNum * tickSpacing * timeScale), 0, lineSize +  marginSize),
			Size = UD(0, 10, 0, lineSize),
			BackgroundTransparency = 1,
			Text = string.format("%.2f", tickNum * tickSpacing),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		animationLabelsList[tickNum] = label
	end

	-- end tick
	local endMarker = Make('TextLabel', {
		Parent = timelineUI.RootFrame,
		Name = 'TickEnd',
		Font = 'ArialBold',
		FontSize = 'Size10',
		TextColor3 = GuiSettings.TextColor,
		Position = UD(0, nameSize + marginSize + (animationLength * timeScale), 0, lineSize +  marginSize),
		Size = UD(0, 10, 0, lineSize),
		BackgroundTransparency = 1,
		Text = string.format("%.2f", animationLength),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	animationLabelsList['TickEnd'] = endMarker


	registerOn(mouseOnLClick, endMarker, function(x, y)
		if (not modal and cursorTime ~= animationLength) then
			timeChangeUI.RootFrame.SaveNameFrame.AnimLengthBox.Text = animationLength
			timeChangeUI.Parent = game:GetService("CoreGui")
			modal = true
		end
		return true
	end)

end


local function createTimelineUI(rootNode)

	if (saveUI == nil) then
		saveUI = Make('ScreenGui', 
		{	
			Name = "SaveUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0.5, -200, 0.5, 0),
				Size = UD(0, 400, 0, marginSize + (lineSize + marginSize) * 5),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.5,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Save As:",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Make('Frame', {
					Parent = timelineUI,
					Name = 'SaveNameFrame',
					Style = 'Custom',
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * 1),
					Size = UD(0.9, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 100/255),
					BackgroundTransparency = 0.3,
					Make('TextBox', {
						Name = 'SaveNameBox',
						Font = 'ArialBold',
						FontSize = 'Size14',
						TextColor3 = GuiSettings.TextColor,
						Position = UD(0.05, 0, 0, 0),
						Size = UD(0.9, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "<name>",
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				}),

				Make('TextButton', {
					Name = 'OKButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * 3),
					Size = UD(0.4, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = "OK",
				}),
				Make('TextButton', {
					Name = 'CancelButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.55, 0, 0, marginSize + (lineSize + marginSize) * 3),
					Size = UD(0.4, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Cancel",
				}),

			}),
		})


		saveUI.RootFrame.OKButton.MouseButton1Click:connect(function()
			saveUI.Parent = nil
			saveCurrentAnimation(saveUI.RootFrame.SaveNameFrame.SaveNameBox.Text)
			modal = false
		end)

		saveUI.RootFrame.CancelButton.MouseButton1Click:connect(function()
			saveUI.Parent = nil
			modal = false
		end)

	end



	if (timeChangeUI == nil) then
		timeChangeUI = Make('ScreenGui', 
		{	
			Name = "TimeChangeUI",
			Make('Frame', {
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0.5, -200, 0.5, 0),
				Size = UD(0, 400, 0, marginSize + (lineSize + marginSize) * 5),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.5,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Animation Length:",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Make('Frame', {
					Parent = timelineUI,
					Name = 'SaveNameFrame',
					Style = 'Custom',
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * 1),
					Size = UD(0.9, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 100/255),
					BackgroundTransparency = 0.3,
					Make('TextBox', {
						Name = 'AnimLengthBox',
						Font = 'ArialBold',
						FontSize = 'Size14',
						TextColor3 = GuiSettings.TextColor,
						Position = UD(0.05, 0, 0, 0),
						Size = UD(0.9, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = animationLength,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				}),

				Make('TextButton', {
					Name = 'OKButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize + (lineSize + marginSize) * 3),
					Size = UD(0.4, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = "OK",
				}),
				Make('TextButton', {
					Name = 'CancelButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.55, 0, 0, marginSize + (lineSize + marginSize) * 3),
					Size = UD(0.4, 0, 0, lineSize * 2),
					BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Cancel",
				}),

			}),
		})


		timeChangeUI.RootFrame.OKButton.MouseButton1Click:connect(function()
			timeChangeUI.Parent = nil
			local scale = timeChangeUI.RootFrame.SaveNameFrame.AnimLengthBox.Text / animationLength
			animationLength = tonumber(timeChangeUI.RootFrame.SaveNameFrame.AnimLengthBox.Text)

			if (animationLength > 30) then
				animationLength = 30
			end

			-- modify animation framerate (easier than trying to combine keyframes)
			if (scale < 1) then
				animationFramerate = animationFramerate * scale
			end

			-- copy out all keyframes
			local tempKeyFrameList = {}
			for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
				tempKeyFrameList[keyframe.Time] = keyframe
			end
			keyframeList = {}

			-- scale all keyframes
			for time, keyframe in spairs(tempKeyFrameList, function(t, a, b) return t[a].Time < t[b].Time end) do
				keyframe.Time = keyframeTimeClamp(scale * time)
				keyframeList[keyframe.Time] = keyframe
--				print("Old time " .. time .. " New time " .. keyframe.Time)

			end

			-- update animation length display
			updateTimeLabels()

			-- update cursor location
			cursorTime = cursorTime * scale
			
			modal = false
		end)

		timeChangeUI.RootFrame.CancelButton.MouseButton1Click:connect(function()
			timeChangeUI.Parent = nil
			modal = false
		end)

	end

	if (menuUI == nil) then
		menuUI = Make('ScreenGui', 
		{
			Name = "MenuUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0, lineSize, 0, lineSize),
				Size = UD(0, 100, 0, (lineSize + (2*marginSize)) + 7 * (buttonSize + marginSize)),
				BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
				BackgroundTransparency = 0.3,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Menu",
					TextXAlignment = Enum.TextXAlignment.Center,
				}),
				Make('TextButton', {
					Name = 'PlayButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, lineSize + (2*marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Play",
				}),
				Make('TextButton', {
					Name = 'SaveButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, (lineSize + (2*marginSize)) + (buttonSize + marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Save",
				}),
				Make('TextButton', {
					Name = 'LoadButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, (lineSize + (2*marginSize)) + 2 * (buttonSize + marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Load",
				}),
				--[[ Remove after import has been implemented
				Make('TextButton', {
					Name = 'ImportButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, (lineSize + (2*marginSize)) + 3 * (buttonSize + marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Import",
				}),
				--]]
				Make('TextButton', {
					Name = 'ExportButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, (lineSize + (2*marginSize)) + 4 * (buttonSize + marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Export",
				}),
				Make('TextButton', {
					Name = 'ResetButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, (lineSize + (2*marginSize)) + 5 * (buttonSize + marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Reset",
				}),
				Make('TextButton', {
					Name = 'DebugButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, (lineSize + (2*marginSize)) + 6 * (buttonSize + marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Debug",
				}),
			}),
		})
	end

	-- creating test GUI
	if (timelineUI == nil) then

		lineCount = 0

		timelineUI = Make('ScreenGui', 
		{
			Name = "TimelineUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0, 0, 0, 0),
				Size = UD(1, 0, 0, 100),
				BackgroundColor3 = Color3.new(0/255, 0/255, 50/255),
				BackgroundTransparency = 0.3,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.25, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Timeline",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Make('TextButton', {
					Name = 'MoreButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0, lineSize, 0, lineSize),
					Size = UD(0, lineSize * 1.1, 
					          0, lineSize * 1.1),
					BackgroundColor3 = Color3.new(50/255, 50/255, 50/255),
					BackgroundTransparency = 0,
					Text = "+",
				}),
				Make('TextButton', {
					Name = 'CloseButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(1, -marginSize - (lineSize * 1.1), 0, marginSize),
					Size = UD(0, lineSize * 1.1, 
					          0, lineSize * 1.1),
					BackgroundColor3 = Color3.new(250/255, 50/255, 50/255),
					BackgroundTransparency = 0,
					Text = "X",
				}),
				Make('TextLabel', {
					Name = 'PriorityLabel',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.7, 0, 0, 1),
					Size = UD(0.1, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Priority:",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Make('TextLabel', {
					Name = 'PriorityDisplay',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.7, 55, 0, 1),
					Size = UD(0, 100, 0, lineSize),
					BackgroundTransparency = 0.5,
					Text = "Core",
					TextXAlignment = Enum.TextXAlignment.Center,
					BackgroundColor3 = dropDownColor,
				}),
				Make('TextLabel', {
					Name = 'LoopLabel',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.9, 0, 0, 1),
					Size = UD(0.1, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Loop:",
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Make('TextButton', {
					Name = 'LoopButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.9, 45, 0, 0),
					Size = UD(0, lineSize * 1.1, 
					          0, lineSize * 1.1),
					BackgroundColor3 = Color3.new(50/255, 50/255, 50/255),
					BackgroundTransparency = 0,
					Text = "",
				}),
				Make('Frame', {
					Name = 'TimeListFrame',
					Style = 'Custom',
					Position = UD(0, nameSize + marginSize, 0, 1 * (lineSize + marginSize)),
					Size = UD(1, -(marginSize + nameSize + timelinemarginSize), 0, lineSize),
					BackgroundColor3 = Color3.new(200/255, 200/255, 150/255),
					BackgroundTransparency = 0.9,
				}),
				Make('Frame', {
					Name = 'TimelineFrame',
					Style = 'Custom',
					Position = UD(0, nameSize + marginSize, 0, 2 * (lineSize + marginSize)),
					Size = UD(1, -(marginSize + nameSize + timelinemarginSize), 0, lineSize),
					BackgroundColor3 = Color3.new(200/255, 200/255, 150/255),
					BackgroundTransparency = 0.1,
				}),				
				Make('Frame', {
					Name = 'Cursor',
					Style = 'Custom',
					Position = UD(0, nameSize + marginSize - (lineSize / 2) , 0, 1 * (lineSize + marginSize)),
					Size = UD(0, lineSize + 2, 0, lineSize + 2),
					BackgroundColor3 = Color3.new(250/255, 50/255, 50/255),
					BackgroundTransparency = 0,
					ZIndex = 1,
					Make('Frame', {
						Name = 'CursorLine',
						Style = 'Custom',
						Position = UD(0, (lineSize / 2), 0, 0),
						Size = UD(0, 2, 0, (lineSize + marginSize) * (lineCount + 2)),
						BackgroundColor3 = Color3.new(250/255, 50/255, 50/255),
						BackgroundTransparency = 0,
						ZIndex = 0,
					}),
				}),
			}),
		})

		-- adding labels
		timelineUI.Parent = game:GetService("CoreGui")
		wait(0.1)

		updateTimeLabels()

		-- M E N U 
		-- P L A Y
		menuUI.RootFrame.PlayButton.MouseButton1Click:connect(function()
			closePopupMenu()
			playCurrentAnimation()
		end)

		-- S A V E
		menuUI.RootFrame.SaveButton.MouseButton1Click:connect(function()
			closePopupMenu()
			modal = true
			saveUI.Parent = game:GetService("CoreGui")
		end)

		-- L O A D
		menuUI.RootFrame.LoadButton.MouseButton1Click:connect(function()
			closePopupMenu()
			modal = true
			showLoadGame()
		end)

		-- I M P O R T 
--[[ Remove after import has been implemented
		menuUI.RootFrame.ImportButton.MouseButton1Click:connect(function()
			closePopupMenu()
			modal = true
			showImportAnim()
			modal = false
		end)
--]]

		-- E X P O R T
		menuUI.RootFrame.ExportButton.MouseButton1Click:connect(function()
			closePopupMenu()
			modal = true
			showExportAnim()
		end)

		-- R E S E T 
		menuUI.RootFrame.ResetButton.MouseButton1Click:connect(function()
			closePopupMenu()
			resetAnimation()
		end)

		-- D E B U G 
		menuUI.RootFrame.DebugButton.MouseButton1Click:connect(function()
--			listEvent(mouseOnLClick)
			for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
				print("keyframe time " .. time .. " poses " .. tablelength(keyframe.Poses))
			end
		end)



		function closePopupMenu(x, y)
			menuUI.Parent = nil
			unregisterEvent(mouseOnLClick, mouseClickEater)
			unregisterEvent(mouseOnLClick, menuClearEvent)
			return true
		end

		timelineUI.RootFrame.MoreButton.MouseButton1Click:connect(function()
			if (not modal) then
				menuUI.Parent = game:GetService("CoreGui")
				mouseClickEater = registerOn(mouseOnLClick,menuUI.RootFrame, function(x, y)	return true	end)
				menuClearEvent = registerOn(mouseOnLClick, nil, closePopupMenu)		
			end
		end)

		timelineUI.RootFrame.CloseButton.MouseButton1Click:connect(function()
			if (not modal) then
				timelineUI.Parent = nil
				resetAnimation()
				clearAllEvents()
				if (MouseTargeterHalt ~= nil) then
					MouseTargeterHalt()
				end
				destroySelectionBoxes()
				exitPlugin()
			end
		end)



		timelineUI.RootFrame.LoopButton.MouseButton1Click:connect(function()
			if (not modal) then
				loopAnimation = not loopAnimation
				updateLoopButton()
			end
		end)


		registerOn(mouseOnLClick, timelineUI.RootFrame.PriorityDisplay, function(x, y)
			if (not modal) then
				local newPriority = displayDropDownMenu(timelineUI.RootFrame.PriorityDisplay, animationPriorityList, x, y)
				if (newPriority ~= nil) then
					animationPriority = newPriority
					timelineUI.RootFrame.PriorityDisplay.Text = newPriority
				end
			end
		end)

		-- hooking up clicks


		-- sliding keyframe cursor
		registerOn(mouseOnLClick, timelineUI.RootFrame.TimelineFrame, function(x, y)
			if (not modal) then
				time = findTime(x)
				local keyframe = getKeyframe(time)

				if (keyframe ~= nil and time > 0) then
					local halt = Repeat(function()
							local mouse = Plugin:GetMouse()
							xvalue = mouse.X - timelineUI.RootFrame.TimelineFrame.AbsolutePosition.X
							mouseTime = findTime(xvalue)
							if (mouseTime < 0) then
								mouseTime = 0
							elseif (mouseTime > animationLength) then
								mouseTime = animationLength
							end
							local currentKeyframe = getKeyframe(mouseTime)
							while (getKeyframe(mouseTime) ~= nil and getKeyframe(mouseTime) ~= keyframe) do
								mouseTime = mouseTime + animationFramerate
							end
							if (mouseTime > animationLength) then
								while (mouseTime > animationLength or (getKeyframe(mouseTime) ~= nil and getKeyframe(mouseTime) ~= keyframe)) do
									mouseTime = mouseTime - animationFramerate
								end
							end
							moveKeyframe(keyframe, mouseTime)
						end)	
					local unregisterEvent = registerOn(mouseOnLUp, nil, function(x, y)
						unregisterEvent(mouseOnLUp, unregisterEvent)
						halt()
						return false
					end)
					return true
				end
			end
			return false
		end)


		-- create or delete keyframe
		registerOn(mouseOnRClick, timelineUI.RootFrame.TimelineFrame, function(x, y)
			if (not modal) then
				time = findTime(x)
				local key = getKeyframe(time)
				if (key == nil) then
					createKeyframe(time)
				else
					local keyframeMenu = { "Delete", "Rename" }
					local selection = displayDropDownMenu(timelineUI.RootFrame.TimelineFrame, keyframeMenu, x, y)
					if (selection == "Delete") then
						if (time > 0) then
							deleteKeyframe(time)
						end
					elseif (selection == "Rename") then
						local newName = showTextExtryDialog("Enter Keyframe Name:", key.Name)
						if (newName ~= nil) then
							key.Name = newName
						end
					end
				end
			end
			return false
		end)

		-- moving time cursor
		registerOn(mouseOnLClick, timelineUI.RootFrame.TimeListFrame, function(x, y)
			if (not modal) then
				if (cursorTime ~= findTime(x)) then
					cursorTime = findTime(x)
					updateCursorPosition()
					wait()
					return true
				end
			end
			return false
		end)

		-- sliding time cursor
		registerOn(mouseOnLClick, timelineUI.RootFrame.Cursor, function(x, y)
			if (not modal) then
				local halt = Repeat(function()
						local mouse = Plugin:GetMouse()
						xvalue = mouse.X - timelineUI.RootFrame.TimelineFrame.AbsolutePosition.X
						cursorTime = findTime(xvalue)
						if (cursorTime < 0) then
							cursorTime = 0
						elseif (cursorTime > animationLength) then
							cursorTime = animationLength
						end
						updateCursorPosition()
						wait()
					end)	
				local unregisterEvent = registerOn(mouseOnLUp, nil, function(x, y)
					unregisterEvent(mouseOnLUp, unregisterEvent)
					halt()
					return false
				end)
				return true
			end
			return false
		end)

	end

	local function createLine(node, indentLevel)
		if (node == nil) then
			return
		end

		local newLine = Make('TextLabel', {
								Name = 'Line' .. lineCount,
								Font = 'Arial',
								FontSize = GuiSettings.TextSmall,
								TextColor3 = GuiSettings.TextColor,
								TextXAlignment = Enum.TextXAlignment.Left,
								Position = UD(0, 10, 0, headerSize + ((lineSize + marginSize) * lineCount)),
								Size = UD(0, nameSize, 0, lineSize),
								BackgroundTransparency = 1,
								Parent = timelineUI.RootFrame,
								---------------------------
								Text = string.rep('   ', indentLevel) .. node.Name,
							})

		if (node.Motor6D ~= nil) then
			local newLineButton = Make('TextButton', {
									Name = 'LineButton' .. node.Name,
									Font = 'Arial',
									FontSize = GuiSettings.TextSmall,
									TextColor3 = GuiSettings.TextColor,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = buttonOffColor,
									Position = UD(0, nameSize - lineSize, 0, 1 + headerSize + ((lineSize + marginSize) * lineCount)),
									Size = UD(0, lineSize, 0, lineSize),
									BackgroundTransparency = 0,
									Parent = timelineUI.RootFrame,
									Text = ' ',
								})

			newLineButton.MouseButton1Click:connect(function()
				partInclude[node.Name] = not partInclude[node.Name]
				if partInclude[node.Name] then
					newLineButton.BackgroundColor3 = buttonOnColor
				else
					newLineButton.BackgroundColor3 = buttonOffColor		
				end
				resetHandleSelection()
				updateCursorPosition()		
			end)
		end

		lineCount = lineCount + 1
		for _, c in pairs(node.Children) do
			createLine(c, indentLevel + 1)
		end
	end

	createLine(rootNode, 0)
	updatePartInclude()

	selectedLine = 	Make('Frame', {
					Name = 'SelectedLineFrame',
					Style = 'Custom',
					Position = UD(0, marginSize, 0, headerSize - (marginSize / 2) + 1 + ((lineSize + marginSize) * (lineCount - 1))),
					Size = UD(1, -(marginSize * 2), 0, lineSize + marginSize),
					BackgroundColor3 = Color3.new(200/255, 200/255, 150/255),
					BackgroundTransparency = 0.9,
				})
	selectedLine.Parent = timelineUI.RootFrame


	timelineUI.RootFrame.Size = UD(1, 0, 0, headerSize + marginSize + ((lineSize + marginSize) * lineCount))
	timelineUI.Parent = game:GetService("CoreGui")

end

function updatePartInclude()
	for partName, setting in pairs(partInclude) do
		local item = partListByName[partName]
		local button =timelineUI.RootFrame:FindFirstChild('LineButton' .. partName)
		if (button ~= nil) then
			if setting then
				button.BackgroundColor3 = buttonOnColor		
			else
				button.BackgroundColor3 = buttonOffColor		
			end
		end
	end
end

function resetAnimation()
	doNotUpdateCursor = true
	resetCopyPoseList()
	resetKeyframes()
	animationLength = 2.0
	cursorTime = 0
	loopAnimation = false
	animationPriority = "Core"

	createKeyframe(0)
	doNotUpdateCursor = false
	updateTimeLabels()
	updateCursorPosition()
	resetHandleSelection()
	updateLoopButton()
	updatePriorityLabel()
	
	for partName, setting in pairs(partInclude) do
		partInclude[partName] = true
	end
	updatePartInclude()

end


stopAnim = false
function showStopAnimUI()
	if (stopAnimUI == nil) then
		stopAnimUI = Make('ScreenGui', 
		{
			Name = "StopAnimUI",
			Make('Frame', {
				Parent = timelineUI,
				Name = 'RootFrame',
				Style = 'Custom',
				Position = UD(0.1, 0, 0.5, 0),
				Size = UD(0, 150, 0, lineSize + buttonSize + 3*marginSize),
				BackgroundColor3 = Color3.new(100/255, 100/255, 150/255),
				BackgroundTransparency = 0.3,
				Make('TextLabel', {
					Name = 'TitleBar',
					Font = 'ArialBold',
					FontSize = 'Size14',
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, marginSize),
					Size = UD(0.9, 0, 0, lineSize),
					BackgroundTransparency = 1,
					Text = "Animation Playing",
					TextXAlignment = Enum.TextXAlignment.Center,
				}),
				Make('TextButton', {
					Name = 'StopButton',
					Font = 'ArialBold',
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UD(0.05, 0, 0, lineSize + (2*marginSize)),
					Size = UD(0.9, 0, 0, buttonSize),
					BackgroundColor3 = Color3.new(150/255, 150/255, 150/255),
					BackgroundTransparency = 0,
					Text = "Stop",
				}),
			}),
		})
	end

	stopAnim = false
	stopAnimUI.Parent = game:GetService("CoreGui")
	stopAnimUI.RootFrame.StopButton.MouseButton1Click:connect(function()
		stopAnim = true
		stopAnimUI.Parent = nil
	end)

end




	function createPoseFromLastKeyframe(time, keyframeData, part)
		if (part ~= nil) then
			local poseParent = keyframeData

			-- see if we can find a pose for this part
			local pose = getClosestPose(time, part)

			if (pose ~= nil) then
				local item = pose.Item
				poseParent = Make('Pose', {					
					Name = part.Name,
					Parent = keyframeData,
					Weight = 1,
					MaskWeight = 0,
					CFrame =(item.OriginC1 
						         and item.OriginC1:inverse()*pose.CFrame:inverse()*item.OriginC1
						         or  pose.CFrame)
				})
			end

			for _, childPart in pairs(part.Children) do
				createPoseFromLastKeyframe(time, poseParent, childPart)
			end
		end
	end

	function createPosesFromKeyframe(keyframe, keyframeData, part)
		if (part ~= nil) then
--			print("Checking " .. part.Name)
			local poseParent = keyframeData
			local poseMade = false
			-- see if we can find a pose for this part
			local active = partInclude[part.Name]
			local pose = keyframe.Poses[part.Item]
			if (active and pose ~= nil) then
				local item = pose.Item
				poseParent = Make('Pose', {					
					Name = part.Name,
					Parent = keyframeData,
					Weight = 1,
					MaskWeight = 0,
					CFrame =(item.OriginC1 
						         and item.OriginC1:inverse()*pose.CFrame:inverse()*item.OriginC1
						         or  pose.CFrame)
--					CFrame =  pose.CFrame * pose.Item.Motor6D.C0,
--					CFrame = pose.CFrame,
				})
--				print("Pose " .. part.Name)
				poseMade = true
			end

			for _, childPart in pairs(part.Children) do
				if (keyframe.Poses[childPart.Item] ~= nil and not poseMade) then
					poseParent = Make('Pose', {					
						Name = part.Name,
						Parent = keyframeData,
						Weight = 1,
						MaskWeight = 0,
						CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
					})
					poseMade = true
--					print("Pose " .. part.Name)
				end
				createPosesFromKeyframe(keyframe, poseParent, childPart)
			end
		end
	end

	function createAnimationFromCurrentData()
		local kfs = Make('KeyframeSequence', {
			Name = "Test",
			Loop = loopAnimation,
			Priority = animationPriority,
		})

		for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
			-- print("Time " .. time)

			local kfd = Make('Keyframe', {
				Name = keyframe.Name,
				Time = time,
				Parent = kfs,
			})

			-- go through part heirarach
			createPosesFromKeyframe(keyframe, kfd, rootPart)
		end

		-- check for end animation keyframe
		local keyframe = keyframeList[animationLength]
		if (keyframe == nil) then
			local kfd = Make('Keyframe', {
				Name = "KF" .. animationLength,
				Time = animationLength,
				Parent = kfs,
			})

			createPoseFromLastKeyframe(animationLength, kfd, rootPart)
		end
		return kfs
	end


	

	playingAnim = false
	function playCurrentAnimation()
		if (not playingAnim) then
			modal = true

			playingAnim = true
			animationPlayID = animationPlayID + 1

			-- Update the model to start positions
			local motorOrig = {}
			for part,elem in pairs(partList) do
				if (elem.Motor6D ~= nil) then
--					local pose = getClosestPose(0, part)
--					elem.Motor6D.C1 = pose.CFrame * pose.Item.OriginC1
					elem.Motor6D.C1 = elem.OriginC1
					nudgeView()
				end
			end

			local kfsp = game:GetService('KeyframeSequenceProvider')

			local kfs = createAnimationFromCurrentData()
			local animID = kfsp:RegisterKeyframeSequence(kfs)
			local dummy = rootPart.Item.Parent

--			print("AnimID = " .. animID)

			local AnimationBlock = dummy:FindFirstChild("AnimSaves")
			if AnimationBlock == nil then
				AnimationBlock = Instance.new('Model')
				AnimationBlock.Name = "AnimSaves"
				AnimationBlock.Parent = dummy
			end

			local Animation = AnimationBlock:FindFirstChild("TestAnim")
			if Animation == nil then
				Animation = Instance.new('Animation')
				Animation.Name = "TestAnim"
				Animation.Parent = AnimationBlock
			end
			Animation.AnimationId = animID

--			print("	Animation Created")
			wait(1)

--			print("Starting Service")
			game:GetService('RunService'):Run()
			wait(1)

--			print("Playing Animation")
			showStopAnimUI()
			currentAnimTrack = animationController:LoadAnimation(Animation)
			currentAnimTrack:Play()


			if (not loopAnimation) then
				Spawn(function()
					local ID = animationPlayID
					time = tick()
					while (tick() - time < animationLength ) do
						wait()
					end	
					if (ID == animationPlayID) then
						stopAnim = true
					end
				end)
			end

			while (not stopAnim) do
				wait()
			end

			currentAnimTrack:Stop()
			wait(1)
			
			stopAnimUI.Parent = nil

			game:GetService('RunService'):Stop()
			game:GetService('RunService'):Reset()
--			print("Stopping Service")

			wait(1)
--			print("Done")
			updateCursorPosition()
			playingAnim = false
			modal = false
		end
	end



	function createStringFromKeyframe(keyframe, keyframeData, part)
		if (part ~= nil) then
--			print("Checking " .. part.Name)
			for part, pose in pairs(keyframe.Poses) do

				if (pose ~= nil) then
					local components = {pose.CFrame:components()}
					saveDataString = saveDataString .. 'part = partListByName["' .. part.Name ..'"]\npose = initializePose(keyframe, part.Item)\n'
					saveDataString = saveDataString .. 'pose.CFrame = CFrame.new('
					local first = true
					for i,v in pairs(components) do
						if (not first) then
							saveDataString = saveDataString .. ', '
						else
							first = false
						end
						saveDataString = saveDataString .. v 
					end 
					saveDataString = saveDataString .. ')\n'
				end
			end
		end
	end

	function createStringAnimationFromCurrentData()
		saveDataString = saveDataString .. 'resetAnimation()\nanimationLength = ' .. animationLength .. '\nupdateTimeLabels()\n'
		if loopAnimation then
			saveDataString = saveDataString .. 'loopAnimation = true\n'
		else
			saveDataString = saveDataString .. 'loopAnimation = false\n'
		end
		saveDataString = saveDataString .. 'animationPriority = "' .. animationPriority.. '"\n'
		saveDataString = saveDataString .. 'local keyframe = nil\nlocal part = nil\nlocal pose = nil\n'

		for time, keyframe in spairs(keyframeList, function(t, a, b) return t[a].Time < t[b].Time end) do
			saveDataString = saveDataString .. 'keyframe = createKeyframe(' .. time .. ')\n'
			saveDataString = saveDataString .. 'keyframe.Name = "' .. keyframe.Name .. '"\n'

			-- go through part heirarach
			createStringFromKeyframe(keyframe, kfd, rootPart)
		end

		-- set included parts after creating keyframes to allow all keyframes to be created even if the part is currently inactive
		for partName, setting in pairs(partInclude) do
			saveDataString = saveDataString .. 'partInclude["' .. partName .. '"] = '
			if (setting) then
				saveDataString = saveDataString .. 'true\n'
			else
				saveDataString = saveDataString .. 'false\n'
			end
		end

		saveDataString = saveDataString .. 'cursorTime = 0\nupdatePartInclude()\nupdateCursorPosition()\nnudgeView()\nupdateLoopButton()\nupdatePriorityLabel()\n'
	end


	local animName = "TestAnimString"
	saveDataString = ''
	function saveCurrentAnimation(animName)
		if (not playingAnim) then

			-- create string
			saveDataString = ''
			createStringAnimationFromCurrentData()

			-- save to string item
			local dummy = rootPart.Item.Parent
			local AnimationBlock = dummy:FindFirstChild("AnimSaves")
			if AnimationBlock == nil then
				AnimationBlock = Instance.new('Model')
				AnimationBlock.Name = "AnimSaves"
				AnimationBlock.Parent = dummy
			end

			local Animation = AnimationBlock:FindFirstChild(animName)
			if Animation == nil then
				Animation = Instance.new('StringValue')
				Animation.Name = animName
				Animation.Parent = AnimationBlock
			end
			Animation.Value = saveDataString
		end
	end

	function loadCurrentAnimation(animName)
		if (not playingAnim) then
			-- show UI to select animation to load

			-- get string item
			local dummy = rootPart.Item.Parent
			local AnimationBlock = dummy:FindFirstChild("AnimSaves")
			if AnimationBlock == nil then
				return
			end

			local Animation = AnimationBlock:FindFirstChild(animName)
			if Animation == nil then
				return
			end
			local dataString = Animation.Value

			-- do it
			local func = loadstring(dataString)
			if (func ~= nil) then
				func()
			else
				print("Nil func")
			end


		end
	end


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

keysDown = {}
keyDownListener = nil
keyUpListener = nil


function isKeyDown(key)
	if ( keysDown[key] == nil ) then
		return false
	else
		return keysDown[key]
	end
end

function onKeyDown(key)
	if ( string.byte(key) == 48 ) then
		keysDown["shift"] = true
	elseif  ( string.byte(key) == 50 ) then
		keysDown["ctrl"] = true
	elseif  ( string.byte(key) == 52 ) then
		keysDown["alt"] = true
	elseif  ( string.byte(key) == 118 ) then
		keysDown["v"] = true
	--	if (isKeyDown("ctrl")) then
			pastePoses()
	--	end
	elseif  ( string.byte(key) == 114 ) then
		keysDown["r"] = true
		toggleHandles()
	end
--   print("Key:", key, " Code:", string.byte(key))

end

function onKeyUp(key)
--  print("Key UP:", key, " Code:", string.byte(key))
	if ( string.byte(key) == 48 ) then
		keysDown["shift"] = false
	elseif  ( string.byte(key) == 50 ) then
		keysDown["ctrl"] = false
	elseif  ( string.byte(key) == 52 ) then
		keysDown["alt"] = false
	elseif  ( string.byte(key) == 118 ) then
		keysDown["v"] = false
	elseif  ( string.byte(key) == 114 ) then
		keysDown["r"] = false
	end
end

function releaseListeners()
	if (keyUpListener ~= nil) then
		keyUpListener:disconnect()
	end
	if (keyDownListener ~= nil) then
		keyDownListener:disconnect()
	end

end

function connectListeners(mouse)
	if (mouse ~= nil) then
		releaseListeners()
		keysDown = {}
		keyDownListener = mouse.KeyDown:connect(onKeyDown)
		keyUpListener = mouse.KeyUp:connect(onKeyUp)
	end
end



----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------



function exitPlugin()
	Plugin:Activate(false)
	_G["AnimationEdit"] = false
	releaseListeners()
end

Plugin.Deactivation:connect(function()
	_G["AnimationEdit"] = false
	releaseListeners()
	if timelineUI then
		resetAnimation()
		timelineUI:Destroy()
	end
	timelineUI = nil
	if menuUI then
		menuUI:Destroy()
	end
	menuUI = nil
	if saveUI then
		saveUI:Destroy()
	end
	saveUI = nil
	if loadUI then
		loadUI:Destroy()
	end
	loadUI = nil
	if stopAnimUI then
		stopAnimUI:Destroy()
	end
	stopAnimUI = nil
	if timeChangeUI then
		timeChangeUI:Destroy()
	end
	timeChangeUI = nil
	if (rotateMoveUI) then
		rotateMoveUI:Destroy()
	end
	rotateMoveUI = nil
	if (destroySelectionBoxes) then
		destroySelectionBoxes()
	end
end)


button.Click:connect(function()

	Plugin:Activate(true)
	_G["AnimationEdit"] = true

	-- reset UI
	timelineUI = nil
	menuUI = nil
	saveUI = nil
	loadUI = nil
	stopAnimUI = nil
	timeChangeUI = nil

	-- reset the assembly information
	partList = {}
	partListByName = {}
	partToItemMap = {}
	partToLineNumber = {}
	rootPart = nil

	partInclude = {}
	modal = false

	local selectedObject = selectObjectToAnimate()
	if (selectedObject == nil) then
		return
	end

	local mouse = Plugin:GetMouse()
	connectListeners(mouse)

	-- find the hierarchy
	--first, gather the info on what's being animated
	local mBaseItem = { --recursive structure holding hierarchy of items
		Item = selectedObject,
		Name = selectedObject.Name,
		Motor6D = nil,
		OriginC1 = CFrame.new(),
		Children = {},
		Parent = nil,
	}

	rootPart = mBaseItem

	local partCount = 1
	do
		local function doCalculate(item)
--			mAllItems[#mAllItems+1] = item
			partList[item.Item] = item
			partListByName[item.Name] = item
			partToItemMap[item.Item] = item
			partToLineNumber[item.Item] = partCount
			partInclude[item.Name] = true

			for _, p in pairs(item.Item:GetChildren()) do
				if p:IsA('Motor6D') or p:IsA('Weld') then
					local joinedTo;
					if p.Part0 == item.Item then
						joinedTo = p.Part1
					elseif p.Part1 == item.Item then
						joinedTo = p.Part0
					else
						error("Animedit only supports Motor6D with Parent == Part0 or Part1", 0)
					end
					local it = {
						Item = joinedTo,
						Name = joinedTo.Name,
						Motor6D = p,
						OriginC1 = p.C1,
						Children = {},
						Parent = item,
					}
					item.Children[#item.Children+1] = it
					partCount = partCount+1
					doCalculate(it)
				end
			end
		end
		doCalculate(mBaseItem)
	end


	MakePartSelectGui(mBaseItem)
	createTimelineUI(mBaseItem)
	resetAnimation()

end)