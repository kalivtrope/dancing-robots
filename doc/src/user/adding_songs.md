# Adding new songs

Check out [this guide](https://outfox.wiki/user-guide/setup/getting-started/) on getting started with OutFox for more information.

The directory structure is the same as with Stepmania:
- song packs are to be placed at `~/.project-outfox/Songs/`
- individual songs should be placed at `~/.project-outfox/Songs/<name-of-the-song-pack>/`

Here's an example of such a directory structure:
```bash
% ~/.project-outfox/Songs tree -d -L 2
.
├── OutFox Serenity Volume 1
│   ├── Aspid Cat - Abandoned Doll
│   ├── Aspid Cat - Conflicting Revenge
│   ├── DJ Megas - Plasma
│   ├── spirai project -drazil- - synthborn lovebirds
├── OutFox Serenity Volume 2
│   ├── Ace of Beat - B-Happy
│   ├── Thomas Dingwall a.k.a. td - CRUSH THE DEVIL (IN MY BRAIN)
│   └── Zenth - Relaxation Piece of Conclusion
└── Undertale Pack
    ├── Chill (MarioNintendo)
    ├── Ghouliday (MarioNintendo)
    ├── Long Elevator (MarioNintendo)
    ├── Oh My (MarioNintendo)
    ├── Ooo (MarioNintendo)
    ├── Pathetic House (MarioNintendo)
```

If your packs are already located elsewhere and you don't feel like linking/copying them,
you can tell the engine to look for them at the specified folder via a preference (as per [this page](https://outfox.wiki/user-guide/config/preferences/#additionalsongfolders)).
Just do `AdditionalSongsFolders=/path/to/other/song-pack-dir` in your `Preferences.ini`.

## Obtaining new songs
- [Stepmania Online database](https://search.stepmaniaonline.net/)
- [Project OutFox Serenity Packs](https://github.com/TeamRizu/OutFox-Serenity)
