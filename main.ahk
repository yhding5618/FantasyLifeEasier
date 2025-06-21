#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"
CoordMode "Pixel", "Client"

myGui := Gui(, "Fantasy Life Easier")
myGui.AddGroupBox('xm ym w240 h150 Section', '游戏窗口')
BuildGuiForGameWindow()
myGui.AddGroupBox('xs ys+160 w240 h50 Section', '重置石')
BuildGuiForReduxStone()
myGui.AddGroupBox('xs ys+60 w240 h50 Section', '任意门')
BuildGuiForTeleportationGate()
myGui.AddGroupBox('xs ys+60 w240 h50 Section', '传奇任务')
BuildGuiForGinormosia()
myGui.AddGroupBox('xs ys+60 w240 h80 Section', '宝箱怪')
BuildGuiForMimic()
myGui.AddGroupBox('xs ys+90 w240 h80 Section', '扭蛋迷宫树')
BuildGuiForGrove()
myGui.AddGroupBox('xs ys+90 w240 h50 Section', '云存档SL')
BuildGuiForSaveLoad()
myGui.AddGroupBox('xs ys+60 w240 h50 Section', '熟成')
BuildGuiForAging()
myGui.AddGroupBox('xs ys+60 w240 h80 Section', '在线功能')
BuildGuiForOnline()
myGui.AddGroupBox('xs ys+90 w240 h110 Section', '制作')
BuildGuiForCraft()
myGui.AddGroupBox('xs ys+120 w240 h50 Section', '其他功能')
BuildGuiForOthers()
myGui.AddStatusBar("vStatusBar", "StatusBar")
myGui.OnEvent('Close', (*) => ExitApp())
myGui['ActivateGameWindow'].OnEvent('Click', ActivateGameWindow)
myGui['BuyReduxStone'].OnEvent('Click', BuyReduxStone)
myGui['SellReduxStone'].OnEvent('Click', SellReduxStone)
myGui['UseTeleportationGate'].OnEvent('Click', UseTeleportationGate)
myGui['UseTeleportationGateReturn'].OnEvent('Click', UseTeleportationGateReturn)
myGui['GinormosiaOnce'].OnEvent('Click', GinormosiaOnce)
myGui['GinormosiaCheck'].OnEvent('Click', GinormosiaCheck)
myGui['KillMimicTest'].OnEvent('Click', KillMimicTest)
myGui['KillMimic'].OnEvent('Click', KillMimic)
myGui['PlantSaplingTest'].OnEvent('Click', PlantSaplingTest)
myGui['PlantSapling'].OnEvent('Click', PlantSapling)
myGui['SaveCloud'].OnEvent('Click', SaveCloud)
myGui['LoadCloud'].OnEvent('Click', LoadCloud)
myGui['AgingOnce'].OnEvent('Click', AgingOnce)
myGui['AgingNext'].OnEvent('Click', AgingNext)
myGui['CraftSingle'].OnEvent('Click', CraftSingle)
myGui['Craft'].OnEvent('Click', Craft)
myGui['OnlineJoin'].OnEvent('Click', OnlineJoin)
myGui['OnlineExit'].OnEvent('Click', OnlineExit)
myGui['OnlineNext'].OnEvent('Click', OnlineNext)
myGui['TestColor'].OnEvent('Click', TestColor)
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
    myGui['StatusBar'].Text := "切换Esc菜单"
    MySend "Escape"
    Sleep 750
}

_SingleTeleportationGate(*) {
    _ToggleMenu()
    color := PixelGetColor(666, 333)
    if (color != 0xE337DB && color != 0xE335DB) {
        if (color == 0x963681) {
            myGui['StatusBar'].Text := "任意门不可用"
            return false
        }
        myGui['StatusBar'].Text := "任意门颜色异常: " color
        return false
    }
    myGui['StatusBar'].Text := "选择任意门"
    MySend "Space"
    Sleep 750
    myGui['StatusBar'].Text := "确认"
    MySend "Space"
    myGui['StatusBar'].Text := "等待开门动画"
    Sleep 4200  ; 开门动画
    myGui['StatusBar'].Text := "等待加载"
    counter := 0
    firstCheck := true
    while (true) {  ; 等待加载
        color := PixelGetColor(50, 50)
        if (firstCheck) {
            if (color != 0xFFFFFF) {
                myGui['StatusBar'].Text := "加载颜色异常: " color
                return false
            }
            firstCheck := false
        }
        else {
            if (color != 0xFFFFFF) {
                myGui['StatusBar'].Text := "加载完成"
                break
            }
            myGui['StatusBar'].Text := "加载中... 计数: " counter
        }
        Sleep 100
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "加载超时"
            return false
        }
    }
    myGui['StatusBar'].Text := "等待关门动画"
    Sleep 2500  ; 关门动画
    myGui['StatusBar'].Text := "完成传送"
    return true
}

