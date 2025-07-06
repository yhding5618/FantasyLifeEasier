#Requires AutoHotkey v2.0
DebugOnline := true
_JoinDebugID := 1

Online_RecruitBtn_Click() {
    _OnlineCheckInput()
    _TalkToColm()
    _OnlineRecruit()
}

Online_HeadOutBtn_Click() {
    _OnlineHeadOutAsHost()
}

Online_EndBtn_Click() {
    _OnlineEndAsHost()
}

Online_EndLoadRecruitBtn_Click() {
    count := 1
    while (true) {
        MyToolTip("第" count "车", 0, 0, 1, DebugOnline)
        LoadFromCloud()
        _TalkToColm()  ; 与科隆对话
        _OnlineRecruit()  ; 开始招募
        _OnlineWaitForBaseCampUI()  ; 等待加载营地界面
        _OnlineHeadOutAsHost()  ; 出发
        _OnlineFinishAgingAndBoss()
        _OnlineEndAsHost()  ; 解散房间
        count++
    }
}

Online_JoinBtn_Click() {
    _OnlineCheckInput()
    _TalkToColm()
    _OnlineJoin()
}

Online_LeaveBtn_Click() {
    _OnlineLeaveAsMember()
}

Online_RejoinBtn_Click() {
    _OnlineCheckInput()
    _OnlineLeaveAsMember()
    _TalkToColm()
    _OnlineJoin()
}

_OnlineCheckInput() {
    if (myGui["Online.Keyword"].Value == "") {
        throw ValueError("关键词不能为空")
    }
}

SelectedTextColor := "0xF8F0DC"  ; 选中对话文本颜色
_OnlineCounterInternetPixel := [703, 933, SelectedTextColor]  ; 感叹号确认“即将开始互联网连接”像素
_OnlineCounterMultiplayerPixel := [144, 75, SelectedTextColor]  ; 标题“多人联机”像素
_OnlineRecruitButtonPixel := [310, 937, "0xFFC444"]  ; 按钮“招募！”像素
_OnlineRecruitDestinationPixel := [890, 238, SelectedTextColor]  ; 标题“设置目的地”像素
_OnlineCounterPos := [1012, 413]  ; 科隆对话[F]位置
_OnlineRecruitTripLogoPos := [960, 600]  ; 啼普加载中图标位置
_OnlineRecruitTripLogoColor := "0x8A703E"  ; 啼普加载中图标颜色
_OnlineJoinDestinationLogoPos := [67, 85]  ; 小蓝人位置
_OnlineJoinDestinationLogoColor := "0x4289FF"  ; 小蓝人颜色
_OnlineJoiningSkyPixel := [1000, 140, "0x1595D7"]  ; 蓝天背景像素
_OnlineJoiningSkyPos := [1000, 140]  ; 蓝天背景位置
_OnlineJoinDoneColor := "0x1595D7"  ; 蓝天背景颜色

; 联机出发[U]位置
_OnlineHeadOutButtonPos := [339, 217]

_OnlineWaitForBaseCampUI() {
    WaitUntilButton(
        _OnlineHeadOutButtonPos[1], _OnlineHeadOutButtonPos[2],
        "联机出发[U]", , , 1000, 10)
    Sleep(500)  ; 等待界面稳定
}

/**
 * @description: 前进到联机柜台并与科隆对话
 */
_TalkToColm() {
    MyPress("w")
    WaitUntilButton(
        _OnlineCounterPos[1], _OnlineCounterPos[2],
        "科隆对话[F]", , , 1000, 10)
    MyRelease("w")
    UpdateStatusBar("开始对话")
    MySend("f")
    match := WaitUntil2ColorMatch(
        UtilsOptionListTopIn2GlowPos, UtilsOptionListGlowColor,
        UtilsOptionListTopIn3GlowPos, UtilsOptionListGlowColor,
        "科隆对话选项")
    if (match == 2) {  ; 三选项时向下一次
        MySend("s", , 200)
    }
    Sleep(500)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCounterInternetPixel[1], _OnlineCounterInternetPixel[2],
        _OnlineCounterInternetPixel[3], "确认连接")
    Sleep(500)
    MySend("Space")
    WaitUntilColorMatch(
        _OnlineCounterMultiplayerPixel[1], _OnlineCounterMultiplayerPixel[2],
        _OnlineCounterMultiplayerPixel[3], "多人联机", , , 1000, 60)
}

