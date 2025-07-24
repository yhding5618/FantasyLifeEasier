#Requires AutoHotkey v2.0

DebugMiniGame := false
_ActionDebugID := 10

MiniGame_SingleActionBtn_Click() {
    OutputDebug("`nInfo.mini_game: 开始单步制作")
    retryLimit := 6
    benchPos := 0
    done := false

    ; 等待 UI
    UpdateStatusBar("等待制作界面...")
    _MiniGameWaitForUI()

    ; 有限次重试搜寻工作台位置
    UpdateStatusBar("制作中...")
    retryCount := 1
    benchPos := _MiniGameGetInitBenchPos()
    while (benchPos == 0 && retryCount <= retryLimit) {
        OutputDebug("Warning.mini_game.SingleActionBtn: 找不到工作台，重试 " retryCount "/" retryLimit)
        benchPos := _MiniGameGetInitBenchPos()
        retryCount++
        Sleep(100)
    }
    if (benchPos == 0) {
        throw TargetError("找不到工作台")
    }

    ; 有限次重试制作
    retryCount := 1
    done := _MiniGameDoNextAction(&benchPos)
    while (!done && retryCount <= retryLimit) {
        OutputDebug("Warning.mini_game.SingleActionBtn: 无法完成操作，重试 " retryCount "/" retryLimit)
        done := _MiniGameDoNextAction(&benchPos)
        retryCount++
        Sleep(100)
    }
    if (!done) {
        throw Error("无法完成操作")
    }
    OutputDebug("Info.mini_game: 完成单次操作")
    UpdateStatusBar("完成单次操作")
}

MiniGame_ContinuousActionBtn_Click() {
    OutputDebug("`nInfo.mini_game:开始连续制作")
    retryLimit := 6
    benchPos := 0

    UpdateStatusBar("等待制作界面...")
    while (uiType := _MiniGameWaitForUI() != 2) {
        UpdateStatusBar("制作中...")

        ; 有限次重试搜寻工作台位置
        UpdateStatusBar("制作中...")
        retryCount := 1
        while (benchPos == 0 && retryCount <= retryLimit) {
            benchPos := _MiniGameGetInitBenchPos()
        }
        while (benchPos == 0 && retryCount <= retryLimit) {
            OutputDebug("Warning.mini_game.ContinuousActionBtn: 找不到工作台，重试 " retryCount "/" retryLimit)
            benchPos := _MiniGameGetInitBenchPos()
            retryCount++
            Sleep(100)
        }
        if (benchPos == 0) {
            throw TargetError("找不到工作台")
        }

        ; 有限次重试制作
        retryCount := 1
        done := _MiniGameDoNextAction(&benchPos)
        while (!done && retryCount <= retryLimit) {
            OutputDebug("Warning.mini_game.ContinuousActionBtn: 无法完成操作，重试 " retryCount "/" retryLimit)
            done := _MiniGameDoNextAction(&benchPos)
            retryCount++
            Sleep(100)
        }
        if (!done) {
            throw Error("无法完成操作")
        }
    }
    UpdateStatusBar("等待制作完成...")
    _MiniGameWaitForComplete()
    OutputDebug("Info.mini_game: 制作完成")
    UpdateStatusBar("制作完成")
    ; _MiniGameIdentifyNewSkills()
}

MiniGame_CheckSkillBtn_Click() {
    UpdateStatusBar("检查技能")
    _MiniGameIdentifyNewSkills()
}

; 重新制作后的“技能重置”界面下方空格位置
_MiniGameRemakeSpacePos := [924, 1015]

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
 * @description 已知当前位置，执行下一步操作
 * @param {VarRef} benchPos 当前工作台位置（1:左, 2:中, 3:右）
 * @returns {Boolean} `true`: 操作成功, `false`: 无有效操作或无法识别操作类型
 */
