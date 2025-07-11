#Requires AutoHotkey v2.0

DebugMiniGame := true
_ActionDebugID := 10

MiniGame_SingleActionBtn_Click() {
    benchPos := 0
    done := _MiniGameDoNextAction(&benchPos)
    if (!done) {
        throw ValueError("无法完成单次操作")
    }
}

MiniGame_ContinuousActionBtn_Click() {
    benchPos := 0
    while (uiType := _MiniGameWaitForUI() != 2) {
        done := _MiniGameDoNextAction(&benchPos)
        if (!done) {
            benchPos := 0  ; 重置工作台位置
        }
    }
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
            UtilsGetOptionListPosition(1, 1, 3),
            UtilsOptionListGlowColor, "新页面加载", , , , 100)
        if (match == 1) {
            ; 重新制作流程
            optionText := "继续重制"
            ; 等待手动技能重置结束，最多等待3分钟
            PlaySuccessSound()
            UtilsWaitUntilOptionListSelected(1, 1, 3,
                "手动技能重置", , , 100, 1800)
        } else {
            ; 普通制作流程，无需等待
            optionText := "再次制作"
        }
        if (count == maxCount) {
            UpdateStatusBar("循环完毕，已完成制作 " count " 次")
            break
        }
        Sleep(500)  ; 等待页面稳定，防止s键被吞
        MySend("s")  ; 下移光标
        ; 如果材料不足选项不会变绿
        UtilsWaitUntilOptionListSelected(1, 2, 3, "选中" optionText)
        MySend("Space")  ; 确认再次制作/继续重制
    }
}

/**
 * @description 执行下一步操作
 * @param {VarRef} benchPos 当前工作台位置（0:未知, 1:左, 2:中, 3:右）
 * @returns {Boolean} `true`表示成功执行操作，`false`表示没有有效操作或无法识别操作类型
 */
_MiniGameDoNextAction(&benchPos) {
    ; 找到下一个工作台位置
    MyToolTip("benchPos: " benchPos, 860, 810, 1, DebugMiniGame)
    if benchPos == 0 {  ; 当前工作台位置未知
        nextBenchPos := _MiniGameInitBenchPos(&benchPos)
    } else {
        nextBenchPos := _MiniGameFindNextBenchPos(&benchPos)
    }
    MyToolTip("nextBenchPos: " nextBenchPos, 860, 840, 2, DebugMiniGame)
    if (benchPos == 0 || nextBenchPos == 0) {
        UpdateStatusBar("未找到有效的工作台操作")
        return false  ; 没有有效操作，可能在动作切换的间隙
    }
    ; 移动到下一个工作台位置
    _MiniGameMoveToBenchPos(&benchPos, nextBenchPos)
    ; 识别上部操作具体类型
    action := _MiniGameRecognizeActionType(benchPos, 1)
    MyToolTip("action: " action, 860, 870, 3, DebugMiniGame)
    if (action == 0) {
        UpdateStatusBar("无法识别当前工作台" benchPos "的操作类型")
        return false  ; 无法识别操作类型
    }
    ; 完成操作
    _MiniGameDoAction(action, benchPos)
    return true
}

; 制作完成横幅像素
_MiniGameCompleteBanner1Pixel := [960, 160, "0xE88536"]
_MiniGameCompleteBanner2Pixel := [960, 170, "0xFFE7BC"]
_MiniGameCompleteBanner3Pixel := [960, 180, "0xA94F0D"]

/**
 * @description 等待“制作完成！”界面出现
 * @throws TimeoutError 如果等待超时
 */
