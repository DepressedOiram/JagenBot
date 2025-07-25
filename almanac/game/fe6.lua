local almanac = require("almanac")
local workspaces = almanac.workspaces

local util = almanac.util

local Infobox = almanac.Infobox
local Pagebox = almanac.Pagebox
 
local Character = {}
local Job = {}
local Item = {}

local rank_exp = {
    E = 1,
    D = 51,
    C = 101,
    B = 151,
    A = 201,
    S = 251
}

local gba_pack = util.emoji.get("database/emoji_gba.json")

---------------------------------------------------
-- Inventory --
---------------------------------------------------
local inventory = util.math.Inventory:new()

local function inventory_atk(data, unit, item)
    return unit.stats.atk + item.stats.mt
end

local function inventory_as(data, unit, item)
    return unit.stats.spd - math.max(item.stats.wt - unit.stats.con, 0)
end

local function inventory_hit(data, unit, item)
    return item.stats.hit + (unit.stats.skl * 2) + util.floor(unit.stats.lck / 2)
end

local function inventory_crit(data, unit, item)
    return util.floor(unit.stats.skl / 2) + item.stats.crit + unit.job:crit_bonus()
end

inventory:item_calc("atk", inventory_atk)
inventory:item_calc("as", inventory_as)
inventory:item_calc("hit", inventory_hit)
inventory:item_calc("crit", inventory_crit)

inventory.eff_multiplier = 3

---------------------------------------------------
-- Character --
---------------------------------------------------
Character.__index = Character
setmetatable(Character, workspaces.Character)

Character.section = almanac.get("database/fe6/char.json")
Character.helper_portrait = "database/fe6/images"

Character.helper_job_base = true

Character.allow_show_promo = true
Character.promo_use_fixed = true

Character.allow_show_cap = false
Character.compare_cap = false

Character.allow_promo_skill = false
Character.average_classic = false
Character.rank_exp = rank_exp
Character.pack = gba_pack

Character.inventory = inventory

Character.alt_icon = {
    {label = "A Route", emoji = "larum"},
    {label = "B Route", emoji = "elffin"}
}

Character.Job = Job
Character.Item = Item

function Character:default_options()
    return {
        class = self.data.job,
        difficulty = "hard",
        growth = false,
        support = false
    }
end

function Character:setup()
    self.job = self.Job:new(self.options.class)
    
    self.difficulty = self.options.difficulty
    
    self.drop = self.options.growth
    
    self.support = self.options.support
    
    if self.support then
        self.support = getmetatable(self):new(self.support)
    end
end

-- Show
function Character:show()
    if self.support then
        return self:show_support()
        
    else
        return workspaces.Character.show(self)
    end
end

local affinity_bonus = {
    fire = {atk = 0.5, hit = 2.5, avoid = 2.5, crit = 2.5},
    thunder = {def = 0.5, avoid = 2.5, crit = 2.5, dodge = 2.5},
    wind = {atk = 0.5, hit = 2.5, crit = 2.5, dodge = 2.5},
    ice = {def = 0.5, hit = 2.5, avoid = 2.5, dodge = 2.5},
    dark = {hit = 2.5, avoid = 2.5, crit = 2.5, dodge = 2.5},
    light = {atk = 0.5, def = 0.5, hit = 2.5, crit = 2.5},
    anima = {atk = 0.5, def = 0.5, avoid = 2.5, dodge = 2.5}
}

-- Support
function Character:show_support()
    local name1 = util.text.remove_parentheses(self.data.name)
    local name2 = util.text.remove_parentheses(self.support.data.name)
    
    local infobox = Infobox:new({title = string.format("%s & %s Bonuses", 
    name1, name2)})
    
    name1 = self:get_affinity() .. name1
    name2 = self.support:get_affinity() .. name2
    
    infobox:set("desc", string.format("%s\n%s", name1, name2))
    
    local aff1 = affinity_bonus[self.data.affinity]
    local aff2 = affinity_bonus[self.support.data.affinity]
    
    
    for i, pair in ipairs({"C", "B", "A"}) do
        local result = util.math.affinity_calc(aff1, aff2, i)
        
        infobox:insert("Support " .. pair, util.table_stats(result, 
        {value_start="**+", value_end="**", order = "equip"}))
    end
    
    infobox:image("thumbnail", self:get_portrait())
    
    return infobox
end

