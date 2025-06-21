#Requires AutoHotkey v2.0
#SingleInstance Force
; ProcessSetPriority "High"
CoordMode "Pixel", "Client"

myGui := Gui(, "Fantasy Life Easier")
_GuiBoxSize(row) {
    return "w" 300 " h" (20 + row * 30) " Section"
}
myGui.AddGroupBox("xm ym " _GuiBoxSize(3), "游戏窗口")
BuildGuiForGameWindow()
myGui.AddGroupBox("xs " _GuiBoxSize(1), "重置石")
BuildGuiForReduxStone()
myGui.AddGroupBox("xs " _GuiBoxSize(1), "任意门")
BuildGuiForTeleportationGate()
myGui.AddGroupBox("xs " _GuiBoxSize(1), "传奇任务")
BuildGuiForGinormosia()
myGui.AddGroupBox("xs " _GuiBoxSize(3), "宝箱怪")
BuildGuiForMimic()
myGui.AddGroupBox("xs " _GuiBoxSize(2), "扭蛋迷宫树")
BuildGuiForGrove()
myGui.AddGroupBox("xs " _GuiBoxSize(1), "云存档")
BuildGuiForSaveLoad()
myGui.AddGroupBox("xs " _GuiBoxSize(1), "熟成")
BuildGuiForAging()
myGui.AddGroupBox("xs " _GuiBoxSize(2), "联机功能（刷惊魂器）")
BuildGuiForOnline()
myGui.AddGroupBox("xs " _GuiBoxSize(5), "制作")
BuildGuiForCraft()
myGui.AddGroupBox("xs " _GuiBoxSize(1), "其他功能")
BuildGuiForOthers()
myGui.AddStatusBar("vStatusBar", "StatusBar")
myGui.OnEvent("Close", (*) => ExitApp())
myGui["_GameWindowActivate"].OnEvent("Click", _GameWindowActivate)
myGui["BuyReduxStone"].OnEvent("Click", BuyReduxStone)
myGui["SellReduxStone"].OnEvent("Click", SellReduxStone)
myGui["TeleportationGateSingleTrip"].OnEvent("Click", TeleportationGateSingleTrip)
myGui["TeleportationGateReturnTrip"].OnEvent("Click", TeleportationGateReturnTrip)
myGui["GinormosiaRefresh"].OnEvent("Click", GinormosiaRefresh)
myGui["GinormosiaCheck"].OnEvent("Click", GinormosiaCheck)
myGui["MimicSingleKill"].OnEvent("Click", MimicSingleKill)
myGui["MimicBatchKill"].OnEvent("Click", MimicBatchKill)
myGui["PlantSaplingNext"].OnEvent("Click", PlantSaplingNext)
myGui["PlantSapling"].OnEvent("Click", PlantSapling)
myGui["SaveCloud"].OnEvent("Click", SaveCloud)
myGui["LoadCloud"].OnEvent("Click", LoadCloud)
myGui["AgingCheck"].OnEvent("Click", AgingCheck)
myGui["AgingNext"].OnEvent("Click", AgingNext)
myGui["CraftSingle"].OnEvent("Click", CraftSingle)
myGui["Craft"].OnEvent("Click", Craft)
myGui["OnlineJoin"].OnEvent("Click", OnlineJoin)
myGui["OnlineExit"].OnEvent("Click", OnlineExit)
myGui["OnlineNext"].OnEvent("Click", OnlineNext)
myGui["TestColor"].OnEvent("Click", TestColor)
myGui.Opt("+Resize +MinSize330x320 +MaxSize330x1200 -MaximizeBox")
myGui.Show("x2200 y100")

Sleep 1000
WinSetAlwaysOnTop 1, "Fantasy Life Easier"

CheckGameWindow()
F3:: Pause(-1)
F4:: ExitApp()

MyPress(key) {
    Send "{" key " down}"
}

MyRelease(key) {
    Send "{" key " up}"
}

MySend(key, delay := 30) {
    MyPress(key)
    Sleep delay
    MyRelease(key)
}

_BuyItem() {
    MySend "Space"
    Sleep 750
    MySend "Space"
    Sleep 750
}

_SelectItemAndGoUp() {
    MySend "Space"
    Sleep 250
    MySend "Up"
    Sleep 250
}

_ToggleMenu() {
    myGui["StatusBar"].Text := "切换Esc菜单"
    MySend "Escape"
    Sleep 750
}