_GinormosiaOnce() {
    myGui['StatusBar'].Text := "刷新无垠大陆等级"
    MySend "f"
    Sleep 500
    MySend "Space"
    Sleep 500
    color := PixelGetColor(1327, 337)  ; "区"颜色
    if (color != 0xF8F0DC) {
        myGui['StatusBar'].Text := "“区”颜色异常: " color
        return false
    }
    MySend "Space"
    Sleep 1000
    myGui['StatusBar'].Text := "检查等级"
    counter := 0
    while (true) {
        color := PixelGetColor(151, 295)  ; 等级标识颜色
        if (color == 0x978056) {
            myGui['StatusBar'].Text := "当前等级未解锁，尝试下一级"
            MySend "e"
        }
        else if (color == 0x086400) {
            myGui['StatusBar'].Text := "当前等级已选择，尝试下一级"
            MySend "e"
        }
        else if (color == 0x3C2918) {
            myGui['StatusBar'].Text := "当前等级可选择"
            MySend "Space"
            break
        }
        else {
            myGui['StatusBar'].Text := "等级颜色异常: " color
            return false
        }
        counter++
        if (counter > 7) {
            myGui['StatusBar'].Text := "等级选择超时"
            return false
        }
        Sleep 500
    }
    Sleep 500
    color := PixelGetColor(975, 913)  ; "OK"颜色
    if (color != 0xF8F0DC) {
        myGui['StatusBar'].Text := "OK颜色异常: " color
        return false
    }
    myGui['StatusBar'].Text := "确认选择"
    MySend "Space"
    Sleep 1000
    MySend "Escape"
    Sleep 500
    MySend "m"
    myGui['StatusBar'].Text := "检查地图"
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
        myGui['StatusBar'].Text := "检查任务: " quest[1]
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
        myGui['StatusBar'].Text := "未检测到任务"
    }
    else {
        if questList[questID][2] {
            myGui['StatusBar'].Text := "重要任务：" questList[questID][1]
            SoundBeep 2500, 500
        }
        else {
            myGui['StatusBar'].Text := "普通任务：" questList[questID][1]
        }
    }
}

_KillWithShortHold() {
    myGui['StatusBar'].Text := "前进同时蓄力"
    Send "{e down}{w down}"
    Sleep 1050
    myGui['StatusBar'].Text := "释放技能"
    Send "{w up}{e up}"
    Sleep 2200  ; 技能后摇
    myGui['StatusBar'].Text := "自动归位"
    wTime := 700
    MySend "w", wTime  ; 前进
    MySend "s", wTime + 220  ; 后退
}

_KillWithLongHold() {
    myGui['StatusBar'].Text := "前进同时蓄力"
    Send "{e down}{w down}"
    Sleep 450
    Send "{w up}"
    Sleep 1200
    myGui['StatusBar'].Text := "释放技能"
    Send "{e up}"
    Sleep 2200  ; 技能后摇
    myGui['StatusBar'].Text := "自动归位"
    MySend "w", 500  ; 前进
    MySend "s", 400  ; 后退
}

_PlantSingleSapling() {
    myGui['StatusBar'].Text := "选择重新种植"
    MySend "s"
    Sleep 100
    MySend "s"
    Sleep 100
    color := PixelGetColor(1324, 432)  ; “重”字颜色
    if (color != 0xD1C5B3) {
        myGui['StatusBar'].Text := "“重”颜色异常: " color
        return false
    }
    MySend "Space"
    Sleep 1000
    myGui['StatusBar'].Text := "选择年代"
    key := (myGui['GroveSelectDirection'].Value = 1) ? "w" : "s"
    num := myGui['GroveSelectMove'].Value
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
        myGui['StatusBar'].Text := "“是”颜色异常: " color
        return false
    }
    MySend "Space"
    myGui['StatusBar'].Text := "等待新的迷宫树"
    Sleep 4000
    MySend "Space"
    Sleep 500
    color := PixelGetColor(119, 62)  ; 迷宫树logo颜色
    if (color != 0xFAE5B5) {
        myGui['StatusBar'].Text := "迷宫树logo颜色异常: " color
        return false
    }
    myGui['StatusBar'].Text := "查看迷宫树"
    return true
}

