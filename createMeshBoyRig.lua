local Plugin = PluginManager():CreatePlugin()
local toolbar = Plugin:CreateToolbar("Animations")
local button = toolbar:CreateButton(
	"", -- The text next to the icon. Leave this blank if the icon is sufficient.
	"Create Man Rig", -- hover text
	"http://www.roblox.com/asset/?id=142301579" -- The icon file's name.
)

local function weldBetween(a, b)
    local weld = Instance.new("Motor6D")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse()*a.CFrame
    weld.Parent = a
    return weld;
end

local function jointBetween(a, b, cfa, cfb)
    local weld = Instance.new("Motor6D")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = cfa
    weld.C1 = cfb
    weld.Parent = a
    return weld;
end

button.Click:connect(function()
	if (_G["AnimationEdit"] == true) then
		print("Cannot create rig while in edit mode.")
		return
	end

	print("Creating rig")

	-- clean up

	local parent = Workspace:FindFirstChild("Dummy")
	if (parent == nil) then
		print("making dummy")
		parent = Instance.new("Model", game.Workspace)
		parent.Name = "Dummy"		
	end

	for index, child in pairs(parent:GetChildren()) do
		if (child.Name ~= "AnimSaves") then
			child:Destroy()
		end
	end

	--

	Root = Instance.new("Part", game.Workspace)
	wait(0.1)
	Root.Name = "HumanoidRootPart"
	Root.FormFactor = "Symmetric"
	Root.Anchored = true
	Root.CanCollide = true
	Root.Transparency = 0.5
	Root.Size = Vector3.new(2, 2, 1)
	Root.CFrame = CFrame.new(0, 5.2, 4.5)
	Root.Parent = parent
	Root.BottomSurface = "Smooth"
	Root.TopSurface = "Smooth"

	Torso = Instance.new("Part", game.Workspace)
	wait(0.1)
	Torso.Name = "Torso"
	Torso.FormFactor = "Symmetric"
	Torso.Anchored = false
	Torso.CanCollide = false
	Torso.Size = Vector3.new(2, 2, 1)
	Torso.CFrame = CFrame.new(0, 5.2, 4.5)
	Torso.Parent = parent
	Torso.BottomSurface = "Smooth"
	Torso.TopSurface = "Smooth"

	RCA = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0 )
	RCB = RCA
	RootHip = jointBetween(Root, Torso, RCA, RCB)
	RootHip.Name = "Root Hip"
	RootHip.MaxVelocity = 0.1


	LeftLeg = Instance.new("Part", game.Workspace)
	wait(0.1)
	LeftLeg.Name = "Left Leg"
	LeftLeg.FormFactor = "Symmetric"
	LeftLeg.Anchored = false
	LeftLeg.CanCollide = false
	LeftLeg.Size = Vector3.new(1, 2, 1)
	LeftLeg.CFrame = CFrame.new(0.5, 3.2, 4.5)
	LeftLeg.Parent = parent
	LeftLeg.BottomSurface = "Smooth"
	LeftLeg.TopSurface = "Smooth"

	LHCA = CFrame.new(-0.5, -1, 0) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -math.pi/2)
	LHCB = CFrame.new(0, 1, 0) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -math.pi/2)
	LeftHip = jointBetween(Torso, LeftLeg, LHCA, LHCB)
	LeftHip.Name = "Left Hip"
	LeftHip.MaxVelocity = 0.1


	RightLeg = Instance.new("Part", game.Workspace)
	wait(0.1)
	RightLeg.Name = "Right Leg"
	RightLeg.FormFactor = "Symmetric"
	RightLeg.Anchored = false
	RightLeg.CanCollide = false
	RightLeg.Size = Vector3.new(1, 2, 1)
	RightLeg.CFrame = CFrame.new(-0.5, 3.2, 4.5)
	RightLeg.Parent = parent
	RightLeg.BottomSurface = "Smooth"
	RightLeg.TopSurface = "Smooth"


	RHCA = CFrame.new(0.5, -1, 0) * CFrame.fromAxisAngle(Vector3.new(0, -1, 0), -math.pi/2)
	RHCB = CFrame.new(0, 1, 0) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.pi/2)
	RightHip = jointBetween(Torso, RightLeg, RHCA, RHCB)
	RightHip.Name = "Right Hip"
	RightHip.MaxVelocity = 0.1


	LeftArm = Instance.new("Part", game.Workspace)
	wait(0.1)
	LeftArm.Name = "Left Arm"
	LeftArm.FormFactor = "Symmetric"
	LeftArm.Anchored = false
	LeftArm.CanCollide = false
	LeftArm.Size = Vector3.new(1, 2, 1)
	LeftArm.CFrame = CFrame.new(1.5, 5.2, 4.5)
	LeftArm.Parent = parent
	LeftArm.BottomSurface = "Smooth"
	LeftArm.TopSurface = "Smooth"


	LSCA = CFrame.new(-1.0, 0.5, 0) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -math.pi/2)
	LSCB = CFrame.new(0.5, 0.5, 0) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -math.pi/2)
	LeftShoulder = jointBetween(Torso, LeftArm, LSCA, LSCB)
	LeftShoulder.Name = "Left Shoulder"
	LeftShoulder.MaxVelocity = 0.1


	RightArm = Instance.new("Part", game.Workspace)
	wait(0.1)
	RightArm.Name = "Right Arm"
	RightArm.FormFactor = "Symmetric"
	RightArm.Anchored = false
	RightArm.CanCollide = false
	RightArm.Size = Vector3.new(1, 2, 1)
	RightArm.CFrame = CFrame.new(-1.5, 5.2, 4.5)
	RightArm.Parent = parent
	RightArm.BottomSurface = "Smooth"
	RightArm.TopSurface = "Smooth"

	RSCA = CFrame.new(1.0, 0.5, 0) * CFrame.fromAxisAngle(Vector3.new(0, -1, 0), -math.pi/2)
	RSCB = CFrame.new(-0.5, 0.5, 0) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.pi/2)
	RightShoulder = jointBetween(Torso, RightArm, RSCA, RSCB)
	RightShoulder.Name = "Right Shoulder"
	RightShoulder.MaxVelocity = 0.1


	Head = Instance.new("Part", game.Workspace)
	wait(0.1)
	Head.Name = "Head"
	Head.FormFactor = "Symmetric"
	Head.Anchored = false
	Head.CanCollide = true
	Head.Size = Vector3.new(2, 1, 1)
	Head.CFrame = CFrame.new(0, 6.7, 4.5)
	Head.Parent = parent
	Head.BottomSurface = "Smooth"
	Head.TopSurface = "Smooth"

	NCA = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	NCB = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	Neck = jointBetween(Torso, Head, NCA, NCB)
	Neck.Name = "Neck"
	Neck.MaxVelocity = 0.1

	Humanoid = Instance.new("Humanoid", parent)


	LArmMesh = Instance.new("CharacterMesh", parent)
	LArmMesh.MeshId = 82907977
	LArmMesh.BodyPart = 2

	RArmMesh = Instance.new("CharacterMesh", parent)
	RArmMesh.MeshId = 82908019
	RArmMesh.BodyPart = 3


	LLegMesh = Instance.new("CharacterMesh", parent)
	LLegMesh.MeshId = 81487640
	LLegMesh.BodyPart = 4

	RLegMesh = Instance.new("CharacterMesh", parent)
	RLegMesh.MeshId = 81487710
	RLegMesh.BodyPart = 5

	TorsoMesh = Instance.new("CharacterMesh", parent)
	TorsoMesh.MeshId = 82907945
	TorsoMesh.BodyPart = 1


	HeadMesh = Instance.new("SpecialMesh", Head)
	HeadMesh.MeshType = 0
	HeadMesh.Scale = Vector3.new(1.25, 1.25, 1.25)


	parent:MoveTo(Vector3.new(0, 1, 0))
end)