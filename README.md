# READ ME | Winwing UFC Addon

**Contact Information**
Email: preston.meade1@gmail.com
Discord: jerold#7539
DCS Forms: prestonflying

Hi! This is my attempt at getting the **Winwing F18 UFC** to work with other DCS Modules. The goal was to create a simple, easily expandable way of sending DCS module information to the **Winwing F18 UFC**.  The result is an updated Winwing lua file that just needs to be copied into your Saved Games/DCS/Scripts folder. See instructions below!

**Help, it is not working!**
The most likely cause is SimApp Pro overwrite the updated `wwt` folder. Check the `Scripts/wwt/wwtExport.lua` and on line 30 ensure you see mention of `ufcPatch` (this addon).

### Disclaimer
This solution depends on the current state of **SimApp Pro** and how it manages the F18 UFC. This is not an ideal way of accomplishing this task, but with SimApp Pro being a compiled executable and not easily changeable, this is the was the simplest way I saw to get the UFC working with other modules.

### How does data get shown on the UFC?
When flying other modules, this addon will mimic the F18 messages to **SimApp Pro** containing the UFC payload but filled with our target data. In the event **SimApp Pro** changes how it reads UFC state from DCS< a change will be required in this add on. SimApp Pro thinks we are flying an F18, and this add-on sends the proper messages to get SimApp Pro to show our data on the real UFC Device.



# Installation
This is easier than it seems, just added every step for all tech levels. TLDR: Replace the `Scripts/wwt` folder with the [wwt](https://github.com/llamaXc/winwing-ufc-addon/tree/main/wwt) folder from inside this repo.

 1. Download this repository and open folder on your computer.
 2. Unzip the .zip file using 7-zip or some other compression program.
 3. You will have a folder titled `winwing-ufc-addon`. Open this folder to see `wwt` `README` and `license`
 4. Ensure SimApp Pro is running
	 - **Note**: SimApp Pro may overwrite `Scripts/wwt/wwtExport.lua`. If this happens, this add-on will need to be re-copied over. This may happen during a SimApp Pro update or clicking "Repair Lua" in SimApp Pro Settings.
 5. Copy the `wwt` folder into `<USER>/Saved Games/<DCS>/Scripts/` and replace the existing `wwt` folder
 6. Launch DCS
 7. Select a compatible module. 
	 - **AV88 Harrier**: Supports ODU and UFC replica of DCS
	 - **UH1 Huey**: Example template that displays basic information on the UFC
6. Fly DCS and verify UFC is working.
7. If something does not look right, take a look at `<USER>/Saved Games/<DCS>/Logs/dcs.log` and look for any errors from the `WWT` log output. You can also file an [issue](https://github.com/llamaXc/winwing-ufc-addon/issues) if you are having problems.

## Known limitations
- The brightness is hard-coded to 80% for the LCD displays. I have not yet found a way to sync it easily across modules, so for now its always light.
- This is not a permeante feature, if Winwing changes SimApp Pro UFC logic, this would effect this add-on and require updates. If that happens I'll share a fix as soon as possible here.
- If anymore are discovered they will be added here.

## Adding more modules

If you find this add on useful and want to see more features, leave an [issue](https://github.com/llamaXc/winwing-ufc-addon/issues) request on this project and myself or someone else can look into adding it.

For those wanting to make a [Pull Request](https://github.com/llamaXc/winwing-ufc-addon/pulls) and add features by yourself, you will want to start by brainstorming a few things before making your PR. 

 1. What module are you looking to update or add? 
	 - You will need to add a new method in `wwt/ufcPatch/ufcPatch.lua` that builds a proper SimApp Pro UFC payload. See the UH1 Huey example for a good starter template. No need to worry about sending the UDP message or building it, this add-on will handle that. 
	 - If adding a new aircraft, you must add a new `if statement` to `getUFCPayloadByModuleType` in `ufcPatch/ufcPatch.lua` that returns the new generated SimApp Pro payload data.
2. What data do you want to export?
	- Keep in mind, the UFC displays are LCD and only have so many segments, thus you are limited to the characters you can display.  Here is the supported data that can be shown on the UFC
	- Use the already provided DCS functions to get data from the game. See this [Export.lua](https://github.com/sprhawk/dcs_scripts/blob/master/Export.lua) for a good example of what data you can access.
	- This data table is an example of what data is shown on the UFC. Scenario is F18 UFC Tacan Menu
<p>
    <img src="images/f18ufc.png" width="400" height="400" />
</p>

|Window Name| Description | Location |Compatible Data|F18 Example Data
|--|--|--|--|--|
|option1| UFC Display Window 1| Right hand side of UFC| Can show 4 characters. Digits or Capital Letters|:T/R **(ignore the : as that is coverd by `selectedWindows` argument)**
|option2| UFC Display Window 2| Right hand side of UFC| Can show 4 characters. Digits or Capital Letters| RCV
|option3| UFC Display Window 3| Right hand side of UFC|Can show 4 characters. Digits or Capital Letters| A/A
|option4| UFC Display Window 4| Right hand side of UFC|Can show 4 characters. Digits or Capital Letters| :X
|option5| UFC Display Window 5| Right hand side of UFC| Can show 4 characters. Digits or Capital Letters | Y
|scratchPadNumbers| UFC Scratch Pad Window | Scratch pad numerical display | Can show 4 digits. 0-9 | 62
|scratchPadString1| UFC Scratch Pad Letter Window 1| Most left charter on the scratch pad| Can show 0-9 or A-Z| O
|scratchPadString2| UFC Scratch Pad Letter Window 2| Most left charter on the scratch pad| Can show 0-9 or A-Z | N
|com1|UFC Com1 Display Window | Bottom Left of UFC | Can show 0-99 or A-Z. (Note due to LCD segments some numbers over 10 look malformed)| 1
|com2|UFC Com2 Display Window | Bottom Rightof UFC | Can show 0-99 or A-Z. (Note due to LCD segments some numbers over 10 look malformed)| 2
|selectedWindows| Along option 1 - 5 left side of the display |Along any option[1-5] window| Array of strings representing index's of windows to show a :. Example {"1","3"} | :X