_MiniGameWaitForComplete() {
    count := 0
    timeoutCount := 30
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

/**
 * @description 等待制作界面出现
 * @returns {Integer} UI类型（1:有图标的制作界面, 2:图标栏全空的制作界面）
 * @throws TimeoutError 如果等待超时
 */
_MiniGameWaitForUI() {
    count := 0
    timeoutCount := 300
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
 * @description 检查工作台是否有操作
 * @param {Integer} ix 工作台识别位置（1:左, 2:中, 3:右）
 * @param {Integer} iy 工作台识别高度（1:上, 2:下）
 * @returns {Boolean} 是否有操作
 */
_MiniGameBenchPosHasAction(ix, iy) {
    x := _MiniGameMousePosX[ix]
    y := _MiniGameMousePosY[iy]
    foundMouseMiddle := SearchColorMatch(
        x, y + _MiniGameMouseMiddleOffsetY,
        _MiniGameActionMouseMiddleColor, [3, 20])  ; 鼠标可能有动画，纵向检测范围要大
    if (!foundMouseMiddle) {
        return false  ; 没有鼠标中键一定是无操作
    }
    foundMouseLeft := SearchColorMatch(
        x + _MiniGameMouseLeftOffsetX, y,
        _MiniGameActionMouseLeftColor, [3, 20])  ; 鼠标可能有动画，纵向检测范围要大
    foundMouseUp := SearchColorMatch(
        x, y + _MiniGameMouseUpOffsetY,
        _MiniGameActionMouseUpColor)  ; 鼠标中键上方的白色位置
    ; 单击：有鼠标左键，有上方白色位置
    foundMouseLU := foundMouseLeft && foundMouseUp
    ; 连按/长按：有鼠标左键，无上方白色位置
    foundMouseL := foundMouseLeft && !foundMouseUp
    ; 转动：无鼠标左键，有上方白色位置
    foundMouseU := !foundMouseLeft && foundMouseUp
    if (foundMouseLU || foundMouseL || foundMouseU) {
        return true  ; 有鼠标左键或上方白色位置
    }
    return false  ; 可能是鼠标中键误判
}

/**
 * @description 识别工作台操作类型
 * @param {Integer} ix 工作台识别位置（1:左, 2:中, 3:右）
 * @param {Integer} iy 工作台识别高度（1:上, 2:下）
 * @returns {Integer} 操作类型（0:未知, 1:单击, 2:连按, 3:长按, 4:转动）
 */
_MiniGameRecognizeActionType(ix, iy) {
    foundMashColor := _MiniGameVerifyActionType(ix, iy, 2)
    foundHoldColor := _MiniGameVerifyActionType(ix, iy, 3)
    foundSpinColor := _MiniGameVerifyActionType(ix, iy, 4)
    if (!foundMashColor && !foundHoldColor && !foundSpinColor) {
        actionType := 1  ; 单击：无特殊颜色
    } else if (foundMashColor && !foundHoldColor && !foundSpinColor) {
        actionType := 2  ; 连按：特殊颜色只有连按
    } else if (!foundMashColor && foundHoldColor && !foundSpinColor) {
        actionType := 3  ; 长按：特殊颜色只有长按
    } else if (!foundMashColor && !foundHoldColor && foundSpinColor) {
        actionType := 4  ; 转动：特殊颜色只有转动
    } else {
        actionType := 0  ; 未知：可能是鼠标图标误判
    }
    toolTipX := 5 + _MiniGameMousePosX[ix] + _MiniGameMouseTextOffsetX
    toolTipY := 5 + _MiniGameMousePosY[iy] + _MiniGameMouseTextOffsetY
    text := (actionType != 0) ?
        "操作" actionType :
        "未知" (foundMashColor foundHoldColor foundSpinColor)
    MyToolTip(text, toolTipX, toolTipY, 10, DebugMiniGame)
    return actionType
}

/**
 * @description 验证工作台操作类型
 * @param {Integer} ix 工作台识别位置（1:左, 2:中, 3:右）
 * @param {Integer} iy 工作台识别高度（1:上, 2:下）
 * @param {Integer} action 操作类型（2:连按, 3:长按, 4:转动）
 * @returns {Boolean} 是否匹配操作类型
 */
_MiniGameVerifyActionType(ix, iy, action) {
    x := _MiniGameMousePosX[ix] + _MiniGameMouseTextOffsetX
    y := _MiniGameMousePosY[iy] + _MiniGameMouseTextOffsetY
    switch (action) {
        case 2:  ; 连按
            textColor := _MiniGameActionMashColor
        case 3:  ; 长按
            textColor := _MiniGameActionHoldColor
        case 4:  ; 转动
            textColor := _MiniGameActionSpinColor
        default:  ; 单击或未知操作
            throw ValueError("无法验证操作类型")
    }
    actionMatch := SearchColorMatch(x, y, textColor)
    return actionMatch
}

/**
 * @description 移动到指定方向
 * @param {Integer} direction 方向（1:左, 2:右）
 * @param {Integer} count 移动次数
 */
_MiniGameMove(direction, count) {
    key := (direction == 1) ? "a" : "d"  ; 左为"a"，右为"d"
    loop count {
        MySend(key)
        Sleep(75)  ; 移动间隔
    }
}

/**
 * @description 移动到下一个工作台位置
 * @param {VarRef} benchPos 当前工作台位置（1:左, 2:中, 3:右）
 * @param {Integer} nextBenchPos 下一个工作台位置（1:左, 2:中, 3:右）
 */
_MiniGameMoveToBenchPos(&benchPos, nextBenchPos) {
    if (benchPos == nextBenchPos) {
        return  ; 不需要移动
    }
    move := nextBenchPos - benchPos
    _MiniGameMove(1 + (move > 0), Abs(move))  ; 左移或右移
    benchPos := nextBenchPos  ; 更新当前工作台位置
}

/**
 * @description 初始化当前工作台位置并找到下一个工作台位置（当前位置为未知）
 * @param {VarRef} benchPos 当前工作台位置（0:未知, 1:左, 2:中, 3:右）
 * @returns {Integer} 下一个工作台位置（0:未知, 1:左, 2:中, 3:右）
 */
_MiniGameInitBenchPos(&benchPos) {
    loop 3 {
        ix := A_Index
        loop 2 {
            iy := A_Index
            foundAction := _MiniGameBenchPosHasAction(ix, iy)
            if (foundAction) {
                break
            }
        }
        if (foundAction) {
            break
        }
    }
    if !foundAction {
        return 0  ; 没有找到任何工作台操作
    }
    if (iy == 1) {  ; 操作在上部
        benchPos := ix  ; ix即为当前工作台位置
        return ix  ; 提前返回
    }
    switch (ix) {
        case 1:  ; 操作在左
            _MiniGameMove(1, 1)  ; 左移一次
        case 2:  ; 操作在中
            _MiniGameMove(1, 1)  ; 左移一次
        case 3:  ; 操作在右
            _MiniGameMove(2, 1)  ; 右移一次
    }
    ; 移动后检测操作是否移到上部
    foundAction := _MiniGameBenchPosHasAction(ix, 1)
    if foundAction {
        benchPos := ix  ; ix即为当前工作台位置
        return ix  ; 提前返回
    }
    ; 如果操作仍在下部，则需要再次移动
    switch (ix) {
        case 1:  ; 操作在左
            _MiniGameMove(1, 1)  ; 再左移一次
        case 2:  ; 操作在中
            _MiniGameMove(2, 1)  ; 右移一次（反向）
        case 3:  ; 操作在右
            _MiniGameMove(2, 1)  ; 再右移一次
    }
    benchPos := ix
    return ix
}

/**
 * @description 找到下一个工作台位置（当前位置为已知）
 * @param {VarRef} benchPos 当前工作台位置（0:未知, 1:左, 2:中, 3:右）
 * @returns {Integer} 下一个工作台位置（0:未知, 1:左, 2:中, 3:右）
 */
_MiniGameFindNextBenchPos(&benchPos) {
    loop 3 {  ; 识别左中右工作台操作
        ix := A_Index
        iy := (benchPos == ix) ? 1 : 2  ; 如果是当前工作台需要识别上部操作
        foundAction := _MiniGameBenchPosHasAction(ix, iy)
        if foundAction {
            return ix
        }
    }
    return 0  ; 没有找到任何工作台操作
}

_MiniGameDoAction(action, benchPos) {
    switch (action) {
        case 1:  ; 单击
            UpdateStatusBar("单击")
            _MiniGameActionTap()
        case 2:  ; 连按
            UpdateStatusBar("连按")
            _MiniGameActionMash(benchPos)
        case 3:  ; 长按
            UpdateStatusBar("长按")
            _MiniGameActionHold(benchPos)
        case 4:  ; 转动
            UpdateStatusBar("转动")
            _MiniGameActionSpin(benchPos)
        default:
            UpdateStatusBar("未知操作")
    }
}

_MiniGameActionTap() {
    MySend("Space")
}

_MiniGameActionMash(benchPos) {
    while (_MiniGameVerifyActionType(benchPos, 1, 2)) {
        loop 3 {
            MySend("Space")
            Sleep(75)
        }
    }
}

_MiniGameActionHold(benchPos) {
    MyPress("Space")
    while (_MiniGameVerifyActionType(benchPos, 1, 3)) {
        Sleep(100)
    }
    MyRelease("Space")
}

_MiniGameActionSpin(benchPos) {
    MouseGetPos(&posX, &posY)
    posReset := [700, 300]
    posMove := [160, 90]
    speed := 100
    while (_MiniGameVerifyActionType(benchPos, 1, 4)) {
        MouseMove(posReset[1], posReset[2], speed)
        loop 5 {
            MouseMove(posMove[1], posMove[2], speed, "R")
            Sleep(20)
        }
    }
    MouseMove(posX, posY, 0)  ; 恢复鼠标位置
}
