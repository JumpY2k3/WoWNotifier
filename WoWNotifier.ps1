#########################################################################
# Name: WoWNotifier                                                     #
# Desc: Notifies you when your World of Warcraft Queue has ended        #
# Author: JumpY2k3 - juZe Venoxis EU  ; Based on ninthwalker            #
# Instructions: https://github.com/JumpY2k3/WoWNotifier                 #
# Date: 03.10.2022                                                      #
# Version: 1.1                                                          #
#########################################################################

############################## CHANGE LOG ###############################
## 1.0                                                                  #
# Initial App version, Special thanks to ninthwalker!!!                 #
# (Source: https://github.com/ninthwalker/WoWNotifier)                  #             
## 1.1                                                                  #
# - Auto detect WoWClassic Window for Screenshot                        #
# - Add function to play sound on fail / success                        #
# - Add language detection GER / ENG                                    #
# - Major changes in routine. Check for disconnect and ended queue      #
## 1.2                                                                  #
# - Change code for Support of Windows 11 and DirectX 12                #
#########################################################################

using namespace Windows.Storage
using namespace Windows.Graphics.Imaging

##########################################
### CHANGE THESE SETTINGS TO YOUR OWN! ###
##########################################

########################
### GENERAL SETTINGS ###
########################

# Amount of seconds to wait before scanning the Queue window. 
# Note: this script uses hardly any resources and is very quick at the screenshot/OCR process.
$delay = 30

# Option to stop WoWNotifier once the Queue has ended. "Yes" to stop the program, or "No" to keep it running.
# Default is 'No', the scan will not end after queue end is detected. (You will receive a lot of messages and sound (every X-seconds like $delay) when login is successfull or failed)
$stopOnQueue = "No"

# Set to "Yes" to enable alerts for what position in queue you are. Also set an interval time for how often it will notify you
# interval time in minutes. Optional, default is "Yes" and interval "5"
$queueCheck = "Yes"
$queueCheckInterval = 5

# Option to play a sound notification when Queue has ended or disconnected. The both sound files "sound_failed.wav" and "sound_success.wav" have to be in the program directory.
# Default is 'Yes', use 'No' for no sound. 
$playSound = "Yes"

# Screenshot Location to save temporary img for OCR Scan. Change if you want it somewhere else. Default: '(Get-Location).Path' , program directory.
# Do not change it unsure if path is correct!
$path = (Get-Location).Path

#############################
### NOTIFICATION SETTINGS ###
#############################

# One or more notification apps are required. One or All of them can be used at the same time.
# Set the notification app you want to use to '$True' to enable it or '$False' to disable it.
# Then enter your webhook or API type tokens for the notification type you want to use.
# All Notifications are set to $False by default.
# See the Advanced section below this for extra features.

## DISCORD ##
$discord = $False
# Your Discord Channel Webhook. Put your own here.
$discordWebHook = "https://discordapp.com/api/webhooks/4593 - EXAMPLE - EVn24sRzpn5KspJHRebCkldhsklrh2378rUIPG8DWgUEtQpEunzGn7ysJ-rT"

## TELEGRAM ##
$telegram = $False
# Get the Token by creating a bot by messaging @BotFather
$telegramBotToken = "96479117:BAH0 - EXAMPLE - yzTvrc6wUKLHKGYUyu34hm2zOgbQDBMu4"
# Get the ChatID by messaging your bot you created, or making your own group with the bot and messaging the group. Then get the ChatID for that conversation with the below step.
# Then go to this url replacing <telegramBotToken> with your own Bots token and look for the chatID to use. https://api.telegram.org/bot<telegramBotToken>/getUpdates
$telegramChatID =  "-371-EXAMPLE-556032"

## PUSHOVER ##
$pushover = $False
$pushoverAppToken = "GetFromPushoverDotNet"
$pushoverUserToken = "GetFromPushoverDotNet"
# optional Pushover settings. Uncomment and set if wanted.
#$device = "Device"
#$title = "Title" 
#$priority = "Priority"
#$sound = "Sound"

