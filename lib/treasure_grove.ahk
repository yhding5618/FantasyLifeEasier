#Requires AutoHotkey v2.0

DebugTreasureGrove := false
_ReplantDebugID := 1

TreasureGrove_ReplantBtn_Click() {
    MySend("f")
    _TreasureGroveReplant()
    _TreasureGroveCheckAllRooms()
}

TreasureGrove_NextReplantBtn_Click() {
    MySend("Escape")
    _TreasureGroveReplant()
    _TreasureGroveCheckAllRooms()
}

TreasureGrove_CheckRoomBtn_Click() {
    _TreasureGroveCheckAllRooms()
}

; 3个选项时发光位置
_TreasureGroveGlow1Pos := UtilsOptionListTopIn3GlowPos
; 5个选项时发光位置
_TreasureGroveGlow2Pos := UtilsOptionListTopIn5GlowPos
; 发光颜色
_TreasureGroveGlowColor := UtilsOptionListGlowColor
; 迷宫树“路线图”logo像素
_TreasureGroveLogoPixel := [119, 58, "0xF7E1B2"]
; 迷宫树地图共10行（不包括起点层）
; 奇数行有6列，偶数行只有5列且向右偏移1个房间
; 迷宫树地图(1,1)房间的中心位置（从1开始计数）
_TreasureGroveRoom11Pos := [424, 272]
; 迷宫树房间大小
; 房间纵向间隔为1个房间大小
; 房间横向间隔为2个房间大小
_TreasureGroveRoomSize := 72
; 空房间颜色
_TreasureGroveEmptyHSVMax := [42, 64, 47]
_TreasureGroveEmptyHSVMin := [21, 48, 36]
_TreasureGroveEmptyHSV := [  ; [31, 56, 41]
    (_TreasureGroveEmptyHSVMax[1] + _TreasureGroveEmptyHSVMin[1]) // 2,
    (_TreasureGroveEmptyHSVMax[2] + _TreasureGroveEmptyHSVMin[2]) // 2,
    (_TreasureGroveEmptyHSVMax[3] + _TreasureGroveEmptyHSVMin[3]) // 2
]
_TreasureGroveEmptyHSVVar := [  ; [11, 9, 6]
    (_TreasureGroveEmptyHSVMax[1] - _TreasureGroveEmptyHSVMin[1]) // 2 + 1,
    (_TreasureGroveEmptyHSVMax[2] - _TreasureGroveEmptyHSVMin[2]) // 2 + 1,
    (_TreasureGroveEmptyHSVMax[3] - _TreasureGroveEmptyHSVMin[3]) // 2 + 1
]
_TreasureGroveEmptyColor := "0x6B5531"
; 怪物层颜色
_TreasureGroveMonsterColor := "0xA75AE6"  ; (4,2) (5,2)
; 采矿层颜色
_TreasureGroveMiningColor := "0xCCC3B8"  ; (4,4)
; 伐木层颜色
_TreasureGroveLoggingColor := "0xBFF2B0"  ; (4,3)
; 钓鱼层颜色
_TreasureGroveFishingColor := "0xA3CCFF"  ; (5,3) (5,4)
; 收获层颜色
_TreasureGroveHarvestingColor := "0xFFA957"  ; (4,4) (5,4)
; 怪物小屋颜色
_TreasureGroveSpecialMonsterRoomColor := "0x583514"
; 熟成祭坛颜色
_TreasureGroveAgingAltarColor := "0x8CF1CA"
; 惊魂器颜色
_TreasureGroveStrangelingColor := "0x03CCC0"
; 宝物库颜色
_TreasureGroveTreasureColor := "0xB1B9C4"
; 怪物Boss颜色
_TreasureGroveBossMonsterColor := "0xEC036D"
; 普通房间颜色
_TreasureGroveNormalRoomColor := Map(
    "怪物", _TreasureGroveMonsterColor,
    "采矿", _TreasureGroveMiningColor,
    "伐木", _TreasureGroveLoggingColor,
    "钓鱼", _TreasureGroveFishingColor,
    "收获", _TreasureGroveHarvestingColor,
)
; 特殊房间颜色
_TreasureGroveSpecialRoomColor := Map(
    "怪物小屋", _TreasureGroveSpecialMonsterRoomColor,
    "熟成祭坛", _TreasureGroveAgingAltarColor,
    "惊魂器", _TreasureGroveStrangelingColor,
    "宝物库", _TreasureGroveTreasureColor
)
; Boss颜色
_TreasureGroveBossColor := Map(
    "怪物", _TreasureGroveBossMonsterColor,
    "采矿", _TreasureGroveMiningColor,
    "伐木", _TreasureGroveLoggingColor,
    "钓鱼", _TreasureGroveFishingColor,
    "收获", _TreasureGroveHarvestingColor
)
; Boss名字OCR范围和颜色，[x, y, w, h]，只包括Boss名字
_TreasureGroveBossNameOCR := [1300, 600, 500, 40, "0xF2EAD8"]
_TreasureGroveBossTypeName := Map(
    "怪物", [""],  ; 怪物Boss
    "采矿", [""],  ; 采矿Boss
    "伐木", [""],  ; 伐木Boss
    "钓鱼", [""],  ; 钓鱼Boss
    "收获", [""]  ; 收获Boss
)

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
    key := myGui["TreasureGrove.YearMoveDir"].Value == 1 ? "w" : "s"
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
    WaitUntilConversationSpace()
    MySend("Space")
}

