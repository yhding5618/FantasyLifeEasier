#Requires AutoHotkey v2.0

DebugWeaponAging := false

WeaponAging_AgeBtn_Click() {
    _WeaponAging()
}

WeaponAging_LoadAndAgeBtn_Click() {
    MySend("Space", , 1000)
    LoadFromCloud()
    Sleep(1000)
    _WeaponAging()
}

_WeaponAgingDonePixel := [812, 128, "0xE88536"]  ; "熟成成功"背景像素

_WeaponAging() {
    UpdateStatusBar("开始武器熟成")
    MySend("f", , 500)
    MySend("Space")
    WaitUntilColorMatch(
        _WeaponAgingDonePixel[1], _WeaponAgingDonePixel[2],
        _WeaponAgingDonePixel[3], "武器熟成")
}
