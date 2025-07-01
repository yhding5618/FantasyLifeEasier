#Requires AutoHotkey v2.0

ScriptControl_AlwaysOnTopChk_Click() {
    checked := myGui["ScriptControl.AlwaysOnTopChk"].Value
    mark := checked ? "+" : "-"
    myGui.Opt(mark "AlwaysOnTop")
}

ScriptControlStatusUpdate() {
    try {
        WinGetPos(&x, &y, &w, &h, myGui.Title)
        myGui["ScriptControl.WindowPos"].Value := x "," y
    }
    catch {
        myGui["ScriptControl.WindowPos"].Value := ""
    }
}

ScriptControl_SuccessSoundChk_Click() {
    if (myGui["ScriptControl.SuccessSoundChk"].Value) {
        UpdateStatusBar("成功音效已启用")
        PlaySuccessSound()
    }
    else {
        UpdateStatusBar("成功音效已禁用")
    }
}

ScriptControl_FailureSoundChk_Click() {
    if (myGui["ScriptControl.FailureSoundChk"].Value) {
        UpdateStatusBar("失败音效已启用")
        PlayFailureSound()
    }
    else {
        UpdateStatusBar("失败音效已禁用")
    }
}

ScriptControl_SuccessMsgBoxChk_Click(*) {
    if (myGui["ScriptControl.SuccessMsgBoxChk"].Value) {
        UpdateStatusBar("成功弹窗已启用")
        ShowSuccessMsgBox("测试成功弹窗")
    }
    else {
        UpdateStatusBar("成功弹窗已禁用")
    }
}

ScriptControl_FailureMsgBoxChk_Click(*) {
    if (myGui["ScriptControl.FailureMsgBoxChk"].Value) {
        UpdateStatusBar("失败弹窗已启用")
        ShowFailureMsgBox("测试失败弹窗", Error())
    }
    else {
        UpdateStatusBar("失败弹窗已禁用")
    }
}

ScriptControl_PauseHotkey_Change() {
    hotkeyName := myGui["ScriptControl.PauseHotkey"].Value
    function := (*) => Pause(-1)
    _SetHotkey(hotkeyName, function)
}

ScriptControl_ExitHotkey_Change() {
    hotkeyName := myGui["ScriptControl.ExitHotkey"].Value
    function := (*) => SaveAndExit()
    _SetHotkey(hotkeyName, function)
}

ScriptControl_ResetHotkey_Change() {
    hotkeyName := myGui["ScriptControl.ResetHotkey"].Value
    function := SaveAndReload
    _SetHotkey(hotkeyName, function)
}

_SetHotkey(hotkeyName, function) {
    ; Hotkey(hotkeyName, function)
}