_MiniGameDoNextAction(&benchPos) {
    MyToolTip("benchPos: " benchPos, 860, 810, 1, DebugMiniGame)
    ; 获得下一个工作台操作位置
    nextBenchPos := _MiniGameGetNextBenchPos(benchPos)
    OutputDebug("Warning.mini_game.DoNextAction: 下一个工作台位置：" nextBenchPos)
    MyToolTip("nextBenchPos: " nextBenchPos, 860, 840, 2, DebugMiniGame)
    if (nextBenchPos == 0) {
        return false
    }

    ; 移动到下一个工作台位置
    _MiniGameMoveToBenchPos(&benchPos, nextBenchPos)

    ; 识别操作类型
    action := _MiniGameGetActionType(benchPos, 1)
    OutputDebug("Info.mini_game.DoNextAction: 识别到操作类型：" action)
    MyToolTip("action: " action, 860, 870, 3, DebugMiniGame)
    if (action == 0) {
        return false  ; 无法识别操作类型
    }
    ; 完成操作
    _MiniGameDoAction(action, benchPos)
    return true
}

; 制作完成横幅1像素
_MiniGameCompleteBanner1Pixel := [960, 160, "0xE88536"]
; 制作完成横幅2像素
_MiniGameCompleteBanner2Pixel := [960, 170, "0xFFE7BC"]
; 制作完成横幅3像素
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
            OutputDebug("Info.mini_game.WaitForComplete: 等待制作完成 " count "/" timeoutCount)
            Sleep(1000)
            count++
        } else {
            break
        }
    }
    if (count >= timeoutCount) {
        throw TimeoutError("等待制作完成超时")
    }
    WaitUntilConversationSpace()
    OutputDebug("Info.mini_game.WaitForComplete: 检测到“道具制作完成”界面")
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

; 顶部倒计时框背景位置
_MiniGameTimerBackgroundPos := [1000, 54]
; 顶部倒计时框背景颜色
_MiniGameTimerBackgroundColor := "0x6B3B0D"
; 顶部倒计时框背景像素
_MiniGameTimerBackgroundPixel := [1000, 54, "0x6B3B0D"]
; 顶部制作图标位置X坐标（左，中，右）
_MiniGameIconPosX := [890, 960, 1030]
; 顶部制作图标位置Y坐标
_MiniGameIconPosY := 78
; 顶部制作图标背景颜色
_MiniGameIconBackgroundColor := "0x8C4609"
; 鼠标中心位置X坐标（左，中，右）
_MiniGameMousePosX := [562, 962, 1362]
; 鼠标中心位置Y坐标（上，下）
_MiniGameMousePosY := [324, 504]
; 鼠标左键相对中心位置X偏移
_MiniGameMouseLeftOffsetX := -20
; 鼠标中键相对中心位置Y偏移
_MiniGameMouseMiddleOffsetY := 20
; 鼠标中键上方的白色位置Y偏移
_MiniGameMouseUpOffsetY := -30
; 鼠标上方文字相对中心位置X偏移
_MiniGameMouseTextOffsetX := 18
; 鼠标上方文字相对中心位置Y偏移
_MiniGameMouseTextOffsetY := -92
; 鼠标左键粉色
_MiniGameActionMouseLeftColor := "0xFFC8C4"
; 鼠标中键黑色
_MiniGameActionMouseMiddleColor := "0x311D09"
; 鼠标中键上方的白色
_MiniGameActionMouseUpColor := "0xFFF8E4"
; “连按”红色
_MiniGameActionMashColor := "0xFFB190"
; “长按”绿色
_MiniGameActionHoldColor := "0x96F485"
; “转动”黄色
_MiniGameActionSpinColor := "0xFFF97C"

/**
 * @description 等待制作界面出现
 * @returns {Integer} 制作界面类型（1: 有图标, 2: 图标栏全空）
 * @throws TimeoutError 如果等待超时
 */
_MiniGameWaitForUI() {
    count := 0
    timeoutCount := 15
    while (count < timeoutCount) {
        loop 20 {
            uiType := _MiniGameGetUIType()
            if (uiType != 0) {  ; 非0为有效UI类型
                OutputDebug("Info.mini_game.WaitForUI: 检测到制作界面 " uiType)
                return uiType
            }
            Sleep(50)
        }
        count++
    }
    throw TimeoutError("等待制作界面超时")
}

