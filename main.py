from dotenv import load_dotenv

import maji
import oifey
import os
import random
from client import client

load_dotenv()

# dev commands
@maji.commands.classic("sync")
async def sync(ctx):
    if ctx.author.id != client.owner:
        return
        
    await client.maji.sync(guild=ctx.src.guild.id)
    await client.maji.sync()
    
    print("Sync!")
    
@maji.commands.classic("exit")
async def exit(ctx):
    if ctx.author.id != client.owner:
        return
    
    print("Shutting down...")
    await client.close()

# Load Modules
oifey.module.get_module_file("oifey/modules/valentia.json")
oifey.module.get_module_file("oifey/modules/mystery.json")
oifey.module.get_module_file("oifey/modules/heroes.json")
oifey.module.get_module_file("oifey/modules/engage.json")
oifey.module.get_module_file("oifey/modules/cipher.json")
oifey.module.get_module_file("oifey/modules/gba.json")
oifey.module.get_module_file("oifey/modules/archanea.json")
oifey.module.get_module_file("oifey/modules/house.json")
oifey.module.get_module_file("oifey/modules/fates.json")
oifey.module.get_module_file("oifey/modules/holy.json")
oifey.module.get_module_file("oifey/modules/tellius.json")
oifey.module.get_module_file("oifey/modules/thracia.json")
oifey.module.get_module_file("oifey/modules/bsfe.json")


# Shortcuts
class Shortcut:
    def __init__(self, game, command):
        self.game = game
        self.command = command
        
        maji.commands.add_classic(self.doit, self.command)
        
    async def doit(self, ctx):
        await oifey.modules[self.game].classic[self.command].classic_callback(ctx)
        
# store it somewhere to prevent it from getting deleted
shortcuts = []

for x in ["art", "quotes", "skill", "artist", "va"]:
    short = Shortcut("feh", x)
    
    shortcuts.append(short)

# Random Command
games = []

for i in range(17):
    number = i + 1
    
    if i == 3: continue
    
    games.append(f"fe{number}")
    
@maji.commands.classic("random")
async def random_command(ctx):
    game = random.choice(games)
    
    ctx.content = "random"
    
    await oifey.modules[game].classic["unit"].classic_callback(ctx)


# Joke Commands
# sommie
engage = oifey.modules["fe17"]

class SommieButton(maji.Button):
    def action(self, interaction):
        user = oifey.user.get(-1)
        
        if not "sommie" in user:
            user["sommie"] = 0
        
        user["sommie"] += 1
        
        oifey.user.update(-1, user)
        
        edit = self.parent.pages[1]
        
        edit.description = edit.description.format(user["sommie"])
        
        super().action(interaction)

async def sommie(ctx):
    embed1 = maji.Embed(desc = "You have found Sommie! Do you wish to pet him?")
    embed1.attach("image", "https://raw.githubusercontent.com/izumi-niche/OifeyImg/master/sommie/default.png?raw")
    
    embed2 = maji.Embed(desc = "Sommie is very happy! He has been pet {} times so far.")
    embed2.attach("image", "https://raw.githubusercontent.com/izumi-niche/OifeyImg/master/sommie/pet.png?raw")
    
    multi = maji.MultiEmbed([embed1, embed2])
    multi.button(page=1, button=SommieButton, label="Pet Sommie!", emoji="<:sommie:1135433638796865716>")
    
    await multi.send(ctx)
    
@maji.commands.classic("sommie_set")
async def sommie_set(ctx):
    if ctx.author.id != client.owner:
        return
        
    user = oifey.user.get(-1)
    
    user["sommie"] = int(ctx.content)
    
    oifey.user.update(-1, user)
    
engage.special["sommie"] = sommie

# ninian
fe6 = oifey.modules["fe6"]

async def ninian(ctx):
    embed = maji.Embed()
        
    embed.attach("image", "database/ninian.png")
    
    return embed

fe6.special["ninian"] = ninian

# lorenz
"""
@maji.commands.classic("fe3")
async def fe3(ctx):
    if ctx.content.lower().strip() == "b2 lorenz":
        embed = maji.Embed()
        
        embed.attach("image", "database/lorenz.gif")
        
        await embed.send(ctx)
        
@maji.commands.classic("b2")
async def b2(ctx):
    if ctx.content.lower().strip() == "lorenz":
        embed = maji.Embed()
        
        embed.attach("image", "database/lorenz.gif")
        
        await embed.send(ctx)
"""

fe3 = oifey.modules["fe3"]
b2 = oifey.modules["b2"]

