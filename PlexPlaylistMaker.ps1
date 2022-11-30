<# MUST CHANGE #>
$DefaultPlexServer = [pscustomobject]@{
    Username           = "Username";
    Token              = "Token";
    UserToken          = ""; <#Only needed if you use a Managed Account#>
    PlexServer         = "Smeghead";
    PlexServerHostname = "192.168.11.188";
    Protocol           = "http";
    Port               = "32400";
    Default            = "True";
}

$PlaylistName = "Marvel / MCU"


<# Can Change #>
$Posters = @(
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU00.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU01.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU02.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU03.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU04.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU05.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU06.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU07.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU08.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU09.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU10.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU11.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU12.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU13.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU14.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU15.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU16.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU17.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU18.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU19.jpg";
    "https://github.com/go2tom42/Marvel-Plex-Playlist-Maker/raw/master/MCU20.jpg"
)

<# NEVER CHANGE#>
$global:LiveAction = "False"

function get-CanonList-Content {
    $CSVFILE = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8
    $TempCanonList = $CSVFILE.Canon | Select-Object -Unique | Where-Object { -not($_ -eq "") }
    $CanonList = @()
    foreach ($item in $TempCanonList) {
        $d = [ordered]@{Title = $item; Status = $false; Contentlist = "" }
        $Asset = New-Object -TypeName PSObject
        $Asset | Add-Member -NotePropertyMembers $d -TypeName Asset
        $CanonList += $Asset
    }
    
    foreach ($item in $CanonList) {
        $Tempcanontype = ($CSVFILE | Where-Object { $_.type -eq "Film" } | where-object { $_.canon -eq $item.Title })
        $templist = @()
        for ($i = 0; $i -lt $Tempcanontype.count; $i++) {
            $templist += "$($Tempcanontype[$i].PlexTitle) ($($Tempcanontype[$i].YearMade))"
        }
        $templist = $templist -join ", "
        $Item.Contentlist = $templist
    }
    foreach ($item in $CanonList) {
        $Tempcanontype = ($CSVFILE | Where-Object { $_.type -eq "Show" } | where-object { $_.canon -eq $item.Title }).PlexTitle | Select-Object -Unique
        if (-not ($null -eq $Tempcanontype)) {
            if ($Item.ContentList -eq "") {
                $item.Contentlist += ($Tempcanontype -join ', ')        
            }
            else {
                $item.Contentlist += ", $($Tempcanontype -join ', ')"
            }
        }
    }
    return $CanonList
}

function mainMenu {
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
            countMenu
        }
        # Launch submenu2
        if ($mainMenu -eq 2) {
            $global:LiveAction = "True"
            countMenu
        }
    }
}

function countMenu {
    $countMenu = 'X'
    while ($countMenu -ne '') {
        Show-PlexArt
        Write-Host "`n`t`t`t`t`t`t Plex Playlists"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n`t`t["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; 
        Write-Host -ForegroundColor DarkCyan " All in one playlist"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n`t`t["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; 
        Write-Host -ForegroundColor DarkCyan " Multiple Playlists, 50 items each"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n`t`t["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; 
        Write-Host -ForegroundColor DarkCyan " Multiple Playlists, 100 items each"
        $countMenu = Read-Host "`nSelection (leave blank to quit)"
        # Option 1
        if ($countMenu -eq 1) {
            Get-PlexIDs
            playALL
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
            exit
        }
        # Option 2
        if ($countMenu -eq 2) {
            Get-PlexIDs
            play50
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
            exit
        }
        # Option 2
        if ($countMenu -eq 3) {
            Get-PlexIDs
            play100
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
            exit
        }

    }
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
    $CSVFILE = Import-Csv -Path ".\playlist.csv" -Encoding utf8

    #$ShowTitles = $CSVFILE.PlexTitle | Select-Object -Unique | Where-Object { -not($_ -eq "") } |  Where-Object {$_Type -eq "Show" }
    $ShowTitles = ($CSVFILE | Where-Object { $_.Type -eq "Show" }).PlexTitle | Select-Object -Unique | Where-Object { -not($_ -eq "") }
    foreach ($item in $ShowTitles) {
        Write-Host -ForegroundColor DarkCyan "`nScript now loading $item titles"
        $newtvdata += $tvdata | Where-Object { $_.grandparentTitle -eq $item }
    }
    $tvdata = $newtvdata

    $totalCSV = $CSVFILE.count
    for ($i = 0; $i -lt $totalCSV; $i++) {

        if ($CSVFILE[$i].type -eq "Show" ) {
            $CSVFILE[$i].PlexId = ($tvdata | Where-Object { ($_.grandparentTitle -eq $CSVFILE[$i].PlexTitle) -and ($_.title -eq $CSVFILE[$i].EpisodeName) }).ratingKey
        }
        if ($CSVFILE[$i].type -eq "Film" ) {
            if ((($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) }).count) -gt 1) {
                $CSVFILE[$i].PlexId = ($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) })[0].ratingKey
            }
            else {
                $CSVFILE[$i].PlexId = ($moviedata | Where-Object { ($_.title -eq $CSVFILE[$i].PlexTitle) -and ($_.year -eq $CSVFILE[$i].YearMade) }).ratingKey
            }
        }
    }

    $CSVFILE | Export-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 -NoTypeInformation

}

