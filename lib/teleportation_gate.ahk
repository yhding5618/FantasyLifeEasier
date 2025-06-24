#Requires AutoHotkey v2.0

DebugLegendary := false
_MenuDebugID := 8

TeleportationGateOneWayBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !TeleportationGateOneWay() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

TeleportationGateReturnTripBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !TeleportationGateOneWay() {
        PlayFailureSound()
        return
    }
    if !TeleportationGateOneWay() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

_TeleportationGateInProgressPos := [50, 50]  ; 传送中白色背景
_TeleportationGateInProgressColor := "0xFFFFFF"  ; 传送中白色背景颜色
_TeleportationGateSavingIconPos := [85, 370]  ; 保存中图标位置
_TeleportationGateSavingIconColor := "0xFFDC7E"  ; 保存中图标位置

TeleportationGateOneWay() {
    if !_MoveToMenuTeleportationGate() {
        return
    }
    MySend("Space", , 750)
    MySend("Space")
    counter := 0
    loading := false
    while (true) {
        color := PixelGetColor(_TeleportationGateInProgressPos[1], _TeleportationGateInProgressPos[2])
        if (!loading && color == _TeleportationGateInProgressColor) {
            loading := true
        }
        else if (loading && color != _TeleportationGateInProgressColor) {
            break
        }
        counter++
        if (loading) {
            UpdateStatusBar("等待白屏加载..." counter)
        }
        else {
            UpdateStatusBar("等待开门动画..." counter)
        }
        if (counter > 100) {
            UpdateStatusBar("传送超时")
            return false
        }
        Sleep(200)
    }
    counter := 0
    savingIconPosRange := 10
    savingIconColorRange := 10
    while (true) {
        foundSavingIcon := PixelSearch(&x, &y,
            _TeleportationGateSavingIconPos[1] - savingIconPosRange,
            _TeleportationGateSavingIconPos[2] - savingIconPosRange,
            _TeleportationGateSavingIconPos[1] + savingIconPosRange,
            _TeleportationGateSavingIconPos[2] + savingIconPosRange,
            _TeleportationGateSavingIconColor, savingIconColorRange)
        if (foundSavingIcon) {
            UpdateStatusBar("传送完成")
            break
        }
        counter++
        UpdateStatusBar("等待关门动画..." counter)
        if (counter > 50) {
            UpdateStatusBar("等待关门动画超时")
            return false
        }
        Sleep(200)
    }
    return true
}

_TeleportationGateIconCheckedColor := "0xD4B1EB"  ; 传送图标已选择颜色
_TeleportationGateIconUncheckedColor := "0xDD7BE3"  ; 传送图标未选择颜色
_TeleportationGateIconDisabledColor := "0x935986"  ; 传送图标不可选颜色

_MoveToMenuTeleportationGate() {
    page := myGui["TeleportationGate.IconPage"].Value
    row := myGui["TeleportationGate.IconRow"].Value
    col := myGui["TeleportationGate.IconCol"].Value
    color := MoveToMenuIcon(page, row, col)
    switch (color) {
        case _TeleportationGateIconCheckedColor:
            UpdateStatusBar("传送图标已选择")
            return true
        case _TeleportationGateIconUncheckedColor:
            UpdateStatusBar("传送图标未选择")
            return false
        case _TeleportationGateIconDisabledColor:
            UpdateStatusBar("传送图标不可选")
            return false
        default:
            UpdateStatusBar("传送图标颜色不匹配: " color)
            return false
    }
}
