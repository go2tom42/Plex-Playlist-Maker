# Plex-Playlist-Maker

Some info in the Wiki section


Set-PlexPlaylist.ps1, Get-AllPlexPlaylists.ps1, & Get-MA-Tokens.ps1 ALL contain this section that has to be updated by you  
  
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


## Usage

    .\Set-PlexPlaylist.ps1 [-File Path to CSV file] [-T Playlist Name/Title] [-q No questions, all titles from CSV added to one playlist*]

\* Assuming you have the titles on your server  



Get-AllPlexPlaylists.ps1 dumps all playlists to seperate CSV files that can be shared with others (Use Set-PlexPlaylist.ps1 to install, DUH)  


Powershell 5.1 screws with titles that have non english characters, use Powershell 7 
