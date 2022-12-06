
param(
    [Parameter(Mandatory = $false)]
    [String]
    $PATH,

    [Parameter(Mandatory = $false)]
    [String]
    $NAME
)

if ($IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" )) { $ConfigFile = "$env:appdata\PlexPlaylist\PlexPlaylist.json" } elseif ($IsLinux -or $IsMacOS) { $ConfigFile = "$HOME/.PlexPlaylist/PlexPlaylist.json" }

if (Test-Path -Path $ConfigFile) {
    $DefaultPlexServer = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
}
else {
    Clear-Host
    Write-Host "Run Set-PlexPlaylist-Config.ps1"
    Pause
    Exit
}

if ($PATH) { $PATH = $PATH } else { $PATH = Read-Host -Prompt 'Enter Path to folder with images' }
if ($NAME) { $NAME = $NAME } else { $NAME = Read-Host -Prompt 'Enter Show Title as it is displayed in Plex' }

if (-not(Test-Path $PATH)) {
    Write-host "Path does not exist"
    exit
}


$path = "$((Get-ChildItem -Path $PATH).DirectoryName[0])\*"


$ImageList = Get-ChildItem -Path $PATH -Include ("*.jpg", "*.png") -ErrorAction SilentlyContinue -Force | Sort-Object
foreach ($file in $ImageList) {
    $episode = (([regex]::matches($file.name, '[sS]?(?<season>\d{1,2})[ xXeE]+(?<episode>\d{1,2})')).Value)
    $file | Add-Member  -NotePropertyName Season -NotePropertyValue ($episode.substring(1, 2))
    $file | Add-Member  -NotePropertyName Episode -NotePropertyValue ($episode.substring(4, 2))
}

Write-Host -ForegroundColor DarkCyan "`nScript executing, looking for PlexIDs."
$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections?X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET"
$showlibs = $Data.MediaContainer.Directory | Where-Object { $_.type -eq "show" }

Remove-Variable tvdata -ErrorAction SilentlyContinue
foreach ($tvItem in $showlibs) {
    Write-Host -ForegroundColor DarkCyan "`nScript now loading episode titles from $($tvItem.title)"
    $tvdata += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($tvItem.key)/all?type=4&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET").MediaContainer.Video)
}
$newtvdata += $tvdata | Where-Object { $_.grandparentTitle -eq $NAME }

foreach ($item in $ImageList) {
    $ratingkey = ($newtvdata | Where-Object { ($_.index -eq [decimal]$($item.episode)) -and ($_.parentIndex -eq [decimal]$($item.season)) }).ratingKey
    Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($ratingkey)/posters?includeExternalMedia=1&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" -InFile "$($item.FullName)"
}
