#Requires AutoHotkey v2.0

DebugMiniGame := true
_ActionDebugID := 10

MiniGame_SingleActionBtn_Click() {
    station := 2
    done := false
    _MiniGameDoNextAction(&station, &done)
    AppendStatusBar("，结束于工作台" station)
}

MiniGame_ContinuousActionBtn_Click() {
    station := 2
    done := false
    while (true) {
        _MiniGameDoNextAction(&station, &done)
        if (done) {
            break
        }
    }
    AppendStatusBar("，结束于工作台" station)
    _MiniGameWaitForComplete()
    ; _MiniGameIdentifyNewSkills()
}

MiniGame_CheckSkillBtn_Click() {
    UpdateStatusBar("检查技能")
    _MiniGameIdentifyNewSkills()
}

_MiniGameRemakeSpacePos := [924, 1015]  ; 重新制作后的“技能重置”界面下方空格位置

MiniGame_LoopCraftAgainBtn_Click() {
    count := 0
    maxCount := myGui["MiniGame.LoopCraftAgainCount"].Value
    infiniteLoop := (maxCount == 0)  ; 0表示无限循环
    while ((count < maxCount) || infiniteLoop) {
        try {
            MiniGame_ContinuousActionBtn_Click()
        } catch Error as e {
            text := "第" count + 1 " 次制作失败，已中止循环"
            e.Message := text "，详情：" e.Message
            MySend("F9", , 500)  ; 保存OBS录像
            throw e
        }
        count++
        UpdateStatusBar("已完成制作 " count " 次")
        Sleep(500)
        if myGui["MiniGame.AutoCaptureChk"].Value {
            MySend("F12", , 500)  ; 截图
        }
        MySend("Space")  ; 确认制作完成
        match := WaitUntil2ColorMatch(
            _MiniGameRemakeSpacePos, UtilsKeyBackgroundColor,
            UtilsOptionListTopIn3GlowPos, UtilsOptionListGlowColor,
            "新页面加载", , , , 100)
        if (match == 1) {
            ; 重新制作流程，先进入技能重置页面
            ; 等待手动选择后进入3选1“继续重制”页面，最多等待3分钟
            WaitUntilColorMatch(
                UtilsOptionListTopIn3GlowPos[1],
                UtilsOptionListTopIn3GlowPos[2],
                UtilsOptionListGlowColor, "手动选择技能",
                , , 100, 1800)
            UpdateStatusBar("进入“继续重制”菜单")
        } else {
            ; 再次制作流程，直接进入3选1“再次制作”页面
            UpdateStatusBar("进入“再次制作”菜单")
        }
        if (count == maxCount) {
            UpdateStatusBar("循环完毕，已完成制作 " count " 次")
            break
        }
        Sleep(500)
        MySend("s", , 500)  ; 选择再次制作/继续重置
        MySend("Space", , 500)  ; 确认再次制作/继续重置
    }
}

/**
 * @description 执行下一步操作
 * @param {VarRef} station 当前工作台位置（1:左, 2:中, 3:右）
 * @param {VarRef} done 是否完成操作
 */
_MiniGameDoNextAction(&station, &done) {
    uiType := _MiniGameWaitForUI()
    MyToolTip("uiType: " uiType, 0, 0, 1, DebugMiniGame)
    if (uiType == 2) {
        done := true  ; 图标栏为空，直接返回
        return
    }
    action := _MiniGameGoNextStation(&station)
    _MiniGameDoAction(action)
}

; 制作完成横幅像素
_MiniGameCompleteBanner1Pixel := [960, 160, "0xE88536"]
_MiniGameCompleteBanner2Pixel := [960, 170, "0xFFE7BC"]
_MiniGameCompleteBanner3Pixel := [960, 180, "0xA94F0D"]

/**
 * @description 等待制作完成
 * @throws TimeoutError 如果等待超时
 */