_SaveCloud() {
    myGui['StatusBar'].Text := "保存云数据"
    _ToggleMenu()
    MySend "x"
    Sleep 1000
    color := PixelGetColor(961, 177)  ; 顶部感叹号背景颜色
    if (color != 0xFFB914) {
        myGui['StatusBar'].Text := "顶部感叹号背景颜色异常: " color
        return false
    }
    color := PixelGetColor(1234, 442) ; 云存档选择颜色
    if (color != 0x5CE93F) {
        if (color == 0xB39770) {
            myGui['StatusBar'].Text := "云存档未选择"
            MySend "c"
            Sleep 300
            color := PixelGetColor(1234, 442) ; 再次检查
        }
        myGui['StatusBar'].Text := "云存档颜色异常: " color
        return false
    }
    myGui['StatusBar'].Text := "确认保存"
    MySend "a"
    Sleep 3000
    MySend "Space"
    counter := 0
    while (true) {  ; 等待覆盖完成
        color := PixelGetColor(975, 915)  ; OK颜色
        if (color == 0xF8F0DC) {
            myGui['StatusBar'].Text := "覆盖完成"
            break
        }
        myGui['StatusBar'].Text := "等待覆盖中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "覆盖超时"
            return false
        }
    }
    Sleep 1000
    MySend "Space"
    Sleep 1000
    _ToggleMenu()
    myGui['StatusBar'].Text := "云数据保存完成"
    return true
}

_LoadCloud() {
    myGui['StatusBar'].Text := "加载云数据"
    _ToggleMenu()
    MySend "Ctrl"  ; Ctrl
    Sleep 500
    myGui['StatusBar'].Text := "返回标题画面"
    MySend "a"
    Sleep 500
    MySend "Space"
    counter := 0
    while (true) {  ; 等待加载
        color := PixelGetColor(1204, 342)  ; "i"颜色
        if (color == 0x030300) {
            myGui['StatusBar'].Text := "加载完成"
            break
        }
        myGui['StatusBar'].Text := "等待加载中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "加载超时"
            return false
        }
    }
    Sleep 1000
    myGui['StatusBar'].Text := "任意键"
    MySend "Space"
    Sleep 1000
    color := PixelGetColor(1352, 963)  ; "X"颜色
    if (color != 0xFFF8E4) {
        myGui['StatusBar'].Text := "X颜色异常: " color
        return false
    }
    myGui['StatusBar'].Text := "选择云存档"
    MySend "x"
    Sleep 2000
    counter := 0
    while (true) {  ; 等待云存档检测
        color := PixelGetColor(971, 910)  ;  "绑定"颜色
        if (color == 0x704215) {
            myGui['StatusBar'].Text := "Epic绑定完成"
            Sleep 200
            MySend "Space"
        }
        color := PixelGetColor(961, 177)  ; 顶部感叹号背景颜色
        if (color == 0xFFB914) {
            myGui['StatusBar'].Text := "云存档检测完成"
            break
        }
        myGui['StatusBar'].Text := "等待云存档检测中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "云存档检测超时"
            return false
        }
    }
    myGui['StatusBar'].Text := "初次确认"
    MySend "a"
    Sleep 2000
    MySend "Space"
    Sleep 1000
    myGui['StatusBar'].Text := "再次确认"
    MySend "a"
    Sleep 2000
    MySend "Space"
    counter := 0
    while (true) {  ; 等待加载完成
        color := PixelGetColor(975, 863)  ; "OK"颜色
        if (color == 0xF8F0DC) {
            myGui['StatusBar'].Text := "加载完成"
            break
        }
        myGui['StatusBar'].Text := "等待加载中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "加载超时"
            return false
        }
    }
    MySend "Space"
    myGui['StatusBar'].Text := "覆盖完成"
    counter := 0
    while (true) {  ; 等待游戏界面
        color := PixelGetColor(1480, 970)  ; 背包颜色
        if (color == 0xDFAC5F) {
            break
        }
        myGui['StatusBar'].Text := "等待游戏界面中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "游戏界面超时"
            return false
        }
    }
    myGui['StatusBar'].Text := "游戏界面已加载"
    return true
}

