#Requires AutoHotkey v2.0
DebugOnline := false
_JoinDebugID := 1
OnlineJoinBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_OnlineJoin() {
        PlayFailureSound()
        return
    }
}

OnlineExitBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_OnlineExit() {
        PlayFailureSound()
        return
    }
}

OnlineRejoinBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_OnlineExit() {
        PlayFailureSound()
        return
    }
    if !_OnlineJoin() {
        PlayFailureSound()
        return
    }
}

_OnlineJoinCounterPos := [1012, 413]  ; 联机柜台"F"位置
_OnlineJoinCounterColor := "0xFFF8E4"  ; 联机柜台"F"颜色
_OnlineJoinTextPos := [240, 77]  ; "联机"位置
_OnlineJoinTextColor := "0xF9F1DD"  ; "联机"颜色
_OnlineJoinDestinationLogoPos := [67, 85]  ; 小蓝人位置
_OnlineJoinDestinationLogoColor := "0x4289FF"  ; 小蓝人颜色
_OnlineJoinDonePos := [1000, 140]  ; 蓝天背景位置
_OnlineJoinDoneColor := "0x1595D7"  ; 蓝天背景颜色

_OnlineJoin() {
    MyPress("w")
    counter := 0
    while (true) {
        color := PixelGetColor(_OnlineJoinCounterPos[1], _OnlineJoinCounterPos[2])
        MyToolTip(color, _OnlineJoinCounterPos[1], _OnlineJoinCounterPos[2], _JoinDebugID, DebugMiniGame)
        if (color == _OnlineJoinCounterColor) {
            UpdateStatusBar("到达柜台")
            MyRelease("w")
            break
        }
        counter++
        UpdateStatusBar("前进中..." counter)
        if (counter > 50) {
            UpdateStatusBar("前进超时")
            MyRelease("w")
            return false
        }
        Sleep(100)
    }
    UpdateStatusBar("开始对话")
    MySend("f", , 1500)
    MySend("Space", , 1000)
    MySend("Space")
    counter := 0
    while (true) {
        color := PixelGetColor(_OnlineJoinTextPos[1], _OnlineJoinTextPos[2])
        MyToolTip(color, _OnlineJoinTextPos[1], _OnlineJoinTextPos[2], _JoinDebugID + 1, DebugMiniGame)
        if (color == _OnlineJoinTextColor) {
            UpdateStatusBar("完成保存")
            break
        }
        counter++
        UpdateStatusBar("等待保存..." counter)
        if (counter > 50) {
            UpdateStatusBar("等待保存超时")
            return false
        }
        Sleep(500)
    }
    UpdateStatusBar("选择加入")
    Sleep(200)
    MySend("d", , 200)
    MySend("Space", , 1000)
    MySend("s", , 200)
    MySend("Space", , 1000)
    UpdateStatusBar("输入关键词")
    keyword := myGui["Online.Keyword"].Value
    if (keyword == "") {
        UpdateStatusBar("关键词不能为空")
        return false
    }
    MySend("Space", , 500)
    SendText(keyword)
    Sleep(800)
    MySend("Enter", , 500)
    MySend("Tab")
    counter := 0
    while (true) {
        color := PixelGetColor(
            _OnlineJoinDestinationLogoPos[1], _OnlineJoinDestinationLogoPos[2])
        MyToolTip(color,
            _OnlineJoinDestinationLogoPos[1], _OnlineJoinDestinationLogoPos[2],
            _JoinDebugID + 2, DebugMiniGame)
        if (color == _OnlineJoinDestinationLogoColor) {
            break
        }
        counter++
        UpdateStatusBar("正在搜索..." counter)
        if (counter > 50) {
            UpdateStatusBar("搜索超时")
            return false
        }
        Sleep(500)
    }
    UpdateStatusBar("已暂停，光标移到目标房间后按F3继续")
    Pause()
    MySend("Space", , 500)
    MySend("Space", , 1000)
    password := myGui["Online.Password"].Value
    if (password == "") {
        UpdateStatusBar("无密码，直接加入")
    }
    else {
        UpdateStatusBar("输入密码")
        SendText(password)
        Sleep(800)
        MySend("Enter")
    }
    counter := 0
    while (true) {
        color := PixelGetColor(_OnlineJoinDonePos[1], _OnlineJoinDonePos[2])
        MyToolTip(color, _OnlineJoinDonePos[1], _OnlineJoinDonePos[2], _JoinDebugID + 3, DebugMiniGame)
        if (color == _OnlineJoinDoneColor) {
            UpdateStatusBar("加入成功")
            break
        }
        counter++
        UpdateStatusBar("等待加入..." counter)
        if (counter > 50) {
            UpdateStatusBar("加入超时")
            return false
        }
        Sleep(500)
    }
    return true
}

_OnlineExit() {
    myGui["StatusBar"].Text := "退出房间"
    MySend("Escape", , 750)
    MySend("q", , 200)
    MySend("w", , 200)
    MySend("a", , 200)
    MySend("Space", , 500)
    MySend("Space", , 1000)
    myGui["StatusBar"].Text := "已退出房间"
    return true
}
