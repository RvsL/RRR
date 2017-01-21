# library(telegram)
# 
# ## Create the bot object
# #R_TELEGRAM_BOT_rvsl_msg_bot=321563103:AAFZ5mR19xcZEwT-pblCUYsmVHkp8b36ef0
# bot <- TGBot$new(token = '321563103:AAFZ5mR19xcZEwT-pblCUYsmVHkp8b36ef0')
# 
# ## Now check bot connection it should print some of your bot's data
# bot$getMe()
# 
# ## Now, on the phone, find and say something to your bot to start a chat
# ## (and obtain a chat id).
# ## ...
# 
# ## Here, check what you have inserted
# bot$getUpdates()
# 
# ## You're interested in the message.chat.id variable: in order to set a
# ## default chat_id for the following commands (to ease typing)
# bot$set_default_chat_id(181686655)
# #bot$set_default_chat_id(user_id('@ravasil'))
# bot$sendMessage('This is text')


library(telegram)
bot <- TGBot$new(token = '321563103:AAFZ5mR19xcZEwT-pblCUYsmVHkp8b36ef0')
bot$set_default_chat_id(181686655)
#bot$sendMessage('This is text')

