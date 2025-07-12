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

Online_LoopRecruitAgingBtn_Click() {
    myGui["Online.Destination"].Value := 4
    count := 1
    while (true) {
        MyToolTip("第" count "车", 0, 0, 1, DebugOnline)
        LoadFromCloud()
        _TalkToColm()  ; 与科隆对话
        _OnlineRecruit()  ; 开始招募
        _OnlineWaitForBaseCampUI()  ; 等待加载营地界面
        _OnlineHeadOutAsHost()  ; 出发
        _OnlineFinishAgingAndBoss()
        _OnlineWaitForBaseCampUI()
        _OnlineWaitForNoMember()
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

; 联机出发[U]位置
_OnlineHeadOutButtonPos := [339, 217]

_OnlineWaitForBaseCampUI() {
    WaitUntilButton(
        _OnlineHeadOutButtonPos[1], _OnlineHeadOutButtonPos[2],
        "联机出发[U]", , , 1000, 10)
    Sleep(500)  ; 等待界面稳定
}

_OnlineWaitForNoMember() {
    count := 0
    maxCount := 90
    joinStatus := [false, false, false, false]
    UpdateStatusBar("等待所有成员离开房间")
    Sleep(3000)  ; 等待UI稳定
    while (count < maxCount) {
        changed := false
        _OnlineCheckMemberJoinStatus(&joinStatus, &changed)
        if (Mod(count, 10) == 0) {
            _OnlineSendGameMessage("等待所有成员离开后重开，"
                (maxCount - count) "秒后强制解散")
        }
        UpdateStatusBar("等待所有成员"
            changed joinStatus[1] joinStatus[2] joinStatus[3] joinStatus[4]
            "离开房间..." count "/" maxCount)
        if joinStatus[1] && !joinStatus[2] && !joinStatus[3] && !joinStatus[4] {
            UpdateStatusBar("所有成员已离开房间")
            return
        }
        count++
        Sleep(1000)
    }
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
    UtilsWaitUntilOptionListSelected(1, 1, 2, "科隆对话选项")
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
    Sleep(500)
    MySend("u", , 300)
    WaitUntilConversationSpace()
    MySend("Space")
    UtilsWaitUntilOptionListSelected(2, 1, 2, "对话界面")
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
; “探索完成！”文本位置X
_OnlineFinishExploreTextPosX := [708, 863, 1027, 1170, 1281]
; “探索完成！”文本位置Y
_OnlineFinishExploreTextPosY := 190
; “探索完成！”文本颜色
_OnlineFinishExploreTextColor := "0xFFD707"

_OnlineFinishAgingAndBoss() {
    WaitUntilSavingIcon()  ; 等待保存图标出现（界面加载完成）
    ; 初始房内前进到传送阵
    _OnlineMoveForwardUntilInteract("传送阵", 6)
    MySend("f")  ; 交互传送阵
    pos := TreasureGroveFindAgingAltar()
    _OnlineTreasureGroveMoveToFloor(pos)
    WaitUntilSavingIcon()
    ; 熟成房内前进到传送阵
    MySend("a", 250)
    MySend("w", 500)
    _OnlineMoveForwardUntilInteract("传送阵", 15)
    MySend("d", 100)
    _OnlineWaitUntilAllAging()  ; 等待所有成员完成熟成
    MySend("f")  ; 交互传送阵
    pos := TreasureGroveFindBoss()
    _OnlineTreasureGroveMoveToFloor(pos)
    _OnlineWaitUntilAdventureComplete()
    UpdateStatusBar("连续空格键跳过结算界面")
    loop 20 {
        MySend("Space", , 250)
    }
}

_OnlineTreasureGroveMoveToFloor(pos) {
    MouseClick(, _TreasureGroveLogoPixel[1], _TreasureGroveLogoPixel[2])
    MouseMove(pos[1], pos[2])
    loop (4 * 5) {  ; 转5圈，每圈4个方向
        if Mod(A_Index, 4) == 1 {
            MouseMove(80, -80, 100, "R")
        } else if Mod(A_Index, 4) == 2 {
            MouseMove(-80, -80, 100, "R")
        } else if Mod(A_Index, 4) == 3 {
            MouseMove(-80, 80, 100, "R")
        } else if Mod(A_Index, 4) == 0 {
            MouseMove(80, 80, 100, "R")
        }
        Sleep(20)
    }
    Sleep(500)
    MySend("Space")
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "确认楼层“是”")
    Sleep(500)
    MySend("Space")
}

_OnlineWaitUntilAllAging() {
    PlaySuccessSound()
    qqMessage := "千熟全自动发车（试运营）"
    if (myGui["Online.Keyword"].Text == myGui["Online.Keyword"].Text) {
        qqMessage .= "，词密：" myGui["Online.Keyword"].Text
    } else {
        qqMessage .= "，词：" myGui["Online.Keyword"].Text
        qqMessage .= "，密：" myGui["Online.Keyword"].Text
    }
    _OnlineSendQQMessage(qqMessage)
    joinStatus := [false, false, false, false]
    readyStatus := [false, false, false, false]
    idleCount := 0
    maxIdleCount := 3
    allReadyCount := 0
    while (true) {
        try {
            ; 等待不是蓝天背景
            WaitUntilColorNotMatch(
                _OnlineJoiningSkyPixel[1], _OnlineJoiningSkyPixel[2],
                _OnlineJoiningSkyPixel[3], "成员加入房间", , , 1000, 60)
        } catch Error as e {
            _OnlineSendQQMessage("脚本等待蓝天超时，建议成员退出")
            continue
        }
        changed := false  ; 每次都需要重置状态变化标志
        joinCount := _OnlineCheckMemberJoinStatus(&joinStatus, &changed)
        readyCount := _OnlineCheckMemberPositionStatus(&readyStatus, &changed)
        text := changed ? "状态变化" : "状态未变"
        loop 3 {
            index := A_Index + 1
            text .= "，" index "P: " joinStatus[index] readyStatus[index]
        }
        UpdateStatusBar(text)
        if !joinStatus[1] {
            _OnlineSendGameMessage("未检测到房主，尝试修复")
            MySend("Escape", , 1000)
            continue
        }
        if (joinCount > 1 && readyCount == joinCount) {
            if changed {
                allReadyCount := 0  ; 状态变化后重置计数器
                maxAllReadyCount := 6 * (4 - readyCount)  ; 每少1人多等6个循环
            }
            text := readyCount "/" joinCount "人已就位"
            if allReadyCount < maxAllReadyCount {
                _OnlineSendGameMessage(text "，"
                    (maxAllReadyCount - allReadyCount) * 10 "秒后出发")
            } else {
                _OnlineSendGameMessage(text "，" "现在出发")
                break
            }
            allReadyCount += 1
        } else {
            if changed {
                _OnlineSendGameMessage("更新状态："
                    joinCount "人加入，" readyCount "人就位")
            } else {
                if (idleCount == 0) {
                    _OnlineSendGameMessage("就位条件：小地图上的“?P”框在传送阵房间内（每10秒检测一次)")
                }
                idleCount := (idleCount == maxIdleCount) ? 0 : idleCount + 1
            }
        }
        Sleep(10 * 1000)
    }
}

_OnlineWaitUntilAdventureComplete() {
    count := 0
    timeoutCount := 300
    while (count < timeoutCount) {
        allTextMatch := true
        for index, x in _OnlineFinishExploreTextPosX {
            textMatch := SearchColorMatch(x, _OnlineFinishExploreTextPosY,
                _OnlineFinishExploreTextColor)
            allTextMatch := allTextMatch && textMatch
        }
        if (allTextMatch) {
            UpdateStatusBar("已完成冒险")
            break
        }
        count++
        Sleep(1000)
        UpdateStatusBar("等待冒险完成..." count "/" timeoutCount)
    }
    if (count >= timeoutCount) {
        throw TimeoutError("等待冒险完成超时")
    }
}

_OnlinePlayerPosX := 72
_OnlinePlayerPosY := [
    56,  ; 房主（左上角）
    764,  ; 成员（左下角第一个）
    892,  ; 成员（左下角第二个）
    1020  ; 成员（左下角第三个）
]
_OnlinePlayerColor := [
    "0xFF6950",  ; 1P颜色
    "0x40A0FF",  ; 2P颜色
    "0xFFC600",  ; 3P颜色
    "0xE97DF3",  ; 4P颜色
]

/**
 * @description: 检查成员的状态
 * @param {VarRef} status - 成员状态数组
 * @param {VarRef} changed - 成员状态变更标志
 * @returns {Integer} 检测到的成员数量
 */
_OnlineCheckMemberJoinStatus(&status, &changed) {
    count := 0
    matchedPos := [false, false, false, false]  ; 记录每个位置是否已经匹配
    loop 4 {  ; 检测1P-4P的4个颜色
        indexPlayer := A_Index
        loop 4 {  ; 检测全部4个位置
            indexPos := A_Index
            if (matchedPos[indexPos]) {
                continue  ; 如果该位置已经匹配，则跳过
            }
            posX := _OnlinePlayerPosX
            posY := _OnlinePlayerPosY[indexPos]
            playerColor := _OnlinePlayerColor[indexPlayer]
            match := SearchColorMatch(posX, posY, playerColor, 2, 5)
            if (match) {
                MyToolTip(indexPlayer "P: " status[indexPlayer] match,
                    posX + 3, posY + 3, 1 + indexPos, DebugOnline)
                matchedPos[indexPos] := true
                count++  ; 1P位置不计数
                break
            } else {
                MyToolTip("空", posX + 3, posY + 3, 1 + indexPos, DebugOnline)
            }
        }
        changed := changed || (status[indexPlayer] != match)
        status[indexPlayer] := match
    }
    return count
}

_OnlineMiniMapCenterPos := [1700, 276]  ; 小地图中心位置
_OnlineMiniMapRange := 116  ; 小地图半径
_OnlineMiniMapWarpCircleRange := 44  ; 小地图传送阵房间半径

/**
 * @description: 检查成员是否在附近
 * @param {VarRef} status - 成员状态数组
 * @param {VarRef} changed - 成员状态变更标志
 * @returns {Integer} 检测到的成员数量
 */
_OnlineCheckMemberPositionStatus(&status, &changed) {
    count := 0
    loop 4 {  ; 小地图上检测1P-4P的4个颜色
        indexPlayer := A_Index
        match := SearchColorMatch(
            _OnlineMiniMapCenterPos[1], _OnlineMiniMapCenterPos[2],
            _OnlinePlayerColor[indexPlayer],
            _OnlineMiniMapWarpCircleRange, 5)
        changed := changed || (status[indexPlayer] ^ match)
        status[indexPlayer] := match
        if (match) {
            count++
        }
        x := _OnlineMiniMapCenterPos[1] + _OnlineMiniMapWarpCircleRange
        y := _OnlineMiniMapCenterPos[2] + _OnlineMiniMapWarpCircleRange +
            (indexPlayer - 1) * 20
        MyToolTip(match ? indexPlayer "P" : "",
            x, y, 6 + indexPlayer, DebugOnline)
    }
    return count
}

_OnlineSendQQMessage(text) {
    if (myGui["Online.SendQQMessageChk"].Value) {
        WinActivate("ahk_exe QQ.exe")
        MyPaste(text)
        MySend("Enter")
        GameWindowActivate()
    }
}

_OnlineSendGameMessage(text) {
    ; UpdateStatusBar("打开输入栏")
    MySend("Enter", 200, 500)  ; 等待输入栏稳定
    ; UpdateStatusBar("输入消息")
    MyPaste(text)
    Sleep(500)
    ; UpdateStatusBar("发送消息")
    MySend("Enter", 200, 500)  ; 等待消息发送完成
}

_OnlineMoveForwardUntilInteract(title, count) {
    UpdateStatusBar("前进到" title "交互[F]")
    MyPress("w")
    loop count {
        UpdateStatusBar("转" count)
        MySend("r", , 650)
    }
    try {
        WaitUntilButton(  ; 检测y=500的交互按钮
            _OnlineGroveInteractButton1Pos[1],
            _OnlineGroveInteractButton1Pos[2],
            "迷宫内" title "交互[F]", [10, 40], , 50, 600)
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
