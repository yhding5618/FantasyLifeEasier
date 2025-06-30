#Requires AutoHotkey v2.0
DebugOnline := false
_JoinDebugID := 1

OnlineCreateBtnClick() {
    _OnlineCheckInput()
    _TalkToOnlineCounter()
    _OnlineCreate()
}

OnlineJoinBtnClick(*) {
    _OnlineCheckInput()
    _TalkToOnlineCounter()
    _OnlineJoin()
}

OnlineExitBtnClick(*) {
    _OnlineExit()
}

OnlineRejoinBtnClick(*) {
    _OnlineCheckInput()
    _OnlineExit()
    _TalkToOnlineCounter()
    _OnlineJoin()
}

_OnlineCheckInput() {
    keyword := myGui["Online.Keyword"].Value
    if (keyword == "") {
        throw ValueError("关键词不能为空")
    }
}

SelectedTextColor := "0xF8F0DC"  ; 选中对话文本颜色
_OnlineCounterText1Pixel := [1314, 453, SelectedTextColor]  ; 对话选项“互联网连接游玩”像素
_OnlineCounterText2Pixel := [703, 933, SelectedTextColor]  ; 感叹号确认“即将开始互联网连接”像素
_OnlineCounterText3Pixel := [144, 75, SelectedTextColor]  ; 标题“多人联机”像素
_OnlineCreateText1Pixel := [310, 937, "0xFFC444"]  ; 按钮“招募！”像素
_OnlineCreateText2Pixel := [890, 238, SelectedTextColor]  ; 标题“设置目的地”像素
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
        MyToolTip(color, _OnlineCounterPos[1], _OnlineCounterPos[2],
            _JoinDebugID, DebugOnline)
        if (color == _OnlineCounterColor) {
            UpdateStatusBar("到达柜台")
            MyRelease("w")
            break
        }
        counter++
        UpdateStatusBar("前进中..." counter)
        if (counter > 100) {
            UpdateStatusBar("前进超时")
            MyRelease("w")
            throw TimeoutError("前往联机柜台超时")
        }
        Sleep(100)
    }
    UpdateStatusBar("开始对话")
    MySend("f")
    WaitUntilColorMatch(
        _OnlineCounterText1Pixel[1],
        _OnlineCounterText1Pixel[2],
        _OnlineCounterText1Pixel[3],
        "对话选项"
    )
    Sleep(100)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCounterText2Pixel[1],
        _OnlineCounterText2Pixel[2],
        _OnlineCounterText2Pixel[3],
        "感叹号确认页"
    )
    Sleep(100)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCounterText3Pixel[1],
        _OnlineCounterText3Pixel[2],
        _OnlineCounterText3Pixel[3],
        "多人联机页", , , 1000, 60
    )
}

_OnlineCreate() {
    UpdateStatusBar("选择创建")
    Sleep(100)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCreateText1Pixel[1],
        _OnlineCreateText1Pixel[2],
        _OnlineCreateText1Pixel[3],
        "招募按钮"
    )
    Sleep(800)
    MySend("Space")
    UpdateStatusBar("选择创建类型")
    WaitUntilColorMatch(
        _OnlineCreateText2Pixel[1],
        _OnlineCreateText2Pixel[2],
        _OnlineCreateText2Pixel[3],
        "设置目的地"
    )
    creatType := myGui["Online.CreateType"].Value
    loop (creatType) {
        MySend("d", , 200)
    }
    MySend("Space", , 500)
    MySend("Escape", , 500)
    loop (6) {
        MySend("s", , 500)
    }
    UpdateStatusBar("输入关键词")
    MySend("Space", , 500)
    keyword := myGui["Online.Keyword"].Value
    SendText(keyword)
    Sleep(500)
    MySend("Enter", 100)
    WaitUntilColorMatch(
        _OnlineCreateText1Pixel[1],
        _OnlineCreateText1Pixel[2],
        _OnlineCreateText1Pixel[3],
        "招募按钮"
    )
    Sleep(800)
    MySend("s", , 500)
    password := myGui["Online.Password"].Value
    if (password == "") {
        UpdateStatusBar("跳过密码")
    }
    else {
        UpdateStatusBar("输入密码")
        MySend("Space", , 500)
        SendText(password)
        Sleep(500)
        MySend("Enter", 100)
        WaitUntilColorMatch(
            _OnlineCreateText1Pixel[1],
            _OnlineCreateText1Pixel[2],
            _OnlineCreateText1Pixel[3],
            "招募按钮"
        )
        Sleep(800)
    }
    UpdateStatusBar("开始招募")
    MySend("s", , 500)
    MySend("s", , 500)
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
        MyToolTip(color, _OnlineJoinDonePos[1], _OnlineJoinDonePos[2],
            _JoinDebugID + 3, DebugOnline)
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
    OpenMenu()
    MySend("q", , 200)
    MySend("w", , 200)
    MySend("a", , 200)
    MySend("Space", , 500)
    MySend("Space", , 1000)
    myGui["StatusBar"].Text := "已退出房间"
}