_AgingOnce() {
    myGui['StatusBar'].Text := "开始熟成"
    MySend "f"
    Sleep 500
    MySend "Space"
    counter := 0
    while (true) {
        color := PixelGetColor(812, 128)  ; "熟成成功"背景颜色
        if (color == 0xE88536) {
            myGui['StatusBar'].Text := "熟成成功"
            break
        }
        myGui['StatusBar'].Text := "等待熟成中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "熟成超时"
            return false
        }
    }
    return true
}

_OnlineJoin() {
    myGui['StatusBar'].Text := "前进"
    myPress("w")
    counter := 0
    while (true) {
        color := PixelGetColor(1012, 413)  ; "F"颜色
        if (color == 0xFFF8E4) {
            MyRelease("w")
            break
        }
        myGui['StatusBar'].Text := "等待对话中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "对话超时"
            MyRelease("w")
            return false
        }
    }
    myGui['StatusBar'].Text := "开始对话"
    MySend("f")
    Sleep 1500
    MySend("Space")
    Sleep 1000
    MySend("Space")
    myGui['StatusBar'].Text := "等待保存"
    counter := 0
    while (true) {
        color := PixelGetColor(240, 77)  ; "联"颜色
        if (color == 0xF9F1DD) {
            break
        }
        myGui['StatusBar'].Text := "等待保存中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "保存超时"
            return false
        }
    }
    myGui['StatusBar'].Text := "选择加入"
    Sleep 200
    MySend("d")
    Sleep 200
    MySend("Space")
    Sleep 1000
    MySend("s")
    Sleep 200
    MySend("Space")
    Sleep 1000
    myGui['StatusBar'].Text := "输入关键词"
    keyword := myGui['OnlineKeyword'].Text
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
        myGui['StatusBar'].Text := "搜索中... 计数: " counter
        Sleep 500
        counter++
        if (counter > 50) {
            myGui['StatusBar'].Text := "搜索超时"
            return false
        }
    }
    myGui['StatusBar'].Text := "已暂停，选中房间后按F3继续"
    Pause()
    myGui['StatusBar'].Text := "继续拜访"
    Sleep 500
    MySend("Space")
    Sleep 500
    MySend("Space")  ; 确认拜访
    Sleep 1000
    myGui['StatusBar'].Text := "输入密码"
    password := myGui['OnlinePassword'].Text
    if (password == "") {
        password := myGui['OnlineKeyword'].Text
    }
    SendText password
    Sleep 800
    MySend("Enter")
    counter := 0
    while (true) {
        color := PixelGetColor(1000, 140)  ; 蓝天颜色
        if (color == 0x1595D7) {
            myGui['StatusBar'].Text := "加入成功"
            break
        }
        myGui['StatusBar'].Text := "加入中... 计数: " counter
        Sleep 1000
        counter++
        if (counter > 60) {
            myGui['StatusBar'].Text := "加入超时"
            return false
        }
    }
    return true
}

_OnlineExit() {
    myGui['StatusBar'].Text := "退出房间"
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
    myGui['StatusBar'].Text := "已退出房间"
}

BuildGuiForGameWindow() {
    myGui.AddButton("xs+10 ys+20 vActivateGameWindow", "激活游戏窗口")
    myGui.AddText("xs+10 ys+50 w220 r4 vGameWindowStatus", "")
}

CheckGameWindow(*) {
    if !WinExist("ahk_exe NFL1-Win64-Shipping.exe") {
        myGui['GameWindowStatus'].Text := "游戏窗口未找到"
        return false
    }
    pid := WinGetPID("ahk_exe NFL1-Win64-Shipping.exe")
    WinGetClientPos(&x, &y, &w, &h, "ahk_pid " pid)
    myGui['GameWindowStatus'].Text := (
        "游戏窗口信息：`n"
        "PID：" pid "`n"
        "位置：(" x ", " y ")`n"
        "大小：" w "x" h "`n"
    )
    return true
}

ActivateGameWindow(*) {
    if !CheckGameWindow() {
        myGui['StatusBar'].Text := "游戏窗口未找到"
        return
    }
    myGui['StatusBar'].Text := "尝试激活游戏窗口"
    WinActivate("ahk_exe NFL1-Win64-Shipping.exe")
    WinWaitActive("ahk_exe NFL1-Win64-Shipping.exe")
    if !WinActive("ahk_exe NFL1-Win64-Shipping.exe") {
        myGui['StatusBar'].Text := "游戏窗口未激活"
        return false
    }
    myGui['StatusBar'].Text := "游戏窗口已激活"
    return true
}