_TeleportationGateSingleTrip(*) {
    _ToggleMenu()
    color := PixelGetColor(666, 333)
    if (color != 0xE337DB && color != 0xE335DB) {
        if (color == 0x963681) {
            myGui["StatusBar"].Text := "任意门不可用"
            return false
        }
        myGui["StatusBar"].Text := "任意门颜色异常: " color
        return false
    }
    myGui["StatusBar"].Text := "选择任意门"
    MySend "Space"
    Sleep 750
    myGui["StatusBar"].Text := "确认"
    MySend "Space"
    myGui["StatusBar"].Text := "等待开门动画"
    Sleep 4200  ; 开门动画
    myGui["StatusBar"].Text := "等待加载"
    counter := 0
    firstCheck := true
    while (true) {  ; 等待加载
        color := PixelGetColor(50, 50)
        if (firstCheck) {
            if (color != 0xFFFFFF) {
                myGui["StatusBar"].Text := "加载颜色异常: " color
                return false
            }
            firstCheck := false
        }
        else {
            if (color != 0xFFFFFF) {
                myGui["StatusBar"].Text := "加载完成"
                break
            }
            myGui["StatusBar"].Text := "加载中... 计数: " counter
        }
        Sleep 100
        counter++
        if (counter > 50) {
            myGui["StatusBar"].Text := "加载超时"
            return false
        }
    }
    myGui["StatusBar"].Text := "等待关门动画"
    Sleep 2500  ; 关门动画
    myGui["StatusBar"].Text := "完成传送"
    return true
}

_GinormosiaRefresh() {
    myGui["StatusBar"].Text := "刷新无垠大陆等级"
    MySend "f"
    Sleep 500
    MySend "Space"
    Sleep 500
    color := PixelGetColor(1327, 337)  ; "区"颜色
    if (color != 0xF8F0DC) {
        myGui["StatusBar"].Text := "“区”颜色异常: " color
        return false
    }
    MySend "Space"
    Sleep 1000
    myGui["StatusBar"].Text := "检查等级"
    counter := 0
    while (true) {
        color := PixelGetColor(151, 295)  ; 等级标识颜色
        if (color == 0x978056) {
            myGui["StatusBar"].Text := "当前等级未解锁，尝试下一级"
            MySend "e"
        }
        else if (color == 0x086400) {
            myGui["StatusBar"].Text := "当前等级已选择，尝试下一级"
            MySend "e"
        }
        else if (color == 0x3C2918) {
            myGui["StatusBar"].Text := "当前等级可选择"
            MySend "Space"
            break
        }
        else {
            myGui["StatusBar"].Text := "等级颜色异常: " color
            return false
        }
        counter++
        if (counter > 7) {
            myGui["StatusBar"].Text := "未找到可选择等级"
            return false
        }
        Sleep 500
    }
    Sleep 500
    color := PixelGetColor(975, 913)  ; "OK"颜色
    if (color != 0xF8F0DC) {
        myGui["StatusBar"].Text := "OK颜色异常: " color
        return false
    }
    myGui["StatusBar"].Text := "确认选择"
    MySend "Space"
    Sleep 1000
    MySend "Escape"
    Sleep 500
    MySend "m"
    myGui["StatusBar"].Text := "检查地图"
    return true
}

_GinormosiaCheck() {
    questList := [
        ["龙瞳山地", true, 960, 152, 0x13A6CD],  ; 传奇任务蓝色
        ["龙鼻山地", true, 336, 749, 0x13A6CD],  ; 传奇任务蓝色
        ["蜿蜒山峰", true, 1146, 153, 0x13A6CD],  ; 传奇任务蓝色
        ["落羽之森", true, 1775, 589, 0x13A6CD],  ; 传奇任务蓝色
        ["菇菇秘境", true, 1630, 314, 0x13A6CD],  ; 传奇任务蓝色
        ["翼尖峡谷", true, 1538, 260, 0x13A6CD],  ; 传奇任务蓝色
        ["干涸沙漠西部", true, 1200, 947, 0x13A6CD],  ; 传奇任务蓝色
        ["干涸沙漠东部", true, 1546, 845, 0x13A6CD],  ; 传奇任务蓝色
        ["龙牙群岛", false, 1233, 170, 0x089ACA],
        ["绿意台地", false, 1733, 687, 0x3BE2AE],
        ["巨腹大平原南部", false, 1861, 944, 0xF2A057],  ; 胡萝卜颜色
        ["巨腹大平原西部", false, 1544, 264, 0x13A6CD],  ; 传奇任务蓝色，和翼尖峡谷有overlap
    ]
    colorVar := 0x10
    range := 10
    questID := 0
    Sleep 500
    loop questList.Length {
        quest := questList[A_Index]
        myGui["StatusBar"].Text := "检查任务: " quest[1]
        xs := quest[3]
        ys := quest[4]
        color := quest[5]
        check := PixelSearch(&x, &y, xs - range, ys - range, xs + range, ys + range, color, colorVar)
        if (check) {
            questID := A_Index
            break
        }
    }
    if (questID == 0) {
        myGui["StatusBar"].Text := "未检测到任务"
    }
    else {
        if questList[questID][2] {
            myGui["StatusBar"].Text := "重要任务：" questList[questID][1]
            SoundBeep 2500, 500
        }
        else {
            myGui["StatusBar"].Text := "普通任务：" questList[questID][1]
        }
    }
}

