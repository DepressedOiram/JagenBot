local almanac = require("almanac")
local workspaces = almanac.workspaces

local util = almanac.util

local fe3 = require("almanac.game.fe3")

local Infobox = almanac.Infobox

local Character = {}
local Job = {}
local Item = {}
---------------------------------------------------
-- Inventory --
---------------------------------------------------
local inventory = fe3.Character.inventory:use_as_base()
inventory.eff_multiplier = 3
inventory.eff_might = false
inventory:get_calc("atk").func = function(data, unit, item)
if item:is_magic() then
    return item.stats.mt
else
    return unit.stats.atk + item.stats.mt
end end
---------------------------------------------------
-- Character --
---------------------------------------------------
Character.__index = Character
setmetatable(Character, workspaces.Character)

Character.section = almanac.get("database/bsfe/char.json")

Character.helper_portrait = "database/bsfe/images"

Character.allow_show_promo = true
Character.promo_minHP = true
Character.helper_job_base = true
Character.compare_cap = true
Character.helper_job_growth = false

Character.inventory = inventory

Character.Job = Job
Character.Item = Item

function Character:setup()
    self.job = self.Job:new(self.options.class)
    
    self.minimal = false
end

function Character:default_options()
    return {
        class = self.data.job
    }
end

function Character:show_cap()
    return nil
end

function Character:get_cap()
    return {hp = 52, atk = 40, skl = 40, spd = 40, lck = 40, def = 40, res = 40}
end

function Character:final_base()
    
    local base = self:calc_base()

    base = util.math.add_stats(base, self.job:get_base())
    base.hp = base.hp - self.job.data.base.hp

    base.wlv = base.wlv - self.job.data.base.wlv 
    
    if self.job.id ~= self.data.job then
        if (base.hp < self.job.data.base.hp) then
            base.hp = math.max(self.job.data.base.hp, self.data.base.hp)
        end
        if (base.wlv < self.job.data.base.wlv) then
            base.wlv = math.max(self.job.data.base.wlv, self.data.base.wlv)
        end
    end
    
    return base
end

function Character:calc_averages(base, args)
    args = args or {}

    local calculator = self.avg:set_character(self)

    for k, v in pairs(args) do
        calculator[k] = v
    end

    base = calculator:calculate(base, self:get_lvl(), self.lvl, self.job_averages)
    return base
end

function Character:calc_base()
    local base = self:get_base()
    local job = self.Job:new(self.data.job)

    if not self.average_classic and self:has_averages() then
        base = self:calc_averages(base)
    end
   

    return base
end



function Character:get_rank_bonus(job1, job2)
    text = ""
    return text
end

function Character:show_rank()
    return self.job:show_rank()
end


function Character:get_promo_bonus(job1, job2)
    local promo
    local job1_base = job1:get_base()
    job1_base.wlv = self.data.base.wlv
    local job2_base = job2:get_base()

    promo = util.math.sub_stats(job2_base, job1_base)
    promo['hp'] = 0
    if promo.wlv < 0 then
        promo['wlv'] = 0
    end
    promo = util.math.remove_zero(promo)
    return promo
end

---------------------------------------------------
-- Item --
---------------------------------------------------
Item.__index = Item
setmetatable(Item, fe3.Item)

Item.section = almanac.get("database/bsfe/item.json")



--------------------------------------------------
-- Job --
---------------------------------------------------
Job.__index = Job
setmetatable(Job, almanac.workspaces.Job)
Job.section = almanac.get("database/bsfe/job.json")
Job.hp_bonus = false

function Job:can_dismount()
    return self.data.dismount
end

function Job:show_dismount()
    return "**Dismount**: " .. 
    util.table_stats(self:get_dismount(), {value_start = "+"})
end

function Job:get_dismount()
    local dismount = Job:new(self.data.dismount)
    local stats = util.math.sub_stats(dismount:get_base(), self:get_base(), {})  
    stats['wlv'] = 0 
    stats['hp'] = 0 
    stats = util.math.remove_zero(stats)
    return stats
end

function Job:promo_bonus(base)
    -- check for 1 hp bonus if no stats change
    local hp_bonus = true
    
    function bonus_check(stat, v1, v2)
        if v2 > v1 then
            hp_bonus = false
            return true
            
        else
            return false
            
        end
        
        return false
    end
    
    local job = self:get_base()
    
    local promo = util.math.rise_stats(base, job, {
    ignore = {"atk", "skl", "spd", "lck", "def", "res", "mov"}, check = bonus_check, ignore_unchanged = true})
    
    if self.hp_bonus and hp_bonus then
        promo.hp = base.hp + 1
    end
    
    return promo
end

function Job:show_rank()
    return util.text.weapon_no_rank(self.data.weapon)
end

return {
    Character = Character,
    Job = Job,
    Item = Item,
}
