async def get_chat_id(name):
    await asyncio.sleep(3)
    return "chat-%s" % name

async def main():
    result = await get_chat_id("django")