_KillWithHold() {
    holdTime := myGui["vMimicHoldTime"].Value
    waitTime := myGui["vMimicWaitTime"].Value
    forwardTime := myGui["vMimicForwardTime"].Value
    backwardTime := myGui["vMimicBackwardTime"].Value
    myGui["StatusBar"].Text := "前进同时蓄力"
    Send "{e down}{w down}"
    Sleep holdTime  ; 前进并蓄力
    myGui["StatusBar"].Text := "释放技能"
    Send "{w up}{e up}"
    Sleep waitTime  ; 技能后摇
    myGui["StatusBar"].Text := "自动归位"
    MySend "w", forwardTime  ; 前进拿树枝
    MySend "s", backwardTime  ; 后退
}

_PlantSingleSapling() {
    myGui["StatusBar"].Text := "选择重新种植"
    MySend "s"
    Sleep 100
    MySend "s"
    Sleep 100
    color := PixelGetColor(1324, 432)  ; “重”字颜色
    if (color != 0xD1C5B3) {
        myGui["StatusBar"].Text := "“重”颜色异常: " color
        return false
    }
    MySend "Space"
    Sleep 1000
    myGui["StatusBar"].Text := "选择年代"
    key := (myGui["GroveSelectDirection"].Value = 1) ? "w" : "s"
    num := myGui["GroveSelectNum"].Value
    loop num {
        MySend key
        Sleep 100
    }
    Sleep 100
    MySend "Space"
    Sleep 500
    MySend "a"
    Sleep 100
    color := PixelGetColor(704, 927)  ; “是”字颜色
    if (color != 0xF8F0DC) {
        myGui["StatusBar"].Text := "“是”颜色异常: " color
        return false
    }
    MySend "Space"
    myGui["StatusBar"].Text := "等待新的迷宫树"
    Sleep 4000
    MySend "Space"
    Sleep 500
    color := PixelGetColor(119, 62)  ; 迷宫树logo颜色
    if (color != 0xFAE5B5) {
        myGui["StatusBar"].Text := "迷宫树logo颜色异常: " color
        return false
    }
    myGui["StatusBar"].Text := "查看迷宫树"
    return true
}

_SaveCloud() {
    myGui["StatusBar"].Text := "保存云数据"
    _ToggleMenu()
    MySend "x"
    Sleep 1000
    color := PixelGetColor(961, 177)  ; 顶部感叹号背景颜色
    if (color != 0xFFB914) {
        myGui["StatusBar"].Text := "顶部感叹号背景颜色异常: " color
        return false
    }
    color := PixelGetColor(1234, 442) ; 云存档选择颜色
    if (color != 0x5CE93F) {
        if (color == 0xB39770) {
            myGui["StatusBar"].Text := "云存档未选择"
            MySend "c"
            Sleep 300
            color := PixelGetColor(1234, 442) ; 再次检查
        }
        myGui["StatusBar"].Text := "云存档颜色异常: " color
        return false
    }
    myGui["StatusBar"].Text := "确认保存"
    MySend "a"
    Sleep 3000
    MySend "Space"
    counter := 0
    while (true) {  ; 等待覆盖完成
        color := PixelGetColor(975, 915)  ; OK颜色
        if (color == 0xF8F0DC) {
            myGui["StatusBar"].Text := "覆盖完成"
            break
        }
        myGui["StatusBar"].Text := "等待覆盖中... 计数: " counter
        Sleep 1000
        counter++
    }
    Sleep 1000
    MySend "Space"
    Sleep 1000
    _ToggleMenu()
    myGui["StatusBar"].Text := "云数据保存完成"
    return true
}