## TEXT MESSAGE ##
$textMsg = $False
# Note: I didn't want to code in all the carriers and all the emails. So only gmail is fully supported for now. If using 2FA, make a google app password from here: https://myaccount.google.com/security
# Feel free to do a pull request to add more if it doesn't work with these default settings optinos. Or just edit the below code with your own carrier and email settings.
# Enter carrier email, should be in the format of: "@vtext.com", "@txt.att.net", "@messaging.sprintpcs.com", "@tmomail.net", "@msg.fi.google.com"
$CarrierEmail = "@txt.att.net" # change to your cell carrier
$phoneNumber = "your phone number" # I didn't need to enter a '1' in front of my number, but you may need to for some carriers
$smtpServer = "smtp.gmail.com" # change to your smtp if you dont use gmail. only Gmail tested though
$smtpPort = "587" # change to your email providers port if not gmail.
$fromAddress = "youremail@domain.com" # usually your email
$emailUser = "youremail@domain.com" # your email address
$emailPass = "your email pass or app password"

## ALEXA NOTIFY ME SKILL ##
$alexa = $False
# Enter in the super long access code that the skill emailed you when you set it up in Alexa"
$alexaAccessCode = "amzn1.ask.account.AEHQ4KJGYGIZ3ZZ - EXAMPLE - LMCMBLAHGKJHLIUHPIUHHTDOUDU567L72OXKPXXLVI568EJJVIHYO2DXGMPXPWZDLJKH678UFUYFJUHLIUG45684679GN2QQ7X23MGMHGGIAJSYG4U2SJIWUF3R5FUPDNPA5I"

## HOME ASSISTANT ##
# This is probably way more advanced than most people will use, but it's here for those that want it.
# I personally use this so my alexa devices will announce that the queue has ended.
$HASS = $False
# Your Home Assistant base url and port. ie: 
$hassURL = "http://192.168.1.20:8123"
# token from Home Assistant
$hassToken = "eyJ0eXAiO - EXAMPLE - iMGDJKOPHRDCMLHHJK8GHGHtyutdiZ.nC15fj0dBr7MRPqee2Dj_eQSS5rLPfdYhjhgljhg34df32f2fgerKHJVmhOi9U"
# entity_id of the script you want to have execute (ie: script.2469282367234)
$entity_ID = "script.15372345285"


#########################################
### DO NOT MODIFY ANYTHING BELOW THIS ###
#########################################


# Force tls1.2 - mainly for telegram since they recently changed this in FEB2020
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# If usuing text method, convert password into secure credential object
if ($textMsg) {
    [SecureString]$secureEmailPass = $emailPass | ConvertTo-SecureString -AsPlainText -Force 
    [PSCredential]$emailCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $emailUser, $secureEmailPass
}

# Screenshot method
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

