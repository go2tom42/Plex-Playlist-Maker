Requires running Set-PlexPlaylist-Config.ps1 before using  

## Usage
```
Set-PlexTitleCards
    [-Path "PATH TO FOLDER WITH TITLECARDS"] if not specified it will ask for it
    [-Name "NAME FOR SHOW"]  if not specified it will ask for it
```

Script grabs PlexIDs for Show title given that also matches the season and episode from image file name, then uploads that image to your Plex server  


Images file names must contains season and episode info in the format of S01E01, not case senitive  

For a Season one poster use S01E00, season two S02E00, etc   
For the "Special Season" use S00E00  
For Series poster use S99E00  