_LoadCloud() {
    myGui["StatusBar"].Text := "加载云数据"
    _ToggleMenu()
    MySend "Ctrl"  ; Ctrl
    Sleep 500
    myGui["StatusBar"].Text := "返回标题画面"
    MySend "a"
    Sleep 500
    MySend "Space"
    counter := 0
    while (true) {  ; 等待加载
        color := PixelGetColor(1204, 342)  ; "i"颜色
        if (color == 0x030300) {
            myGui["StatusBar"].Text := "加载完成"
            break
        }
        myGui["StatusBar"].Text := "等待加载中... 计数: " counter
        Sleep 1000
        counter++
    }
    Sleep 1000
    myGui["StatusBar"].Text := "任意键"
    MySend "Space"
    Sleep 1000
    color := PixelGetColor(1352, 963)  ; "X"颜色
    if (color != 0xFFF8E4) {
        myGui["StatusBar"].Text := "X颜色异常: " color
        return false
    }
    myGui["StatusBar"].Text := "选择云存档"
    MySend "x"
    Sleep 2000
    counter := 0
    while (true) {  ; 等待云存档检测
        color := PixelGetColor(971, 910)  ;  "绑定"颜色
        if (color == 0x704215) {
            myGui["StatusBar"].Text := "Epic绑定完成"
            Sleep 200
            MySend "Space"
        }
        color := PixelGetColor(961, 177)  ; 顶部感叹号背景颜色
        if (color == 0xFFB914) {
            myGui["StatusBar"].Text := "云存档检测完成"
            break
        }
        myGui["StatusBar"].Text := "等待云存档检测中... 计数: " counter
        Sleep 1000
        counter++
    }
    myGui["StatusBar"].Text := "初次确认"
    MySend "a"
    Sleep 1000
    MySend "Space"
    Sleep 1000
    myGui["StatusBar"].Text := "再次确认"
    MySend "a"
    Sleep 1000
    MySend "Space"
    counter := 0
    while (true) {  ; 等待加载完成
        color := PixelGetColor(975, 863)  ; "OK"颜色
        if (color == 0xF8F0DC) {
            myGui["StatusBar"].Text := "加载完成"
            break
        }
        myGui["StatusBar"].Text := "等待加载中... 计数: " counter
        Sleep 1000
        counter++
    }
    MySend "Space"
    myGui["StatusBar"].Text := "覆盖完成"
    return true
}

_CloudLoadDone() {
    ; 只适用于在扭蛋迷宫树前的加载后检测（其他地图背包位置不同）
    counter := 0
    while (true) {  ; 等待游戏界面
        color := PixelGetColor(1480, 970)  ; 背包颜色
        if (color == 0xDFAC5F) {
            break
        }
        myGui["StatusBar"].Text := "等待游戏界面中... 计数: " counter
        Sleep 1000
        counter++
    }
    myGui["StatusBar"].Text := "游戏界面已加载"
}

_AgingCheck() {
    myGui["StatusBar"].Text := "开始熟成"
    MySend "f"
    Sleep 500
    MySend "Space"
    counter := 0
    while (true) {
        color := PixelGetColor(812, 128)  ; "熟成成功"背景颜色
        if (color == 0xE88536) {
            myGui["StatusBar"].Text := "熟成成功"
            break
        }
        myGui["StatusBar"].Text := "等待熟成中... 计数: " counter
        Sleep 1000
        counter++
    }
    return true
}

_OnlineJoin() {
    myGui["StatusBar"].Text := "前进"
    myPress("w")
    counter := 0
    while (true) {
        color := PixelGetColor(1012, 413)  ; "F"颜色
        if (color == 0xFFF8E4) {
            MyRelease("w")
            break
        }
        myGui["StatusBar"].Text := "等待对话中... 计数: " counter
        Sleep 1000
        counter++
    }
    myGui["StatusBar"].Text := "开始对话"
    MySend("f")
    Sleep 1500
    MySend("Space")
    Sleep 1000
    MySend("Space")
    myGui["StatusBar"].Text := "等待保存"
    counter := 0
    while (true) {
        color := PixelGetColor(240, 77)  ; "联"颜色
        if (color == 0xF9F1DD) {
            break
        }
        myGui["StatusBar"].Text := "等待保存中... 计数: " counter
        Sleep 500
        counter++
    }
    myGui["StatusBar"].Text := "选择加入"
    Sleep 200
    MySend("d")
    Sleep 200
    MySend("Space")
    Sleep 1000
    MySend("s")
    Sleep 200
    MySend("Space")
    Sleep 1000
    myGui["StatusBar"].Text := "输入关键词"
    keyword := myGui["OnlineKeyword"].Text
    if (keyword == "") {
        myGui["StatusBar"].Text := "关键词不能为空"
        return false
    }
    MySend("Space")
    Sleep 500
    SendText keyword
    Sleep 500
    MySend("Enter")
    Sleep 500
    MySend("Tab")
    counter := 0
    while (true) {
        color := PixelGetColor(327, 65)  ; "览"颜色
        if (color == 0xF9F1DD) {
            break
        }
        myGui["StatusBar"].Text := "搜索中... 计数: " counter
        Sleep 500
        counter++
    }
    myGui["StatusBar"].Text := "已暂停，选中房间后按F3继续"
    Pause()
    myGui["StatusBar"].Text := "继续拜访"
    Sleep 500
    MySend("Space")
    Sleep 500
    MySend("Space")  ; 确认拜访
    Sleep 1000
    myGui["StatusBar"].Text := "输入密码"
    password := myGui["OnlinePassword"].Text
    if (password == "") {
        password := myGui["OnlineKeyword"].Text
    }
    SendText password
    Sleep 800
    MySend("Enter")
    counter := 0
    while (true) {
        color := PixelGetColor(1000, 140)  ; 蓝天颜色
        if (color == 0x1595D7) {
            myGui["StatusBar"].Text := "加入成功"
            break
        }
        myGui["StatusBar"].Text := "加入中... 计数: " counter
        Sleep 1000
        counter++
    }
    return true
}