_OnlineRecruit() {
    UpdateStatusBar("选择招募")
    Sleep(500)
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
    MySend("Space", , 500)
    SendText(myGui["Online.Keyword"].Value)
    Sleep(500)
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
    Sleep(500)  ; 等待界面稳定
    counter := 0
    while (true) {
        if SearchColorMatch(
            _OnlineJoinDestinationLogoPos[1], _OnlineJoinDestinationLogoPos[2],
            _OnlineJoinDestinationLogoColor, 2
        ) {
            UpdateStatusBar("已找到目标房间")
            break
        }
        if SearchColorMatch(
            UtilsWindowOK5Pos[1], UtilsWindowOK5Pos[2], UtilsWindowButtonColor
        ) {
            throw ValueError("房间搜索错误，请检查关键词或密码")
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
        _OnlineJoiningSkyPixel[3], "加入", , , 1000, 60)
}

_OnlineHeadOutAsHost() {
    MySend("u")
    WaitUntilConversationSpace()
    MySend("Space")
    WaitUntilColorMatch(
        UtilsShortOptionListTopIn2GlowPos[1],
        UtilsShortOptionListTopIn2GlowPos[2],
        UtilsOptionListGlowColor, "对话界面")
    Sleep(300)  ; 等待对话界面稳定
    MySend("Space")  ; 选择“出发”选项
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "确认出发“是”")
    Sleep(300)
    MySend("Space")  ; 确认出发
}

; 迷宫内交互[F]位置（先是y=500，视角自动调整后变400）
_OnlineGroveInteractButton1Pos := [1017, 500]
_OnlineGroveInteractButton2Pos := [1017, 400]

_OnlineFinishAgingAndBoss() {
    WaitUntilSavingIcon()  ; 等待保存图标出现（界面加载完成）
    _OnlineMoveForwardUntilInteract("传送阵", 6)  ; 到传送阵
    MySend("f")  ; 交互传送阵
    pos := TreasureGroveFindAgingAltar()
    MouseMove(pos[1], pos[2])
    loop (4 * 3) {
        if Mod(A_Index, 4) == 1 {
            MouseMove(80, 80, 100, "R")
        } else if Mod(A_Index, 4) == 2 {
            MouseMove(-80, 80, 100, "R")
        } else if Mod(A_Index, 4) == 3 {
            MouseMove(-80, -80, 100, "R")
        } else if Mod(A_Index, 4) == 0 {
            MouseMove(80, -80, 100, "R")
        }
        Sleep(1)
    }
    Sleep(500)
    MySend("Space")
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "确认楼层“是”")
    Sleep(500)
    MySend("Space")
    WaitUntilSavingIcon()
    ; _OnlineMoveForwardUntilInteract("熟成祭坛", 8)  ; 到熟成祭坛
    ; MySend("a", 500)
    ; MySend("w", 500)
    ; MySend("d", 500)
    ; MySend("w", 500)  ; 绕过熟成祭坛
    MySend("a", 250)
    MySend("w", 500)
    _OnlineMoveForwardUntilInteract("传送阵", 15)  ; 到传送阵
    UpdateStatusBar("已暂停，等待队友完成熟成后按F3继续")
    MySend("F3")
    MySend("f")  ; 交互传送阵
    pos := TreasureGroveFindBoss()
    MouseMove(pos[1], pos[2])
    loop (4 * 3) {
        if Mod(A_Index, 4) == 1 {
            MouseMove(80, 80, 100, "R")
        } else if Mod(A_Index, 4) == 2 {
            MouseMove(-80, 80, 100, "R")
        } else if Mod(A_Index, 4) == 3 {
            MouseMove(-80, -80, 100, "R")
        } else if Mod(A_Index, 4) == 0 {
            MouseMove(80, -80, 100, "R")
        }
        Sleep(1)
    }
    Sleep(500)
    MySend("Space")
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "确认楼层“是”")
    Sleep(500)
    MySend("Space")
    Sleep(5000)
    count := 0
    timeoutCount := 300
    while (count < timeoutCount) {
        try {
            WaitUntilConversationSpace(100, 1000)  ;一次等10秒
        } catch {
            UpdateStatusBar("等待Boss战... " count "/" timeoutCount)
            count++
            continue
        }
        UpdateStatusBar("已完成Boss战")
        break
    }
    if (count >= timeoutCount) {
        throw TimeoutError("等待Boss战结束超时")
    }
    MySend(1000)
    MySend("Space", , 1000)
    WaitUntilConversationSpace()
    MySend("Space", , 1000)
    _OnlineWaitForBaseCampUI()
}