BuildGuiForReduxStone() {
    myGui.AddEdit("xs+10 ys+20 w50")
    myGui.AddUpDown("vReduxStoneNum Range1-999", 100)
    myGui.AddText("xp+60 w60 hp 0x200", "数量(1-999)")
    myGui.AddButton("xp+70 w40 vBuyReduxStone", "购买")
    myGui.AddButton("xp+50 wp vSellReduxStone", "出售")
    ; myGui.AddText("xs+10 ys+50 w220",
    ;     "购买（重复按两次空格）：`n"
    ;     "1. 游戏内定位到长披风`n"
    ;     "2. 选择数量并点击购买按钮`n"
    ;     "`n"
    ;     "出售（重复按空格再按上）：`n"
    ;     "1. 游戏内定位到出售界面最下面的长披风`n"
    ;     "2. 选择数量并点击出售按钮`n"
    ;     "3. 游戏内手动出售"
    ; )
}

BuyReduxStone(*) {
    if !ActivateGameWindow() {
        return
    }
    num := myGui['ReduxStoneNum'].Value
    loop num {
        myGui['StatusBar'].Text := "正在购买" A_Index " / " num "个..."
        _BuyItem()
    }
    myGui['StatusBar'].Text := "已购买 " num " 个"
}

SellReduxStone(*) {
    if !ActivateGameWindow() {
        return
    }
    num := myGui['ReduxStoneNum'].Value
    loop num {
        myGui['StatusBar'].Text := "正在选择" A_Index " / " num "个..."
        _SelectItemAndGoUp()
    }
    myGui['StatusBar'].Text := "已选择 " num " 个"
}

BuildGuiForTeleportationGate() {
    myGui.AddButton("xs+10 ys+20 vUseTeleportationGate", "单次任意门")
    myGui.AddButton("xp+80 vUseTeleportationGateReturn", "往返任意门")
}

UseTeleportationGate(*) {
    if !ActivateGameWindow() {
        return
    }
    if !_SingleTeleportationGate() {
        return
    }
    myGui['StatusBar'].Text := "单次传送完成"
}

UseTeleportationGateReturn(*) {
    if !ActivateGameWindow() {
        return
    }
    if !_SingleTeleportationGate() {
        return
    }
    Sleep 500
    if !_SingleTeleportationGate() {
        return
    }
    myGui['StatusBar'].Text := "往返传送完成"
}

BuildGuiForGinormosia() {
    myGui.AddButton("xs+10 ys+20 w40 vGinormosiaOnce", "刷新")
    myGui.AddButton("xp+50 wp vGinormosiaCheck", "检查")
}

GinormosiaOnce(*) {
    if !ActivateGameWindow() {
        return
    }
    MySend "Escape"
    Sleep 500
    if !_GinormosiaOnce() {
        return
    }
    _GinormosiaCheck()
}

GinormosiaCheck(*) {
    if !ActivateGameWindow() {
        return
    }
    _GinormosiaCheck()
}

BuildGuiForMimic() {
    myGui.AddEdit("xs+10 ys+20 w50")
    myGui.AddUpDown("vMimicNum Range1-99", 10)
    myGui.AddText("xp+60 w60 hp 0x200", "数量(1-99)")
    myGui.AddButton("xp+70 w40 vKillMimicTest", "测试")
    myGui.AddButton("xp+50 wp vKillMimic", "击杀")
    myGui.AddRadio("xs+10 ys+50 h22 vShortHold Checked 0xC00", "短蓄力")
    myGui.AddRadio("xp+60 hp vLongHold 0xC00", "长蓄力")
    ; myGui.AddButton("xp+70 w40 vKillMimicTest", "单次")
    ; myGui.AddButton("xp+50 wp vKillMimic", "击杀")
    ; myGui.AddText("xs+10 ys+80 w220",
    ;     "测试（只进行单次击杀）：`n"
    ;     "1.游戏内定位到宝箱的必经之路`n"
    ;     "2.点击测试按钮`n"
    ;     "`n"
    ;     "击杀（重复往返传送并击杀）：`n"
    ;     "1.游戏内定位到宝箱的必经之路`n"
    ;     "2.设置宝箱数量并点击击杀按钮"
    ; )
}

KillMimicTest(*) {
    if !ActivateGameWindow() {
        return
    }
    if myGui['ShortHold'].Value {
        _KillWithShortHold()
    }
    if myGui['LongHold'].Value {
        _KillWithLongHold()
    }
    myGui['StatusBar'].Text := "测试击杀完成"
}