_OnlineExit() {
    myGui["StatusBar"].Text := "退出房间"
    _ToggleMenu()
    MySend "q"
    Sleep 200
    MySend "w"
    Sleep 200
    MySend "a"
    Sleep 200
    MySend "Space"
    Sleep 500
    MySend "Space"
    Sleep 1000
    myGui["StatusBar"].Text := "已退出房间"
}

BuildGuiForGameWindow() {
    myGui.AddButton("xs+10 ys+20 v_GameWindowActivate", "激活游戏窗口")
    myGui.AddText("xp w280 r4 vGameWindowStatus", "")
}

CheckGameWindow(*) {
    if !WinExist("ahk_exe NFL1-Win64-Shipping.exe") {
        myGui["GameWindowStatus"].Text := "游戏窗口未找到"
        return false
    }
    pid := WinGetPID("ahk_exe NFL1-Win64-Shipping.exe")
    WinGetClientPos(&x, &y, &w, &h, "ahk_pid " pid)
    myGui["GameWindowStatus"].Text := (
        "游戏窗口信息：`n"
        "PID：" pid "`n"
        "位置：(" x ", " y ")`n"
        "大小：" w "x" h "`n"
    )
    return true
}

_GameWindowActivate(*) {
    if !CheckGameWindow() {
        myGui["StatusBar"].Text := "游戏窗口未找到"
        return
    }
    myGui["StatusBar"].Text := "尝试激活游戏窗口"
    WinActivate("ahk_exe NFL1-Win64-Shipping.exe")
    WinWaitActive("ahk_exe NFL1-Win64-Shipping.exe")
    if !WinActive("ahk_exe NFL1-Win64-Shipping.exe") {
        myGui["StatusBar"].Text := "游戏窗口未激活"
        return false
    }
    myGui["StatusBar"].Text := "游戏窗口已激活"
    return true
}

BuildGuiForReduxStone() {
    myGui.AddEdit("xs+10 ys+20 w50")
    myGui.AddUpDown("vReduxStoneNum Range1-999", 100)
    myGui.AddText("xp+60 w60 hp 0x200", "数量(1-999)")
    myGui.AddButton("xp+70 w40 vBuyReduxStone", "购买")
    myGui.AddButton("xp+50 wp vSellReduxStone", "出售")
}

BuyReduxStone(*) {
    if !_GameWindowActivate() {
        return
    }
    num := myGui["ReduxStoneNum"].Value
    loop num {
        myGui["StatusBar"].Text := "正在购买" A_Index " / " num "个..."
        _BuyItem()
    }
    myGui["StatusBar"].Text := "已购买 " num " 个"
}

SellReduxStone(*) {
    if !_GameWindowActivate() {
        return
    }
    num := myGui["ReduxStoneNum"].Value
    loop num {
        myGui["StatusBar"].Text := "正在选择" A_Index " / " num "个..."
        _SelectItemAndGoUp()
    }
    myGui["StatusBar"].Text := "已选择 " num " 个"
}

BuildGuiForTeleportationGate() {
    myGui.AddButton("xs+10 ys+20 vTeleportationGateSingleTrip", "单程")
    myGui.AddButton("yp vTeleportationGateReturnTrip", "往返")
}

TeleportationGateSingleTrip(*) {
    if !_GameWindowActivate() {
        return
    }
    if !_TeleportationGateSingleTrip() {
        return
    }
    myGui["StatusBar"].Text := "单次传送完成"
}

TeleportationGateReturnTrip(*) {
    if !_GameWindowActivate() {
        return
    }
    if !_TeleportationGateSingleTrip() {
        return
    }
    Sleep 500
    if !_TeleportationGateSingleTrip() {
        return
    }
    myGui["StatusBar"].Text := "往返传送完成"
}

BuildGuiForGinormosia() {
    myGui.AddButton("xs+10 ys+20 vGinormosiaRefresh", "刷新等级")
    myGui.AddButton("yp vGinormosiaCheck", "检查任务类型")
}

GinormosiaRefresh(*) {
    if !_GameWindowActivate() {
        return
    }
    MySend "Escape"  ; 退出地图
    Sleep 500
    if !_GinormosiaRefresh() {
        return
    }
    _GinormosiaCheck()
}

GinormosiaCheck(*) {
    if !_GameWindowActivate() {
        return
    }
    _GinormosiaCheck()
}