_MiniGameWaitForComplete() {
    count := 0
    timeoutCount := 20
    while (count < timeoutCount) {
        notComplete := true
        notComplete &= !SearchColorMatch(_MiniGameCompleteBanner1Pixel*)
        notComplete &= !SearchColorMatch(_MiniGameCompleteBanner2Pixel*)
        notComplete &= !SearchColorMatch(_MiniGameCompleteBanner3Pixel*)
        if (notComplete) {
            UpdateStatusBar("等待制作完成..." count "/" timeoutCount)
            Sleep(1000)
            count++
        } else {
            UpdateStatusBar("制作完成")
            break
        }
    }
    if (count >= timeoutCount) {
        throw TimeoutError("等待制作完成超时")
    }
    WaitUntilConversationSpace()
    UpdateStatusBar("检测到“道具制作完成”界面")
}

_MiniGameNewSkillsOCR := [
    1268, 347, 360, 160, "0x6B3B0D", 20]

_MiniGameIdentifyNewSkills() {
    result := UtilsOCRFromRegionEnhanced(_MiniGameNewSkillsOCR*)
    ; targetSkill := myGui["MiniGame.TargetSkill"].Text
    targetSkill := ""
    for index, line in result.Lines {
        newSkill := StrReplace(line.Text, " ")
        if (newSkill == targetSkill) {
            ShowSuccessMsgBox("识别到新技能：" newSkill)
        }
    }
}

_MiniGameTimerBackgroundPos := [1000, 54]  ; 顶部倒计时框背景位置
_MiniGameTimerBackgroundColor := "0x6B3B0D"  ; 顶部倒计时框背景颜色
_MiniGameTimerBackgroundPixel := [1000, 54, "0x6B3B0D"]  ; 顶部倒计时框背景像素
_MiniGameIconPosX := [890, 960, 1030]  ; 顶部制作图标位置X坐标（左，中，右）
_MiniGameIconPosY := 78  ; 顶部制作图标位置Y坐标
_MiniGameIconBackgroundColor := "0x8C4609"  ; 顶部制作图标背景颜色
_MiniGameMousePosX := [562, 962, 1362]  ; 鼠标中心位置X坐标（左，中，右）
_MiniGameMousePosY := [324, 504]  ; 鼠标中心位置Y坐标（上，下）
_MiniGameMouseLeftOffsetX := -20  ; 鼠标左键相对中心位置X偏移
_MiniGameMouseMiddleOffsetY := 20  ; 鼠标中键相对中心位置Y偏移
_MiniGameMouseUpOffsetY := -30  ; 鼠标中键上方的白色位置Y偏移
_MiniGameMouseTextOffsetX := 18  ; 鼠标上方文字相对中心位置X偏移
_MiniGameMouseTextOffsetY := -92  ; 鼠标上方文字相对中心位置Y偏移
_MiniGameActionMouseLeftColor := "0xFFC8C4"  ; 鼠标左键粉色
_MiniGameActionMouseMiddleColor := "0x311D09"  ; 鼠标中键黑色
_MiniGameActionMouseUpColor := "0xFFF8E4"  ; 鼠标中键上方的白色
_MiniGameActionMashColor := "0xFFB190"  ; “连按”红色
_MiniGameActionHoldColor := "0x96F485"  ; “长按”绿色
_MiniGameActionSpinColor := "0xFFF97C"  ; “转动”黄色

_MiniGameWaitForUI() {
    count := 0
    timeoutCount := 200
    while (count < timeoutCount) {
        uiType := _MiniGameRecognizeUIType()
        if (uiType != 0) {  ; 非0为有效UI类型
            return uiType
        }
        UpdateStatusBar("等待制作界面..." count "/" timeoutCount)
        Sleep(50)
        count++
    }
    throw TimeoutError("等待制作界面超时")
}