KillMimic(*) {
    if !ActivateGameWindow() {
        return
    }
    num := myGui['MimicNum'].Value
    loop num {
        myGui['StatusBar'].Text := "正在击杀第" A_Index " / " num "个宝箱..."
        if !_SingleTeleportationGate() {
            return
        }
        Sleep 500
        if !_SingleTeleportationGate() {
            return
        }
        if myGui['ShortHold'].Value {
            _KillWithShortHold()
        }
        if myGui['LongHold'].Value {
            _KillWithLongHold()
        }
        myGui['StatusBar'].Text := "手动归位"
        Sleep 3000
    }
    myGui['StatusBar'].Text := "已击杀 " num " 个宝箱"
}

BuildGuiForGrove() {
    myGui.AddEdit("xs+10 ys+20 w50")
    myGui.AddUpDown("vGroveNum Range1-99", 10)
    myGui.AddText("xp+60 w60 hp 0x200", "数量(1-99)")
    myGui.AddButton("xp+70 w40 vPlantSaplingTest", "测试")
    myGui.AddButton("xp+50 wp vPlantSapling", "种植")
    myGui.AddText("xs+10 ys+50 w64 h22 0x200", "年代选择：")
    myGui.AddComboBox("xp+70 w40 vGroveSelectDirection Choose2", ["上", "下"])
    myGui.AddEdit("xp+50 w40")
    myGui.AddUpDown("vGroveSelectMove Range0-10", 3)
    ; myGui.AddText("xs+10 ys+50 w220",
    ;     "种植（重复种植）：`n"
    ;     "1.游戏内定位扭蛋迷宫树并按F对话`n"
    ;     "2.设置数量并点击种植按钮`n"
    ; )
}

PlantSaplingTest(*) {
    if !ActivateGameWindow() {
        return
    }
    _PlantSingleSapling()
}

PlantSapling(*) {
    if !ActivateGameWindow() {
        return
    }
    num := myGui['GroveNum'].Value
    loop num {
        myGui['StatusBar'].Text := "正在种植第" A_Index " / " num "棵树..."
        _PlantSingleSapling()
        myGui['StatusBar'].Text := "已暂停，按F3进行下一次重新种植"
        Pause()
        MySend "Escape"
        Sleep 2000
    }
    myGui['StatusBar'].Text := "已种植 " num " 棵树"
}

BuildGuiForSaveLoad() {
    myGui.AddButton("xs+10 ys+20 w40 vSaveCloud", "保存")
    myGui.AddButton("xp+50 wp vLoadCloud", "加载")
}

SaveCloud(*) {
    if !ActivateGameWindow() {
        return
    }
    myGui['StatusBar'].Text := "正在保存云数据..."
    if !_SaveCloud() {
        return
    }
    myGui['StatusBar'].Text := "云数据保存完成"
}

LoadCloud(*) {
    if !ActivateGameWindow() {
        return
    }
    myGui['StatusBar'].Text := "正在加载云数据..."
    if !_LoadCloud() {
        return
    }
    myGui['StatusBar'].Text := "云数据加载完成"
}

BuildGuiForAging() {
    myGui.AddButton("xs+10 ys+20 w40 vAgingOnce", "检查")
    myGui.AddButton("xp+50 wp vAgingNext", "继续")
}

AgingOnce(*) {
    if !ActivateGameWindow() {
        return
    }
    if !_AgingOnce() {
        return
    }
}

AgingNext(*) {
    if !ActivateGameWindow() {
        return
    }
    MySend "Space"
    Sleep 1000
    if !_LoadCloud() {
        return
    }
    Sleep 2000
    if !_AgingOnce() {
        return
    }
}

BuildGuiForOnline() {
    myGui.AddText("xs+10 ys+20 w36 h22 0x200", "关键词")
    myGui.AddEdit("xp+40 w60 vOnlineKeyword", "")
    myGui.AddText("xp+70 w36 h22 0x200", "密码")
    myGui.AddEdit("xp+40 w60 vOnlinePassword", "")
    myGui.AddButton("xs+10 ys+50 w40 vOnlineJoin", "加入")
    myGui.AddButton("xp+50 w40 vOnlineExit", "退出")
    myGui.AddButton("xp+90 w40 vOnlineNext", "继续")
}

OnlineJoin(*) {
    if !ActivateGameWindow() {
        return
    }
    if !_OnlineJoin() {
        return
    }
}

