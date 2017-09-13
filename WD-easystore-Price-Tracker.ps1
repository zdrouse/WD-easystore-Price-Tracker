# Script path.
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
# XML Configuration file.
[xml]$configFile = Get-Content "$scriptPath/config.xml"

# Get the email account and Google App Password from the config file.
$emailAccount = $configFile.Configurations.GmailAccountConfig.EmailAccount
# Google App Password - Must generate an App password to be used for sending email with Google's SMTP Server.  Please refer to: https://support.google.com/accounts/answer/185833?hl=en
$gAppPassword = ConvertTo-SecureString -String $configFile.Configurations.GmailAccountConfig.GoogleAppPassword -AsPlainText -Force
# Create the PSCredential object.
$credentials = New-Object System.Management.Automation.PSCredential $emailAccount, $gAppPassword

# SKU ID for the 8TB external WD Red hard drive.  In theory, this could be swapped with any SKU ID of any other product to track a price.
$skuId = 5792401

# Send-Mail constants from config file.
$from = $configFile.Configurations.SMTPConfig.MailFrom
$to = $configFile.Configurations.SMTPConfig.MailTo
$subject = $configFile.Configurations.SMTPConfig.Subject
$smtpServer = $configFile.Configurations.SMTPConfig.SMTPServer
$smtpPort = $configFile.Configurations.SMTPConfig.SMTPPort

# Initiate price history array list for price history tracking.
$priceHistory = @()

# Function to create headers, invoke rest method and return response.  Takes in a skuId. 
function Get-Current-Item-Response ($id) {
    # Create headers for the request.
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-CLIENT-ID", 'BROWSE')
    $headers.Add("DNT", '1')
    $headers.Add("Accept-Encoding", 'gzip, deflate, br')
    $headers.Add("Accept-Language", 'en-US,en;q=0.8')
    try {
        $bestBuyUrl = "https://www.bestbuy.com/pricing/v1/price/item?salesChannel=LargeView&clientId=BROWSE&context=price-view&catalog=bby&usePriceWithCart=true&skuId=$id"
        $response = Invoke-RestMethod -Method Get -Headers $headers -Uri $bestBuyUrl -UseBasicParsing
        return $response
    } catch {
        $errors = $_.Exception.Message
        Write-Host "`n$errors" -ForegroundColor Red
    }
}

function Get-Price () {
    $response = Get-Current-Item-Response $skuId
    $price = $response.currentPrice
    Write-Host "Current price is: " -NoNewline
    Write-Host "$" -NoNewline -ForegroundColor Green -BackgroundColor Black
    Write-Host $price -BackgroundColor Black
    return $price
}

# Function to compare current/new price with old price - Invokes an Email message to the user if the price has lowered.
function Compare-Prices ($newPrice, $oldPrice) {
    if ($newPrice -eq $oldPrice) {
        Write-Host "Current price has not changed since the previous check." -ForegroundColor Cyan
    } elseif ($newPrice -gt $oldPrice) {
        $difference = $newPrice - $oldPrice
        Write-Host "Current price has risen `$$difference since the previous check.  Don't Buy!" -ForegroundColor Red
    } elseif ($newPrice -lt $oldPrice) {
        $difference = $oldPrice - $newPrice
        $body = "Current price has dropped `$$difference since the previous check.  Consider Buying!"
        Write-Host $body -ForegroundColor Green
        Send-MailMessage -To $to -Subject $subject -Body $body -From $from -SmtpServer $smtpServer -Credential $credentials -Port $smtpPort -UseSsl
    }
}

# Can be modified to track desired Best Buy item price.
Write-Host "Tracking price for WD - easystore® 8TB External USB 3.0 Hard Drive - Black...`n`n`n`n`n`n`n`n" -ForegroundColor Magenta

# Initial counter
$counter = 0

# Use this to test the email message by swapping the current price from price history
# [Decimal]$testEmail = 180.00

# Infinite loop
while ($true) {
    Write-Host "Number of price checks so far: " -NoNewline
    $priceCheckCounter = $counter + 1
    Write-Host "$priceCheckCounter`n" -ForegroundColor Magenta
    $currentPrice = Get-Price
    # Add this current price to the price history.
    $priceHistory += $currentPrice
    Write-Host "Comparing price with previous price check..." -NoNewline
    if ($priceHistory.Count -eq 1) {
        Write-Host "First price check - No price to compare yet." -ForegroundColor Yellow
    } elseif ($priceHistory.Count -eq 0) {
        Write-Warning "`nThe first price check should be stored in the History... Something else appears to be wrong."
    } else {
        Compare-Prices $currentPrice $priceHistory[$counter-1]
    }
    # Time and Progress bar handlers.
    $seconds = 3600
    $minutes = $seconds / 60
    foreach ($count in (1..$seconds)) {
        Write-Progress -PercentComplete (($count/$seconds) * 100) -Activity "Checking price again in $minutes minutes" -SecondsRemaining ($seconds - $count)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Id 1 -Activity "Checking" -Status "Completed" -PercentComplete 100 -Completed
    $counter++
    Write-Host ""
}

Read-Host -Prompt "Press Enter key to exit..."