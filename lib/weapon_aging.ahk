#Requires AutoHotkey v2.0

WeaponAgingStartBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_WeaponAging() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

WeaponAgingNextBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    MySend("Space", , 1000)
    if !LoadFromCloud() {
        PlayFailureSound()
        return
    }
    if !_WeaponAgingWaitUI() {
        PlayFailureSound()
        return
    }
    Sleep(2000)
    if !_WeaponAging() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

_WeaponAgingDonePos := [812, 128]  ; "熟成成功"背景位置
_WeaponAgingDoneColor := "0xE88536"  ; "熟成成功"背景颜色
_WeaponAgingBagPos := [1480, 970]  ; 背包位置
_WeaponAgingBagColor := "0xDFAC5F"  ; 背包颜色

_WeaponAging() {
    UpdateStatusBar("开始武器熟成")
    MySend("f", , 500)
    MySend("Space")
    counter := 0
    while (true) {
        color := PixelGetColor(_WeaponAgingDonePos[1], _WeaponAgingDonePos[2])
        MyToolTip(color, _WeaponAgingDonePos[1], _WeaponAgingDonePos[2], 1, DebugMiniGame)
        if (color == _WeaponAgingDoneColor) {
            UpdateStatusBar("武器熟成完成")
            return true
        }
        counter++
        UpdateStatusBar("等待武器熟成完成..." counter)
        if (counter > 50) {
            UpdateStatusBar("等待超时")
            return false
        }
        Sleep(100)
    }
}

_WeaponAgingWaitUI() {
    UpdateStatusBar("等待界面加载")
    counter := 0
    while (true) {
        color := PixelGetColor(_WeaponAgingBagPos[1], _WeaponAgingBagPos[2])
        MyToolTip(color, _WeaponAgingBagPos[1], _WeaponAgingBagPos[2], 2, DebugMiniGame)
        if (color == _WeaponAgingBagColor) {
            UpdateStatusBar("界面加载完成")
            return true
        }
        counter++
        UpdateStatusBar("等待界面加载..." counter)
        if (counter > 50) {
            UpdateStatusBar("等待超时")
            return false
        }
        Sleep(1000)
    }
}