OnlineExit(*) {
    if !ActivateGameWindow() {
        return
    }
    _OnlineExit()
}

OnlineNext(*) {
    if !ActivateGameWindow() {
        return
    }
    while true {
        _OnlineExit()
        if !_OnlineJoin() {
            return
        }
        myGui['StatusBar'].Text := "已暂停，拿到惊魂器后按F3继续"
        Pause()
    }
}

BuildGuiForCraft() {
    myGui.AddText("xs+10 ys+20 h22 0x200", "长按")
    myGui.AddEdit("yp w48 hp")
    myGui.AddUpDown("vCraftLongPress Range1-3000", 1600)
    myGui.AddText("yp hp 0x200", "ms")
    myGui.AddText("yp hp 0x200", "连点")
    myGui.AddEdit("yp w36 hp")
    myGui.AddUpDown("vCraftMultiClick Range1-99", 6)
    myGui.AddText("yp hp 0x200", "次")
    myGui.AddButton("xs+10 ys+50 w40 vCraftReset", "重置")
    myGui.AddButton("yp w40 vCraftSingle", "单次")
    myGui.AddButton("yp w40 vCraft", "循环")
    myGui.AddText("yp w20 hp 0x200 vCraftPos", "空")
    myGui.AddText("yp w20 hp 0x200 vCraftMove", "0/0")
    myGui.AddText("xs+10 ys+80 h22 0x200", "左：")
    myGui.AddText("yp w30 hp vCraft1 0x200", "00")
    myGui.AddText("yp hp 0x200", "中：")
    myGui.AddText("yp w30 hp vCraft2 0x200", "00")
    myGui.AddText("yp hp 0x200", "右：")
    myGui.AddText("yp w30 hp vCraft3 0x200", "00")
}

_CraftSearchColor(xs, ys, color, rangeX := 2, rangeY := 10, colorVar := 0x10) {
    return PixelSearch(
        &x, &y,
        xs - rangeX, ys - rangeY,
        xs + rangeX, ys + rangeY,
        color, colorVar)
}

_CraftCenterX := 960
_CraftCenterY := 123
_CraftDoneOffsetY := 60  ; 中心位置偏移
_CraftBackgroundColor := 0x8C4609  ; 背景颜色
_CraftMoveDoneColor := 0xFFF8E4  ; 完成行动icon颜色
_CraftIconWidth := 96  ; 图标宽度
_CraftIconInterval := 32  ; 图标间隔
_CraftIconNext := _CraftIconWidth + _CraftIconInterval

