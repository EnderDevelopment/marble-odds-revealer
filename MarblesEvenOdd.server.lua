local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local NPC_TAG = "MarblesNPC"
local PICK_ATTRIBUTE = "MarblesPicked"
local RESULT_ATTRIBUTE = "MarblesResult"
local REVEAL_DURATION = 8

local resultEvent = ReplicatedStorage:FindFirstChild("MarblesResultRevealed")
if not resultEvent then
	resultEvent = Instance.new("RemoteEvent")
	resultEvent.Name = "MarblesResultRevealed"
	resultEvent.Parent = ReplicatedStorage
end

local function getDisplayPart(npc)
	if npc:IsA("Model") then
		return npc:FindFirstChild("Head") or npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart", true)
	end

	if npc:IsA("BasePart") then
		return npc
	end

	return nil
end

local function showResult(npc, count, result)
	local displayPart = getDisplayPart(npc)
	if not displayPart then
		return
	end

	local oldGui = displayPart:FindFirstChild("MarblesResultDisplay")
	if oldGui then
		oldGui:Destroy()
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "MarblesResultDisplay"
	billboard.Adornee = displayPart
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(240, 70)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.Parent = displayPart

	local label = Instance.new("TextLabel")
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = string.format("NPC picked %d: %s", count, result)
	label.TextColor3 = result == "Even" and Color3.fromRGB(100, 220, 255) or Color3.fromRGB(255, 180, 90)
	label.TextScaled = true
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	task.delay(REVEAL_DURATION, function()
		if billboard.Parent then
			billboard:Destroy()
		end
	end)
end

local function normalizePick(value)
	if typeof(value) == "number" then
		return math.max(0, math.floor(value))
	end

	if typeof(value) == "string" then
		local number = tonumber(value)
		if number then
			return math.max(0, math.floor(number))
		end
	end

	return nil
end

local function revealNpcPick(npc, pickedValue)
	local count = normalizePick(pickedValue)
	if not count then
		return false, "The NPC pick must be a non-negative number."
	end

	local result = count % 2 == 0 and "Even" or "Odd"
	npc:SetAttribute(PICK_ATTRIBUTE, count)
	npc:SetAttribute(RESULT_ATTRIBUTE, result)
	resultEvent:FireAllClients(npc, count, result)
	showResult(npc, count, result)

	return true, result
end

local function connectNpc(npc)
	if not (npc:IsA("Model") or npc:IsA("BasePart")) then
		return
	end

	npc:GetAttributeChangedSignal(PICK_ATTRIBUTE):Connect(function()
		local pick = npc:GetAttribute(PICK_ATTRIBUTE)
		if pick ~= nil then
			revealNpcPick(npc, pick)
		end
	end)
end

for _, npc in CollectionService:GetTagged(NPC_TAG) do
	connectNpc(npc)
end

CollectionService:GetInstanceAddedSignal(NPC_TAG):Connect(connectNpc)

_G.RevealMarblesNpcPick = revealNpcPick
