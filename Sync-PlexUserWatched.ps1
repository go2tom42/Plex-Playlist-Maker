<# Can Change #>
Param(
    [parameter(Mandatory = $false)]
    [ValidateSet('Watched', 'Unwatched', 'All')]
    [String]
    $Mode = "Watched",
    [parameter(Mandatory = $false)]
    [String]
    $Days,
    [parameter(Mandatory = $false)]
    [String]
    $ToUser,
    [parameter(Mandatory = $false)]
    [String]
    $FromUser
)


if ($days) {
    $currenttime = [int](Get-Date -UFormat %s -Millisecond 0)
    $time = $currenttime - ([int]$Days * 86400)
}

if ($ToUser) { $ToUser = $ToUser } else { $ToUser = Read-Host -Prompt 'Destination Username' }
if ($FromUser) { $FromUser = $FromUser } else { $FromUser = Read-Host -Prompt 'Source Username' }

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

if ($ToUser) {
    if ($ToUser -eq $DefaultPlexServer.Title ) {
        $DefaultPlexServer.ToUserToken = $DefaultPlexServer.Token
    }
    else {
        $DefaultPlexServer.ToUserToken = ($DefaultPlexServer.users | Where-Object { $_.Title -eq $ToUser }).Token
    }
}

if ($FromUser) {
    if ($FromUser -eq $DefaultPlexServer.Title ) {
        $DefaultPlexServer.FromUserToken = $DefaultPlexServer.Token
    }
    else {
        $DefaultPlexServer.FromUserToken = ($DefaultPlexServer.users | Where-Object { $_.Title -eq $FromUser }).Token
    }
}
Write-Host -ForegroundColor DarkCyan "`nScript now grabbing Plex Library list."
$LibraryList = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections?X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET"
$LibraryList = $LibraryList.MediaContainer.Directory

foreach ($Library in $LibraryList) {
    $RestError = $null
    Try {
        Write-Host -ForegroundColor DarkCyan "`nScript now grabbing $ToUser Watched status in the $($Library.Title) Plex Library."
        $FromUserData += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($Library.key)/allLeaves?X-Plex-Token=$($DefaultPlexServer.FromUserToken)" -Method "GET").MediaContainer.Video)
    }
    Catch {
        $RestError = $_
    }
    $RestError = $null
    Try {
        Write-Host -ForegroundColor DarkCyan "`nScript now grabbing $FromUser Watched status in the $($Library.Title) Plex Library."
        $ToUserData += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($Library.key)/allLeaves?X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET").MediaContainer.Video)
    }
    Catch {
        $RestError = $_
    }
}

if ($time) {
    $FromUserDataWatched = ($FromUserData | where-object { $_.viewCount } | where-object { [int]$_.lastViewedAt -gt $time }).ratingKey
    $FromUserDataUnwatched = ($FromUserData | where-object { -not($_.viewCount) }).ratingKey

    $ToUserDataWatched = ($ToUserData | where-object { $_.viewCount } | where-object { [int]$_.lastViewedAt -gt $time }).ratingKey
    $ToUserDataUnwatched = ($ToUserData | where-object { -not($_.viewCount) }).ratingKey
}
else {
    $FromUserDataWatched = ($FromUserData | where-object { $_.viewCount }).ratingKey
    $FromUserDataUnwatched = ($FromUserData | where-object { -not($_.viewCount) }).ratingKey

    $ToUserDataWatched = ($ToUserData | where-object { $_.viewCount }).ratingKey
    $ToUserDataUnwatched = ($ToUserData | where-object { -not($_.viewCount) }).ratingKey
}

if ($Mode -eq "Watched") {
    Write-Host -ForegroundColor DarkCyan "`nScript comparing $ToUser Watched list and $FromUser Watched list."
    $FromUserMinusToUserWatched = ($fromUserDataWatched | Where-Object { $ToUserDataWatched -NotContains $_ })
    Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser Watched list."
    foreach ($item in $FromUserMinusToUserWatched) {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/scrobble`?identifier=com.plexapp.plugins.library&key=$($item)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
    }
}
if ($Mode -eq "Unwatched") {
    Write-Host -ForegroundColor DarkCyan "`nScript comparing $ToUser Unwatched list and $FromUser Unwatched list."
    $FromUserMinusToUserUnwatched = ($fromUserDataUnwatched | Where-Object { $ToUserDataUnwatched -NotContains $_ })
    Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser Unwatched list."
    foreach ($item in $FromUserMinusToUserUnwatched) {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/unscrobble`?identifier=com.plexapp.plugins.library&key=$($item)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
    }
}
if ($Mode -eq "All") {
    Write-Host -ForegroundColor DarkCyan "`nScript comparing $ToUser Watched list and $FromUser Watched list."
    $FromUserMinusToUserWatched = ($fromUserDataWatched | Where-Object { $ToUserDataWatched -NotContains $_ })
    Write-Host -ForegroundColor DarkCyan "`nScript comparing $ToUser Unwatched list and $FromUser Unwatched list."
    $FromUserMinusToUserUnwatched = ($fromUserDataUnwatched | Where-Object { $ToUserDataUnwatched -NotContains $_ })
    Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser Unwatched list."
    foreach ($item in $FromUserMinusToUserUnwatched) {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/unscrobble`?identifier=com.plexapp.plugins.library&key=$($item)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
    }
    Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser Watched list."
    foreach ($item in $FromUserMinusToUserWatched) {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/scrobble`?identifier=com.plexapp.plugins.library&key=$($item)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
    }
}
Write-Host -ForegroundColor DarkCyan "`nScript is complete."