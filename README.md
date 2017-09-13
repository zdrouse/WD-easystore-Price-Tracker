# WD-easystore-Price-Tracker
Track the price of the WD - easystore® 8TB External USB 3.0 Hard Drive - Black.  These drives frequently go on sale at Best Buy and contain WD Red NAS drives inside.  You can shuck the hard drive out of external enclosure and put inside a NAS.

[Drive shucking](https://hardforum.com/attachments/shuck-techniques-pdf.24360/)

I wrote this project as I found a lack of tools available to track the price of Best Buy items.  camelcamelcamel appears to only support Amazon price tracking and these drives typically have the best sale at Best Buy.  If you don't like it, don't use it.

## Install
PowerShell 3.0+ must be installed.

Assuming `git` is installed on the local machine:

 - Open `command-prompt` and `cd` to a location/folder to save the project.
 - Perform `git clone https://github.com/rousez/WD-easystore-Price-Tracker`.

## Configure
In the `config.xml` file:
 - Provide this file your specific email account information.

 - If you have 2-factor authentication on your Gmail account (which you should), it is best to generate a Google App password which can be used for specific application permissions like sending email.  Please refer to information on how to [generate a Google App Password](https://support.google.com/accounts/answer/185833?hl=en). See below for generation type:

  ![Generate a Mail and Windows Computer App Password](https://i.imgur.com/JNW4abo.png)

 - Supply the configuration xml file the 16-digit passcode.

In the `WD-easystore-Price-Tracker.ps1` file:

 - Default time-checking interval is 1 hour (3600 seconds).  Adjust the `$seconds` variable for a custom time.
 
 - This script can be used to track the price of any Best Buy item by providing the SKU ID.  You can change the `$skuId` variable to another item if you desire.


## Run
Right-click the PowerShell file and run with PowerShell.  This may require allowing PowerShell scripts to run on your machine.