BuildGuiForMimic() {
    myGui.AddText("xs+10 ys+20 h22 0x200", "前进蓄力")
    myGui.AddEdit("yp w48 hp")
    myGui.AddUpDown("vMimicHoldTime Range1-3000", 1050)
    myGui.AddText("yp hp 0x200", "毫秒")
    myGui.AddText("yp w10 hp", "")
    myGui.AddText("yp hp 0x200", "技能后摇")
    myGui.AddEdit("yp w48 hp")
    myGui.AddUpDown("vMimicWaitTime Range1-3000", 2200)
    myGui.AddText("yp hp 0x200", "毫秒")
    myGui.AddText("xs+10 ys+50 h22 0x200", "归位前进")
    myGui.AddEdit("yp w48 hp")
    myGui.AddUpDown("vMimicForwardTime Range1-3000", 700)
    myGui.AddText("yp hp 0x200", "毫秒")
    myGui.AddText("yp w10 hp", "")
    myGui.AddText("yp hp 0x200", "归位后退")
    myGui.AddEdit("yp w48 hp")
    myGui.AddUpDown("vMimicBackwardTime Range1-3000", 920)
    myGui.AddText("yp hp 0x200", "毫秒")
    myGui.AddButton("xs+10 ys+80 vMimicSingleKill", "单次击杀")
    myGui.AddText("yp w40", "")
    myGui.AddEdit("yp w36")
    myGui.AddUpDown("vMimicNum Range1-99", 10)
    myGui.AddText("yp hp 0x200", "数量(1-99)")
    myGui.AddButton("yp vMimicBatchKill", "批量击杀")
}

MimicSingleKill(*) {
    if !_GameWindowActivate() {
        return
    }
    _KillWithHold()
}

MimicBatchKill(*) {
    if !_GameWindowActivate() {
        return
    }
    num := myGui["MimicNum"].Value
    loop num {
        myGui["StatusBar"].Text := "正在击杀第" A_Index " / " num "个宝箱..."
        if !_TeleportationGateSingleTrip() {
            return
        }
        Sleep 500
        if !_TeleportationGateSingleTrip() {
            return
        }
        _KillWithHold()
        waitTime := 3
        loop waitTime {
            myGui["StatusBar"].Text := "等待手动归位..." (waitTime - A_Index)
            sleep 1000
        }
    }
    myGui["StatusBar"].Text := "已击杀 " num " 个宝箱"
}

BuildGuiForGrove() {
    myGui.AddText("xs+10 ys+20 h22 0x200", "年代选择：向")
    myGui.AddComboBox("yp w36 vGroveSelectDirection Choose2", ["上", "下"])
    myGui.AddEdit("yp w36")
    myGui.AddUpDown("vGroveSelectNum Range0-10", 1)
    myGui.AddText("yp hp 0x200", "次")
    myGui.AddButton("xs+10 ys+50 vPlantSapling", "种植")
    myGui.AddButton("yp hp vPlantSaplingNext", "退出并重新种植")
}

PlantSapling(*) {
    if !_GameWindowActivate() {
        return
    }
    _PlantSingleSapling()
}

PlantSaplingNext(*) {
    if !_GameWindowActivate() {
        return
    }
    MySend "Escape"
    Sleep 2000
    _PlantSingleSapling()
}

BuildGuiForSaveLoad() {
    myGui.AddButton("xs+10 ys+20 vSaveCloud", "保存")
    myGui.AddButton("yp vLoadCloud", "加载")
}

SaveCloud(*) {
    if !_GameWindowActivate() {
        return
    }
    myGui["StatusBar"].Text := "正在保存云数据..."
    if !_SaveCloud() {
        return
    }
    myGui["StatusBar"].Text := "云数据保存完成"
}

LoadCloud(*) {
    if !_GameWindowActivate() {
        return
    }
    myGui["StatusBar"].Text := "正在加载云数据..."
    if !_LoadCloud() {
        return
    }
    myGui["StatusBar"].Text := "云数据加载完成"
}

BuildGuiForAging() {
    myGui.AddButton("xs+10 ys+20 vAgingCheck", "检查属性")
    myGui.AddButton("yp vAgingNext", "SL并检查属性")
}

AgingCheck(*) {
    if !_GameWindowActivate() {
        return
    }
    if !_AgingCheck() {  ; 检查属性
        return
    }
}

AgingNext(*) {
    if !_GameWindowActivate() {
        return
    }
    MySend "Space"  ; 确认属性
    Sleep 1000
    if !_LoadCloud() {  ; 加载云数据
        return
    }
    if !_CloudLoadDone() {  ; 等待界面加载
        return
    }
    Sleep 2000
    if !_AgingCheck() {  ; 检查属性
        return
    }
}

BuildGuiForOnline() {
    myGui.AddText("xs+10 ys+20 w36 h22 0x200", "关键词")
    myGui.AddEdit("xp+40 w60 vOnlineKeyword", "")
    myGui.AddText("xp+70 w36 h22 0x200", "密码")
    myGui.AddEdit("xp+40 w60 vOnlinePassword", "")
    myGui.AddButton("xs+10 ys+50 vOnlineJoin", "加入")
    myGui.AddButton("yp vOnlineExit", "退出")
    myGui.AddButton("yp vOnlineNext", "退出并重新加入")
}

