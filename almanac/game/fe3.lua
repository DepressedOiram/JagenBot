local almanac = require("almanac")
local workspaces = almanac.workspaces

local util = almanac.util

local Infobox = almanac.Infobox

local pack = util.emoji.get("database/fe3/emoji.json")

local fe2 = require("almanac.game.fe2")

 
local Character = {}
local Redirect = {}
local Book1 = {}
local Book2 = {}
local Job = {}
local Item = {}

local shard_bonus = {
    capricorn = {hp = 20, skl = -10, spd = -10, wlv = 30, def = 10},
    aquarius = {skl = 10, str= 10, spd = 10, wlv = 10},
    gemini = {str = 30, wlv = -10, def = 20},
    taurus = {hp = 5, str = 5, skl = 5, spd = 5, wlv = 5, lck = 5, def = 5, res =5},
    cancer = {str = -10, def = 50},
    libra = {hp = -10, spd = 40, lck = 10, wlv = 10, res = -10},
    scorpio = {str = 20, skl = 20, spd = 10, lck = -10},
    leo = {str = 50, def = -10},
    virgo = {wlv = 20, def = -10, res = 30},
    sagittarius = {hp = -10, skl = 40, spd = 10},
    pisces = {hp = 10, def = 10, res = 10,lck = 10},
    aries = {lck = 40}
}
---------------------------------------------------
-- Inventory --
---------------------------------------------------
local inventory = fe2.Character.inventory:use_as_base()
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

Character.section = almanac.get("database/fe3/b2.json")
Character.helper_portrait = "database/fe3/images"


Character.allow_show_promo = true
Character.promo_minHP = true
Character.helper_job_base = true
Character.compare_cap = true
Character.helper_job_growth = false

Character.inventory = inventory

Character.Job = Job
Character.Item = Item

Character.item_warning = true


function Character:setup()
    self.job = self.Job:new(self.options.class)
    
    self.shard = self.options.shard or {}
    
    if self.options.secret then
        self.shard = {}
        
        for key, value in pairs(shard_bonus) do
            table.insert(self.shard, key)
        end

    end
    self.minimal = false
end

function Character:default_options()
    return {
        class = self.data.job,
        book = "b2",
        shard = false,
        secret = false
    }
end

-- Mod
function Character:show_info()
    local infobox = self:show_mod()
    
    if self.job:can_promo() then
        local promo = self.job:get_promo()
        
        promo_text = promo:promo_bonus(self:final_base())
        promo_text = util.table_stats(promo_text)
        
        local name = promo:get_name()
    end
    
    infobox:image("thumbnail", self:get_portrait())   

    return infobox
end

function Character:show_cap()
    return nil
end

function Character:get_cap()
    return {hp = 52, atk = 20, skl = 20, spd = 20, lck = 20, def = 20, res = 20, wlv = 20}
end

function Character:get_mod()
    local text = self:get_lvl_mod()
    
    if #self.shard > 0 then
        local add = "Shard: "
        
        for i, pair in ipairs(self.shard) do
            add = add .. pack:get("shard_" .. pair)
        end
        
        text = text .. "\n" .. add
    end

    text = text .. self:common_mods()
    
    return text
end

function Character:final_base()
    
    local base = self:calc_base()

    -- For reclass games
    if not self.average_classic then
        if self.helper_job_base and not self:is_personal() then         
            base = util.math.add_stats(base, self.job:get_base())

            base.hp = base.hp - self.job.data.base.hp
            base.wlv = base.wlv - self.job.data.base.wlv 
            
            if self.job.id ~= self.data.job then
                local promo = self.job:promo_bonus(base)
        
                base = util.math.rise_stats(base, promo)
            end
          --[[
            print(self.job.data.name)
            if self.promo_remove_hp then
                base.hp = base.hp - self.job:get_base().hp
            end
            print('reclass')
            print(base.hp)
            ]]
        end
    end
    
    base = self:common_base(base)
    
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

-- Growth
function Character:calc_growth()
    local growth = self:get_growth()
    
    for i, pair in ipairs(self.shard) do
        growth = growth + shard_bonus[pair]
    end
    
    return growth
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
-- Redirect --
---------------------------------------------------
Redirect.__index = Redirect
setmetatable(Redirect, almanac.Workspace)

Redirect.section = almanac.get("database/fe3/redirect.json")

Redirect.redirect = true

function Redirect:default_options()
    return {book = false}
end

function Redirect:setup()
    self.book = self.options.book
end

local redirect_table = {
    b1 = Book1,
    b2 = Book2
    
}

function Redirect:show()
    local character = self:get()
    
    return character:show()
end

function Redirect:get()
    if not self.book then
       
        self.book = self.data.book[1]
      
    
    elseif book and not util.misc.value_in_table(self.data.book, self.book) then
        self.book = self.data.book[1]
    end
    
    local character = redirect_table[self.book]:new(self.id)
    character:set_options(self.passed_options)
    
    return character
end

---------------------------------------------------
-- Books --
---------------------------------------------------

-- Book1
Book1.__index = Book1
setmetatable(Book1, Character)

Book1.section = almanac.get("database/fe3/b1.json")

Book1.book = "b1"

-- Book2
Book2.__index = Book2
setmetatable(Book2, Character)

Book2.section = almanac.get("database/fe3/b2.json")

Book2.book = "b2"

---------------------------------------------------
-- Item --
---------------------------------------------------
Item.__index = Item
setmetatable(Item, fe2.Item)

Item.section = almanac.get("database/fe3/item.json")



--------------------------------------------------
-- Job --
---------------------------------------------------
Job.__index = Job
setmetatable(Job, almanac.workspaces.Job)
Job.section = almanac.get("database/fe3/job.json")
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
    Redirect = Redirect,
    Book1 = Book1,
    Book2 = Book2,
}