/**
 * @description 检测 UI 类型
 * @returns {Integer} UI 类型（0: 非制作界面, 1: 制作界面, 2: 空界面）
 */
_MiniGameGetUIType() {
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
            return 1
        }
        if (icon111) {
            return 2
        }
    }
    return 0  ; 未检测到制作界面
}

/**
 * @description 检查指定工作台是否有操作
 * @param {Integer} targetPos 目标工作台位置（1:左, 2:中, 3:右）
 * @param {Integer} targetHeight 目标操作高度（1:上, 2:下）
 * @returns {Boolean} 是否有操作
 */
_MiniGameIsHaveAction(targetPos, targetHeight) {
    x := _MiniGameMousePosX[targetPos]
    y := _MiniGameMousePosY[targetHeight]
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
    if (foundMouseLeft || foundMouseUp) {
        return true  ; 有鼠标左键或上方白色位置
    }
    return false  ; 可能是鼠标中键误判
}

/**
 * @description 识别指定工作台的操作类型
 * @param {Integer} targetPos 目标工作台位置（1:左, 2:中, 3:右）
 * @param {Integer} targetHeight 目标操作高度（1:上, 2:下）
 * @returns {Integer} 操作类型（0:未知, 1:单击, 2:连按, 3:长按, 4:转动）
 */
_MiniGameGetActionType(targetPos, targetHeight) {

    foundMashColor := _MiniGameIsActionCorrect(targetPos, targetHeight, 2)
    foundHoldColor := _MiniGameIsActionCorrect(targetPos, targetHeight, 3)
    foundSpinColor := _MiniGameIsActionCorrect(targetPos, targetHeight, 4)

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
    toolTipX := 5 + _MiniGameMousePosX[targetPos] + _MiniGameMouseTextOffsetX
    toolTipY := 5 + _MiniGameMousePosY[targetHeight] + _MiniGameMouseTextOffsetY
    text := (actionType != 0) ?
        "操作" actionType :
        "未知" (foundMashColor foundHoldColor foundSpinColor)
    MyToolTip(text, toolTipX, toolTipY, 10, DebugMiniGame)
    return actionType
}

/**
 * @description 验证指定工作台的操作类型
 * @param {Integer} targetPos 目标工作台位置（1:左, 2:中, 3:右）
 * @param {Integer} targetHeight 目标操作高度（1:上, 2:下）
 * @param {Integer} action 操作类型（2:连按, 3:长按, 4:转动）
 * @returns {Boolean} 是否匹配操作类型
 */
_MiniGameIsActionCorrect(targetPos, targetHeight, action) {
    ; OutputDebug("Debug.mini_gameIsActionCorrect: 验证 [" targetPos "," targetHeight "] 操作类型是否为" action)
    x := _MiniGameMousePosX[targetPos] + _MiniGameMouseTextOffsetX
    y := _MiniGameMousePosY[targetHeight] + _MiniGameMouseTextOffsetY
    switch (action) {
        case 1:  ; 单击
            throw ValueError("非法操作类型：单击")
        case 2:  ; 连按
            textColor := _MiniGameActionMashColor
        case 3:  ; 长按
            textColor := _MiniGameActionHoldColor
        case 4:  ; 转动
            textColor := _MiniGameActionSpinColor
        default:  ; 单击或未知操作
            throw Error("无法验证操作类型")
    }
    actionMatch := SearchColorMatch(x, y, textColor)
    ; OutputDebug("Debug.mini_gameIsActionCorrect: " actionMatch)
    return actionMatch
}

/**
 * @description 指定方向移动
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
 * @description 移动到指定工作台位置
 * @param {VarRef} benchPos 当前工作台位置（1:左, 2:中, 3:右）
 * @param {Integer} targetPos 目标工作台位置（1:左, 2:中, 3:右）
 */
_MiniGameMoveToBenchPos(&benchPos, targetPos) {
    if (benchPos == targetPos) {  ; 不需要移动
        return
    }
    move := targetPos - benchPos
    _MiniGameMove(1 + (move > 0), Abs(move))
    benchPos := targetPos  ; 更新当前工作台位置
}

