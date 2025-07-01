#Requires AutoHotkey v2.0

DebugMiniGame := false
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
}

/**
 * @description 执行下一步操作
 * @param {VarRef} station 当前工作台位置（1:左, 2:中, 3:右）
 * @param {VarRef} done 是否完成操作
 */
_MiniGameDoNextAction(&station, &done) {
    uiType := _MiniGameWaitForUI()
    MyToolTip("uiType: " uiType, 0, 0, 1, DebugMiniGame)
    MyToolTip("station: " station, 960, 800, 2, DebugMiniGame)
    if (uiType == 2) {
        done := true  ; 图标栏为空，直接返回
        return
    }
    action := _MiniGameGoNextStation(&station)
    _MiniGameDoAction(action)
}

_MiniGameTimerBackgroundPos := [1000, 54]  ; 顶部倒计时框背景位置
_MiniGameTimerBackgroundColor := "0x6B3B0D"  ; 顶部倒计时框背景颜色
_MiniGameTimerBackgroundPixel := [1000, 54, "0x6B3B0D"]  ; 顶部倒计时框背景像素
_MiniGameIconPosX := [890, 960, 1030]  ; 顶部制作图标位置X坐标（左，中，右）
_MiniGameIconPosY := 78  ; 顶部制作图标位置Y坐标
_MiniGameIconBackgroundColor := "0x8C4609"  ; 顶部制作图标背景颜色
_MiniGameMousePosX := [562, 962, 1362]  ; 鼠标图标滚轮位置X坐标（左，中，右）
_MiniGameMousePosY := [324, 504]  ; 鼠标图标滚轮位置Y坐标（上，下）
_MiniGameMouseLeftOffsetX := -20  ; 鼠标左键相对滚轮位置X偏移
_MiniGameMouseTextOffsetX := 18  ; 鼠标上方文字相对滚轮位置X偏移
_MiniGameMouseTextOffsetY := -92  ; 鼠标上方文字相对滚轮位置Y偏移
_MiniGameActionTapColor := "0xFFC8C4"  ; 鼠标左键粉色
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
                _MiniGameIconBackgroundColor
            )
            MyToolTip(iconEmpty[A_Index],
                _MiniGameIconPosX[A_Index] + 5, _MiniGameIconPosY + 5,
                10 + A_Index, DebugMiniGame
            )
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
 * @returns {Integer} 操作类型（0:未知, 1:单击, 2:连按, 3:长按, 4:转动）
 */
_MiniGameRecognizeAction(ix, iy) {
    x := _MiniGameMousePosX[ix]
    y := _MiniGameMousePosY[iy]
    foundTap := SearchColorMatch(
        x + _MiniGameMouseLeftOffsetX, y,
        _MiniGameActionTapColor)
    foundMash := SearchColorMatch(
        x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY,
        _MiniGameActionMashColor)
    foundHold := SearchColorMatch(
        x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY,
        _MiniGameActionHoldColor)
    foundSpin := SearchColorMatch(
        x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY,
        _MiniGameActionSpinColor)
    foundSpecial := foundMash || foundHold || foundSpin
    if (foundTap && !foundSpecial) {
        MyToolTip("单击", x + 5, _MiniGameMousePosY[1] + 5,
            17 + ix, DebugMiniGame)
        return 1  ; 单击
    } else if (foundMash) {
        MyToolTip("连按", x + 5, _MiniGameMousePosY[1] + 5,
            17 + ix, DebugMiniGame)
        return 2  ; 连按
    } else if (foundHold) {
        MyToolTip("长按", x + 5, _MiniGameMousePosY[1] + 5,
            17 + ix, DebugMiniGame)
        return 3  ; 长按
    } else if (foundSpin) {
        MyToolTip("转动", x + 5, _MiniGameMousePosY[1] + 5,
            17 + ix, DebugMiniGame)
        return 4  ; 转动
    } else {
        MyToolTip("未知", x + 5, _MiniGameMousePosY[1] + 5,
            17 + ix, DebugMiniGame)
        return 0  ; 未知
    }
}

/**
 * @description 识别工作台操作并移动到下一个工作台
 * @param {VarRef} station 当前工作台位置（1:左, 2:中, 3:右）
 * @returns {Integer} 操作类型（0:未知, 1:单击, 2:连按, 3:长按, 4:转动）
 */
_MiniGameGoNextStation(&station) {
    nextStation := 0  ; 初始化为未知
    count := 0
    timeoutCount := 25
    while (count < timeoutCount) {
        loop 3 {  ; 识别左中右工作台操作
            ix := A_Index
            iy := (station == ix) ? 1 : 2  ; 如果是当前工作台需要识别上部操作
            action := _MiniGameRecognizeAction(ix, iy)
            if (action > 0) {
                nextStation := ix
                break
            }
        }
        if (action > 0) {
            break  ; 如果识别到操作，跳出循环
        }
        Sleep(20)
        count++
    }
    if (action == 0) {
        throw TimeoutError("工作台操作识别超时")
    }
    if (nextStation == station) {
        return action  ; 当前工作台不需要移动，直接返回
    }
    move := nextStation - station
    UpdateStatusBar("移动到工作台" nextStation)
    key := move > 0 ? "d" : "a"
    loop (Abs(move)) {
        MySend(key)
        Sleep(50)  ; 移动间隔
    }
    station := nextStation
    return action  ; 返回操作类型
}

_MiniGameActionTap() {
    MySend("Space")
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
            _MiniGameActionMash(mashCount, mashInterval)
        case 3:  ; 长按
            UpdateStatusBar("长按")
            _MiniGameActionHold(holdDelay)
        case 4:  ; 转动
            UpdateStatusBar("转动")
            _MiniGameActionSpin(spinCount, spinInterval)
        default:
            UpdateStatusBar("未知操作")
    }
}

_MiniGameActionMash(count, interval) {
    loop count {
        MySend("Space")
        Sleep(interval)
    }
}

_MiniGameActionHold(delay) {
    MyPress("Space")
    Sleep(delay)
    MyRelease("Space")
}

_MiniGameActionSpin(count, interval, length := 150, sideNum := 12, speed := 100,
    delay := 1) {
    Pi := 3.141592653589793
    MouseMove(960, 100, speed)  ; 鼠标复位
    loop count {
        loop sideNum {
            side := A_Index
            radian := (side - 1) / sideNum * 2 * Pi
            x := Round(Cos(radian) * length)
            y := Round(Sin(radian) * length)
            MouseMove(x, y, speed, "R")  ; 相对移动
            Sleep(delay)
        }
        Sleep(interval)
    }
}
