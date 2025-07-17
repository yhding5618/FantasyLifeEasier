#Requires AutoHotkey v2.0

Farming_HarvestBtn_Click() {
    _FarmingHarvest()
}

_FarmingHarvest() {
    count := myGui["Farming.HarvestCount"].Value
    waitDelay := myGui["Farming.HarvestWaitDelay"].Value
    loop count {
        TeleportationGateOneWay()
        TeleportationGateOneWay()  ; 刷新农田
        prefix := A_Index " / " count " "
        OutputDebug("Info.harvest.WhistlingUntilNone: " prefix "收获农田")
        UpdateStatusBar(prefix "收获农田")
        _FarmingWhistlingUntilNone(prefix)
        loop waitDelay {
            remainingTime := waitDelay - A_Index + 1
            OutputDebug("Info.harvest.WhistlingUntilNone: " prefix "等待收获完成..." remainingTime "秒")
            UpdateStatusBar(prefix "等待收获完成..." remainingTime "秒")
            Sleep(1000)  ; 每秒更新一次状态栏
        }
    }
}

_FarmingWhistleIconPixel := [845, 570, "0x7BA0A6"]  ; 哨子图标像素

_FarmingWhistlingUntilNone(prefix := "") {
    WaitUntilColorMatch(
        _FarmingWhistleIconPixel[1], _FarmingWhistleIconPixel[2],
        _FarmingWhistleIconPixel[3], prefix "哨子图标")
    count := 0
    maxCount := 100
    while (count < maxCount) {
        MySend("t", , 500)  ; 使用哨子
        if !SearchColorMatch(_FarmingWhistleIconPixel*) {
            OutputDebug("Debug.harvest.WhistlingUntilNone: " prefix "哨子已消失")
            break
        }
    }
    if (count >= maxCount) {
        OutputDebug("Error.harvest.WhistlingUntilNone: 哨子仍未消失")
        throw ValueError(prefix "哨子仍未消失")
    }
}
