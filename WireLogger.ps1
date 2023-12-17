Import-Module Selenium
$WebDriver = Start-SeEdge
Enter-SeUrl https://wireclub.com/chat/room/philosophy -Driver $WebDriver
$MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$UTF8 = New-Object -TypeName System.Text.UTF8Encoding
$MessageHashes = @{}
$i = 0
while($True){
    $Element = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("/html/body/div[3]/div[2]/div[2]/div/table/tbody/tr/td[1]/div/div"))
    foreach($RawMessage in $Element){
        $TimeStamp = [string](Get-Date -UFormat %s -Millisecond 0)
        $UserAndMessage = $RawMessage.Text -split "`n"
        $MessageContent = "$($UserAndMessage[0]) $($UserAndMessage[1])"
        $MessageID = [System.BitConverter]::ToString($MD5.ComputeHash($UTF8.GetBytes($MessageContent)))
        if(-not $MessageHashes.ContainsKey($MessageID)){
            if($UserAndMessage[0] -ne ""){
                Write-Host "MessageID:" $MessageID
                Write-Host "TimeStamp: "$TimeStamp
                Write-Host "User: "$UserAndMessage[0]
                Write-Host "Message: "$UserAndMessage[1]
                Write-Host "-------------------------------------------------------------------------------"
                $CSVFormattedLine = '"{0}","{1}","{2}"' -f $TimeStamp, $UserAndMessage[0], $UserAndMessage[1]
                Add-Content -Path "C:\Users\$Env:UserName\Desktop\Philosophy.csv" -Value $CSVFormattedLine
                $MessageHashes.Add($MessageID, $TimeStamp)
            }
        }
    }
    Start-Sleep -Seconds 1
    $i += 1
    if($i -gt 1776){
        $i = 0
        $EarliestTime = [string](Get-Date -UFormat %s) - 888
        foreach($MessageHashTime in $MessageHashes.Keys){
            if($MessageHashTime -lt $EarliestTime){
                $MessageHashes.Remove($MessageHashTime)
            }
        }
		Enter-SeUrl https://wireclub.com/chat/room/philosophy -Driver $WebDriver
    }
}
