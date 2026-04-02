import discord, random
from discord.ext import tasks

OWNER_ID = 240452436152549377

random_status = [
    "The best Jagen",
    "Try out compare! @Jagen fe4 lewyn!ced, lewyn!arthur 14",
    "Cipher cards look pretty cool: @Jagen cipher",
    "Acting as the decoy",
    "@Jagen calendar",
    "@Jagen legendary",
    "@Jagen weekly"
]

discord.utils.setup_logging()

change_status = None


class Oifey(discord.AutoShardedClient):
    def __init__(self, **kwargs) -> None:
        #kwargs["activity"] = discord.Game("testing new stuff")
        super().__init__(**kwargs)

        self.debug = True
        self.maji = None
        
        self.owner = OWNER_ID

    async def on_ready(self) -> None:
        print(f"Logged in as {self.user} {self.user.id}!")
        change_status.start()
        
        ping = f"<@{self.user.id}> "
        
        if not ping in self.maji.prefix:
            self.maji.prefix.append(ping)

    async def on_interaction(self, interaction):
        if self.maji and interaction.type == discord.InteractionType.application_command:
            await self.maji.check_slash(interaction)

    async def on_message(self, ctx) -> None:
        if self.maji:
            await self.maji.check(ctx)


intents = discord.Intents.default()

intents.bans = False
intents.dm_reactions = False
intents.dm_typing = False
intents.guild_reactions = False
intents.guild_typing = False
intents.invites = False
intents.reactions = False
intents.typing = False
intents.voice_states = False
intents.webhooks = False
intents.message_content = False

client = Oifey(intents=intents, log_handler=None)

# random status
@tasks.loop(hours=1.0)
async def change_status():
    await client.change_presence(activity=discord.Game(random.choice(random_status)))
