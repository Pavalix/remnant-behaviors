
local ModuleContainer = _G.ModuleContainer or require(game:GetService("ReplicatedStorage").ModuleScriptLookup)
local ObjectOrientation = require(ModuleContainer.ObjectOrientation)
local Behavior = require(ModuleContainer.Behavior)
local module = {
    className = "Wander";
    value = 9999;
}
ObjectOrientation.inheritClass(module,Behavior)
--ObjectOrientation.implementInterfaces(module,<INTERFACE>)
--ObjectOrientation.expressTraits(module,<TRAIT>)

--constructor:
function module:new()
    self = self.Super:new()

    --do constructor stuff

    return self
end

function module:DebugVisualizeWanderPoints(Vector)
	local part = Instance.new("Part")
	part.Name = "WanderLocation"
	part.Material = "Neon"
	part.Color = Color3.new(0,1,0)
	part.Size = Vector3.new(2, 2, 2)
	part.Position = Vector + Vector3.new(0,7,0)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = game.Workspace
end

function module:BasicWander(MobAsset,actionData)
    local MobHumanoid = MobAsset.Humanoid
    local MobPosition = MobAsset:GetPrimaryPartCFrame().Position
    local wanderChance = actionData.wanderChance
    local wanderRadius = math.random(actionData.wanderRange.min,actionData.wanderRange.max)
    local Angle = math.random(0,2*math.pi)
    local AngleX = math.cos(Angle)
    local AngleZ = math.sin(Angle)
    local wanderVector = Vector3.new(wanderRadius*AngleX,0,wanderRadius*AngleZ) + MobPosition
    if wanderChance>math.random() then
        Parameters = {PathingType="PathfindingOnly",Override=true,MobAsset=MobAsset,targetPoint=wanderVector}
        self:PathTo(Parameters)
    end
end

ObjectOrientation.solidifyClass(module)
return module