#Requires AutoHotkey v2.0

ScriptControlAlwaysOnTopChkClick(*) {
    checked := myGui["ScriptControl.AlwaysOnTopChk"].Value
    mark := checked ? "+" : "-"
    myGui.Opt(mark "AlwaysOnTop")
}

ScriptControlStatusUpdate(*) {
    try {
        WinGetPos(&x, &y, &w, &h, myGui.Title)
        myGui["ScriptControl.WindowPos"].Value := x "," y
    }
    catch {
        myGui["ScriptControl.WindowPos"].Value := ""
    }
}

ScriptControlSuccessSoundChkClick(*) {
    PlaySuccessSound()
    if (myGui["ScriptControl.SuccessSoundChk"].Value) {
        UpdateStatusBar("成功音效已启用")
    }
    else {
        UpdateStatusBar("成功音效已禁用")
    }
}

ScriptControlFailureSoundChkClick(*) {
    PlayFailureSound()
    if (myGui["ScriptControl.FailureSoundChk"].Value) {
        UpdateStatusBar("失败音效已启用")
    }
    else {
        UpdateStatusBar("失败音效已禁用")
    }
}
