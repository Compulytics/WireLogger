$URL = "https://www.wireclub.com/chat/room/philosophy"
$DataPattern = '<div class="message clearfix".*?</span>'
$NamePattern = '(?<=\>)\s*(.*) </a'
$MessagePattern = ";'>(.*?)</"
$TimeStampPattern = 'data-timestamp=(.*?)>'
While ($True){
	try {
		$HTTPRequest = Invoke-WebRequest -Uri $URL
		$RawData = $HTTPRequest.Content
	} catch {
		Write-Host "Failed to retrieve the chat."
		exit
	}
	$Matches = [regex]::Matches($RawData, $DataPattern)
	foreach ($Match in $Matches) {
		$TimeStamp = [regex]::Matches($Match.Value, $TimeStampPattern).Groups[1].Value -replace '"', ""
		$NameDirty = [regex]::Matches($Match.Value, $NamePattern).Value
		$Pointer = $NameDirty.LastIndexOf('>')
		$Name = $NameDirty.Substring($Pointer + 1) -replace ' </a',''
		$MessageDirty = [regex]::Matches($Match.Value, $MessagePattern).Groups[1].Value -replace ";'>", ""
		$MessageHTML = $MessageDirty -replace "</",""
		$Message = [System.Web.HttpUtility]::HtmlDecode($MessageHTML)
		if ($TimeStamp -gt $LastTimeStamp){
			Write-Host "$TimeStamp~$Name`: $Message"
			Add-Content -Path C:\Users\user\Desktop\Philosophy.csv "$Timestamp,$Name,$Message"
		}
	}
	$LastTimeStamp = $TimeStamp
	sleep 15
}
