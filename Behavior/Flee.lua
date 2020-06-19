
local ModuleContainer = _G.ModuleContainer or require(game:GetService("ReplicatedStorage").ModuleScriptLookup)
local ObjectOrientation = require(ModuleContainer.ObjectOrientation)
local Behavior = require(ModuleContainer.Behavior)
local module = {
    className = "Flee";
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

function module:findTerrainPointFromVector(Vector)
    local RaisedVector = Vector+Vector3.new(0,50,0)
    local PointRay = Ray.new(RaisedVector,Vector3.new(0,-200,0))
    local Part, hitPosition,surfaceNormal,Material = workspace:FindPartOnRay(PointRay)
    --what do we do if it's trying to run to the water?? (enum.Material.Water)
    return hitPosition+Vector3.new(0,0.1,0)
end

function module:FleeFromAsset(MobAsset,Asset)
    local MobHumanoid = MobAsset.Humanoid
    local mobPosition = MobAsset:GetPrimaryPartCFrame().Position
    local combinedVector = ((Asset.HumanoidRootPart.Position-mobPosition)*Vector3.new(1,0,1))
    local invertedUnitVector = (combinedVector*Vector3.new(-1,1,-1)).Unit
    local fleeVector = (invertedUnitVector*Vector3.new(30,1,30)) + mobPosition
    local trueFleeVector = self:findTerrainPointFromVector(fleeVector)
    Parameters = {PathingType="PathfindingOnly",Override=false,MobAsset=MobAsset,targetPoint=trueFleeVector,TargetedAsset=Asset}
    self:PathTo(Parameters)
end

ObjectOrientation.solidifyClass(module)
return module