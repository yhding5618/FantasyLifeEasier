#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "lib/utils.ahk"
#Include "lib/gui.ahk"
#Include "lib/game_window.ahk"
#Include "lib/teleportation_gate.ahk"
#Include "lib/save_load.ahk"
#Include "lib/long_cape.ahk"
#Include "lib/mini_game.ahk"
#Include "lib/treasure_grove.ahk"
#Include "lib/weapon_aging.ahk"
#Include "lib/online.ahk"
#Include "lib/mystery_box.ahk"
#Include "lib/mimic.ahk"
#Include "lib/legendary.ahk"
#Include "lib/harvest.ahk"
#Include "lib/script_control.ahk"
; 外部库
#Include "lib/external/OCR.ahk"

ProcessSetPriority("High")
CoordMode("Pixel", "Client")

F3:: Pause(-1)
F4:: SaveAndExit()
F5:: SaveAndReload()

MainTitle := "Fantasy Life Easier"
myGui := Gui(, MainTitle)
myGui.OnEvent("Close", (*) => SaveAndExit())
BuildMyGui()
LoadConfig()
ShowMyGui()

SetTimer(UpdateByTimer1, 500)
UpdateByTimer1() {
    GameWindowStatusUpdate()
    ScriptControlStatusUpdate()
}