async def lorenz(ctx):
    if ctx.content.lower().strip() == "b2 lorenz" or ctx.content.lower().strip() == 'lorenz':
        embed = maji.Embed()

        embed.attach("image", "database/lorenz.gif")
    
    return embed
fe3.special["b2 lorenz"] = lorenz
b2.special["lorenz"] = lorenz

# b2 jagen
fe3 = oifey.modules["fe3"]
b2 = oifey.modules["b2"]

async def jagen(ctx):
    if ctx.content.lower().strip() == "b2 jagen" or ctx.content.lower().strip() == 'jagen':
        embed = maji.Embed()

        embed.attach("image", "database/jagenb2.png")
    
    return embed
fe3.special["b2 jagen"] = jagen
b2.special["jagen"] = jagen

# fe12 Jagen
fe12 = oifey.modules["fe12"]

async def jagenfe12(ctx):
    embed = maji.Embed()
        
    embed.attach("image", "database/jagenb2.png")
    
    return embed

fe12.special["jagen"] = jagenfe12

# malledus
fe1 = oifey.modules["fe1"]
fe3 = oifey.modules["fe3"]
b1 = oifey.modules["b1"]
fe11 = oifey.modules["fe11"]
async def malledus(ctx):
    if ctx.content.lower().strip() == "b1 malledus" or ctx.content.lower().strip() == 'malledus':
        embed = maji.Embed()

        embed.attach("image", "database/malledus.png")
    
        return embed
fe1.special["malledus"] = malledus
fe3.special["malledus"] = malledus
b1.special["malledus"] = malledus
fe11.special["malledus"] = malledus

# denning
fe7 = oifey.modules["fe7"]

async def denning(ctx):
    embed = maji.Embed()
        
    embed.attach("image", "database/denning.jpg")
    
    return embed

fe7.special["denning"] = denning

@maji.commands.classic("calendar")
async def calendar(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/august-september-2026-calendar-v0-go3myi1kvnih1.jpeg?auto=webp&s=ba9bc99fd75dcf96f6529e1959497d2866250114")
    
    await embed.send(ctx)

@maji.commands.classic("legendary")
async def legendary(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/legendary-mythic-emblem-heroes-schedule-updated-august-31st-v0-zw447w5ktqmh1.png?width=1080&crop=smart&auto=webp&s=426997c6a4d7940a2bec52996985e427173f510b")
    
    await embed.send(ctx)

@maji.commands.classic("mythic")
async def mythic(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/legendary-mythic-emblem-heroes-schedule-updated-august-31st-v0-zw447w5ktqmh1.png?width=1080&crop=smart&auto=webp&s=426997c6a4d7940a2bec52996985e427173f510b")
    
    await embed.send(ctx)

@maji.commands.classic("emblem")
async def mythic(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/legendary-mythic-emblem-heroes-schedule-updated-august-31st-v0-zw447w5ktqmh1.png?width=1080&crop=smart&auto=webp&s=426997c6a4d7940a2bec52996985e427173f510b")
    
    await embed.send(ctx)

@maji.commands.classic("remix")
async def remix(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/legendary-mythic-emblem-heroes-schedule-updated-august-2nd-v0-te5sl58xtygh1.png?width=1080&crop=smart&auto=webp&s=3b61e07e3fdf27cbf8e09201988efd4dc5928c6d")
    
    await embed.send(ctx)

@maji.commands.classic("revival")
async def remix(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/legendary-mythic-emblem-heroes-schedule-updated-august-31st-v0-z3q6ww5ktqmh1.png?width=1080&crop=smart&auto=webp&s=cf7fb46cdbd8f92cb0f383f5b0f27f33a5a3077b")
    
    await embed.send(ctx)

@maji.commands.classic("weekly")
async def remix(ctx):
    embed = maji.Embed()
    
    embed.attach("image", "https://preview.redd.it/weekly-revival-summoning-focus-schedule-august-2026-to-v0-uzcb8lr3s7hh1.png?width=1080&crop=smart&auto=webp&s=7e1025165d318f678c6126be60c4142946b9e2d3")
    
    await embed.send(ctx)

# help command
@maji.commands.classic("help")
async def help_command(ctx):
    embed = maji.Embed(title = "Jagen Bot")
    
    def read(txt):
        with open(txt, "r", encoding="utf-8" ) as f:
            return f.read()
            
    embed.set("desc", read("text/help_changes.txt"))
    
    embed.add_field("Games", read("text/help_main.txt"), True)
    embed.add_field("Other", read("text/help_other.txt"), True)
    
    embed.attach("image", "text/help_image.png")
    
    await embed.send(ctx)
    
# run (or try to)
    
client.run(os.getenv('TOKEN'))


