# MocaOmniPak
Repo for all of my custom HP2 PC content.
Models, textures, and sounds are separate due to file size limits. The packages can be found in [Releases](https://github.com/mocacola02/MocaOmniPak/releases).

## Installing
### Installing the M212 Engine
This content requires the M212 Engine for HP2. As of now, it is currently in beta and only available on the [HP Modding Discord](https://discord.gg/tpN4grB). Please join the server to download the updated engine. The [HP Modding Discord](https://discord.gg/tpN4grB) is also a great resource for modding and mapping questions, so I recommend sticking around.

After downloading the engine installer from the server, run the installer and install the engine into your HP2 game installation.


### Pre-Built Packages
To install pre-built content packages, download the latest files from [Releases](https://github.com/mocacola02/MocaOmniPak/releases). **You will need to download the latest MocaOmniPak, MocaTexturePak, MocaModelPak, and MocaSoundPak.**

Once downloaded, copy each package file into the System folder of your HP2 installation. Do NOT copy it into your Windows system folder.

### Building from Source
Download the MocaOmniPak source code from this repo. You will still need to download the MocaTexturePak, MocaModelPak, and MocaSoundPak packages and place them into the System folder.

If you downloaded MocaOmniPak as a .zip file, extract it. Copy the MocaOmniPak folder into the HP2 game folder (next to the other folders like System, Textures, etc). Inside the MocaOmniPak folder should be another folder called "Classes". If not, then please make sure your folders are ordered properly.

Go into the game's System folder, and make a copy of the 'Default.ini' file. Rename it to something else (e.g. Moca.ini). Open the file in Notepad (or another text editor) and search for EditPackages. You should find a list of EditPackages values with the stock game packages listed. At the end of the list (after M212Share), paste the following:

    EditPackages=MocaTexturePak
    EditPackages=MocaSoundPak
    EditPackages=MocaModelPak
    EditPackages=MocaCakePak
    EditPackages=MocaOmniPak
    
Save the .ini file and close it. Open a terminal/cmd window in the System folder, and type the following:

    ucc make ini=Moca.ini
   
   Note: If that doesn't work, try this:
   

    ./ucc make ini=Moca.ini

Allow the UAC pop-up, and then the package should begin compiling. It will auto-close, and the MocaOmniPak.u file should now be present in the System folder. If not, go to your Documents folder for the game (Harry - Coding Evolved by default), and check for errors in the UCC.log file. Please upload it in a bug ticket [here](https://github.com/mocacola02/MocaOmniPak/issues).


## User Agreement
By using any portion of my content in any way (including non-Unreal projects), you agree to the following:

 - You must include credit in some form. A credit in a readme file is fine, as long as it is easily available to other users. I appreciate in-game credit, but it is not required.
 - You cannot use this content in any commercial product or mod. This includes redistributing the assets directly or using them in another project commercially.
 - Do not ping or message the HP2 New Engine (M212 Engine) developers regarding bugs in my content. Direct ALL bug or feature requests to this repo, or ping me in the HP Modding Discord (@moca). You can open a ticket in [Issues](https://github.com/mocacola02/MocaOmniPak/issues).
 - Any feature requests made will be publicly available -- there will be no exclusive content additions.
 - I reserve the right to implement any bug fixes or other changes/additions introduced in forks. I will give full credit to any contributors via this page. **If you are interested in making changes or additions, feel free to reach out to me about contributing.**

The original content created by me in this repo, including both code and asset packages, is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). Any content derived from another source, namely KnowWonder and members of the modding community who helped with certain code snippets, belong to their respective owners.
