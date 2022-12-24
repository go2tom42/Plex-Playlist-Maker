<# Can Change #>
Param(
    [parameter(Mandatory = $false)]
    [Switch]$progress = $false,
    [parameter(Mandatory = $false)]
    [Switch]$watched = $false,
    [parameter(Mandatory = $false)]
    [Switch]$unwatched = $false,
    [parameter(Mandatory = $false)]
    [Switch]$all = $false,
    [parameter(Mandatory = $false)]
    [Switch]$fix = $false,
    [parameter(Mandatory = $false)]
    [String]$Days,
    [parameter(Mandatory = $false)]
    [String]$ToUser,
    [parameter(Mandatory = $false)]
    [String]$FromUser
)

if (($progress -eq $false) -and ($progress -eq $false) -and ($watched -eq $false) -and ($unwatched -eq $false) -and ($all -eq $false) -and ($fix -eq $false)) {
    Write-Host "inside 1st if"
    $watched = $true
}

if ($all) {
    Write-Host "inside 2nd if"
    $watched = $true
    $progress = $true
    $unwatched = $true
}

if ($days) {
    $currenttime = [int](Get-Date -UFormat %s -Millisecond 0)
    $time = $currenttime - ([int]$Days * 86400)
}

if ($FromUser) { $FromUser = $FromUser } else { $FromUser = Read-Host -Prompt 'Source Username' }

if ($fix) {
    $ToUser = $FromUser
}

if ($ToUser) { $ToUser = $ToUser } else { $ToUser = Read-Host -Prompt 'Destination Username' }


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
        Write-Host -ForegroundColor DarkCyan "`nScript now grabbing $FromUser Watched status in the $($Library.Title) Plex Library."
        $FromUserData += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($Library.key)/allLeaves?X-Plex-Token=$($DefaultPlexServer.FromUserToken)" -Method "GET").MediaContainer.Video)
    }
    Catch {
        $RestError = $_
    }
    $RestError = $null
    Try {
        if (-not $fix) {
            Write-Host -ForegroundColor DarkCyan "`nScript now grabbing $ToUser Watched status in the $($Library.Title) Plex Library."
            $ToUserData += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($Library.key)/allLeaves?X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET").MediaContainer.Video)
        }
    }
    Catch {
        $RestError = $_
    }
}


if ($time) {
    $FromUserDataWatched = ($FromUserData | where-object { $_.viewCount } | where-object { [int]$_.lastViewedAt -gt $time }).ratingKey
    $FromUserDataUnwatched = ($FromUserData | where-object { -not($_.viewCount) }).ratingKey
    $FromUserDataProgress = ($FromUserData | where-object { $_.viewOffset } | where-object { [int]$_.lastViewedAt -gt $time })

    $ToUserDataWatched = ($ToUserData | where-object { $_.viewCount } | where-object { [int]$_.lastViewedAt -gt $time }).ratingKey
    $ToUserDataUnwatched = ($ToUserData | where-object { -not($_.viewCount) }).ratingKey
}
else {
    $FromUserDataWatched = ($FromUserData | where-object { $_.viewCount }).ratingKey
    $FromUserDataUnwatched = ($FromUserData | where-object { -not($_.viewCount) }).ratingKey
    $FromUserDataProgress = ($FromUserData | where-object { $_.viewOffset })

    $ToUserDataWatched = ($ToUserData | where-object { $_.viewCount }).ratingKey
    $ToUserDataUnwatched = ($ToUserData | where-object { -not($_.viewCount) }).ratingKey
}


if ($watched) {
    Write-Host -ForegroundColor DarkCyan "`nScript comparing $ToUser Watched list and $FromUser Watched list."
    $FromUserMinusToUserWatched = ($fromUserDataWatched | Where-Object { $ToUserDataWatched -NotContains $_ })
    Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser Watched list."
    foreach ($item in $FromUserMinusToUserWatched) {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/scrobble`?identifier=com.plexapp.plugins.library&key=$($item)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
    }
}

if ($unwatched) {
    Write-Host -ForegroundColor DarkCyan "`nScript comparing $ToUser Unwatched list and $FromUser Unwatched list."
    $FromUserMinusToUserUnwatched = ($fromUserDataUnwatched | Where-Object { $ToUserDataUnwatched -NotContains $_ })
    Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser Unwatched list."
    foreach ($item in $FromUserMinusToUserUnwatched) {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/unscrobble`?identifier=com.plexapp.plugins.library&key=$($item)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
    }
}

if ($progress) {
    foreach ($item in $FromUserDataProgress) {
        Write-Host -ForegroundColor DarkCyan "`nScript fixing progress issues with Android TV."
        if (([int]$item.viewOffset / [int]$item.duration) -ge .95) {
            Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/scrobble`?identifier=com.plexapp.plugins.library&key=$($item.ratingKey)&X-Plex-Token=$($DefaultPlexServer.FromUserToken)" -Method "GET" | Out-Null
            Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/scrobble`?identifier=com.plexapp.plugins.library&key=$($item.ratingKey)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
        }
        Write-Host -ForegroundColor DarkCyan "`nScript updating $ToUser's progress status to match $FromUser."
        if (([int]$item.viewOffset / [int]$item.duration) -lt .95) {
            Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/progress`?identifier=com.plexapp.plugins.library&key=$($item.ratingKey)&time=$($item.viewOffset)&X-Plex-Token=$($DefaultPlexServer.ToUserToken)" -Method "GET" | Out-Null
        }
    }
}

if ($fix) {
    foreach ($item in $FromUserDataProgress) {
        Write-Host -ForegroundColor DarkCyan "`nScript fixing progress issues with Android TV."
        if (([int]$item.viewOffset / [int]$item.duration) -ge .95) {
            Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/:/scrobble`?identifier=com.plexapp.plugins.library&key=$($item.ratingKey)&X-Plex-Token=$($DefaultPlexServer.FromUserToken)" -Method "GET" | Out-Null
        }
    }
}