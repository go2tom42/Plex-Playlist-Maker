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
$CurrentPlexServer = Get-PlexServer -Name $DefaultPlexServer.PlexServer -ErrorAction Stop
$Data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$($CurrentPlexServer.machineIdentifier)/access_tokens.xml?auth_token=$($DefaultPlexServer.Token)&includeProviders=1" -ErrorAction Stop
$Data = $Data.access_tokens.access_token

for ($i = 0; $i -lt $Data.Count; $i++) {

    if ($Data[$i].library_section) {
        "Username/Title: $($Data[$i].title)"
        "Token: $($Data[$i].token)"
    }
}
Pause