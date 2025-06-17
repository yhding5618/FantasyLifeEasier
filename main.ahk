#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"
CoordMode "Pixel", "Client"

myGui := Gui(, "Fantasy Life Easier")
myGui.AddGroupBox('xm ym w240 h150 Section', '游戏窗口')
BuildGuiForGameWindow()
myGui.AddGroupBox('xs ys+160 w240 h170 Section', '重置石')
BuildGuiForReduxStone()
myGui.AddGroupBox('xs ys+180 w240 h50 Section', '任意门')
BuildGuiForTeleportationGate()
myGui.AddGroupBox('xs ys+60 w240 h100 Section', '宝箱')
BuildGuiForMimic()
myGui.AddGroupBox('xs ys+110 w240 h50 Section', '其他功能')
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
myGui['Test'].OnEvent('Click', Test)
myGui.Show("x2200 y500")
CheckGameWindow()
; SetKeyDelay 0, 50, "Play"
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
    MySend "w", 350  ; 前进
    MySend "s", 630  ; 后退
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
    myGui.AddText("xs+10 ys+50 w220",
        "购买：`n"
        "1. 游戏内定位到长披风`n"
        "2. 选择数量并点击购买按钮`n"
        "`n"
        "出售：`n"
        "1. 游戏内定位到出售界面最下面的长披风`n"
        "2. 选择数量并点击出售按钮`n"
        "3. 游戏内手动出售"
    )
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

BuildGuiForOthers() {
    myGui.AddButton("xs+10 ys+20 vTest", "测试")
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
    Sleep 1000
    color := PixelGetColor(666, 333, "Alt")
    myGui['StatusBar'].Text := "获取颜色完成: " color
}

; SetTimer _TestColor, 500

Test(*) {
    if !ActivateGameWindow() {
        return
    }
    _TestColor()
}
