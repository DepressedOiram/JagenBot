local almanac = require("almanac")
local workspaces = almanac.workspaces

local util = almanac.util

local Infobox = almanac.Infobox
local Pagebox = almanac.Pagebox

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
    aquarius = {skl = 10, atk= 10, spd = 10, wlv = 10},
    gemini = {atk = 30, wlv = -10, def = 20},
    taurus = {hp = 5, atk = 5, skl = 5, spd = 5, wlv = 5, lck = 5, def = 5, res =5},
    cancer = {atk = -10, def = 50},
    libra = {hp = -10, spd = 40, lck = 10, wlv = 10, res = -10},
    scorpio = {atk = 20, skl = 20, spd = 10, lck = -10},
    leo = {atk = 50, def = -10},
    virgo = {wlv = 20, def = -10, res = 30},
    sagittarius = {hp = -10, skl = 40, spd = 10},
    pisces = {hp = 10, def = 10, res = 10,lck = 10},
    aries = {lck = 40}
}
---------------------------------------------------
-- Inventory --
---------------------------------------------------
local inventory = fe2.Character.inventory:use_as_base()
inventory.eff_might = 3
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
Character.compare_cap = false
Character.helper_job_growth = false

Character.inventory = inventory

Character.Job = Job
Character.Item = Item

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

function Character:show_cap()
    return nil
end

function Character:get_cap()
    return {hp = 52, atk = 20, skl = 20, spd = 20, lck = 20, wlv = 20, def = 20, res = 20}
end

-- Supports
function Character:show_sup()
    sup_title = self:get_name() .. ' Support Bonuses'
    local infobox = Infobox:new({title = sup_title })
    
    local text = "Units must be standing within 3 tiles to recieve bonus Hit/Avoid/Crit.\n\n"

    if self.data.support['give'] ~= false then
        for key, value in pairs(self.data.support['give']) do
            text = text .. '**Gives +' .. key .. " to:** "
            text = text .. table.concat(self.data.support['give'][key], ", ")
            text = text .. '\n'
        end
        text = text .. '\n'
        
    end

    if self.data.support['recieve'] ~= false then
        for key, value in pairs(self.data.support['recieve']) do
            text = text .. '**Receives +' .. key .. " from:** "
            text = text .. table.concat(self.data.support['recieve'][key], ", ")
            text = text .. '\n'
        end
    end
    
    infobox:set("desc", text)
    infobox:set("footer", "Supports are not all reciprocal")
    
    return infobox
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
    local base = workspaces.Character.calc_base(self)

    return base
end

function Character:show_info()
    local box = self:show_mod()

    
    if (self.data.support ~= false) then
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
    job1_base.hp = self.data.base.hp
    job1_base.wlv = self.data.base.wlv
    local job2_base = job2:get_base()

    promo = util.math.sub_stats(job2_base, job1_base)
    if promo.hp < 0 then
        promo['hp'] = 0
    end
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

function Job:promo_bonus(job1, job2)

    local job1_base = job1:get_base()
    local job2_base = job2:get_base()
    
    local promo = util.math.sub_stats(job2_base, job1_base)
    if promo.hp < 0 then
        promo['hp'] = 0
    end
    if promo.wlv < 0 then
        promo['wlv'] = 0
    end
    promo = util.math.remove_zero(promo)

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