_CraftCheckRound() {
    moveNum := 0
    initX := 0
    counter := 0
    while (true) {  ; 等待背景颜色稳定
        leftColor := PixelGetColor(
            _CraftCenterX - _CraftIconNext // 2, _CraftCenterY)  ; 左侧背景
        centerColor := PixelGetColor(
            _CraftCenterX, _CraftCenterY)  ; 中心位置颜色
        rightColor := PixelGetColor(
            _CraftCenterX + _CraftIconNext // 2, _CraftCenterY)  ; 右侧背景
        leftMatch := (leftColor == _CraftBackgroundColor)
        centerMatch := (centerColor == _CraftBackgroundColor)
        rightMatch := (rightColor == _CraftBackgroundColor)
        if (!leftMatch && centerMatch && !rightMatch) {
            moveNum := 4
            initX := _CraftCenterX - _CraftIconNext * 3 // 2
            break
        }
        if (leftMatch && !centerMatch && rightMatch) {
            moveNum := 5
            initX := _CraftCenterX - _CraftIconNext * 2
            break
        }
        myGui['StatusBar'].Text := "匹配背景..." leftMatch " " centerMatch " " rightMatch
        Sleep 20
        counter++
    }
    color := PixelGetColor(initX, _CraftCenterY)  ; 第一个图标位置颜色
    if (color == _CraftBackgroundColor) {
        moveNum -= 2  ; 如果第一个图标为空，则减少2个行动
        initX += _CraftIconNext  ; 初始位置向右移动一个图标间隔
    }
    myGui['StatusBar'].Text := "共" moveNum "个行动"
    return [moveNum, initX]
}

_CraftMouseX := [560, 960, 1360]
_CraftMouseY := [320, 504]
_CraftMouseLeftOffsetX := -20  ; 左键偏移
_CraftMouseTextOffsetY := -105  ; 文本偏移
_CraftWheelColor := 0x311D09  ; 滚轮颜色
_CraftLeftColor := 0xFFC9C5  ; 粉色左键
_CraftGreenColor := 0x96F485  ; 绿色文本
_CraftRedColor := 0xFFB190  ; 红色文本

_CraftCheckMoveType(xi, yi) {
    x := _CraftMouseX[xi]
    y := _CraftMouseY[yi]
    range := 2
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
    if foundLeft && !foundGreenText && !foundRedText
        return 1
    if foundGreenText
        return 2
    if foundRedText
        return 3
    return 0
}

_CraftSingleMove(resetPos, longPress, multiClick) {
    static currentPos := 2
    if resetPos {
        currentPos := 2
        myGui['CraftPos'].Text := "中"
        return
    }
    nextPos := 0
    while true {
        loop 3 {
            xp := A_Index
            yp := (currentPos == A_Index) ? 1 : 2
            move := _CraftCheckMoveType(xp, yp)
            myGui['StatusBar'].Text := "pos=" xp ", move=" move
            if move != 0 {
                nextPos := xp
                break
            }
        }
        if (nextPos != 0) {
            break
        }
    }
    deltaPos := nextPos - currentPos
    if (deltaPos != 0) {
        myGui['StatusBar'].Text := "移动: " currentPos " -> " nextPos
        key := (deltaPos > 0) ? "d" : "a"
        deltaPos := Abs(deltaPos)
        loop deltaPos {
            MySend key, 10
            Sleep 40
        }
        currentPos := nextPos
        switch currentPos {
            case 1:
                myGui['CraftPos'].Text := "左"
            case 2:
                myGui['CraftPos'].Text := "中"
            case 3:
                myGui['CraftPos'].Text := "右"
            default:
                myGui['CraftPos'].Text := "空"
        }
    }
    else {
        myGui['StatusBar'].Text := "不动"
    }
    switch move {
        case 1:
            myGui['StatusBar'].Text := "单击"
            MySend "Space", 10
            Sleep 40
        case 2:
            myGui['StatusBar'].Text := "长按"
            MyPress "Space"
            Sleep longPress
            MyRelease "Space"
            Sleep 40
        case 3:
            myGui['StatusBar'].Text := "连按"
            loop multiClick {
                MySend "Space", 10
                Sleep 40
            }
    }
    return
}

_CraftSingleRound(longPress, multiClick) {
    ret := _CraftCheckRound()
    moveNum := ret[1]
    initX := ret[2]
    loop moveNum {
        currentMove := A_Index
        myGui['CraftMove'].Text := currentMove " / " moveNum
        _CraftSingleMove(false, longPress, multiClick)
        Sleep 80
    }
}

CraftReset(*) {
    if !ActivateGameWindow() {
        return
    }
    longPress := myGui['CraftLongPress'].Value
    multiClick := myGui['CraftMultiClick'].Value
    _CraftSingleMove(true, longPress, multiClick)
}

CraftSingle(*) {
    if !ActivateGameWindow() {
        return
    }
    longPress := myGui['CraftLongPress'].Value
    multiClick := myGui['CraftMultiClick'].Value
    _CraftSingleRound(longPress, multiClick)
}

Craft(*) {
    if !ActivateGameWindow() {
        return
    }
    longPress := myGui['CraftLongPress'].Value
    multiClick := myGui['CraftMultiClick'].Value
    while (true) {
        _CraftSingleRound(longPress, multiClick)
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
    myGui['StatusBar'].Text := "MySend Space"
    MySend "Space"
    Sleep 1000
    myGui['StatusBar'].Text := "MySend r"
    MySend "r"
    Sleep 1000
    myGui['StatusBar'].Text := "Send Space"
    Send "Space"
    Sleep 1000
    myGui['StatusBar'].Text := "Send r"
    Send "r"
    Sleep 1000
    myGui['StatusBar'].Text := "测试发送完成"
}

_TestColor() {
    color := PixelGetColor(myGui['TestX'].Value, myGui['TestY'].Value)
    myGui['StatusBar'].Text := "当前颜色: " color
}

TestColor(*) {
    static _Testing := false
    if (_Testing) {
        _Testing := false
        SetTimer(_TestColor, 0)
        myGui['TestColor'].Text := "测试颜色"
    }
    else {
        _Testing := true
        Sleep 500
        SetTimer(_TestColor, 250)
        myGui['TestColor'].Text := "停止测试"
    }
}
