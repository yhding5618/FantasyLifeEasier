#Requires AutoHotkey v2.0

DebugMiniGame := true
_ReplantDebugID := 1

TreasureGroveReplantBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    MySend("f", , 1000)
    if (!_TreasureGroveReplant()) {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

TreasureGroveContinueReplantBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    MySend("Escape", , 1000)
    if (!_TreasureGroveReplant()) {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

_TreasureGroveReplantPos := [1323, 441]  ; “重新种植”位置
_TreasureGroveReplantColor := "0xF7EFDB"  ; “重新种植”颜色
_TreasureGroveReplantConfirmPos := [704, 927]  ; 确认重新种植“是”位置
_TreasureGroveReplantConfirmColor := "0xF8F0DC"  ; 确认重新种植“是”颜色
_TreasureGroveLogoPos := [119, 62]  ; 迷宫树logo位置
_TreasureGroveLogoColor := "0xFAE5B5"  ; 迷宫树logo颜色

_TreasureGroveReplant() {
    UpdateStatusBar("重新种植")
    MySend("s")
    Sleep(100)
    MySend("s")
    color := PixelGetColor(_TreasureGroveReplantPos[1], _TreasureGroveReplantPos[2])
    MyToolTip(color, _TreasureGroveReplantPos[1], _TreasureGroveReplantPos[2], _ReplantDebugID, DebugMiniGame)
    if (color != _TreasureGroveReplantColor) {
        UpdateStatusBar("颜色异常")
        return false
    }
    MySend "Space"
    Sleep(1000)
    UpdateStatusBar("选择年代")
    key := myGui["TreasureGrove.YearMoveDir"].Value == 1 ? "w" : "s"
    count := myGui["TreasureGrove.YearMoveCount"].Value
    loop count {
        MySend(key)
        Sleep(100)
    }
    MySend("Space")
    Sleep(500)
    UpdateStatusBar("确认重新种植")
    MySend("a")
    Sleep(100)
    color := PixelGetColor(_TreasureGroveReplantConfirmPos[1], _TreasureGroveReplantConfirmPos[2])
    MyToolTip(color, _TreasureGroveReplantConfirmPos[1], _TreasureGroveReplantConfirmPos[2], _ReplantDebugID,
        DebugMiniGame)
    if (color != _TreasureGroveReplantConfirmColor) {
        UpdateStatusBar("颜色异常")
        return false
    }
    MySend "Space"
    UpdateStatusBar("等待新的迷宫树")
    Sleep(4000)
    MySend("Space")
    Sleep(500)
    color := PixelGetColor(_TreasureGroveLogoPos[1], _TreasureGroveLogoPos[2])
    MyToolTip(color, _TreasureGroveLogoPos[1], _TreasureGroveLogoPos[2], _ReplantDebugID, DebugMiniGame)
    if (color != _TreasureGroveLogoColor) {
        UpdateStatusBar("颜色异常")
        return false
    }
    UpdateStatusBar("重新种植完成")
    return true
}
