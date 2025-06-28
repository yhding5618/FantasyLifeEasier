#Requires AutoHotkey v2.0
DebugOnline := false
_JoinDebugID := 1

OnlineCreateBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_CheckInput() {
        PlayFailureSound()
        return
    }
    if !_TalkToOnlineCounter() {
        PlayFailureSound()
        return
    }
    if !_OnlineCreate() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

OnlineJoinBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_CheckInput() {
        PlayFailureSound()
        return
    }
    if !_TalkToOnlineCounter() {
        PlayFailureSound()
        return
    }
    if !_OnlineJoin() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
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
    PlaySuccessSound()
}

OnlineRejoinBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_CheckInput() {
        PlayFailureSound()
        return
    }
    if !_OnlineExit() {
        PlayFailureSound()
        return
    }
    if !_TalkToOnlineCounter() {
        PlayFailureSound()
        return
    }
    if !_OnlineJoin() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

_CheckInput() {
    keyword := myGui["Online.Keyword"].Value
    if (keyword == "") {
        UpdateStatusBar("关键词不能为空")
        return false
    }
    return true
}

_OnlineCounterPos := [1012, 413]  ; 联机柜台"F"位置
_OnlineCounterColor := "0xFFF8E4"  ; 联机柜台"F"颜色
_OnlineCounterTextPos := [240, 77]  ; "联机"位置
_OnlineCounterTextColor := "0xF9F1DD"  ; "联机"颜色
_OnlineCreateTripLogoPos := [960, 600]  ; 啼普加载中图标位置
_OnlineCreateTripLogoColor := "0x8A703E"  ; 啼普加载中图标颜色
_OnlineJoinDestinationLogoPos := [67, 85]  ; 小蓝人位置
_OnlineJoinDestinationLogoColor := "0x4289FF"  ; 小蓝人颜色
_OnlineJoinDonePos := [1000, 140]  ; 蓝天背景位置
_OnlineJoinDoneColor := "0x1595D7"  ; 蓝天背景颜色

_TalkToOnlineCounter() {
    MyPress("w")
    counter := 0
    while (true) {
        color := PixelGetColor(_OnlineCounterPos[1], _OnlineCounterPos[2])
        MyToolTip(color, _OnlineCounterPos[1], _OnlineCounterPos[2], _JoinDebugID, DebugOnline)
        if (color == _OnlineCounterColor) {
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
        color := PixelGetColor(_OnlineCounterTextPos[1], _OnlineCounterTextPos[2])
        MyToolTip(color, _OnlineCounterTextPos[1], _OnlineCounterTextPos[2], _JoinDebugID + 1, DebugOnline)
        if (color == _OnlineCounterTextColor) {
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
    return true
}

_OnlineCreate() {
    UpdateStatusBar("选择创建")
    Sleep(200)
    MySend("Space", , 1000)
    MySend("Space", , 1000)
    creatType := myGui["Online.CreateType"].Value
    loop (creatType) {
        MySend("d", , 200)
    }
    MySend("Space", , 200)
    MySend("Escape", , 500)
    keyword := myGui["Online.Keyword"].Value
    UpdateStatusBar("输入关键词")
    loop (6) {
        MySend("s", , 200)
    }
    MySend("Space", , 500)
    SendText(keyword)
    Sleep(800)
    MySend("Enter", , 500)
    password := myGui["Online.Password"].Value
    MySend("s", , 200)
    if (password == "") {
        UpdateStatusBar("跳过密码")
    }
    else {
        UpdateStatusBar("输入密码")
        MySend("Space", , 500)
        SendText(password)
        Sleep(800)
        MySend("Enter", , 500)
    }
    UpdateStatusBar("开始招募")
    MySend("s", , 200)
    MySend("s", , 200)
    MySend("Space", 500)
    UpdateStatusBar("确认招募")
    MySend("Space", , 500)
    UpdateStatusBar("再次确认")
    MySend("Space", , 500)
    counter := 0
    creating := false
    while (true) {
        foundTrip := PixelSearch(&x, &y,
            _OnlineCreateTripLogoPos[1] - 1, _OnlineCreateTripLogoPos[2] - 1,
            _OnlineCreateTripLogoPos[1] + 1, _OnlineCreateTripLogoPos[2] + 1,
            _OnlineCreateTripLogoColor, 10)
        if (foundTrip && !creating) {
            creating := true
        }
        else if (!foundTrip && creating) {
            creating := false
            UpdateStatusBar("创建完成")
            break
        }
        counter++
        UpdateStatusBar("等待创建..." counter)
        if (counter > 50) {
            UpdateStatusBar("创建超时")
            return false
        }
        Sleep(500)
    }
    return true
}

_OnlineJoin() {
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
            _JoinDebugID + 2, DebugOnline)
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
        MyToolTip(color, _OnlineJoinDonePos[1], _OnlineJoinDonePos[2], _JoinDebugID + 3, DebugOnline)
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