_OnlineMoveForwardUntilInteract(title, count) {
    UpdateStatusBar("前进到" title "交互[F]")
    MyPress("w")
    loop count {
        UpdateStatusBar("转" count)
        MySend("r", , 650)
    }
    try {
        WaitUntilButton(  ; 同时检测y=400和y=500的交互按钮
            _OnlineGroveInteractButton1Pos[1], _OnlineGroveInteractButton1Pos[2
            ],
            "迷宫内" title "交互[F]", , , 100, 300)
    } catch {
        MyRelease("w")
        throw ValueError("迷宫内" title "交互[F]按钮未找到")
    }
    MyRelease("w")
    UpdateStatusBar("已到达迷宫内" title "交互[F]")
}

; 菜单退出图标（石洞）中心颜色，用于：结束（迷宫树）
_OnlineEndCaveIconColor := "0x3C4C44"
; 菜单退出图标（山峰）中心颜色，用于：结束探索（大陆），（房主）解散房间，（成员）离开房间
_OnlineEndMountainIconColor := "0x9D9640"

_OnlineEndAsHost() {
    UpdateStatusBar("退出房间")
    pos := OpenMenuAndMoveToIcon(2, 3, 4)  ; [1246, 794]
    loop 10 {
        isCave := SearchColorMatch(  ; 离开
            pos[1], pos[2], _OnlineEndCaveIconColor, 2)
        isMountain := SearchColorMatch(  ; 解散
            pos[1], pos[2], _OnlineEndMountainIconColor, 2)
        if (isCave && isMountain) {
            throw ValueError("退出图标颜色冲突")
        }
        if (isCave || isMountain) {
            break
        }
        UpdateStatusBar("等待退出图标颜色匹配")
        Sleep(100)
    }
    MySend("Space")  ; 点击退出房间图标
    WaitUntilColorMatch(
        UtilsWindowNo2Pos[1], UtilsWindowNo2Pos[2],
        UtilsWindowButtonColor, "退出房间“否”")
    Sleep(500)  ; 等待界面稳定
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "退出房间“是”")
    Sleep(500)  ; 等待确认按钮稳定
    MySend("Space")  ; 确认退出
    if (isMountain) {
        WaitUntilSavingIcon()
    }
    if (isCave) {
        WaitUntilButton(
            _OnlineHeadOutButtonPos[1], _OnlineHeadOutButtonPos[2],
            "联机出发[U]", , , 100, 500)
    }
    UpdateStatusBar("已退出")
}

_OnlineLeaveAsMember() {
    UpdateStatusBar("离开房间")
    pos := OpenMenuAndMoveToIcon(2, 3, 4)  ; [1246, 794]
    loop 10 {
        isMountain := SearchColorMatch(
            pos[1], pos[2], _OnlineEndMountainIconColor, 2)
        if (isMountain) {
            break
        }
        UpdateStatusBar("等待离开图标颜色匹配")
        Sleep(100)
    }
    if (!isMountain) {
        throw ValueError("离开图标颜色不匹配")
    }
    MySend("Space")  ; 点击离开房间图标
    WaitUntilColorMatch(
        UtilsWindowYes1Pos[1], UtilsWindowYes1Pos[2],
        UtilsWindowButtonColor, "离开房间“是”")
    Sleep(500)  ; 等待确认按钮稳定
    MySend("Space")  ; 确认离开
    WaitUntilSavingIcon()
    UpdateStatusBar("已离开")
}
