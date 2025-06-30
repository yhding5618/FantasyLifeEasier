#Requires AutoHotkey v2.0

DebugTreasureGrove := false
_ReplantDebugID := 1

TreasureGroveReplantBtnClick() {
    MySend("f", , 1200)
    _TreasureGroveReplant()
}

TreasureGroveContinueReplantBtnClick() {
    MySend("Escape", , 1500)
    _TreasureGroveReplant()
}

_TreasureGroveReplant1Pos := [1323, 401]  ; “重新种植”在第一行位置
_TreasureGroveReplant2Pos := [1323, 441]  ; “重新种植”在第三行位置
_TreasureGroveReplantColor := "0xF7EFDB"  ; “重新种植”颜色
_TreasureGroveReplantConfirmPos := [704, 927]  ; 确认重新种植“是”位置
_TreasureGroveReplantConfirmColor := "0xF8F0DC"  ; 确认重新种植“是”颜色
_TreasureGroveLogoPos := [119, 62]  ; 迷宫树logo位置
_TreasureGroveLogoColor := "0xFAE5B5"  ; 迷宫树logo颜色

_TreasureGroveReplant() {
    UpdateStatusBar("重新种植")
    if !SearchColorMatch(
        _TreasureGroveReplant1Pos[1], _TreasureGroveReplant1Pos[2],
        _TreasureGroveReplantColor
    ) {
        UpdateStatusBar("向下两次")
        MySend("s", , 200)
        MySend("s", , 200)
        if !SearchColorMatch(
            _TreasureGroveReplant2Pos[1], _TreasureGroveReplant2Pos[2],
            _TreasureGroveReplantColor
        ) {
            throw ValueError("未找到重新种植选项")
        }
    }
    MySend("Space", , 1000)
    UpdateStatusBar("选择年代")
    key := myGui["TreasureGrove.YearMoveDir"].Value == 1 ? "w" : "s"
    count := myGui["TreasureGrove.YearMoveCount"].Value
    loop count {
        MySend(key, , 200)
    }
    MySend("Space", , 1000)
    UpdateStatusBar("确认重新种植")
    MySend("a", , 500)
    if !SearchColorMatch(
        _TreasureGroveReplantConfirmPos[1], _TreasureGroveReplantConfirmPos[2],
        _TreasureGroveReplantConfirmColor
    ) {
        throw ValueError("无法找到确认重新种植按钮")
    }
    MySend("Space")
    UpdateStatusBar("等待新的迷宫树")
    Sleep(4000)
    MySend("Space", , 500)
    if !SearchColorMatch(
        _TreasureGroveLogoPos[1], _TreasureGroveLogoPos[2],
        _TreasureGroveLogoColor
    ) {
        throw ValueError("迷宫树加载失败")
    }
    UpdateStatusBar("重新种植完成")
}
