#Requires AutoHotkey v2.0

DebugMiniGame := true
_ActionDebugID := 10

MiniGameSingleActionBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    ret := _MiniGameDoNextAction()
    done := ret[1]
    station := ret[2]
    if (station == 0) {
        PlayFailureSound()
        return
    }
    AppendStatusBar("，结束于工作台" station)
    PlaySuccessSound()
}

MiniGameContinuousActionBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    UpdateStatusBar("执行连续操作")
    station := 2
    while (true) {
        ret := _MiniGameDoNextAction(station)
        done := ret[1]
        station := ret[2]
        if (done) {
            break
        }
    }
    if (station == 0) {
        PlayFailureSound()
        return
    }
    AppendStatusBar("，结束于工作台" station)
    PlaySuccessSound()
}

_MiniGameDoNextAction(station := 2) {
    uiType := _MiniGameWaitForUI()
    MyToolTip("uiType: " uiType, 0, 0, 1, DebugMiniGame)
    if (uiType == 0) {
        return [true, 0]  ; 错误或超时
    }
    else if (uiType == 2) {
        return [true, station]  ; 图标栏为空，正常结束
    }
    MyToolTip("station: " station, 960, 800, 2, DebugMiniGame)
    ret := _MiniGameGoNextStation(station)
    station := ret[1]
    action := ret[2]
    if (station == 0 || action == 0) {
        MyToolTip("here: " station action, 960, 900, 3, DebugMiniGame)
        return [true, 0]  ; 错误或超时
    }
    _MiniGameDoAction(action)
    return [false, station]  ; 继续执行
}

_MiniGameTimerBackgroundPos := [1000, 54]  ; 顶部倒计时框背景位置
_MiniGameTimerBackgroundColor := "0x6B3B0D"  ; 顶部倒计时框背景颜色
_MiniGameIconPosX := [890, 960, 1030]  ; 顶部制作图标位置X坐标（左，中，右）
_MiniGameIconPosY := 85  ; 顶部制作图标位置Y坐标
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
    counter := 0
    while (true) {
        uiType := _MiniGameRecognizeUIType()
        if (uiType != 0) {
            return uiType
        }
        UpdateStatusBar("等待制作界面..." counter)
        counter++
        if (counter >= 200) {
            UpdateStatusBar("等待制作界面超时")
            return uiType
        }
        Sleep(50)
    }
}

_MiniGameRecognizeUIType() {
    color := PixelGetColor(_MiniGameTimerBackgroundPos[1], _MiniGameTimerBackgroundPos[2])
    foundTimer := (color == _MiniGameTimerBackgroundColor)
    MyToolTip("Timer" foundTimer, _MiniGameTimerBackgroundPos[1], _MiniGameTimerBackgroundPos[2], 8, DebugMiniGame)
    if (foundTimer) {
        allIconEmpty := True
        anyIconFound := False
        loop (3) {
            color := PixelGetColor(_MiniGameIconPosX[A_Index], _MiniGameIconPosY)
            iconEmpty := (color == _MiniGameIconBackgroundColor)
            allIconEmpty := allIconEmpty && iconEmpty
            anyIconFound := anyIconFound || !iconEmpty
            MyToolTip(iconEmpty, _MiniGameIconPosX[A_Index] + 10, _MiniGameIconPosY + 10, 10 + A_Index, DebugMiniGame)
        }
        if anyIconFound && !allIconEmpty {
            MyToolTip("图标栏非空", 960, 800, 14, DebugMiniGame)
            UpdateStatusBar("检测到制作界面")
            return 1
        }
        if allIconEmpty {
            MyToolTip("图标栏为空", 960, 800, 14, DebugMiniGame)
            UpdateStatusBar("图标栏为空")
            return 2
        }
    }
    return 0
}

_MiniGameRecognizeAction(ix, iy) {
    x := _MiniGameMousePosX[ix]
    y := _MiniGameMousePosY[iy]
    leftColor := PixelGetColor(x + _MiniGameMouseLeftOffsetX, y)
    textColor := PixelGetColor(x + _MiniGameMouseTextOffsetX, y + _MiniGameMouseTextOffsetY)
    foundTap := leftColor == _MiniGameActionTapColor
    foundMash := textColor == _MiniGameActionMashColor
    foundHold := textColor == _MiniGameActionHoldColor
    foundSpin := textColor == _MiniGameActionSpinColor
    foundSpecial := foundMash || foundHold || foundSpin
    if (foundTap && !foundSpecial) {
        MyToolTip("单击", x + 10, y + 10, 17 + ix, DebugMiniGame)
        return 1  ; 单击
    }
    else if (foundMash) {
        MyToolTip("连按", x + 10, y + 10, 17 + ix, DebugMiniGame)
        return 2  ; 连按
    }
    else if (foundHold) {
        MyToolTip("长按", x + 10, y + 10, 17 + ix, DebugMiniGame)
        return 3  ; 长按
    }
    else if (foundSpin) {
        MyToolTip("转动", x + 10, y + 10, 17 + ix, DebugMiniGame)
        return 4  ; 转动
    }
    else {
        MyToolTip("未知", x + 10, y + 10, 17 + ix, DebugMiniGame)
        return 0  ; 未知
    }
}

_MiniGameGoNextStation(station) {
    nextStation := 0  ; 初始化为未知
    counter := 0
    while (true) {
        loop 3 {  ; 识别左中右工作台操作
            ix := A_Index
            iy := (station == ix) ? 1 : 2
            action := _MiniGameRecognizeAction(ix, iy)
            if (action > 0) {
                nextStation := ix
                if (nextStation == station) {
                    return [station, action]
                }
                break
            }
        }
        if (nextStation > 0) {
            break
        }
        counter++
        if (counter > 25) {
            UpdateStatusBar("工作台识别超时")
            return [0, 0]  ; 超时返回
        }
        Sleep(20)
    }
    move := nextStation - station
    UpdateStatusBar("移动到工作台" nextStation)
    key := move > 0 ? "d" : "a"
    loop (Abs(move)) {
        MySend(key)
        Sleep(50)  ; 移动间隔
    }
    station := nextStation
    return [station, action]
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
        MyToolTip("连按" A_Index, 960, 300, _ActionDebugID, DebugMiniGame)
        MySend("Space")
        Sleep(interval)
    }
}

_MiniGameActionHold(delay) {
    MyPress("Space")
    Sleep(delay)
    MyRelease("Space")
}

_MiniGameActionSpin(count, interval, length := 150, sideNum := 12, speed := 100, delay := 1) {
    Pi := 3.141592653589793
    MouseMove(960, 100, speed)  ; 鼠标复位
    loop count {
        MyToolTip("转动" A_Index, 960, 300, _ActionDebugID, DebugMiniGame)
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
