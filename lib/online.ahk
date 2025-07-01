#Requires AutoHotkey v2.0
DebugOnline := false
_JoinDebugID := 1

Online_RecruitBtn_Click() {
    _OnlineCheckInput()
    _TalkToOnlineCounter()
    _OnlineRecruit()
}

Online_ExitBtn_Click() {
    _OnlineExit()
}

Online_DismissBtn_Click() {
    _OnlineDismiss()
}

Online_JoinBtn_Click() {
    _OnlineCheckInput()
    _TalkToOnlineCounter()
    _OnlineJoin()
}

Online_LeaveBtn_Click() {
    _OnlineLeave()
}

Online_RejoinBtn_Click() {
    _OnlineCheckInput()
    _OnlineLeave()
    _TalkToOnlineCounter()
    _OnlineJoin()
}

_OnlineCheckInput() {
    if (myGui["Online.Keyword"].Value == "") {
        throw ValueError("关键词不能为空")
    }
}

SelectedTextColor := "0xF8F0DC"  ; 选中对话文本颜色
_OnlineCounterOptionPixel := [1314, 453, SelectedTextColor]  ; 对话选项“互联网连接游玩”像素
_OnlineCounterInternetPixel := [703, 933, SelectedTextColor]  ; 感叹号确认“即将开始互联网连接”像素
_OnlineCounterMultiplayerPixel := [144, 75, SelectedTextColor]  ; 标题“多人联机”像素
_OnlineRecruitButtonPixel := [310, 937, "0xFFC444"]  ; 按钮“招募！”像素
_OnlineRecruitDestinationPixel := [890, 238, SelectedTextColor]  ; 标题“设置目的地”像素
_OnlineCounterPixel := [1012, 413, "0xFFF8E4"]  ; 联机柜台"F"位置
_OnlineRecruitTripLogoPos := [960, 600]  ; 啼普加载中图标位置
_OnlineRecruitTripLogoColor := "0x8A703E"  ; 啼普加载中图标颜色
_OnlineJoinDestinationLogoPos := [67, 85]  ; 小蓝人位置
_OnlineJoinDestinationLogoColor := "0x4289FF"  ; 小蓝人颜色
_OnlineJoiningSkyPixel := [1000, 140, "0x1595D7"]  ; 蓝天背景像素
_OnlineJoiningSkyPos := [1000, 140]  ; 蓝天背景位置
_OnlineJoinDoneColor := "0x1595D7"  ; 蓝天背景颜色

_TalkToOnlineCounter() {
    MyPress("w")
    WaitUntilColorMatch(
        _OnlineCounterPixel[1], _OnlineCounterPixel[2],
        _OnlineCounterPixel[3], "联机柜台", , , , 100)
    MyRelease("w")
    UpdateStatusBar("开始对话")
    MySend("f")
    WaitUntilColorMatch(
        _OnlineCounterOptionPixel[1], _OnlineCounterOptionPixel[2],
        _OnlineCounterOptionPixel[3], "对话选项")
    Sleep(100)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCounterInternetPixel[1], _OnlineCounterInternetPixel[2],
        _OnlineCounterInternetPixel[3], "确认连接")
    Sleep(100)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCounterMultiplayerPixel[1], _OnlineCounterMultiplayerPixel[2],
        _OnlineCounterMultiplayerPixel[3], "多人联机", , , 1000, 60)
}