OnlineJoin(*) {
    if !_GameWindowActivate() {
        return
    }
    if !_OnlineJoin() {
        return
    }
}

OnlineExit(*) {
    if !_GameWindowActivate() {
        return
    }
    _OnlineExit()
}

OnlineNext(*) {
    if !_GameWindowActivate() {
        return
    }
    while true {
        _OnlineExit()
        if !_OnlineJoin() {
            return
        }
        myGui["StatusBar"].Text := "已暂停，拿到惊魂器后按F3继续"
        Pause()
    }
}

BuildGuiForCraft() {
    myGui.AddText("xs+10 ys+20 h22 0x200", "长按：")
    myGui.AddEdit("yp w48 hp")
    myGui.AddUpDown("vCraftPressDelay Range1-3000", 1600)
    myGui.AddText("yp hp 0x200", "毫秒")
    myGui.AddText("xs+10 ys+50 h22 0x200", "连点：")
    myGui.AddEdit("yp w36 hp")
    myGui.AddUpDown("vCraftNumClick Range1-99", 6)
    myGui.AddText("yp hp 0x200", "次")
    myGui.AddText("xs+10 ys+80 h22 0x200", "画圈：")
    myGui.AddEdit("yp w36 hp")
    myGui.AddUpDown("vCraftNumPolygon Range1-99", 5)
    myGui.AddText("yp hp 0x200", "次边长为")
    myGui.AddEdit("yp w36 hp")
    myGui.AddUpDown("vCraftPolygonSideLength Range1-1000", 50)
    myGui.AddText("yp hp 0x200", "像素的")
    myGui.AddEdit("yp w36 hp")
    myGui.AddUpDown("vCraftPolygonNumSide Range1-99", 64)
    myGui.AddText("yp hp 0x200", "边形")
    myGui.AddButton("xs+10 ys+110 vCraft", "开始制作")
    myGui.AddButton("yp vCraftSingle", "单次制作")
    myGui.AddText("xs+10 ys+140 h22 0x200", "位置：")
    myGui.AddText("yp hp 0x200 vCraftPos", "中")
    myGui.AddText("yp hp 0x200", "行动：")
    myGui.AddText("yp w20 hp 0x200 vCraftAction", "0/0")
    myGui.AddButton("yp vCraftReset", "手动重置位置")
}

_CraftMouseX := [560, 960, 1360]
_CraftMouseY := [320, 504]
_CraftMouseLeftOffsetX := -20  ; 左键偏移
_CraftMouseTextOffsetY := -105  ; 文本偏移
_CraftLeftColor := "0xFFC9C5"  ; 粉色左键
_CraftGreenColor := "0x96F485"  ; 绿色文本
_CraftRedColor := "0xFFB190"  ; 红色文本
_CraftYellowColor := "0xFFF478"  ; 黄色文本

_CraftCheckActionType(xi, yi) {
    x := _CraftMouseX[xi]
    y := _CraftMouseY[yi]
    range := 1
    colorVar := 10
    foundLeft := PixelSearch(
        &xs, &ys,
        x + _CraftMouseLeftOffsetX - range, y - range,
        x + _CraftMouseLeftOffsetX + range, y + range,
        _CraftLeftColor, colorVar
    )
    foundGreenText := PixelSearch(
        &xs, &ys,
        x - range, y + _CraftMouseTextOffsetY - range,
        x + range, y + _CraftMouseTextOffsetY + range,
        _CraftGreenColor, colorVar
    )
    foundRedText := PixelSearch(
        &xs, &ys,
        x - range, y + _CraftMouseTextOffsetY - range,
        x + range, y + _CraftMouseTextOffsetY + range,
        _CraftRedColor, colorVar
    )
    foundYellowText := PixelSearch(
        &xs, &ys,
        x - range, y + _CraftMouseTextOffsetY - range,
        x + range, y + _CraftMouseTextOffsetY + range,
        _CraftYellowColor, colorVar
    )
    if foundLeft && !foundGreenText && !foundRedText && !foundYellowText
        return 1
    if foundGreenText
        return 2
    if foundRedText
        return 3
    if foundYellowText
        return 4
    return 0
}

