
param(
    [Parameter(Mandatory = $false)]
    [String]
    $username,

    [Parameter(Mandatory = $false)]
    [String]
    $pass,

    [Parameter(Mandatory = $false)]
    [String]
    $address
)


if ($username) { $plextvusername = $username } else { $plextvusername = Read-Host -Prompt 'Enter Plex.tv Username' }
if ($pass) { $plextvpassword = $pass } else { $plextvpassword = Read-Host -Prompt 'Enter Plex.tv password' }
if ($address) { $Serverurl = $address } else { $Serverurl = Read-Host -Prompt 'Enter LOCAL Plex URL' }

$ServerIP = ([System.Uri]$Serverurl).Host
$ServerPORT = ([System.Uri]$Serverurl).Port
$ServerProtocol = ([System.Uri]$Serverurl).Scheme

$Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $plextvusername, $plextvpassword)))
$Data = Invoke-RestMethod -Uri "https://plex.tv/users/sign_in.json" -Method POST -Headers @{
    'Authorization'            = ("Basic {0}" -f $Base64AuthInfo);
    'X-Plex-Client-Identifier' = "PowerShell-Test";
    'X-Plex-Product'           = 'PowerShell-Test';
    'X-Plex-Version'           = "V0.01";
    'X-Plex-Username'          = $plextvusername;
} -ErrorAction Stop

$DefaultPlexServer = [PSCustomObject]@{
    Username           = $Data.user.username;
    Token              = $Data.user.authentication_token;
    UserToken          = "";
    Title              = $Data.user.username;
    PlexServer         = "";
    PlexServerHostname = $ServerIP;
    Protocol           = $ServerProtocol;
    Port               = $ServerPORT;
    Default            = "True";
    machineIdentifier  = '';
    Users              = @();
    AddedOn            = $(Get-Date -Format 's')
}
$GetServerName = Invoke-WebRequest -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/`?`X-Plex-Token=$($DefaultPlexServer.Token)" -ErrorAction Stop -UseBasicParsing -Headers (@{"Accept" = "application/json, text/plain, */*" })
$DefaultPlexServer.PlexServer = ($GetServerName.Content | ConvertFrom-Json).MediaContainer.friendlyName

$getmachineIdentifier = Invoke-RestMethod -Uri "https://plex.tv/api/servers`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -UseBasicParsing
$DefaultPlexServer.machineIdentifier = ($getmachineIdentifier.MediaContainer.Server | Where-Object { $_.name -eq $DefaultPlexServer.PlexServer }).machineIdentifier

$Data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$($DefaultPlexServer.machineIdentifier)/access_tokens.xml?auth_token=$($DefaultPlexServer.Token)&includeProviders=1" -ErrorAction Stop
$TempUserList = $Data.access_tokens.access_token | Where-Object { $_.allow_sync }

$UserList = @()
foreach ($item in $TempUserList) {
    $d = [ordered]@{Username = $item.username; Title = $item.title ; Token = $item.token }
    $Asset = New-Object -TypeName PSObject
    $Asset | Add-Member -NotePropertyMembers $d -TypeName Asset
    $UserList += $Asset
}
$DefaultPlexServer.Users = $UserList

if ($IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" )) {
    $ConfigFile = "$env:appdata\PlexPlaylist\PlexPlaylist.json"
}
elseif ($IsLinux -or $IsMacOS) {
    $ConfigFile = "$HOME/.PlexPlaylist/PlexPlaylist.json"
}

New-Item -ItemType Directory -Path (Split-Path $ConfigFile) -ErrorAction SilentlyContinue | Out-Null
ConvertTo-Json -InputObject $DefaultPlexServer | Out-File -FilePath $ConfigFile -Force -ErrorAction Stop