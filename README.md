# Plex-Playlist-Maker

Some info in the Wiki section


Set-PlexPlaylist.ps1, Get-AllPlexPlaylists.ps1, $ Get-MA-Tokens.ps1 contain this section that has to be updated by you  
  
    $DefaultPlexServer = [pscustomobject]@{
     Username = "Username";
     Token = "Token";
     UserToken = ""; <#Only needed if you use a Managed Account#>
     PlexServer = "Smeghead";
     PlexServerHostname = "192.168.11.188";
     Protocol = "http";
     Port = "32400";
     Default = "True";
    }

The UserToken it used for [Managed Accounts](https://support.plex.tv/articles/203948776-managed-users/)  
You can get the Main Token [THIS WAY](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/)  
After editing the above section you can use Get-MA-Tokens.ps1 to get Tokens for Managed Accounts
