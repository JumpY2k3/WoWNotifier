<p align="center">
  <img src="https://user-images.githubusercontent.com/16124598/193567201-acc31773-9212-418a-b1da-9300371e7a87.png">
</p>

# WoW Notifier for World of Warcraft classic
Sends periodic messages of your position in the WoW login queue and alerts on disconnect or when queue has ended.

General functions overview:
1. Detect your position in queue and ETA for login
2. Play sound alerts on disconnect or when queue has ended (optional)
3. Supports different message methods like Discord, Telegram, Text Messages, Alexa 'Notify Me' Skill, Home Assistant scripts and Pushover (Special thanks to @ninthwalker for his work before!) (optional)
  
Note: This does not interact with the game at any level or in any way.  
Default settings should work for most people and offer a high probability of being informed.

Just set up at least one notification app and you are good to go!  

## Details/Requirements
1. Windows 10
2. Powershell 3.0+ (Comes with WIN10)
3. .Net Framework 3.5+ (Usually already on Windows 10 as well)
4. The World of Warcraft classic game (installed on your Windows 10 computer)
5. One notification app: Discord, Telegram, Pushover, Cell Phone, or Alexa Device.

## How it works
It takes a screenshot of the wowclassic game window. (NEW: It does not have to be in the foreground!)
It then uses Windows 10 Built-in OCR (Optical Character Recognition) to read the text in that screenshot. It will decide which routine is active and inform you about different states of the login queue.

## How to use

1. Click 'Start' to begin scanning your queue status and notifying you.
2. Click 'Stop' to halt scanning and notifications.
3. ???
4. Profit!
  
## Install Options  

1. Click the 'Code' button on this page. Then select 'Download ZIP'  
2. Extract the contents of the ZIP file. You will need the 'WoWNotifier.lnk' shortcut, the 'WoWNotifier.ps1' and the both soundfiles 'sound_failed.wav' and 'sound_success.wav'. Make sure you keep all 4 files in the same directory whereever you want. 
3. Start the script with a double click to the shortcut **WoWNotifier.lnk**.

You may need to 'unblock' the zip file before extracting. This is normal behavior for Microsoft Windows to do for files downloaded from the internet.  
`Right click > Properties > Check 'Unblock'`

## Config/Settings  
Some initial configuration is required before it will send information to your notification app.
To activate and edit your notification setting, right click and edit the **WoWNotifier.ps1** file. You will find all notification settings in one area # NOTIFICATION SETTINGS #. See the explanation close to the specific settings when you edit them.

**Note: The only required setting to make this work is to set up one notification type.**  
Currently supported Notification apps are: Discord, Telegram, Pushover, Text Messages, Home Assistant and the Alexa 'Notify Me' Skill.  

### Required Settings:  
At least one of the below notification types is required. Or you can set up all 5 if you want!  

* **Discord**  
Set discord to $True to enable this notification type.
Enter in the discord webhook for the channel you would like the notification to go to. (May create your own server for this) 
Discord > Click cogwheel next to a channel to edit it > Webhooks > Create webhook.
See this quick video I found on Youtube if you need further help. It's very easy. Do not share this Webhook with anyone else.
[Create Discord Webhook](https://www.youtube.com/watch?v=zxi926qhP7w)  
**Important:** If using the Discord notification type, the Desktop Discord App on your computer must *not* be running. (Discord does not send mobile notifications if you are Active in another Discord app =( See Dev post [here](https://twitter.com/discordapp/status/720723876934582272))

* **Pushover**  
Set pushover to $True to enable this notification type.  
Log in and create a new application in your Pushover.net account.  
Copy the User API Key and the newly created Application API Key to the Pushover variables.  
Set the optional commented out settings if desired.  
(Thanks to @pattont for this Notification Type)    

* **Telegram**  
This can be a little more complicated to set up, but you can look online for further help. The basics are below but I didn't go into detail:  
Set telegram to $True to enable this notification type.  
Get the Token by creating a bot by messaging @BotFather  
Get the ChatID by messaging your bot you created, or making your own group with the bot and messaging the group. Then get the ChatID for that conversation with the below step.  
Go to this url replacing [telegramBotToken] with your own Bot's token and look for the chatID to use. 
https://api.telegram.org/bot[telegramBotToken]/getUpdates

* **Text Message**  
Note: I didn't want to code in all the carriers and all the emails. So only Gmail is fully supported for now. If using 2FA, make a google app password from here: https://myaccount.google.com/security.  
Feel free to do a pull request to add more if it doesn't work with these default settings and options. Or just edit the below code with your own carrier and email settings.  
Set textMsg to $True  to enable this notification type.  
Enter carrier email, should be in the format of:  
"@vtext.com", "@txt.att.net", "@messaging.sprintpcs.com", "@tmomail.net", "@msg.fi.google.com"  
Enter in your phone number, email address and email password.  
Change the smtp server and port if you are not using Gmail.  

* **Alexa 'Notify Me' Skill**  
Set alexa to $True to enable this notification type.  
Enable the Skill inside the Alexa app. once linked it will email you an Access Code.  

* **Home Assistant**  
This is probably way more advanced than most people will use, but it's here for those that want it.  
I personally use this so my Alexa devices will announce when my queue has ended.  
Set HASS to $True  
Set your HASS URL, and API Token  
Enter in your script's entity_id that you want to have run when the Queue .

### Optional/Advanced Settings:  

To edit optional settings, right click and edit the WoWNotifier.ps1 file. You will find all optional settings in one area # GENERAL SETTINGS #. See the explanation close to the specific settings when you edit them.

1. **Delay**
If you would like to change how often the script scans the Queue Window you can enter a different time here in seconds.
Note: this script uses hardly any resources and is very quick at the screenshot/OCR process.  
Default Value: 30 seconds 

2. **Stop on Queue**
'Yes' will stop the script when the Queue window is gone. 'No' will have it continue to scan and must be stopped manually.
You will receive a lot of messages and sound (every X-seconds like $delay) when login is successfull or failed. It is very helpful to get several messages to detect a random disconnect or notice that the queue is finished. (You have a small time window to react on this!)  
Default Value: 'No'

3. **Queue Check**
Set to "Yes" to enable alerts for what position in queue you are. Also set an interval time for how often it will notify you.  
Use interval time in minutes.  
Queue Check Default Value: 'Yes'  
Queue Check Interval Default value: 5

4. **Play Sound**
Option to play a sound notification when Queue has ended or disconnected. The both sound files "sound_failed.wav" and "sound_success.wav" have to be in the program directory. The sound is played on the active output device configured in Windows.  
Default Value: 'Yes'

5. **Screenshot Path**
Set the path to where you would like the temporary screenshot to be saved to. Do not change it if you are unsure if the path is correct!  
By default it goes to your application directory.  
  
## FAQ/Common Issues  
1. As noted above, this app is entirely legal/safe/conforms to all TOS of Amazon and WoW. This does not touch the game or files in any way.  
2. Make sure you have double quotes around your app webhooks and most settings you configured in the script. ie: "webhook here"  
3. If you use a different language setting other than English or German for your Game language, this may not work. You can contact me for other languages. 

**Special Thanks to @Ninthwalker for his initial version of the script. Check out his Repositories: https://github.com/ninthwalker**

## Screenshots
<p align="center">
  <img src="https://user-images.githubusercontent.com/16124598/193568545-52cb03fb-77fc-4524-9268-b42ca56465d1.png">
</p>