_OnlineRecruit() {
    UpdateStatusBar("选择招募")
    Sleep(100)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineRecruitButtonPixel[1], _OnlineRecruitButtonPixel[2],
        _OnlineRecruitButtonPixel[3], "招募按钮")
    Sleep(800)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineRecruitDestinationPixel[1], _OnlineRecruitDestinationPixel[2],
        _OnlineRecruitDestinationPixel[3], "设置目的地")
    destination := myGui["Online.Destination"].Value
    loop (destination - 1) {
        MySend("d", , 200)
    }
    MySend("Space", , 300)
    MySend("Escape", , 300)
    loop (6) {
        MySend("s", , 300)
    }
    UpdateStatusBar("输入关键词")
    MySend("Space", , 300)
    SendText(myGui["Online.Keyword"].Value)
    Sleep(300)
    MySend("Enter", 100)
    WaitUntilColorMatch(
        _OnlineRecruitButtonPixel[1], _OnlineRecruitButtonPixel[2],
        _OnlineRecruitButtonPixel[3], "招募按钮")
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
            _OnlineRecruitButtonPixel[1], _OnlineRecruitButtonPixel[2],
            _OnlineRecruitButtonPixel[3], "招募按钮")
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
    WaitUntilColorMatch(
        _OnlineRecruitTripLogoPos[1], _OnlineRecruitTripLogoPos[2],
        _OnlineRecruitTripLogoColor, "创建中", , , 500, 60)
    WaitUntilColorNotMatch(
        _OnlineRecruitTripLogoPos[1], _OnlineRecruitTripLogoPos[2],
        _OnlineRecruitTripLogoColor, "创建完成", , , 500, 60)
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
    WaitUntilColorMatch(
        _OnlineJoiningSkyPixel[1], _OnlineJoiningSkyPixel[2],
        _OnlineJoiningSkyPixel[3], "加入", , , 500, 60)
}

_OnlineExitIconColor := "0x3C4C44"  ; 退出房间图标中心颜色
_OnlineDismissIconColor := "0x9D9640"  ; 解散房间图标中心颜色
_OnlineLeaveIconColor := _OnlineDismissIconColor  ; 离开房间图标中心颜色

_OnlineExit() {
    myGui["StatusBar"].Text := "退出房间"
    pos := OpenMenuAndMoveToIcon(2, 3, 4)  ; [1246, 794]
    if !SearchColorMatch(pos[1], pos[2], _OnlineExitIconColor, 2) {
        color := PixelGetColor(pos[1], pos[2])
        throw ValueError("退出房间图标颜色不匹配[" color "]")
    }
    MySend("Space")  ; 点击退出房间图标
    WaitUntilColorMatch(
        UtilsWindowNo2Pos[1], UtilsWindowNo2Pos[2],
        UtilsWindowButtonColor, "退出房间“否”")
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "退出房间“是”")
    Sleep(500)  ; 等待确认按钮稳定
    MySend("Space")  ; 确认退出
    myGui["StatusBar"].Text := "已退出房间"
}

_OnlineDismiss() {
    myGui["StatusBar"].Text := "解散房间"
    pos := OpenMenuAndMoveToIcon(2, 3, 4)  ; [1246, 794]
    if !SearchColorMatch(pos[1], pos[2], _OnlineDismissIconColor, 2) {
        color := PixelGetColor(pos[1], pos[2])
        throw ValueError("解散房间图标颜色不匹配[" color "]")
    }
    MySend("Space")  ; 点击解散房间图标
    WaitUntilColorMatch(
        UtilsWindowNo2Pos[1], UtilsWindowNo2Pos[2],
        UtilsWindowButtonColor, "解散房间“否”")
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "解散房间“是”")
    Sleep(500)  ; 等待确认按钮稳定
    MySend("Space")  ; 确认解散
    WaitUntilSavingIcon()
    myGui["StatusBar"].Text := "已解散房间"
}

_OnlineLeave() {
    myGui["StatusBar"].Text := "离开房间"
    pos := OpenMenuAndMoveToIcon(2, 3, 4)  ; [1246, 794]
    if !SearchColorMatch(pos[1], pos[2], _OnlineLeaveIconColor, 2) {
        color := PixelGetColor(pos[1], pos[2])
        throw ValueError("离开房间图标颜色不匹配[" color "]")
    }
    MySend("Space")  ; 点击离开房间图标
    WaitUntilColorMatch(
        UtilsWindowYes1Pos[1], UtilsWindowYes1Pos[2],
        UtilsWindowButtonColor, "离开房间“是”")
    MySend("Space")  ; 确认离开
    WaitUntilSavingIcon()
    myGui["StatusBar"].Text := "已离开房间"
}
