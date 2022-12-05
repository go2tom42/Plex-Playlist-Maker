<# Can Change #>
Param(
    [parameter(Mandatory = $false)]
    [alias("File")]
    [String]
    $CSVFILEtemp = ".\playlist.csv",
    [parameter(Mandatory = $false)]
    [alias("Title")]
    [String]
    $PlaylistName = "Marvel / MCU",
    [parameter(Mandatory = $false)]
    [Switch]
    $quick,
    [parameter(Mandatory = $false)]
    [String]
    $Poster,
    [parameter(Mandatory = $false)]
    [String]
    $user
)

$Poster
pause

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

if ($user) {
    $DefaultPlexServer.UserToken = ($DefaultPlexServer.users | Where-Object { $_.Title -eq $user }).Token
}

if ($Poster) {
    Write-Host "true"
    $Posters = Get-Content -Path $Poster -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
} 

If (-not($Poster)) {
    $Posters = '[
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist00.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist01.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist02.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist03.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist04.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist05.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist06.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist07.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist08.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist09.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist10.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist11.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist12.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist13.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist14.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist15.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist16.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist17.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist18.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist19.png",
        "https://github.com/go2tom42/Plex-Playlist-Maker/raw/master/playlist20.png"
      ]' | ConvertFrom-Json
}

<# NEVER CHANGE#>
$global:LiveAction = "False"

