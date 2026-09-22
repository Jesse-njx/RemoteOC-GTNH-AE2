local requested = {}

local function status()
    return {
        hasFailed = function() return false end,
        isComputing = function() return false end,
        isDone = function() return true end,
        isCanceled = function() return false end,
    }
end

local function craftable(stack)
    return {
        getStack = function() return stack end,
        request = function(amount, prioritizePower, cpuName)
            requested.amount = amount
            requested.prioritizePower = prioritizePower
            requested.cpuName = cpuName
            return status()
        end,
    }
end

local me = {
    getItemsInNetwork = function()
        return {{name = "minecraft:stone", label = "Stone", damage = 0, size = 64, isCraftable = true}}
    end,
    getFluidsInNetwork = function()
        return {{name = "water", label = "Water", amount = 1000, size = 1000, isCraftable = true}}
    end,
    getCraftable = function(details, stackType)
        requested.details = details
        requested.stackType = stackType
        if stackType == "fluid" then
            return craftable({name = details.name, label = "Water", amount = 0, size = 0})
        end
        return craftable({name = details.name, label = "Stone", damage = details.damage, size = 0})
    end,
    getCraftables = function()
        return {
            craftable({name = "minecraft:stone", label = "Stone", damage = 0, size = 0}),
            craftable({name = "water", label = "Water", amount = 0, size = 0}),
        }
    end,
    getCpus = function() return {} end,
}

package.preload.component = function()
    return {
        proxy = function() return me end,
        isAvailable = function() return false end,
    }
end
package.preload.env = function() return {aeAddress = "test"} end
package.preload["lib.base64"] = function() return {encode = function(value) return "base64:" .. value end} end

dofile("client/plugins/ae.lua")

local all = ae.getAllItems().data
assert(#all == 2, "items and native fluids should be returned together")
assert(all[1].stackType == "item")
assert(all[2].stackType == "fluid")

local simple = ae.getAllSilempleItems().data
assert(#simple == 2)
assert(simple[2].name == "water" and simple[2].stackType == "fluid")

local itemResult = ae.requestItem("minecraft:stone", 0, 12)
assert(itemResult.message == "success")
assert(requested.stackType == "item" and requested.details.damage == 0)
assert(itemResult.data.stack.stackType == "item")

local fluidResult = ae.requestFluid("water", 4000, "Main CPU")
assert(fluidResult.message == "CPU不存在", "named CPU validation should still be enforced")

local fluidAutoResult = ae.requestFluid("water", 4000)
assert(fluidAutoResult.message == "success")
assert(requested.stackType == "fluid" and requested.amount == 4000)
assert(fluidAutoResult.data.stack.stackType == "fluid")

local craftables = ae.getAllCraftables().data
assert(#craftables == 2)
assert(craftables[1].stackType == "item")
assert(craftables[2].stackType == "fluid")

print("test_ae.lua: ok")