function Questiontime {
    Write-Host -ForegroundColor DarkCyan "`nScript now formating plexIDs for a playlist."
    if ($LiveAction -eq "False") {
        $Results = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) }
    }
    if ($LiveAction -eq "True") {
        $Results = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) } | Where-Object { ($_.LiveAction -eq "True") }
    }
    
    $CanonList = get-CanonList-Content
    $YesOrNo = ''
    for ($i = 0; $i -lt $CanonList.Count; $i++) {
        Clear-Host
        write-host "Confirm $($i+1)/$($CanonList.count)"
        write-host -NoNewline "Do you want to to include "; write-host -NoNewline -ForegroundColor red $($CanonList[$i].Title); write-host "?"
        write-host -NoNewline "Items include: "; write-host -ForegroundColor cyan "$($CanonList[$i].Contentlist)"
        while ("y", "n", 'yes', 'no' -notcontains $YesOrNo ) {
            $YesOrNo = Read-Host "Please enter your response (y/n)"
        }
        switch ($YesOrNo) {
            ("y" ) { $CanonList[$i].Status = $true }
            ( "yes") { $CanonList[$i].Status = $true }
            ("n" ) {  }
            ("no") {  }
        }
        $YesOrNo = ''
    }
    if ($LiveAction -eq "False") {
        $TempResults = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) }
    }
    if ($LiveAction -eq "True") {
        $TempResults = Import-Csv -Path ".\PlexIDs.csv"  -Encoding utf8 | Where-Object { (-not($_.PlexID -eq "NULL")) -and (-not($_.PlexID -eq "")) } | Where-Object { ($_.LiveAction -eq "True") }
    }
    for ($i = 0; $i -lt $CanonList.Count; $i++) {
        if ($CanonList[$i].Status -eq $true ) {
            $newTempResults += $TempResults | Where-Object { ($_.Canon -eq $CanonList[$i].Title) }
        }
    }
    $Results = $newTempResults  | Sort-Object -Property Order
    
    return $Results
}

function playALL {
    [array]$CurrentPlexServer = ((Invoke-RestMethod -Uri "https://plex.tv/api/servers`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -UseBasicParsing).MediaContainer.Server) | Where-Object { $_.name -eq $DefaultPlexServer.PlexServer }
    $Results = Questiontime
    $ItemsToAdd = $Results.PlexID -join ','
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))
    if ($DefaultPlexServer.UserToken -eq "") {
        Write-Host -ForegroundColor DarkCyan "`nScript now creating said playlist."
        # create playlist, and fill it
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"
        # Get New Playlist ID
        $PlaylistID = $Data.MediaContainer.Playlist.ratingKey
        #Set Poster
        Write-Host -ForegroundColor DarkCyan "`nScript now installing playlist poster."
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($00Poster))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"    
    }

    if (-not($DefaultPlexServer.UserToken -eq "")) {
        Write-Host -ForegroundColor DarkCyan "`nScript now creating said playlist."
        # create playlist, and fill it
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"        
        # Get New Playlist ID
        $PlaylistID = $Data.MediaContainer.Playlist.ratingKey
        #Set Poster
        Write-Host -ForegroundColor DarkCyan "`nScript now installing playlist poster."
        $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[0])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"
    }

}

function play50 {
    [array]$CurrentPlexServer = ((Invoke-RestMethod -Uri "https://plex.tv/api/servers`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -UseBasicParsing).MediaContainer.Server) | Where-Object { $_.name -eq $DefaultPlexServer.PlexServer }
    $Results = Questiontime
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))


    $numplaylists = [math]::ceiling($Results.count / 50)
    if ($DefaultPlexServer.UserToken -eq "") {
        for ($i = 1; $i -le $numplaylists; $i++) {
            Write-Host -ForegroundColor DarkCyan "`nScript now creating playlist $($i) and installing poster."; 
            $ItemsToAdd = ($Results.PlexID | Select-Object -First 50 -skip (($i - 1) * 50)) -join ","; 
            #set & create playlist
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"; 
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
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"; 
            $PlaylistID = $Data.MediaContainer.Playlist.ratingKey; 
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[$i])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" 
        }
    }
}   

function play100 {
    [array]$CurrentPlexServer = ((Invoke-RestMethod -Uri "https://plex.tv/api/servers`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -UseBasicParsing).MediaContainer.Server) | Where-Object { $_.name -eq $DefaultPlexServer.PlexServer }
    $Results = Questiontime
    $PlaylistTitle = ([uri]::EscapeDataString($PlaylistName))



    $numplaylists = [math]::ceiling($Results.count / 100)
    if ($DefaultPlexServer.UserToken -eq "") {
        for ($i = 1; $i -le $numplaylists; $i++) {
            Write-Host -ForegroundColor DarkCyan "`nScript now creating playlist $($i) and installing poster."; 
            $i
            $ItemsToAdd = ($Results.PlexID | Select-Object -First 100 -skip (($i - 1) * 100)) -join ","; 
            #set & create playlist
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST"; 
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
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$($PlaylistTitle)%20$i&smart=0&type=video&X-Plex-Token=$($DefaultPlexServer.UserToken)" -Method "POST"; 
            $PlaylistID = $Data.MediaContainer.Playlist.ratingKey; 
            $Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($PlaylistID)/posters?url=$([uri]::EscapeDataString($($Posters[$i])))&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" 
        }
    } 
}

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

mainMenu