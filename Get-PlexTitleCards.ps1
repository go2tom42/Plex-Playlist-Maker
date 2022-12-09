param(
    [Parameter(Mandatory = $false)]
    [String]
    $Title,

    [Parameter(Mandatory = $false)]
    [String]
    $SavePath,

    [Parameter(Mandatory = $false)]
    [Switch]
    $Posters
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

if ($Title) { $Title = $Title } else { $Title = Read-Host -Prompt 'Enter Show Title as it is displayed in Plex' }
function Get-ImageType {
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $path
    )
    $knownHeaders = @{
        jpg = @( "FF", "D8" );
        bmp = @( "42", "4D" );
        gif = @( "47", "49", "46" );
        tif = @( "49", "49", "2A" );
        png = @( "89", "50", "4E", "47", "0D", "0A", "1A", "0A" );
        pdf = @( "25", "50", "44", "46" );
    }
    $bytes = Get-Content -LiteralPath $Path -AsByteStream -ReadCount 1 -TotalCount 8 -ErrorAction Ignore
    $ext = ''
    foreach ($key in $knownHeaders.Keys) {
        $fileHeader = $bytes | Select-Object -First $knownHeaders[$key].Length | ForEach-Object { $_.ToString("X2") }
        if (($fileHeader -join '') -eq ($knownHeaders[$key] -join '')) {
            $ext = $key
        }
    }
    return $ext

}

Write-Host -ForegroundColor DarkCyan "`nScript executing, looking for PlexIDs."
$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections?X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET"
$showlibs = $Data.MediaContainer.Directory | Where-Object { $_.type -eq "show" }

Remove-Variable tvdata -ErrorAction SilentlyContinue
foreach ($tvItem in $showlibs) {
    Write-Host -ForegroundColor DarkCyan "`nScript now loading episode titles from $($tvItem.title)"
    $tvdata += ((Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/sections/$($tvItem.key)/all?type=4&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET").MediaContainer.Video)
}
$newtvdata += $tvdata | Where-Object { $_.grandparentTitle -eq $Title }

New-Item -path ".\$title" -ItemType Directory
foreach ($item in $newtvdata) {
    if ($posters) {
        if (-not(test-path -Path ".\$Title\$($item.grandparentTitle) - S$("{00:d2}" -f [int]$item.parentIndex)E00.*" )) {
            $WebClient = New-Object System.Net.WebClient;
            $WebClient.DownloadFile("$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)$($item.parentThumb)/?X-Plex-Token=$($DefaultPlexServer.Token)", ".\Get-PlexTitleCards.temp")
            $ext = Get-ImageType ".\Get-PlexTitleCards.temp"
            Move-Item -Path ".\Get-PlexTitleCards.temp" -Destination ".\$Title\$($item.grandparentTitle) - S$("{00:d2}" -f [int]$item.parentIndex)E00.$ext"
        }
        if (-not(test-path -Path ".\$Title\$($item.grandparentTitle) - S99E00.*" )) {
            $WebClient = New-Object System.Net.WebClient;
            $WebClient.DownloadFile("$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)$($item.grandparentThumb)/?X-Plex-Token=$($DefaultPlexServer.Token)", ".\Get-PlexTitleCards.temp")
            $ext = Get-ImageType ".\Get-PlexTitleCards.temp"
            Move-Item -Path ".\Get-PlexTitleCards.temp" -Destination ".\$Title\$($item.grandparentTitle) - S99E00.$ext"
        }
    }
    $WebClient = New-Object System.Net.WebClient;
    $WebClient.DownloadFile("$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)$($item.thumb)/?X-Plex-Token=$($DefaultPlexServer.Token)", ".\Get-PlexTitleCards.temp")
    $ext = Get-ImageType ".\Get-PlexTitleCards.temp"
    Move-Item -Path ".\Get-PlexTitleCards.temp" -Destination ".\$Title\$($item.grandparentTitle) - S$("{00:d2}" -f [int]$item.parentIndex)E$("{00:d2}" -f [int]$item.index).$ext"
}