_MiniGameRecognizeUIType() {
    foundTimer := SearchColorMatch(
        _MiniGameTimerBackgroundPixel[1], _MiniGameTimerBackgroundPixel[2],
        _MiniGameTimerBackgroundPixel[3]
    )
    if foundTimer {
        iconEmpty := [false, false, false]
        loop (3) {
            iconEmpty[A_Index] := SearchColorMatch(
                _MiniGameIconPosX[A_Index], _MiniGameIconPosY,
                _MiniGameIconBackgroundColor, 1)
            MyToolTip(!iconEmpty[A_Index],
                _MiniGameIconPosX[A_Index] + 5, _MiniGameIconPosY + 5,
                10 + A_Index, DebugMiniGame)
        }
        icon101 := iconEmpty[1] && !iconEmpty[2] && iconEmpty[3]
        icon010 := !iconEmpty[1] && iconEmpty[2] && !iconEmpty[3]
        icon111 := iconEmpty[1] && iconEmpty[2] && iconEmpty[3]
        if (icon101 || icon010) {
            UpdateStatusBar("检测到制作界面")
            return 1
        }
        if (icon111) {
            UpdateStatusBar("图标栏全空")
            return 2
        }
    }
    return 0  ; 未检测到制作界面
}

/**
 * @description 识别工作台操作
 * @param {Integer} ix 工作台识别位置（1:左, 2:中, 3:右）
 * @param {Integer} iy 工作台识别高度（1:上, 2:下）
 * @returns {Integer} 操作类型（0:无, 1:单击, 2:连按, 3:长按, 4:转动）
 */
_MiniGameRecognizeAction(ix, iy) {
    x := _MiniGameMousePosX[ix]
    y := _MiniGameMousePosY[iy]
    toolTipX := x + 5
    toolTipY := y + 5
    toolTipID := 17 + ix
    foundMouseMiddle := SearchColorMatch(
        x, y + _MiniGameMouseMiddleOffsetY,
        _MiniGameActionMouseMiddleColor, [3, 20])  ; 鼠标有动画，纵向检测范围要大
    if (!foundMouseMiddle) {  ; 没有鼠标中键一定是无操作
        MyToolTip("无操作", toolTipX, toolTipY, toolTipID, DebugMiniGame)
        return 0
    }
    foundMouseLeft := SearchColorMatch(
        x + _MiniGameMouseLeftOffsetX, y,
        _MiniGameActionMouseLeftColor, [3, 20])  ; 鼠标有动画，纵向检测范围要大
    foundMouseUp := SearchColorMatch(
        x, y + _MiniGameMouseUpOffsetY,
        _MiniGameActionMouseUpColor)  ; 鼠标中键上方的白色位置
    foundMashColor := SearchColorMatch(
        x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY,
        _MiniGameActionMashColor)
    foundHoldColor := SearchColorMatch(
        x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY,
        _MiniGameActionHoldColor)
    foundSpinColor := SearchColorMatch(
        x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY,
        _MiniGameActionSpinColor)
    if (  ; 单击：有鼠标左键，有上方白色，无特殊颜色
        foundMouseLeft && foundMouseUp &&
        !foundMashColor && !foundHoldColor && !foundSpinColor
    ) {
        MyToolTip("单击", toolTipX, toolTipY, toolTipID, DebugMiniGame)
        return 1
    } else if (  ; 连按：有鼠标左键，无上方白色，特殊颜色只有连按
        foundMouseLeft && !foundMouseUp &&
        foundMashColor && !foundHoldColor && !foundSpinColor
    ) {
        MyToolTip("连按", toolTipX, toolTipY, toolTipID, DebugMiniGame)
        return 2
    } else if (  ; 长按：有鼠标左键，无上方白色，特殊颜色只有长按
        foundMouseLeft && !foundMouseUp &&
        !foundMashColor && foundHoldColor && !foundSpinColor
    ) {
        MyToolTip("长按", toolTipX, toolTipY, toolTipID, DebugMiniGame)
        return 3
    } else if (  ; 转动：无鼠标左键，有上方白色，特殊颜色只有转动
        !foundMouseLeft && foundMouseUp &&
        !foundMashColor && !foundHoldColor && foundSpinColor
    ) {
        MyToolTip("转动", toolTipX, toolTipY, toolTipID, DebugMiniGame)
        return 4
    } else {  ; 其他情况：未知操作，可能是鼠标中键误判
        text := (foundMouseLeft foundMouseUp
            foundMashColor foundHoldColor foundSpinColor)
        MyToolTip(text, toolTipX, toolTipY, toolTipID, DebugMiniGame)
        return 0  ; 未知操作
    }
}