-- Info
function Character:show_info()
    local box = self:show_mod()
    
    if util.table_has(self.data.support) then
        local supportbox = self:show_sup()

        
        -- If unit has alts it means it already it's a pagebox
        if self.data.alt and #self.data.alt > 0 then
            box:page(supportbox)
            
            box:button({label = "Supports", emoji = "bubble"})
            
            return box
        else
            local pagebox = Pagebox:new()
            
            pagebox:page(box)
            pagebox:stats_button()
            
            -- add supportbox here
            pagebox:page(supportbox)
            pagebox:button({label = "Supports", emoji = "bubble"})
            
            
            
            return pagebox
        end
    else
        return box
    end
end

function Character:show_mod()
    local infobox = self:show_unit_info()
    
    -- Multiple versions of this unit
    if self.data.alt and #self.data.alt > 0 then
        local pagebox = Pagebox:new()
        local icon = self.alt_icon
        
        pagebox:page(infobox)
        pagebox:button({label = icon[1].label, emoji = gba_pack:get(icon[1].emoji)})
        
        local tbl = getmetatable(self)
        
        for i, pair in ipairs(self.data.alt) do
            local character = tbl:new(pair)
            character:set_options(self.passed_options)
            
            pagebox:page(character:show_unit_info())
            pagebox:button({label = icon[1+i].label, emoji = gba_pack:get(icon[1+i].emoji)})
        end
        
        return pagebox
    else
        return infobox
    end
end

-- Separate the main unit page if they have multiple route versions
function Character:show_unit_info()
    local infobox = workspaces.Character.show_mod(self)
    
    if not self:is_changed() and self.data.affinity then
        infobox:set("desc", infobox:get("desc") .. string.format("\n%s%s", 
                        gba_pack:get("aff_" .. self.data.affinity), util.title(self.data.affinity)))
    end
    
    if self:has_differences() then
        if self.difficulty == "hard" then
            infobox:set("footer", "Hard Mode | Stats can vary by -1/+1 point due to how hard bonuses work.")
        
        else
            infobox:set("footer", "Normal Mode")
        end
        
    end
    
    return infobox
end

-- Support Page
function Character:show_sup()
    local infobox = Infobox:new({title = self:get_name()})
    
    local text = ""
    
    for key, value in pairs(self.data.support) do
        local add = string.format("%s**%s:** Base: %s | Growth: %s",
                                  gba_pack:get("aff_" .. value.affinity),
                                  key, value.base, value.growth)
                                  
        text = text .. add .. "\n"
    end
    
    infobox:set("desc", text)
    
    return infobox
end

-- Base
function Character:calc_base()
    local base = workspaces.Character.calc_base(self)
    
    return base
end

-- Change stats based on difficulty
function Character:final_base()
    local base = workspaces.Character.final_base(self)

    if self.job.id ~= self.data.job then
        
        local job = self.Job:new(self.data.job)
    end

    -- if it's mounted
    if self.job.data.mov then
        local aid
        if self.data.gender == "female" then aid = 20 else aid = 25 end
        
        base.aid = math.max(aid - base.con, 0)
        
    else
        base.aid = math.max(base.con - 1, 0)
    end
    
    return base
end

function Character:get_base()
    local key = "base"
    
    if self:has_differences() and self.difficulty ~= "normal" then
        key = self.difficulty
    end
    
    return util.copy(self.data[key])
end

-- If unit has differences between difficulties
function Character:has_differences()
    return (self.data.hard)
end

-- Growth
function Character:calc_growth()
    local growth = self:get_growth()
    
    if self.drop then
        growth = growth + 5
    end
    
    return growth
end

-- Cap
function Character:get_cap()
    return self.job:get_cap()
end

-- Rank Display
function Character:show_rank()
    if self.job:has_rank() then
        local rank = self:get_rank()
        
        return util.text.weapon_rank(rank, {exp = self.rank_exp, pack = gba_pack})
    end
end

function Character:get_rank()
    local result = self.job:get_rank()
    
    for k, v in pairs(self.data.rank) do
        if result[k] ~= nil then
            result[k] = v
        end
    end
    
    return result
end

function Character:get_affinity()
    return gba_pack:get("aff_" .. self.data.affinity)
end

---------------------------------------------------
-- Job --
---------------------------------------------------
Job.__index = Job
setmetatable(Job, workspaces.Job)

Job.crit_value = 30
Job.crit_table = {"swordmasterf", "swordmasterm", "swordmaster", "berserker"}

Job.section = almanac.get("database/fe6/job.json")

Job.rank_exp = rank_exp
Job.pack = gba_pack

function Job:crit_bonus()
    if util.value_in_table(self.crit_table, self.id) then
        return self.crit_value
        
    else
        return 0
    end
end

---------------------------------------------------
-- Item --
---------------------------------------------------
Item.__index = Item
setmetatable(Item, workspaces.Item)

Item.section = almanac.get("database/fe6/item.json")

return {
    Character = Character,
    Job = Job,
    Item = Item
}