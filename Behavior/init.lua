
local ModuleContainer = _G.ModuleContainer or require(game:GetService("ReplicatedStorage").ModuleScriptLookup)
local ObjectOrientation = require(ModuleContainer.ObjectOrientation)
local PathfindingService = game:GetService("PathfindingService")
local module = {
	className = "Behavior";

	PathingType = "";
	MobAsset = false;
	TargetedAsset = false;
	Override = false;
	Connection = false;

	queueMap = {};
	activeMap = false;
	currentlyPathing = false;
	Path = false;
	currentWaypointIndex = 1;

	usedRayToPathfindLast = false;
}
--ObjectOrientation.inheritClass(module,<CLASS TO INHERIT>)
--ObjectOrientation.implementInterfaces(module,<INTERFACE>)
--ObjectOrientation.expressTraits(module,<TRAIT>)
local FailedToProvideA = "PathTo Error: Failed to Provide a "
--constructor:
function module:new()
    self = ObjectOrientation.classCopy(self)

    --do constructor stuff

    return self
end

function module:FindPlayerModelsInRadius(position,radius)
    local playerModels = {}
    for _,player in pairs(game.Players:GetPlayers()) do
        local CharModel = player.Character
        if CharModel then
            local dist = (position - CharModel.HumanoidRootPart.Position).Magnitude
            if dist<radius then
                table.insert(playerModels,CharModel)
            end
        end
    end
    return playerModels
end

function module:FindClosestPlayerModelInRadius(position,radius)
	local playerModel = false
	local Closest = math.huge
    for _,player in pairs(game.Players:GetPlayers()) do
        local CharModel = player.Character
        if CharModel then
            local dist = (position - CharModel.HumanoidRootPart.Position).Magnitude
            if dist<radius and dist<Closest then
                playerModel = CharModel
            end
        end
    end
    return playerModel
end

function module:DebugVisualizeCriticalPoints(Vector)
	local part = Instance.new("Part")
	part.Name = "CriticalPart"
	part.Shape = "Ball"
	part.Material = "Neon"
	part.Color = Color3.new(1,0,0)
	part.Size = Vector3.new(1.5, 1.5, 1.5)
	part.Position = Vector + Vector3.new(0,9,0)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = game.Workspace
end

function module:DebugVisualize(Vector)
	local part = Instance.new("Part")
	part.Name = "VisualPart"
	part.Shape = "Ball"
	part.Material = "Neon"
	part.Size = Vector3.new(1, 1, 1)
	part.Position = Vector
	part.Anchored = true
	part.CanCollide = false
	part.Parent = game.Workspace
end

function module:DebugVisualizeRemove()
	for i,v in pairs(workspace:GetChildren()) do if v.Name == "VisualPart" then v:Destroy() end end
end

function module:DebugVisualizeRemoveCritical()
	for i,v in pairs(workspace:GetChildren()) do if v.Name == "CriticalPart" then v:Destroy() end end
end

function module:DebugFindOtherMobs()
	return {self.MobAsset}
end

function module:RayTo(target)
	local MobVector = self.MobAsset.HumanoidRootPart.Position
	local targetVector
	if target:IsA("BasePart") then targetVector = target.CFrame.Position else targetVector = target end
	local ray = Ray.new(MobVector, (targetVector - MobVector).Unit * 80)
	local toIgnoreMobs = self:DebugFindOtherMobs()
	local hit,position = workspace:FindPartOnRayWithIgnoreList(ray,toIgnoreMobs)
	return hit,position
end

function module:MoveToPoint(Vector)
	self.MobAsset.Humanoid:MoveTo(Vector)
end

function module:OnFinishedMoveSmart()
	local waypoints = {}
	if self.queueMap[1] ~= self.activeMap and self.Override == true then
			spawn(function() 
				self:ComputeSmart() 
			end)
	else
		if not self.usedRayToPathfindLast then
			waypoints = self.Path:GetWaypoints()
			if self.currentWaypointIndex >= #waypoints then
				self.currentlyPathing=false
			else
				self.currentWaypointIndex = self.currentWaypointIndex+1
				self:MoveToPoint(waypoints[self.currentWaypointIndex].Position)
			end
		else
			self.currentlyPathing=false
		end
	end
end

