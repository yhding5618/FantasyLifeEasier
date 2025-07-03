#Requires AutoHotkey v2.0

ScriptControl_AlwaysOnTopChk_Click() {
    checked := myGui["ScriptControl.AlwaysOnTopChk"].Value
    mark := checked ? "+" : "-"
    myGui.Opt(mark "AlwaysOnTop")
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

ScriptControlStatusUpdate() {
    try {
        WinGetPos(&x, &y, &w, &h, myGui.Title)
        myGui["ScriptControl.WindowPosX"].Value := x
        myGui["ScriptControl.WindowPosY"].Value := y
    }
    catch {
        myGui["ScriptControl.WindowPosX"].Value := -1
        myGui["ScriptControl.WindowPosY"].Value := -1
    }
    try {
        myGui["ScriptControl.TabIndex"].Value := myGui["MainTab"].Value
    }
    catch {
        myGui["ScriptControl.TabIndex"].Value := 1
    }
}

ScriptControlGetWindowPos() {
    MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
    if myGui["ScriptControl.RememberWindowPos"].Value {
        x := Max(left, Min(right,
            Integer(myGui["ScriptControl.WindowPosX"].Value)))
        y := Max(top, Min(bottom,
            Integer(myGui["ScriptControl.WindowPosY"].Value)))
        return "x" x " y" y
    } else {
        return "Center"
    }
}

ScriptControlGetTabIndex() {
    if myGui["ScriptControl.RememberTabIndex"].Value {
        return Integer(myGui["ScriptControl.TabIndex"].Value)
    } else {
        return 1  ; 默认返回第一个标签页
    }
}