/**
 * @description 检查地图上所有房间
 */
_TreasureGroveCheckAllRooms() {
    UpdateStatusBar("检查所有房间")
    targetSpecialRoom := myGui["TreasureGrove.TargetSpecialRoom"].Text
    targetBossName := myGui["TreasureGrove.TargetBossName"].Text
    targetSRMatch := false
    targetBNMatch := false
    WaitUntilColorMatch(
        _TreasureGroveLogoPixel[1], _TreasureGroveLogoPixel[2],
        _TreasureGroveLogoPixel[3], "迷宫树路线图logo")
    loop 10 {  ; 遍历10行，包括第10行（Boss房间）
        row := A_Index
        loop 6 {  ; 遍历6个房间
            col := A_Index
            if (Mod(row, 2) == 0 && col == 6) {
                continue  ; 偶数行只有5个房间
            }
            roomType := _TreasureGroveCheckSingleRoom(row, col)
            if (_TreasureGroveSpecialRoomColor.Has(roomType)) {
                if (
                    (targetSpecialRoom == "全部") ||
                    (targetSpecialRoom == roomType)
                ) {
                    targetSRMatch := true
                }
            }
            if (row == 10) {
                bossName := roomType
                if (
                    (targetBossName == "") ||
                    (targetBossName == bossName)
                ) {
                    targetBNMatch := true
                }
            }
        }
    }
    if (targetSRMatch || targetBNMatch) {
        ShowSuccessMsgBox("找到目标房间", true)
    }
}

/**
 * @description 检查单个房间类型
 * @param {Integer} row 行号（从1开始计数）
 * @param {Integer} col 列号（从1开始计数）
 * @return {String}  房间类型串或Boss名字
 */
_TreasureGroveCheckSingleRoom(row, col) {
    static debugId := 1
    static hsvMax := [0, 0, 0]
    static hsvMin := [360, 100, 100]
    isBoss := row == 10
    x := _TreasureGroveRoom11Pos[1] +
        _TreasureGroveRoomSize * (col * 2 - 1 - Mod(row, 2))
    y := _TreasureGroveRoom11Pos[2] +
        _TreasureGroveRoomSize * (row - 1)
    color := UtilsGetColor(x, y)
    hsv := UtilsRGB2HSV(color)
    roomType := ""
    if UtilsMatchColorHSV(
        color, _TreasureGroveEmptyHSV, _TreasureGroveEmptyHSVVar
    ) {
        ; MyToolTip("空", x, y, debugId, DebugTreasureGrove)
        ; debugId := debugId == 20 ? 1 : debugId + 1
        return "空"
    }
    if isBoss {
        ; 匹配Boss房间颜色
        for key, value in _TreasureGroveBossColor {
            if UtilsMatchColorHSV(color, value) {
                roomType := key
                break
            }
        }
        if roomType != "" {
            MyToolTip(roomType, x, y, debugId, DebugTreasureGrove)
            debugId := debugId == 20 ? 1 : debugId + 1
            bossName := _TreasureGroveIdentifyBoss(x, y, roomType)
            return bossName
        }
    } else {
        ; 匹配特殊房间颜色
        for key, value in _TreasureGroveSpecialRoomColor {
            if UtilsMatchColorHSV(color, value) {
                roomType := key
                break
            }
        }
        if roomType != "" {
            MyToolTip(roomType, x, y, debugId, DebugTreasureGrove)
            debugId := debugId == 20 ? 1 : debugId + 1
            return roomType
        }
        ; 匹配普通房间颜色
        for key, value in _TreasureGroveNormalRoomColor {
            if UtilsMatchColorHSV(color, value) {
                roomType := key
                break
            }
        }
        if roomType != "" {
            ; MyToolTip(roomType, x, y, debugId, DebugTreasureGrove)
            ; debugId := debugId == 20 ? 1 : debugId + 1
            return roomType
        }
    }
    MyToolTip(color "`n" hsv[1] ", " hsv[2] ", " hsv[3],
        x, y, debugId, DebugTreasureGrove)
    throw ValueError("未知的房间类型" color)
}

_TreasureGroveIdentifyBoss(x, y, bossType) {
    ; 缓慢移动鼠标激活boss信息
    MouseGetPos(&xm, &ym)
    MouseMove(x, y)
    loop 10 {
        MouseMove(1, 1, 100, "R")
        Sleep(1)
    }
    MouseMove(xm, ym)  ; 恢复鼠标位置
    Sleep(500)  ; 等待界面稳定
    ; OCR识别Boss名字
    try {
        result := UtilsOCRFromRegion(_TreasureGroveBossNameOCR*)
        if result.Lines.Length != 1 {
            throw ValueError("无法解析OCR结果：`n" result.Text)
        }
        bossName := StrReplace(result.Text, " ")
        nameMatch := false
        for idx, value in _TreasureGroveBossTypeName[bossType] {
            if (value == bossName) {
                nameMatch := true
                break
            }
        }
    } catch Error as e {
        throw ValueError("OCR识别Boss名字失败：" e.Message)
    }
    UpdateStatusBar("检测到" bossType "Boss：" bossName)
    return bossName
}
