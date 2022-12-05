# Plex-Playlist-Maker

Some info in the Wiki section

Run Set-PlexPlaylist-Config.ps1 to set your config file

The config file will contain 
* Username
* Main Token
* PlexServer name
* PlexServer Host address
* Protocol
* Port
* Managed Users names & tokens

It will be saved C:\Users\USERNAME\AppData\Roaming\PlexPlaylist\PlexPlaylist.json on windows or "$HOME/.PlexPlaylist/PlexPlaylist.json" on Linux or MacOS

Look over Set-PlexPlaylist-Config.ps1 you will see all data stays between your PC and Plex.tv, but if you don't want to login in to Plex.TV using the script you can manuually create the config JSON file

```
{
  "Username": "dabom42",
  "Token": "sVb27591de98a93ydRmx",
  "UserToken": "",
  "Title": "dabom42",
  "PlexServer": "Aname",
  "PlexServerHostname": "192.168.24.188",
  "Protocol": "http",
  "Port": 32400,
  "Default": "True",
  "machineIdentifier": "f3127591de98a1275759127591de91275bc5a35",
  "Users": [
    {
      "Username": "",
      "Title": "Tom42",
      "Token": "PVy3fuX4q2UuaggTessQ"
    },
    {
      "Username": "",
      "Title": "Wife",
      "Token": "4PxUwdsfsadvgdfghess"
    }
  ],
  "AddedOn": "2022-12-04T23:02:53"
}
```

You can get the Main Token [THIS WAY](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/)  
http://<IP_OF_PMS>:32400/identity will get you machineIdentifier  



## Usage
```
Set-PlexPlaylist
    [-File "PATH TO CSV FILE"] ".\playlist.csv" if not specified
    [-Title "NAME FOR PLAYLIST"] "Marvel / MCU" if not specified
    [-q] No questions, all titles from CSV added to one playlist* If not specified you're asked if you want to include different catagories
    [-Poster "PATH TO JSON WITH POSTER LINKS"] if not specified 21 generic posters are supplied
    [-user MANAGED USER NAME] if not specified Playlist will be for Main account
```

\* Assuming you have the titles on your server  

## Usage
```
Set-PlexPlaylist-Config
    [-username PLEX.TV USERNAME] if not specified it will ask for it
    [-pass PLEX.TV PASSWORD] if not specified it will ask for it
    [-address] if not specified it will ask for it EX: http://192.168.22.818:32400/web/index.html or just http://192.168.22.818:32400
```


Get-AllPlexPlaylists.ps1 dumps all playlists for all users to seperate CSV files that can be shared with others (Use Set-PlexPlaylist.ps1 to install, DUH)  


Powershell 5.1 screws with titles that have non english characters, use Powershell 7 