function Show-PlexArt {
    $ps5esc = [char]0x1b
    $ps7esc = "`e"
    if ($PSVersionTable.PSVersion.Major -lt 6) { $esc = $ps5esc }
    if ($PSVersionTable.PSVersion.Major -gt 5) { $esc = $ps7esc }
    $graphic = @(
        ("                    $($esc)" + '[48;5;15m                          ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m                                               ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;15m                          ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m                                               ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;15m                          ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m                                               ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[38;5;0;48;5;15m▄▄▄▄▄▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;0;48;5;15m▄▄▄' + "$($esc)" + '[38;5;0;48;5;243m▄' + "$($esc)" + '[38;5;0;48;5;234m▄▄' + "$($esc)" + '[38;5;0;48;5;7m▄' + "$($esc)" + '[38;5;0;48;5;15m▄▄▄' + "$($esc)" + '[48;5;15m        ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m         ' + "$($esc)" + '[38;5;240;48;5;15m▄' + "$($esc)" + '[38;5;0;48;5;15m▄▄▄' + "$($esc)" + '[38;5;0;48;5;235m▄' + "$($esc)" + '[38;5;0;48;5;233m▄' + "$($esc)" + '[38;5;0;48;5;241m▄' + "$($esc)" + '[38;5;0;48;5;15m▄▄▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[38;5;178;48;5;15m▄▄▄▄▄▄▄' + "$($esc)" + '[38;5;15;48;5;15m▄' + "$($esc)" + '[48;5;15m       ' + "$($esc)" + '[38;5;0;48;5;15m▄▄▄▄▄▄▄▄' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;0m            ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[38;5;255;48;5;15m▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m      ' + "$($esc)" + '[38;5;252;48;5;15m▄' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;0m             ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;15;48;5;222m▄' + "$($esc)" + '[48;5;178m       ' + "$($esc)" + '[38;5;178;48;5;15m▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[38;5;0;48;5;236m▄' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m                     ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;0m       ' + "$($esc)" + '[38;5;233;48;5;0m▄' + "$($esc)" + '[38;5;237;48;5;0m▄' + "$($esc)" + '[48;5;0m        ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;230;48;5;178m▄' + "$($esc)" + '[48;5;178m      ' + "$($esc)" + '[38;5;178;48;5;230m▄' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m       ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m        ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[38;5;15;48;5;253m▄' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[38;5;15;48;5;234m▄' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;0;48;5;253m▄' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m      ' + "$($esc)" + '[38;5;15;48;5;248m▄' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;15;48;5;178m▄' + "$($esc)" + '[48;5;178m       ' + "$($esc)" + '[38;5;222;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m          ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[38;5;0;48;5;233m▄' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[38;5;15;48;5;253m▄' + "$($esc)" + '[48;5;15m         ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[38;5;15;48;5;15m▄' + "$($esc)" + '[48;5;178m       ' + "$($esc)" + '[38;5;178;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m            ' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[38;5;0;48;5;238m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m                       ' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[38;5;15;48;5;178m▄' + "$($esc)" + '[48;5;178m      ' + "$($esc)" + '[38;5;178;48;5;214m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;15;48;5;233m▄' + "$($esc)" + '[48;5;15m      ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m            ' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[38;5;236;48;5;0m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m                      ' + "$($esc)" + '[38;5;232;48;5;0m▄' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[38;5;178;48;5;222m▄' + "$($esc)" + '[48;5;178m      ' + "$($esc)" + '[38;5;15;48;5;178m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m      ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m         ' + "$($esc)" + '[38;5;15;48;5;15m▄' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;0;48;5;253m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;248;48;5;0m▄' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[38;5;15;48;5;15m▄' + "$($esc)" + '[48;5;15m                  ' + "$($esc)" + '[38;5;214;48;5;15m▄' + "$($esc)" + '[48;5;178m       ' + "$($esc)" + '[38;5;15;48;5;178m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;0;48;5;145m▄' + "$($esc)" + '[48;5;0m ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m        ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[38;5;233;48;5;15m▄' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[38;5;0;48;5;15m▄▄' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m       ' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m      ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;178;48;5;15m▄' + "$($esc)" + '[48;5;178m       ' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;8;48;5;15m▄' + "$($esc)" + '[48;5;0m     ' + "$($esc)" + '[38;5;248;48;5;15m▄' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m                     ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[48;5;0m        ' + "$($esc)" + '[38;5;7;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m                 ' + "$($esc)" + '[38;5;15;48;5;236m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;178;48;5;178m▄' + "$($esc)" + '[48;5;178m      ' + "$($esc)" + '[38;5;15;48;5;178m▄' + "$($esc)" + '[48;5;15m   ' + "$($esc)" + '[48;5;0m       ' + "$($esc)" + '[38;5;0;48;5;15m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;241;48;5;0m▄' + "$($esc)" + '[48;5;0m            ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m       ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m    ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m            ' + "$($esc)" + '[38;5;247;48;5;0m▄' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;178;48;5;15m▄' + "$($esc)" + '[48;5;178m       ' + "$($esc)" + '[38;5;15;48;5;214m▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;0m       ' + "$($esc)" + '[48;5;15m ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;241m ' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[38;5;15;48;5;0m▄▄▄▄▄▄▄▄' + "$($esc)" + '[48;5;15m            ' + "$($esc)" + '[38;5;15;48;5;0m▄▄▄▄' + "$($esc)" + '[38;5;15;48;5;188m▄' + "$($esc)" + '[48;5;15m        ' + "$($esc)" + '[38;5;15;48;5;0m▄▄▄▄▄▄▄▄' + "$($esc)" + '[38;5;15;48;5;238m▄' + "$($esc)" + '[48;5;15m     ' + "$($esc)" + '[38;5;15;48;5;178m▄▄▄▄▄▄▄' + "$($esc)" + '[48;5;15m         ' + "$($esc)" + '[38;5;15;48;5;0m▄▄▄▄▄' + "$($esc)" + '[48;5;15m  ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[38;5;246;48;5;241m▄' + "$($esc)" + '[48;5;15m                                                                        ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m      ' + "$($esc)" + '[48;5;15m                                                                         ' + "$($esc)" + '[m');
        ("                    $($esc)" + '[48;5;0m    ' + "$($esc)" + '[38;5;15;48;5;0m▄' + "$($esc)" + '[48;5;15m                                                                          ' + "$($esc)" + '[m')
    )
    Clear-Host
    $graphic
}

function playALL {
    $Results = Questiontime
    $ItemsToAdd = $Results.PlexID -join ','
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))
    if ($DefaultPlexServer.UserToken -eq "") {
        Write-Host -ForegroundColor DarkCyan "`nScript now creating said playlist."
        # create playlist, and fill it
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"
        # Get New Playlist ID
        $PlaylistID = $Data.MediaContainer.Playlist.ratingKey
        #Set Poster
        Write-Host -ForegroundColor DarkCyan "`nScript now installing playlist poster."
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[0])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"    
    }

    if (-not($DefaultPlexServer.UserToken -eq "")) {
        Write-Host -ForegroundColor DarkCyan "`nScript now creating said playlist."
        # create playlist, and fill it
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"        
        # Get New Playlist ID
        $PlaylistID = $Data.MediaContainer.Playlist.ratingKey
        #Set Poster
        Write-Host -ForegroundColor DarkCyan "`nScript now installing playlist poster."
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[0])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"
    }

}

function play50 {
    $Results = Questiontime
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))


    $numplaylists = [math]::ceiling($Results.count / 50)
    if ($DefaultPlexServer.UserToken -eq "") {
        for ($i = 1; $i -le $numplaylists; $i++) {
            Write-Host -ForegroundColor DarkCyan "`nScript now creating playlist $($i) and installing poster."; 
            $ItemsToAdd = ($Results.PlexID | Select-Object -First 50 -skip (($i - 1) * 50)) -join ","; 
            #set & create playlist
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"; 
            #Get Playlist ID
            $PlaylistID = $Data.MediaContainer.Playlist.ratingKey; 
            #set playlist thumbnail
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[$i])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" 
        }
    }
    
    if (-not($DefaultPlexServer.UserToken -eq "")) {
        for ($i = 1; $i -le $numplaylists; $i++) {
            Write-Host -ForegroundColor DarkCyan "`nScript now creating playlist $($i) and installing poster."; 
            $ItemsToAdd = ($Results.PlexID | Select-Object -First 50 -skip (($i - 1) * 50)) -join ","; 
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"; 
            $PlaylistID = $Data.MediaContainer.Playlist.ratingKey; 
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[$i])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" 
        }
    }
}   

function play100 {
    $Results = Questiontime
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))

    $numplaylists = [math]::ceiling($Results.count / 100)
    if ($DefaultPlexServer.UserToken -eq "") {
        for ($i = 1; $i -le $numplaylists; $i++) {
            Write-Host -ForegroundColor DarkCyan "`nScript now creating playlist $($i) and installing poster."; 
            $i
            $ItemsToAdd = ($Results.PlexID | Select-Object -First 100 -skip (($i - 1) * 100)) -join ","; 
            #set & create playlist
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"; 
            #Get Playlist ID
            $PlaylistID = $Data.MediaContainer.Playlist.ratingKey; 
            #set playlist thumbnail
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[$i])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" 
        }
    }
    
    if (-not($DefaultPlexServer.UserToken -eq "")) {
        for ($i = 1; $i -le $numplaylists; $i++) {
            Write-Host -ForegroundColor DarkCyan "`nScript now creating playlist $($i) and installing poster."; 
            $ItemsToAdd = ($Results.PlexID | Select-Object -First 100 -skip (($i - 1) * 100)) -join ","; 
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"; 
            $PlaylistID = $Data.MediaContainer.Playlist.ratingKey; 
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[$i])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" 
        }
    } 
}

function get-categoryList-Content {
    $CSVFILE = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8
    $TempcategoryList = $CSVFILE.category | Select-Object -Unique | Where-Object { -not($_ -eq "") }
    $categoryList = @()
    foreach ($item in $TempcategoryList) {
        $d = [ordered]@{Title = $item; Status = $false; Contentlist = "" }
        $Asset = New-Object -TypeName PSObject
        $Asset | Add-Member -NotePropertyMembers $d -TypeName Asset
        $categoryList += $Asset
    }
    
    foreach ($item in $categoryList) {
        $Tempcategorytype = ($CSVFILE | Where-Object { $_.type -eq "movie" } | where-object { $_.category -eq $item.Title })
        $templist = @()
        for ($i = 0; $i -lt $Tempcategorytype.count; $i++) {
            $templist += "$($Tempcategorytype[$i].PlexTitle) ($($Tempcategorytype[$i].YearMade))"
        }
        $templist = $templist -join ", "
        $Item.Contentlist = $templist
    }
    foreach ($item in $categoryList) {
        $Tempcategorytype = ($CSVFILE | Where-Object { $_.type -eq "episode" } | where-object { $_.category -eq $item.Title }).PlexTitle | Select-Object -Unique
        if (-not ($null -eq $Tempcategorytype)) {
            if ($Item.ContentList -eq "") {
                $item.Contentlist += ($Tempcategorytype -join ', ')        
            }
            else {
                $item.Contentlist += ", $($Tempcategorytype -join ', ')"
            }
        }
    }
    return $categoryList
}

function Questiontime {
    Write-Host -ForegroundColor DarkCyan "`nScript now formating plexIDs for a playlist."
    if ($LiveAction -eq "False") {
        $Results = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) }
    }
    if ($LiveAction -eq "True") {
        $Results = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) } | Where-Object { ($_.LiveAction -eq "True") }
    }
    
    $categoryList = get-categoryList-Content

    if ($categoryList.count -gt 1) {
        $YesOrNo = ''
        for ($i = 0; $i -lt $categoryList.Count; $i++) {
            Clear-Host
            write-host "Confirm $($i+1)/$($categoryList.count)"
            write-host -NoNewline "Do you want to to include "; write-host -NoNewline -ForegroundColor red $($categoryList[$i].Title); write-host "?"
            write-host -NoNewline "Items include: "; write-host -ForegroundColor cyan "$($categoryList[$i].Contentlist)"
            while ("y", "n", 'yes', 'no' -notcontains $YesOrNo ) {
                $YesOrNo = Read-Host "Please enter your response (y/n)"
            }
            switch ($YesOrNo) {
                ("y" ) { $categoryList[$i].Status = $true }
                ( "yes") { $categoryList[$i].Status = $true }
                ("n" ) {  }
                ("no") {  }
            }
            $YesOrNo = ''
        }
    }
    if ($categoryList.count -eq 1) { $categoryList[0].Status = $true }

    if ($LiveAction -eq "False") {
        $TempResults = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) }
    }
    if ($LiveAction -eq "True") {
        $TempResults = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) } | Where-Object { ($_.LiveAction -eq "True") }
    }
    for ($i = 0; $i -lt $categoryList.Count; $i++) {
        if ($categoryList[$i].Status -eq $true ) {
            $newTempResults += $TempResults | Where-Object { ($_.category -eq $categoryList[$i].Title) }
        }
    }
    $Results = $newTempResults  | Sort-Object -Property Order
    
    return $Results
}

function Get-PlexIDs {
    Write-Host -ForegroundColor DarkCyan "`nScript executing, looking for PlexIDs."
    $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections?X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET"
    $showlibs = $Data.MediaContainer.Directory | Where-Object { $_.type -eq "show" }
    $movielibs = $Data.MediaContainer.Directory | Where-Object { $_.type -eq "movie" }
    Remove-Variable tvdata -ErrorAction SilentlyContinue
    foreach ($tvItem in $showlibs) {
        Write-Host -ForegroundColor DarkCyan "`nScript now loading episode titles from $($tvItem.title)"
        $tvdata += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($tvItem.key)/all?type=4&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET").MediaContainer.Video)
    }
    foreach ($movieItem in $movielibs) {
        Write-Host -ForegroundColor DarkCyan "`nScript now loading movie titles from $($movieItem.title)"
        $moviedata += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($movieItem.key)/all?X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET").MediaContainer.Video)
    }
    $CSVFILE = Import-Csv -Path $CSVFILEtemp -Encoding utf8

    $ShowTitles = ($CSVFILE | Where-Object { $_.Type -eq "episode" }).PlexTitle | Select-Object -Unique | Where-Object { -not($_ -eq "") }
    foreach ($item in $ShowTitles) {
        Write-Host -ForegroundColor DarkCyan "`nScript now loading $item titles"
        $newtvdata += $tvdata | Where-Object { $_.grandparentTitle -eq $item }
    }
    $tvdata = $newtvdata

    $totalCSV = $CSVFILE.count
    for ($i = 0; $i -lt $totalCSV; $i++) {

        if ($CSVFILE[$i].type -eq "episode" ) {
            if ((($tvdata | Where-Object { ($_.grandparentTitle -eq $CSVFILE[$i].PlexTitle) -and ($_.title -eq $CSVFILE[$i].EpisodeName) }).count) -gt 1) {
                $CSVFILE[$i].PlexId = ($tvdata | Where-Object { ($_.grandparentTitle -eq $CSVFILE[$i].PlexTitle) -and ($_.title -eq $CSVFILE[$i].EpisodeName) })[0].ratingKey
            }
            if ((($tvdata | Where-Object { ($_.grandparentTitle -eq $CSVFILE[$i].PlexTitle) -and ($_.title -eq $CSVFILE[$i].EpisodeName) }).count) -lt 2) {
                $CSVFILE[$i].PlexId = ($tvdata | Where-Object { ($_.grandparentTitle -eq $CSVFILE[$i].PlexTitle) -and ($_.title -eq $CSVFILE[$i].EpisodeName) }).ratingKey
            }

        }
        if ($CSVFILE[$i].type -eq "movie" ) {
            if ((($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) }).count) -gt 1) {
                $CSVFILE[$i].PlexId = ($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) })[0].ratingKey
            }
            if ((($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) }).count) -lt 2) {
                $CSVFILE[$i].PlexId = ($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) }).ratingKey
            }
        }
    }

    $CSVFILE | Export-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 -NoTypeInformation

}

function mainMenu {
    if ($quick) {
        Get-Quick
    }
    $mainMenu = 'X'
    while ($mainMenu -ne '') {
        Show-PlexArt
        Write-Host "`n`t`t`t`t`t`t   Plex Playlist Maker"
        Write-Host -ForegroundColor Cyan "`n`t`t`t`t`t`t    Animated Content?"

        Write-Host -ForegroundColor DarkCyan -NoNewline "`n    ["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Include animated content"

        Write-Host -ForegroundColor DarkCyan -NoNewline "`n    ["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan ' Include live action only'
        $mainMenu = Read-Host "`nSelection (leave blank to quit)"
        # Launch submenu1
        if ($mainMenu -eq 1) {
            $global:LiveAction = "False"
        }
        # Launch submenu2
        if ($mainMenu -eq 2) {
            $global:LiveAction = "True"
        }
        Clear-Host
        Write-Host "`n`t`t`t`t`t`t Plex Playlists"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n`t`t["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; 
        Write-Host -ForegroundColor DarkCyan " All in one playlist"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n`t`t["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; 
        Write-Host -ForegroundColor DarkCyan " Multiple Playlists, 50 items each"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n`t`t["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; 
        Write-Host -ForegroundColor DarkCyan " Multiple Playlists, 100 items each"
        $answer = Read-Host "`nSelection?"
        while ("1", "2", '3' -notcontains $answer ) {
            $answer = Read-Host "Selection?"
        }
        switch ($answer) {
            ("1") {
                Get-PlexIDs
                playALL
                Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
                Write-Host "`nPress any key to return to exit"
                [void][System.Console]::ReadKey($true)
                exit 
            }
            ("2") {            
                Get-PlexIDs
                play50
                Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
                Write-Host "`nPress any key to return to exit"
                [void][System.Console]::ReadKey($true)
                exit
            }
            ("3") {            
                Get-PlexIDs
                play100
                Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
                Write-Host "`nPress any key to return to exit"
                [void][System.Console]::ReadKey($true)
                exit 
            }
            
        }
    }
}

function Get-Quick {
    Get-PlexIDs
    $categoryList = get-categoryList-Content
    foreach ($item in $categoryList) {
        $item.Status = "True"
    }

    if ($LiveAction -eq "False") {
        $TempResults = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) }
    }
    for ($i = 0; $i -lt $categoryList.Count; $i++) {
        if ($categoryList[$i].Status -eq $true ) {
            $newTempResults += $TempResults | Where-Object { ($_.category -eq $categoryList[$i].Title) }
        }
    }
    $Results = $newTempResults  | Sort-Object -Property Order

    $ItemsToAdd = $Results.PlexID -join ','
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))
    if ($DefaultPlexServer.UserToken -eq "") {
        Write-Host -ForegroundColor DarkCyan "`nScript now creating said playlist."
        # create playlist, and fill it
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"
        # Get New Playlist ID
        $PlaylistID = $Data.MediaContainer.Playlist.ratingKey
        #Set Poster
        Write-Host -ForegroundColor DarkCyan "`nScript now installing playlist poster."
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($00Poster))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"    
    }

    if (-not($DefaultPlexServer.UserToken -eq "")) {
        Write-Host -ForegroundColor DarkCyan "`nScript now creating said playlist."
        # create playlist, and fill it
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($DefaultPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"        
        # Get New Playlist ID
        $PlaylistID = $Data.MediaContainer.Playlist.ratingKey
        #Set Poster
        Write-Host -ForegroundColor DarkCyan "`nScript now installing playlist poster."
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[0])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"
    }
    Write-Host -ForegroundColor DarkCyan "`nScript now finished."
    exit
}




mainMenu