/**
 * @description 无条件破坏性获得工作台位置（初始化）
 * @returns 工作台位置（0:未知, 1:左, 2:中, 3:右）
 */
_MiniGameGetInitBenchPos() {
    ; 确定操作所在位置
    loop 3 {
        ix := A_Index
        loop 2 {
            iy := A_Index
            foundAction := _MiniGameIsHaveAction(ix, iy)
            if (foundAction) {
                break
            }
        }
        if (foundAction) {
            break
        }
    }
    if (!foundAction) {  ; 没有找到任何操作
        return 0
    }
    if (iy == 1) {  ; 操作在上部
        return ix  ; ix 即为当前工作台位置
    }
    switch (ix) {
        case 1:  ; 操作在左下
            _MiniGameMove(1, 1)  ; 左移一次
        case 2:  ; 操作在中下
            _MiniGameMove(1, 1)  ; 左移一次
        case 3:  ; 操作在右下
            _MiniGameMove(2, 1)  ; 右移一次
    }
    ; 移动后检测操作是否移到上部
    foundAction := _MiniGameIsHaveAction(ix, 1)
    if (foundAction) {
        return ix  ; ix即为当前工作台位置
    }
    ; 如果操作仍在下部，则在剩余位置
    switch (ix) {
        case 1:  ; 初始在左下，左移后仍不正确
            return 2
        case 2:  ; 初始在中间，左移后仍不正确
            return 1
        case 3:  ; 初始在右边，右移后仍不正确
            return 2
    }
    return 0  ; 非正常情况
}

/**
 * @description 当位置为已知时，找到下一个工作台位置
 * @param {Integer} benchPos 当前工作台位置（1:左, 2:中, 3:右）
 * @returns {Integer} 下一个工作台位置（0:未知, 1:左, 2:中, 3:右）
 */
_MiniGameGetNextBenchPos(benchPos) {
    loop 3 {  ; 识别左中右工作台操作
        ix := A_Index
        iy := (benchPos == ix) ? 1 : 2  ; 如果是当前工作台需要识别上部操作
        foundAction := _MiniGameIsHaveAction(ix, iy)
        if foundAction {
            return ix
        }
    }
    return 0  ; 没有找到任何工作台操作
}

/**
 * @description 已知位置和操作，执行一次操作
 * @param {Integer} action 操作类型（1:单击, 2:连按, 3:长按, 4:转动）
 * @param {Integer} benchPos 当前工作台位置（1:左, 2:中, 3:右）
 */
_MiniGameDoAction(action, benchPos) {
    switch (action) {
        case 1:  ; 单击
            _MiniGameActionTap()
        case 2:  ; 连按
            _MiniGameActionMash(benchPos)
        case 3:  ; 长按
            _MiniGameActionHold(benchPos)
        case 4:  ; 转动
            _MiniGameActionSpin(benchPos)
        default:
            throw ValueError("尝试执行非法操作")
    }
}

_MiniGameActionTap() {
    MySend("Space")
}

_MiniGameActionMash(benchPos) {
    while (_MiniGameIsActionCorrect(benchPos, 1, 2)) {
        loop 3 {
            MySend("Space")
            Sleep(20)
        }
    }
}

_MiniGameActionHold(benchPos) {
    MyPress("Space")
    while (_MiniGameIsActionCorrect(benchPos, 1, 3)) {
        Sleep(300)
    }
    MyRelease("Space")
}

_MiniGameActionSpin(benchPos) {
    MouseGetPos(&posX, &posY)
    posReset := [700, 300]
    posMove := [160, 90]
    speed := 100
    while (_MiniGameIsActionCorrect(benchPos, 1, 4)) {
        MouseMove(posReset[1], posReset[2], speed)
        loop 5 {
            MouseMove(posMove[1], posMove[2], speed, "R")
            Sleep(20)
        }
    }
    MouseMove(posX, posY, 0)  ; 恢复鼠标位置
}
