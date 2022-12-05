
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

function Get-AllPlaylists($token, $user) {
    
    $Data = Invoke-WebRequest -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists/$Id`?`X-Plex-Token=$($Token)" -ErrorAction Stop -UseBasicParsing -Headers (@{"Accept" = "application/json, text/plain, */*" })
    $UTF8String = [system.Text.Encoding]::UTF8.GetString($Data.RawContentStream.ToArray())
    [array]$Results = ($UTF8String | ConvertFrom-Json).MediaContainer.Metadata
    foreach ($Playlist in $Results) {
        [array]$Items = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists/$($Playlist.ratingKey)/items`?`X-Plex-Token=$($DefaultPlexServer.Token)" -ErrorAction Stop -UseBasicParsing -Headers (@{"Accept" = "application/json, text/plain, */*" })
        $Playlist | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer.Metadata
    }
    for ($a = 0; $a -lt $results.count; $a++) {
        $csvfilename = $($Results[$a].title).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        
        $test = for ($i = 0; $i -lt $Results[$a].items.count; $i++) {
            if ($Results[$a].items[$i].type -eq "episode") { $PlexTitle = $Results[$a].items[$i].grandparentTitle }
            if ($Results[$a].items[$i].type -eq "movie") { $PlexTitle = $Results[$a].items[$i].title }
            if ($Results[$a].items[$i].type -eq "episode") { $Episode = "s$($Results[$a].items[$i].parentIndex.ToString('00'))e$($Results[$a].items[$i].index.ToString('00'))" }
            if ($Results[$a].items[$i].type -eq "movie") { $Episode = "" }
            if ($Results[$a].items[$i].originallyAvailableAt) { $YearMade = ($($Results[$a].items[$i].originallyAvailableAt).split('-')[0]) }
            if ($Results[$a].items[$i].type -eq "episode") { $EpisodeName = $Results[$a].items[$i].title } 
            if ($Results[$a].items[$i].type -eq "movie") { $EpisodeName = "" } 
            [PsCustomObject]@{
                Order       = $(($i + 1).ToString('000'))
                Source      = "unknown"
                Type        = $Results[$a].items[$i].type
                Category    = 'playlist'
                LiveAction  = "True"
                YearMade    = $YearMade
                PlexTitle   = $PlexTitle
                Episode     = $Episode
                EpisodeName = $EpisodeName
                StoryTime   = $YearMade
                PlexId      = "NULL"
            }
        }
        $test | Export-Csv  -Path ".\$user-$csvfilename.csv" -Encoding UTF8 -NoTypeInformation
    }
        
}
Get-AllPlaylists ($DefaultPlexServer.Token) ($DefaultPlexServer.Username)

$users = $DefaultPlexServer.Users

foreach ($item in $users) {
    $Token = $item.Token
    $user = $item.title 
    Get-AllPlaylists $token $user
}