# Add the WinRT assembly, and load the appropriate WinRT types
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile,                Windows.Storage,         ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine,                Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Foundation.IAsyncOperation`1,       Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.SoftwareBitmap,    Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.RandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]

# New Screenshot function
# Detects wowclassic window automatically
function Get-WoWQueue {

    Add-Type -AssemblyName System.Drawing
    Add-Type -TypeDefinition @'
    using System;
    using System.Runtime.InteropServices;

    [StructLayout(LayoutKind.Sequential)]
    public struct Rect
    {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    public class User32
    {
        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out Rect lpRect);
        [DllImport("user32.dll")]
        public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, int nFlags);
    }
'@

    $proc = Get-Process wowclassic | Select-Object -First 1
    if (-not ($proc)) {
        Get-Process | Where-Object { $_.MainWindowTitle -like '*World of Warcraft*' } | Select-Object -First 1
    }
    $rect = [Rect]::new()
    [User32]::GetWindowRect($proc.MainWindowHandle, [ref]$rect)

    $width = $rect.right - $rect.left
    $height = $rect.bottom - $rect.top
    $bmp = [System.Drawing.Bitmap]::new($width, $height, 'Format32bppArgb')
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $hdcBitmap = $graphics.GetHdc()

    [User32]::PrintWindow($proc.MainWindowHandle, $hdcBitmap, 2)

    $graphics.ReleaseHdc($hdcBitmap)
    $graphics.Dispose()

    $bmp.Save("$path\WoWNotifier_Img.png", 'Png')

}

# OCR Scan Function
function Get-Ocr {

# Takes a path to an image file, with some text on it.
# Runs Windows 10 OCR against the image.
# Returns an [OcrResult], hopefully with a .Text property containing the text
# OCR part of the script from: https://github.com/HumanEquivalentUnit/PowerShell-Misc/blob/master/Get-Win10OcrTextFromImage.ps1

    [CmdletBinding()]
    Param
    (
        # Path to an image file
        [Parameter(Mandatory=$true, 
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    Position=0,
                    HelpMessage='Path to an image file, to run OCR on')]
        [ValidateNotNullOrEmpty()]
        $Path
    )

    Begin {
            
        # [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages
        $ocrEngine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    

        # PowerShell doesn't have built-in support for Async operations, 
        # but all the WinRT methods are Async.
        # This function wraps a way to call those methods, and wait for their results.
        $getAwaiterBaseMethod = [WindowsRuntimeSystemExtensions].GetMember('GetAwaiter').
                                    Where({
                                            $PSItem.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
                                        }, 'First')[0]

        Function Await {
            param($AsyncTask, $ResultType)

            $getAwaiterBaseMethod.
                MakeGenericMethod($ResultType).
                Invoke($null, @($AsyncTask)).
                GetResult()
        }
    }

    Process
    {
        foreach ($p in $Path)
        {
      
            # From MSDN, the necessary steps to load an image are:
            # Call the OpenAsync method of the StorageFile object to get a random access stream containing the image data.
            # Call the static method BitmapDecoder.CreateAsync to get an instance of the BitmapDecoder class for the specified stream. 
            # Call GetSoftwareBitmapAsync to get a SoftwareBitmap object containing the image.
            #
            # https://docs.microsoft.com/en-us/windows/uwp/audio-video-camera/imaging#save-a-softwarebitmap-to-a-file-with-bitmapencoder

            # .Net method needs a full path, or at least might not have the same relative path root as PowerShell
            $p = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
        
            $params = @{ 
                AsyncTask  = [StorageFile]::GetFileFromPathAsync($p)
                ResultType = [StorageFile]
            }
            $storageFile = Await @params


            $params = @{ 
                AsyncTask  = $storageFile.OpenAsync([FileAccessMode]::Read)
                ResultType = [Streams.IRandomAccessStream]
            }
            $fileStream = Await @params


            $params = @{
                AsyncTask  = [BitmapDecoder]::CreateAsync($fileStream)
                ResultType = [BitmapDecoder]
            }
            $bitmapDecoder = Await @params


            $params = @{ 
                AsyncTask = $bitmapDecoder.GetSoftwareBitmapAsync()
                ResultType = [SoftwareBitmap]
            }
            $softwareBitmap = Await @params

            # Run the OCR
            Await $ocrEngine.RecognizeAsync($softwareBitmap) ([Windows.Media.Ocr.OcrResult])

        }
    }
}

# Notification function
function WoWNotifier {

    # alert function
    function Send-Alert {

        # msg Discord
        if ($discord) {

            $discordHeaders = @{
                "Content-Type" = "application/json"
            }

            $discordBody = @{
                content = $msg
            } | convertto-json

            Invoke-RestMethod -Uri $discordWebHook -Method POST -Headers $discordHeaders -Body $discordBody
        }

        # msg Telegram
        if ($telegram) {
            Invoke-RestMethod -Uri "https://api.telegram.org/bot$($telegramBotToken)/sendMessage?chat_id=$($telegramChatID)&text=$($msg)"
        }
    
        # msg Pushover
        if ($pushover) {
            $data = @{
                token = "$pushoverAppToken"
                user = "$pushoverUserToken"
                message = "$msg"
            }
        
            if ($device)   { $data.Add("device", "$device") }
            if ($title)    { $data.Add("title", "$title") }
            if ($priority) { $data.Add("priority", $priority) }
            if ($sound)    { $data.Add("sound", "$sound") }

            Invoke-RestMethod "https://api.pushover.net/1/messages.json" -Method POST -Body $data
        }
    
        # text Msg
        if ($textMsg) {
            Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Priority High -from $fromAddress -to $($phoneNumber+$CarrierEmail) -Subject "WoW Alert" -Body $msg -Credential $emailCreds
        }
    
        # msg Alexa
        if ($alexa) {
            $alexaBody = @{
                notification = $msg
                accessCode = $alexaAccessCode
            } | ConvertTo-Json

            Invoke-RestMethod https://api.notifymyecho.com/v1/NotifyMe -Method POST -Body $alexaBody
        }

        if ($HASS) {
    
            $hassHeaders = @{
                "Content-Type" = "application/json"
                "Authorization"= "Bearer $hassToken"
            }

            $hassBody = @{
                "entity_id" = $entity_ID
            } | convertto-json

            Invoke-RestMethod -Uri "$hassURL/api/services/script/toggle" -Method POST -Headers $hassHeaders -Body $hassBody
        }
    }

    function play-Sound ([string]$soundfile) {
        $SoundPlayer=New-Object System.Media.SoundPlayer
        $SoundPlayer.SoundLocation=(Get-Location).Path + $soundfile
        $SoundPlayer.playsync()
    }

    $script:cancelLoop = $False

    # Main check process
    :check Do {
        # check for clicks in the form since we are looping
        for ($i=0; $i -lt $delay; $i++) {

            [System.Windows.Forms.Application]::DoEvents()

            if ($script:cancelLoop) {
                $button_start.Enabled = $True
                $button_start.Visible = $True
                $button_stop.Enabled = $False
                $button_stop.Visible = $False
                $form.MinimizeBox = $True
                $label_status.text = ""
                $label_status.Refresh()
                $script:label_coords_text.Visible = $True
                $label_help.Visible = $True
                $label_version.Visible = $True
                Break check
            }

            Start-Sleep -Seconds 1

        }

        Get-WoWQueue
        $WoWAlert = (Get-Ocr $path\WoWNotifier_Img.png).Text

        if (-not ($WoWAlert)) { 
            # set messages           
            $msg = "No Game detected! Check if WoW is running!"
            
            if ($playSound -eq "Yes") {
                play-Sound "\sound_failed.wav"
            }
            Send-Alert

            if ($script:cancelLoop) {
                Return
            }

            $label_status.ForeColor = "#7CFC00"
            $label_status.text = "No Game detected! `r`n Check if WoW is running!"
            $label_status.Refresh()

            if ($stopOnQueue -eq "Yes") {
                $button_stop.Enabled = $True
                $button_stop.Visible = $True
                $button_start.Enabled = $False
                $button_start.Visible = $False
            }
            # Restart Check routine
            WoWNotifier
        }
       
        # Check if queue screen is shown (Word "Position" in OCR detected)
        if ($WoWAlert -like "*Position*") {

            # Check for position in queue and ETA
            if ($WoWAlert -match '(?<=Position.+)\d+') {
                $yourPos = $matches[0]
            }
            else {
                $yourPos = "Unknown"
            }
            if ($WoWAlert -match '(?<=Dauer.+)\d+') {
                $yourEta = $matches[0]
                $language = "ger"
            } elseif ($WoWAlert -match '(?<=Estimated time.+)\d+') {
                $yourEta = $matches[0]
                $language = "eng"
            }
            else {
                $yourEta = "Unknown"
            }

            # Auto-detect language of game version and adjust messages
            switch ( $language ) {
                ger {
                    $msg = "Position in der Wartschlange: $yourPos - ETA: $yourEta min"
                    $label_status.text = "Position in der Wartschlange: $yourPos `n`r ETA: $yourEta min"
                    $label_status.Refresh()
                }
                eng {
                    $msg = "Position in Queue: $yourPos - ETA: $yourEta min"
                    $label_status.text = "Position in Queue: $yourPos `n`r ETA: $yourEta min"
                    $label_status.Refresh()
                }
            }

            if ($queueCheck -eq "Yes") {
                # Generate unix time_now 
                $time_now = Get-Date -UFormat %s -Millisecond 0

                # If time_now < last_send_time + choosen delay -> Send-alert
                if ([int]$last_send_time + [int]$queueCheckInterval*60 -lt [int]$time_now) {

                    if ([int]$last_send_time -eq 0) {
                        $msg = "Started WoWNotifier `n`r" + $msg
                    }

                    $last_send_time = Get-Date -UFormat %s -Millisecond 0
                    Send-Alert
                }            
            }
        }

        # Check if character screen is shown (Word "Enter" or "betreten" in OCR detected)
        elseif ($WoWAlert -like "*Enter*" -or $WoWAlert -like "*betreten*") {
            # set messages           
            $msg = "Queue has ended. Have fun!"
            
            if ($playSound -eq "Yes") {
                play-Sound "\sound_success.wav"
            }
            Send-Alert

            if ($script:cancelLoop) {
                Return
            }
            
            $label_status.ForeColor = "#7CFC00"
            $label_status.text = "Queue has ended. Have fun!"
            $label_status.Refresh()

            if ($stopOnQueue -eq "Yes") {
                $button_stop.Enabled = $False
                $button_stop.Visible = $False
                $button_start.Enabled = $True
                $button_start.Visible = $True
            }
            elseif ($stopOnQueue -eq "No") {
                WoWNotifier
            }
        }

        elseif ($WoWAlert -like "*disconnected*" -or $WoWAlert -like "*reconnect*" -or $WoWAlert -like "*unterbrochen*" -or $WoWAlert -like "*wiederverbinden*") {
            # set messages           
            $msg = "You have been Disconnected!"
            
            if ($playSound -eq "Yes") {
                play-Sound "\sound_failed.wav"
            }
            Send-Alert

            if ($script:cancelLoop) {
                Return
            }

            $label_status.ForeColor = "#7CFC00"
            $label_status.text = "You have been Disconnected! `n`r Reconnect!"
            $label_status.Refresh()

            if ($stopOnQueue -eq "Yes") {
                $button_stop.Enabled = $True
                $button_stop.Visible = $True
                $button_start.Enabled = $False
                $button_start.Visible = $False
            }
            # Restart Check routine
            WoWNotifier
        }

        else {
            # set messages           
            $msg = "Unknown status! - Check Game window!"
            
            if ($playSound -eq "Yes") {
                play-Sound "\sound_failed.wav"
            }
            Send-Alert

            if ($script:cancelLoop) {
                Return
            }

            $label_status.ForeColor = "#7CFC00"
            $label_status.text = "Unknown status! `n`r Check Game window!"
            $label_status.Refresh()

            if ($stopOnQueue -eq "Yes") {
                $button_stop.Enabled = $True
                $button_stop.Visible = $True
                $button_start.Enabled = $False
                $button_start.Visible = $False
            }
            # Restart Check routine
            WoWNotifier
        }
    }

    Until ($WoWAlert -notlike "*Position*")
}

# Form section
$form                           = New-Object System.Windows.Forms.Form
$form.Text                      ='WoW Notifier'
$form.Width                     = 300
$form.Height                    = 150
$form.AutoSize                  = $True
$form.MaximizeBox               = $False
$form.BackColor                 = "#4a4a4a"
$form.TopMost                   = $False
$form.StartPosition             = 'CenterScreen'
$form.FormBorderStyle           = "FixedDialog"

# Start Button
$button_start                   = New-Object system.Windows.Forms.Button
$button_start.BackColor         = "#f5a623"
$button_start.text              = "START"
$button_start.width             = 120
$button_start.height            = 50
$button_start.location          = New-Object System.Drawing.Point(80,15)
$button_start.Font              = 'Microsoft Sans Serif,9,style=Bold'
$button_start.FlatStyle         = "Flat"

# Stop Button
$button_stop                    = New-Object system.Windows.Forms.Button
$button_stop.BackColor          = "#f5a623"
$button_stop.ForeColor          = "#FF0000"
$button_stop.text               = "STOP"
$button_stop.width              = 120
$button_stop.height             = 50
$button_stop.location           = New-Object System.Drawing.Point(80,15)
$button_stop.Font               = 'Microsoft Sans Serif,9,style=Bold'
$button_stop.FlatStyle          = "Flat"
$button_stop.Enabled            = $False
$button_stop.Visible            = $False

# Status label
$label_status                   = New-Object system.Windows.Forms.Label
$label_status.text              = ""
$label_status.AutoSize          = $True
$label_status.width             = 30
$label_status.height            = 20
$label_status.location          = New-Object System.Drawing.Point(20,80)
$label_status.Font              = 'Microsoft Sans Serif,10,style=Bold'
$label_status.ForeColor         = "#7CFC00"

# Version label
$label_version                  = New-Object system.Windows.Forms.Label
$label_version.text              = "v1.1 - JumpY2k3"
$label_version.AutoSize          = $True
$label_version.width             = 30
$label_version.height            = 20
$label_version.location          = New-Object System.Drawing.Point(10,100)
$label_version.Font              = 'Microsoft Sans Serif,9'
$label_version.ForeColor         = "#f5a623"

# Help link
$label_help                     = New-Object system.Windows.Forms.LinkLabel
$label_help.text                = "Help"
$label_help.AutoSize            = $true
$label_help.width               = 70
$label_help.height              = 20
$label_help.location            = New-Object System.Drawing.Point(240,100)
$label_help.Font                = 'Microsoft Sans Serif,9'
$label_help.ForeColor           = "#00ff00"
$label_help.LinkColor           = "#f5a623"
$label_help.ActiveLinkColor     = "#f5a623"
$label_help.add_Click({[system.Diagnostics.Process]::start("http://github.com/JumpY2k3/WoWNotifier")})

# add all controls
$form.Controls.AddRange(($button_start,$button_stop,$label_status,$label_version,$label_help))

# Button methods
$button_start.Add_Click(
    {
        $button_start.Enabled = $False
        $button_start.Visible = $False
        $button_stop.Enabled = $True
        $button_stop.Visible = $True
        $form.MinimizeBox = $False # disable while running since it breaks things
        $label_help.Visible = $False
        $label_version.Visible = $False
        $label_status.ForeColor = "#FFFF00"
        $label_status.text = "Checking for Queue ..."
        $label_status.Refresh()
        WoWNotifier
    }
    )


$button_stop.Add_Click({
    if (Test-Path $path\WoWNotifier_Img.png) {
        Remove-Item $path\WoWNotifier_Img.png -Force -Confirm:$False
    }
    $script:cancelLoop = $True
})

# catch close handle
$form.add_FormClosing({
    if (Test-Path $path\WoWNotifier_Img.png) {
        Remove-Item $path\WoWNotifier_Img.png -Force -Confirm:$False
    }
    $script:cancelLoop = $True
})

# show the forms
$form.ShowDialog()

# close the forms
$form.Dispose()
