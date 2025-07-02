#Requires AutoHotkey v2.0

DebugTreasureGrove := false
_ReplantDebugID := 1

TreasureGrove_ReplantBtn_Click() {
    MySend("f")
    _TreasureGroveReplant()
    _TreasureGroveCheckBoss()
}

TreasureGrove_NextReplantBtn_Click() {
    MySend("Escape")
    _TreasureGroveReplant()
    _TreasureGroveCheckBoss()
}

_TreasureGroveGlow1Pos := UtilsOptionListTopIn3GlowPos  ; 3个选项时发光位置
_TreasureGroveGlow2Pos := UtilsOptionListTopIn5GlowPos  ; 5个选项时发光位置
_TreasureGroveGlowColor := UtilsOptionListGlowColor  ; 发光颜色
_TreasureGroveContinueSpacePixel := UtilsConversationSpacePixel  ; 继续按钮像素
; 迷宫树地图共10行11列，奇数行只有奇数列有效，偶数行只有偶数列有效（从1开始计数）
_TreasureGroveRoomZeroPos := [424, 272]  ; 迷宫树地图(1,1)房间的中心位置
_TreasureGroveRoomSize := 72  ; 迷宫树房间大小
_TreasureGroveBossGlowColor := "0xDA7054"  ; 迷宫树关底boss发光颜色

_TreasureGroveReplant() {
    UpdateStatusBar("种植")
    count := 0
    timeoutCount := 50
    while (count < timeoutCount) {
        optionAtFirst := SearchColorMatch(  ; 3选1st
            _TreasureGroveGlow1Pos[1], _TreasureGroveGlow1Pos[2],
            _TreasureGroveGlowColor
        )
        optionAtThird := SearchColorMatch(  ; 5选3rd
            _TreasureGroveGlow2Pos[1], _TreasureGroveGlow2Pos[2],
            _TreasureGroveGlowColor
        )
        if (optionAtFirst ^ optionAtThird) {
            break
        }
        UpdateStatusBar("等待“重新种植”选项..." count "/" timeoutCount)
        Sleep(100)
        count++
    }
    if (count >= timeoutCount) {
        throw TimeoutError("“重新种植”选项等待超时")
    }
    Sleep(500)  ; 等待界面稳定
    if (optionAtThird) {
        UpdateStatusBar("向下两次")
        MySend("s", , 100)
        MySend("s", , 100)
    }
    ; Pause()
    MySend("Space", , 1000)
    UpdateStatusBar("选择年代")
    key := myGui["TreasureGrove.YearMoveDirDdl"].Value == 1 ? "w" : "s"
    count := myGui["TreasureGrove.YearMoveCount"].Value
    loop count {
        MySend(key, , 200)
    }
    MySend("Space")
    WaitUntilColorMatch(
        UtilsWindowNo1Pos[1], UtilsWindowNo1Pos[2],
        UtilsWindowButtonColor, "确认重新种植“否”按钮")
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes1Pos[1], UtilsWindowYes1Pos[2],
        UtilsWindowButtonColor, "确认重新种植“是”按钮")
    MySend("Space")
    WaitUntilColorMatch(
        _TreasureGroveContinueSpacePixel[1],
        _TreasureGroveContinueSpacePixel[2],
        _TreasureGroveContinueSpacePixel[3],
        "继续按钮", , , 200, 100)
    MySend("Space")
}

_TreasureGroveCheckBoss() {
    count := 0
    timeoutCount := 50
    while (count < timeoutCount) {
        bossAreaLeft := _TreasureGroveRoomZeroPos[1]
        bossAreaRight := _TreasureGroveRoomZeroPos[1] +
            _TreasureGroveRoomSize * 10
        bossAreaTop := _TreasureGroveRoomZeroPos[2] +
            _TreasureGroveRoomSize * 9 - _TreasureGroveRoomSize // 2
        bossAreaBottom := _TreasureGroveRoomZeroPos[2] +
            _TreasureGroveRoomSize * 10 + _TreasureGroveRoomSize // 2
        found := PixelSearch(&xf, &yf,
            bossAreaLeft, bossAreaTop,
            bossAreaRight, bossAreaBottom,
            _TreasureGroveBossGlowColor, 10)
        if (found) {
            UpdateStatusBar("检测到迷宫树关底boss")
            MouseGetPos(&xm, &ym)
            MouseMove(xf, yf)
            ; 缓慢移动鼠标触发boss信息
            loop 25 {
                MouseMove(1, 1, 100, "R")
                Sleep(4)
            }
            MouseMove(xm, ym)  ; 恢复鼠标位置
            break
        }
        UpdateStatusBar("等待迷宫树关底boss..." count "/" timeoutCount)
        Sleep(100)
        count++
    }
    if (count >= timeoutCount) {
        throw TimeoutError("“迷宫树关底boss”等待超时")
    }
}