/**
 * @description 识别工作台操作并移动到下一个工作台
 * @param {VarRef} station 当前工作台位置（1:左, 2:中, 3:右）
 * @returns {Integer} 操作类型（0:未知, 1:单击, 2:连按, 3:长按, 4:转动）
 */
_MiniGameGoNextStation(&station) {
    nextStation := 0  ; 初始化为未知
    nextAction := 0
    count := 0
    timeoutCount := 25
    while (count < timeoutCount) {
        loop 3 {  ; 识别左中右工作台操作
            ix := A_Index
            iy := (station == ix) ? 1 : 2  ; 如果是当前工作台需要识别上部操作
            action := _MiniGameRecognizeAction(ix, iy)
            if (action > 0) {
                nextStation := ix
                nextAction := action
                MyToolTip("next: " nextStation " " nextAction,
                    960, 800, 2, DebugMiniGame)
            }
        }
        if (nextStation > 0) {
            break  ; 如果识别到下一个工作台位置，跳出循环
        }
        Sleep(20)
        count++
    }
    if (nextAction == 0) {
        throw TimeoutError("工作台操作识别超时")
    }
    if (nextStation == station) {
        return nextAction  ; 当前工作台不需要移动，直接返回
    }
    move := nextStation - station
    key := move > 0 ? "d" : "a"
    loop (Abs(move)) {
        MySend(key)
        Sleep(50)  ; 移动间隔
    }
    station := nextStation
    return nextAction  ; 返回操作类型
}

_MiniGameDoAction(action) {
    mashCount := myGui["MiniGame.MashCount"].Value
    mashInterval := myGui["MiniGame.MashInterval"].Value
    holdDelay := myGui["MiniGame.HoldDelay"].Value
    spinCount := myGui["MiniGame.SpinCount"].Value
    spinInterval := myGui["MiniGame.spinInterval"].Value
    switch (action) {
        case 1:  ; 单击
            UpdateStatusBar("单击")
            _MiniGameActionTap()
        case 2:  ; 连按
            UpdateStatusBar("连按")
            _MiniGameActionMash(&station)
        case 3:  ; 长按
            UpdateStatusBar("长按")
            _MiniGameActionHold(&station)
        case 4:  ; 转动
            UpdateStatusBar("转动")
            _MiniGameActionSpin(&station)
        default:
            UpdateStatusBar("未知操作")
    }
}

_MiniGameActionTap() {
    MySend("Space")
}

_MiniGameActionMash(&station) {
    while (SearchColorMatch(
        _MiniGameMousePosX[station] + _MiniGameMouseTextOffsetX, _MiniGameMousePosY[1] + _MiniGameMouseTextOffsetY,
        _MiniGameActionMashColor)
    ) {
        loop 3 {
            MySend("Space")
            Sleep(50)
        }
    }
}

_MiniGameActionHold(&station) {
    MyPress("Space")
    while (SearchColorMatch(
        _MiniGameMousePosX[station] + _MiniGameMouseTextOffsetX, _MiniGameMousePosY[1] + _MiniGameMouseTextOffsetY,
        _MiniGameActionHoldColor)
    ) {
        Sleep(100)
    }
    MyRelease("Space")
}

_MiniGameActionSpin(&station) {
    posReset := [700, 300]
    posMove := [160, 90]
    speed := 100

    while (SearchColorMatch(
        _MiniGameMousePosX[station] + _MiniGameMouseTextOffsetX, _MiniGameMousePosY[1] + _MiniGameMouseTextOffsetY,
        _MiniGameActionSpinColor)
    ) {
        MouseMove(posReset[1], posReset[2], speed)
        loop 5 {
            MouseMove(posMove[1], posMove[2], speed, "R")
            Sleep(20)
        }
    }
}
