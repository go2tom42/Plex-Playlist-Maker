param(
    [Parameter(Mandatory = $false)]
    [String]
    $PATH,

    [Parameter(Mandatory = $false)]
    [String]
    $NAME,

    [Parameter(Mandatory = $false)]
    [Switch]
    $COMPRESS
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
    if ($COMPRESS) {
        Start-Process "jpegtran" -ArgumentList ("-copy none -optimize -outfile `"$($file.FullName)`" `"$($file.FullName)`"") -wait -PassThru -NoNewWindow
    }
    $episode = (([regex]::matches($file.name, '[sS]?(?<season>\d{1,2})[ xXeE]+(?<episode>\d{1,2})')))
    $file | Add-Member  -NotePropertyName Episode -NotePropertyValue (($episode.Groups | where-object { $_.Name -eq "episode" }).value)
    $file | Add-Member  -NotePropertyName Season -NotePropertyValue (($episode.Groups | where-object { $_.Name -eq "season" }).value)
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
    if ([decimal]$item.episode -eq '0' ) {

        if (($item.season -ge 0) -and ($item.season -lt 99)) {
            Write-Host -ForegroundColor DarkCyan "`nScript now installing Poster for Season $($item.season) Episode $($item.episode)"
            $tempratingkey = ($newtvdata | Where-Object { ($_.parentIndex -eq [decimal]$item.season) }) 
            if ($tempratingkey -is [array] ) {
                $ratingkey = $tempratingkey[0].parentRatingKey
                Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($ratingkey)/posters?includeExternalMedia=1&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" -InFile "$($item.FullName)" 
            }
        }
        if ($item.season -eq 99) {
            Write-Host -ForegroundColor DarkCyan "`nScript now installing Poster for Season $($item.season) Episode $($item.episode)"
            $tempratingkey = ($newtvdata | Where-Object { ($_.parentIndex -gt .9) })
            if ($tempratingkey -is [array] ) {
                $ratingkey = $tempratingkey[0].grandparentRatingKey 
                Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($ratingkey)/posters?includeExternalMedia=1&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" -InFile "$($item.FullName)" 
            }
        }
    } 
    if ([decimal]$item.episode -gt '0') {
        Write-Host -ForegroundColor DarkCyan "`nScript now installing Poster for Season $($item.season) Episode $($item.episode)"
        $ratingkey = (($newtvdata | Where-Object { ($_.index -eq [decimal]$($item.episode)) -and ($_.parentIndex -eq [decimal]$($item.season)) }).ratingKey ) 
        if ($ratingkey -gt 0) { 
            Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/library/metadata/$($ratingkey)/posters?includeExternalMedia=1&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "POST" -InFile "$($item.FullName)"
        }
    }
}

Write-Host -ForegroundColor DarkCyan "`nScript now done"