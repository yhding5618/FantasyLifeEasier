#Requires AutoHotkey v2.0

GameWindowTitle := "ahk_exe NFL1-Win64-Shipping.exe"

; GUI callbacks
GameWindowCheckBtnClick(*) {
    if !GameWindowStatusUpdate() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

GameWindowActivateBtnClick(*) {
    if !GameWindowActivate() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

GameWindowPixelInfoUpdateToogle() {
    myGui["GameWindow.PixelInfoUpdateChk"].Value := !myGui["GameWindow.PixelInfoUpdateChk"].Value
    GameWindowPixelInfoUpdateChkClick()
}

GameWindowPixelInfoUpdateChkClick(*) {
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
    myGui["GameWindow.PixelInfo"].Text := x ", " y ", " color
}

GameWindowStatusUpdate() {
    if !WinExist(GameWindowTitle) {
        myGui["GameWindow.Status"].Text := "游戏窗口未找到"
        return false
    }
    pid := WinGetPID(GameWindowTitle)
    WinGetClientPos(&x, &y, &w, &h, "ahk_pid " pid)
    myGui["GameWindow.Status"].Text := (
        "PID：" pid "`n"
        "位置：(" x ", " y ")`n"
        "大小：" w "x" h "`n"
        ; "已打开：" (WinActive(GameWindowTitle) ? "是" : "否")
    )
    return true
}

GameWindowActivate() {
    if !WinExist(GameWindowTitle) {
        UpdateStatusBar("游戏窗口未找到")
        return false
    }
    UpdateStatusBar("正在打开游戏窗口...")
    WinActivate(GameWindowTitle)
    WinRestore(GameWindowTitle)
    hwnd := WinWaitActive(GameWindowTitle, , 5)
    if (hwnd = 0) {
        UpdateStatusBar("未能打开游戏窗口，可能已最小化")
        return false
    }
    UpdateStatusBar("游戏窗口已激活")
    return true
}
