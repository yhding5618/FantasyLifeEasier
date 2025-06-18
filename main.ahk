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
myGui.AddGroupBox('xs ys+60 w240 h80 Section', '宝箱怪')
BuildGuiForMimic()
myGui.AddGroupBox('xs ys+90 w240 h80 Section', '扭蛋迷宫树')
BuildGuiForGrove()
myGui.AddGroupBox('xs ys+90 w240 h50 Section', '其他功能')
BuildGuiForOthers()
myGui.AddStatusBar("vStatusBar", "StatusBar")
myGui.OnEvent('Close', (*) => ExitApp())
myGui['ActivateGameWindow'].OnEvent('Click', ActivateGameWindow)
myGui['BuyReduxStone'].OnEvent('Click', BuyReduxStone)
myGui['SellReduxStone'].OnEvent('Click', SellReduxStone)
myGui['UseTeleportationGate'].OnEvent('Click', UseTeleportationGate)
myGui['UseTeleportationGateReturn'].OnEvent('Click', UseTeleportationGateReturn)
myGui['KillMimicTest'].OnEvent('Click', KillMimicTest)
myGui['KillMimic'].OnEvent('Click', KillMimic)
myGui['PlantSaplingTest'].OnEvent('Click', PlantSaplingTest)
myGui['PlantSapling'].OnEvent('Click', PlantSapling)
myGui['TestColor'].OnEvent('Click', TestColor)
myGui.Show("x2200 y500")
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

_SingleTeleportationGate(*) {
    myGui['StatusBar'].Text := "进入菜单"
    MySend "Escape"
    Sleep 750
    color := PixelGetColor(666, 333)
    if (color != 0xE337DB && color != 0xE335DB) {
        if (color = 0x963681) {
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
                myGui['StatusBar'].Text := "加载异常: " color
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
        if (counter > 500) {
            myGui['StatusBar'].Text := "加载超时"
            return false
        }
    }
    myGui['StatusBar'].Text := "等待关门动画"
    Sleep 2500  ; 关门动画
    myGui['StatusBar'].Text := "完成传送"
    return true
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
        return
    }
    WinActivate("ahk_exe NFL1-Win64-Shipping.exe")
    WinWaitActive("ahk_exe NFL1-Win64-Shipping.exe", "", 1000)
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
    myGui['StatusBar'].Text := "获取颜色完成: " color
}

TestColor(*) {
    if !ActivateGameWindow() {
        return
    }
    static _Testing := false
    if (_Testing) {
        myGui['StatusBar'].Text := "停止测试"
        _Testing := false
        SetTimer(_TestColor, 0)
    }
    else {
        myGui['StatusBar'].Text := "开始测试"
        _Testing := true
        Sleep 500
        SetTimer(_TestColor, 250)
    }
}
