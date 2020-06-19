
local ModuleContainer = _G.ModuleContainer or require(game:GetService("ReplicatedStorage").ModuleScriptLookup)
local ObjectOrientation = require(ModuleContainer.ObjectOrientation)
local Behavior = require(ModuleContainer.Behavior)
local module = {
    className = "Chase";
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

function module:ChaseAsset(MobAsset,Asset)
    local MobHumanoid = MobAsset.Humanoid
    local mobPosition = MobAsset:GetPrimaryPartCFrame().Position
    local targetPosition = Asset.HumanoidRootPart.Position
    Parameters = {PathingType="Smart",Override=true,MobAsset=MobAsset,targetPoint=targetPosition,TargetedAsset=Asset}
    self:PathTo(Parameters)
end

ObjectOrientation.solidifyClass(module)
return module