function module:OnFinishedMovePathfindingOnly()
	local waypoints = {}
	if self.queueMap[1] ~= self.activeMap and self.Override == true then
			spawn(function() 
				self:ComputePathfindingOnly() 
			end)
	else
		waypoints = self.Path:GetWaypoints()
		if self.currentWaypointIndex >= #waypoints then
			self.currentlyPathing=false
		else
			self.currentWaypointIndex = self.currentWaypointIndex+1
			self:MoveToPoint(waypoints[self.currentWaypointIndex].Position)
		end
	end
end

function module:ComputePathfindingOnly()
	self.currentWaypointIndex = 1
	self.currentlyPathing = true
	self.activeMap = self.queueMap[1]
	if self.Path then self.Path:Destroy() end
	self.Path = PathfindingService:CreatePath()
	self.Path:ComputeAsync(self.MobAsset.HumanoidRootPart.Position,self.queueMap[1])
	local waypoints = {}

	if self.Path.Status == Enum.PathStatus.Success and #waypoints >= 2 then
		waypoints = self.Path:GetWaypoints()
		self.currentWaypointIndex = 2
		self:MoveToPoint(waypoints[self.currentWaypointIndex].Position)
	else
		self:MoveToPoint(self.MobAsset.HumanoidRootPart.Position)
	end
end

function module:ComputeSmart()
	local pathfindingNeeded = true
	local rayHit,rayPosition = self:RayTo(self.TargetedAsset.HumanoidRootPart)
	if rayHit then
		if rayHit:IsDescendantOf(self.TargetedAsset) then
			pathfindingNeeded = false
			self:MoveToPoint(rayPosition)
		end
	end
	if pathfindingNeeded then
		self.currentWaypointIndex = 1
		self.currentlyPathing = true
		self.activeMap = self.queueMap[1]
		if self.Path then self.Path:Destroy() end
		self.Path = PathfindingService:CreatePath()
		self.Path:ComputeAsync(self.MobAsset.HumanoidRootPart.Position,self.queueMap[1])
		local waypoints = {}
		
		if self.Path.Status == Enum.PathStatus.Success and #waypoints >= 2 then
			waypoints = self.Path:GetWaypoints()
			self.currentWaypointIndex = 2
			self:MoveToPoint(waypoints[self.currentWaypointIndex].Position)
		else
			self:MoveToPoint(self.MobAsset.HumanoidRootPart.Position)
		end

	end
end

function module:DecidePathFinishedConnection()
	if self.Connection then self.Connection:Disconnect() end
	if self.PathingType == "PathfindingOnly" then
		self.Connection = self.MobAsset.Humanoid.MoveToFinished:Connect(function() self:OnFinishedMovePathfindingOnly() end)
	elseif self.PathingType == "Smart" then
		self.Connection = self.MobAsset.Humanoid.MoveToFinished:Connect(function() self:OnFinishedMoveSmart() end)
	end
end

function module:PathTo(Parameters)
	local PathingType = Parameters.PathingType or error(FailedToProvideA.."Pathing Type")
	local Override = Parameters.Override or false
	local MobAsset = Parameters.MobAsset or error(FailedToProvideA.."Mob Asset")
	local targetPoint = Parameters.targetPoint or error(FailedToProvideA.."Target Point")
	local TargetedAsset = Parameters.TargetedAsset or false if not TargetedAsset and PathingType=="Smart" then error(FailedToProvideA.."Targeted Asset (Required while running smart.)") end

	if not self.MobAsset then 
		self.MobAsset = MobAsset 
	end
	if self.PathingType ~= PathingType then
		self.PathingType = PathingType
		self:DecidePathFinishedConnection()
		self.currentlyPathing = false
	end
	self.Override = Override
	self.TargetedAsset = TargetedAsset
	table.insert(self.queueMap,1,targetPoint)
	if #self.queueMap>2 then table.remove(self.queueMap,#self.queueMap) end

	if not self.currentlyPathing then
		if PathingType=="Smart" then
			self:ComputeSmart()
		elseif PathingType=="PathfindingOnly" then
			self:ComputePathfindingOnly()
		end
	end

end
-- {PathingType="",Override=true,MobAsset=MobAsset,targetPoint=vector,targetedAsset=model}


ObjectOrientation.solidifyClass(module)
return module