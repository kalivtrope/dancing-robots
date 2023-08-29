# More about the theme
While we have covered the main engine controller code, there is still a couple of important files and concepts we should be aware of.

## Screens
This theme (partially) defines three additional screens.
For more information about screens and their layers, see [the OutFox wiki](https://outfox.wiki/dev/theming/Theming-3-Anatomy-Screen/).
### ScreenSelectConfig

| ![ScreenSelectConfig](../img/guide_problemmenu.png) |
| :--:                                                |
| ScreenSelectConfig                                  |

Because of the available resources (and my limited knowledge), this screen is defined in `eralk/metrics.ini` and `eralk/Scripts/ListAllConfigurations.lua`.
It contains the logic for filtering files from `Inputs` and `Outputs` while passing the selected problem instance to the `engine` module via an environment variable.

#### Scripts
Be aware that the directory `eralk/Scripts` is meant to be used for quick-and-dirty scripts that are globally available from everywhere in the game environment.
However, the alternative option to this was defining the lua function directly in `eralk/metrics.ini` which in my opinion felt slightly more messy than this.
### ScreenGameplay overlay

| ![ScreenGameplay overlay](../img/guide_gameplay.png)       |
| :--:                                                       |
| ScreenGameplay overlay with notefield and judgment proxies |


This is where the `engine.dancefloor` gets drawn at. The dancefloor actually gets to be drawn over the whole screen.
The rest of the drawing logic ensures that the notefield and judgment messages get rendered as well.
This is done by creating actor proxies and drawing them over `dancefloor`.

The current implementation of my drawing actors isn't "resistant" to some of the songs that you may find out in the wild (or even in the Serenity pack).
It's those songs that define a `#FGCHANGES` in their configuration which lets them draw over, manipulate or straight up discard whatever this theme provides.
Also, this theme doesn't really disable anything else but the original notefield, so things like background animations in the song might slow down the rendering.

Code for this screen resides at `eralk/BGAnimations/ScreenGameplay overlay`.
### ScreenEvaluationEralk
| ![ScreenEvaluationEralk](../img/guide_screenfailed.png) |
| :--:                                                    |
| ScreenEvaluationEralk                                   |


This is the evaluation screen for the Eralk gameplay. It simply reports whether the game was succesful and provides at most 3 remarks / errors for the player.
Code for this screen resides at `eralk/BGAnimations/ScreenEvaluationEralk overlay`.

## Languages
You can find localization files for my custom screen's titles an list descriptions in `eralk/Languages`.

There is currently only an English file.
Why not Czech? Because not even the original Stepmania was localized for Czech, just for Slovak (and I don't speak Slovak).
