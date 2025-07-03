#Requires AutoHotkey v2.0

GameWindowTitle := "ahk_exe NFL1-Win64-Shipping.exe"

; GUI callbacks
GameWindow_CheckBtn_Click() {
    GameWindowStatusUpdate()
}

GameWindow_ActivateBtn_Click() {
    GameWindowActivate()
}

GameWindowPixelInfoUpdateToogle() {
    myGui["GameWindow.PixelInfoUpdateChk"].Value := !myGui[
        "GameWindow.PixelInfoUpdateChk"].Value
    GameWindow_PixelInfoUpdateChk_Click()
}

GameWindow_PixelInfoUpdateChk_Click(args*) {
    if (myGui["GameWindow.PixelInfoUpdateChk"].Value) {
        SetTimer(GameWindowPixelInfoUpdate, 100)
        GameWindowPixelInfoUpdate()
    } else {
        SetTimer(GameWindowPixelInfoUpdate, 0)
    }
}

GameWindowPixelInfoUpdate() {
    MouseGetPos(&x, &y)
    color := PixelGetColor(x, y)
    myGui["GameWindow.PixelInfo"].Text := x "," y ",`"" color "`""
}

GameWindowStatusUpdate() {
    if !WinExist(GameWindowTitle) {
        myGui["GameWindow.Status"].Text := "未检测到游戏窗口"
        return
    }
    pid := WinGetPID(GameWindowTitle)
    WinGetClientPos(&x, &y, &w, &h, "ahk_pid " pid)
    text := "PID：" pid "`n"
    text .= "位置：(" x ", " y ")`n"
    text .= "大小：" w "x" h "`n"
    if (w = 0 || h = 0) {
        text .= "游戏窗口可能已最小化"
    } else if w != 1920 || h != 1080 {
        text .= "请使用1920x1080分辨率运行"
    } else {
        text .= "检测到游戏窗口"
    }
    myGui["GameWindow.Status"].Text := text
}

GameWindowActivate() {
    if !WinExist(GameWindowTitle) {
        throw TargetError("游戏窗口未找到")
    }
    UpdateStatusBar("正在打开游戏窗口...")
    WinActivate(GameWindowTitle)
    WinRestore(GameWindowTitle)
    hwnd := WinWaitActive(GameWindowTitle, , 5)
    if (hwnd = 0) {
        throw TargetError("未能打开游戏窗口，可能已最小化")
    }
    UpdateStatusBar("游戏窗口已激活")
}