_CraftGoNextPos(resetPos := false) {
    static currentPos := 2
    if resetPos {
        currentPos := 2
        myGui["CraftPos"].Text := "中"
        return 0
    }
    nextPos := 0
    counter := 0
    myGui["StatusBar"].Text := "正在识别下一次行动..."
    while true {
        loop 3 {
            xp := A_Index
            yp := (currentPos == xp) ? 1 : 2
            action := _CraftCheckActionType(xp, yp)
            if action != 0 {
                nextPos := xp
                break
            }
        }
        if (nextPos != 0) {
            break
        }
        counter++
        if (counter > 100) {
            myGui["StatusBar"].Text := "行动识别超时"
            return 0
        }
        color := PixelGetColor(962, 162)  ; "道具制作完成"背景颜色
        if (color == 0xE88536) {
            myGui["StatusBar"].Text := "检测到制作完成"
            return 0
        }
        Sleep 100
    }
    deltaPos := nextPos - currentPos
    if (deltaPos != 0) {
        myGui["StatusBar"].Text := "移动: " currentPos " -> " nextPos
        key := (deltaPos > 0) ? "d" : "a"
        deltaPos := Abs(deltaPos)
        loop deltaPos {
            MySend key
            Sleep 40
        }
        currentPos := nextPos
        switch currentPos {
            case 1:
                myGui["CraftPos"].Text := "左"
            case 2:
                myGui["CraftPos"].Text := "中"
            case 3:
                myGui["CraftPos"].Text := "右"
            default:
                myGui["CraftPos"].Text := "空"
        }
    }
    else {
        myGui["StatusBar"].Text := "不动"
    }
    return action
}

_CraftSingleAction() {
    pressDelay := myGui["CraftPressDelay"].Value
    numClick := myGui["CraftNumClick"].Value
    numPolygon := myGui["CraftNumPolygon"].Value
    polygonNumSide := myGui["CraftPolygonNumSide"].Value
    polygonSideLength := myGui["CraftPolygonSideLength"].Value
    action := _CraftGoNextPos()
    switch action {
        case 0:
            return false
        case 1:
            myGui["StatusBar"].Text := "单击"
            MySend "Space"
            Sleep 40
        case 2:
            myGui["StatusBar"].Text := "长按"
            MyPress "Space"
            Sleep pressDelay
            MyRelease "Space"
            Sleep 40
        case 3:
            myGui["StatusBar"].Text := "连按"
            loop numClick {
                MySend "Space"
                Sleep 40
            }
        case 4:
            myGui["StatusBar"].Text := "画圈"
            speed := 0
            delay := 0
            Pi := 3.141592653589793
            MouseMove(1920 // 2, 0, speed)  ; 移动鼠标到中间
            loop numPolygon {
                loop polygonNumSide {
                    side := A_Index
                    radian := (side - 1) / polygonNumSide * 2 * Pi
                    x := Round(Cos(radian) * polygonSideLength)
                    y := Round(Sin(radian) * polygonSideLength)
                    MouseMove(x, y, speed, "R")
                    myGui["StatusBar"].Text := side " / " polygonNumSide " 位置: (" x ", " y ")"
                    Sleep delay
                }
            }
    }
    return true
}

CraftReset(*) {
    if !_GameWindowActivate() {
        return
    }
    _CraftGoNextPos(resetPos := true)  ; 重置Pos
}

CraftSingle(*) {
    if !_GameWindowActivate() {
        return
    }
    _CraftSingleAction()
}

Craft(*) {
    if !_GameWindowActivate() {
        return
    }
    while (true) {
        if !_CraftSingleAction() {
            break
        }
        sleep 100
    }
}

BuildGuiForOthers() {
    myGui.AddEdit("xs+10 ys+20 w50")
    myGui.AddUpDown("vTestX Range1-1920", 1)
    myGui.AddEdit("xp+60 w50")
    myGui.AddUpDown("vTestY Range1-1080", 1)
    myGui.AddButton("xp+60 w60 vTestColor", "测试颜色")
}

_TestSend() {
    Sleep 1000
    myGui["StatusBar"].Text := "MySend Space"
    MySend "Space"
    Sleep 1000
    myGui["StatusBar"].Text := "MySend r"
    MySend "r"
    Sleep 1000
    myGui["StatusBar"].Text := "Send Space"
    Send "Space"
    Sleep 1000
    myGui["StatusBar"].Text := "Send r"
    Send "r"
    Sleep 1000
    myGui["StatusBar"].Text := "测试发送完成"
}

_TestColor() {
    color := PixelGetColor(myGui["TestX"].Value, myGui["TestY"].Value)
    myGui["StatusBar"].Text := "当前颜色: " color
}

TestColor(*) {
    xs := 1920 // 2
    ys := 1080 // 2
    numSide := 8
    width := 200
    speed := 0
    delay := 1
    Pi := 3.141592653589793
    sleep 1000
    MouseMove(xs, ys, speed)  ; 移动鼠标到窗口中心
    loop 3 {
        loop numSide {
            side := A_Index
            radian := (side - 1) / numSide * 2 * Pi
            x := Round(Cos(radian) * width)
            y := Round(Sin(radian) * width)
            MouseMove(x, y, speed, "R")
            myGui["StatusBar"].Text := side " / " numSide " 位置: (" x ", " y ")"
            Sleep delay
        }
    }
}
