#Requires AutoHotkey v2.0

ScriptControlVersion := "v1.2"
ScriptControlLatestReleaseURL :=
    "https://github.com/yhding5618/FantasyLifeEasier/releases/latest"

ScriptControl_AlwaysOnTopChk_Click(args*) {
    checked := myGui["ScriptControl.AlwaysOnTopChk"].Value
    mark := checked ? "+" : "-"
    myGui.Opt(mark "AlwaysOnTop")
}

ScriptControl_SuccessSoundChk_Click(args*) {
    if (myGui["ScriptControl.SuccessSoundChk"].Value) {
        UpdateStatusBar("成功音效已启用")
        PlaySuccessSound()
    }
    else {
        UpdateStatusBar("成功音效已禁用")
    }
}

ScriptControl_FailureSoundChk_Click(args*) {
    if (myGui["ScriptControl.FailureSoundChk"].Value) {
        UpdateStatusBar("失败音效已启用")
        PlayFailureSound()
    }
    else {
        UpdateStatusBar("失败音效已禁用")
    }
}

ScriptControl_SuccessMsgBoxChk_Click(args*) {
    if (myGui["ScriptControl.SuccessMsgBoxChk"].Value) {
        UpdateStatusBar("成功弹窗已启用")
        ShowSuccessMsgBox("测试成功弹窗")
    }
    else {
        UpdateStatusBar("成功弹窗已禁用")
    }
}

ScriptControl_FailureMsgBoxChk_Click(args*) {
    if (myGui["ScriptControl.FailureMsgBoxChk"].Value) {
        UpdateStatusBar("失败弹窗已启用")
        ShowFailureMsgBox("测试失败弹窗", Error())
    }
    else {
        UpdateStatusBar("失败弹窗已禁用")
    }
}

/**
 * @description: 按钮名称列表（自定义顺序）
 * @example HotkeyActionNameList[1] = "无"
 */
HotkeyActionNameList := Array("无")

/**
 * @description: 按钮名称->回调函数映射（无法定义顺序）
 * @example HotkeyAction2Function["基本-打开游戏窗口"] = GameWindow_ActivateBtn_Click
 * @note 按钮名称和回调函数一一对应
 */
HotkeyAction2Function := Map()

; 最多5个自定义快捷键
HotkeyMaxNum := 5

/**
 * @description: 初始化自定义快捷键
 * @note 需要在脚本启动时调用
 */
ScriptControlRegisterAllHotkeys() {
    loop HotkeyMaxNum {
        prefix := "ScriptControl.CustomHotkey" A_Index
        actionName := myGui[prefix "ActionName"].Text
        keyName := myGui[prefix "KeyName"].Value
        ScriptControlRegisterHotkey(prefix, actionName, keyName)
    }
}

ScriptControlCheckHotkeyExist(keyName) {
    if (keyName == "") {
        return false  ; 空快捷键视为不存在
    }
    loop HotkeyMaxNum {
        prefix := "ScriptControl.CustomHotkey" A_Index
        if (myGui[prefix "KeyName"].Value == keyName) {
            MsgBox(prefix keyName, "")
            return true  ; 找到匹配的快捷键
        }
    }
    return false  ; 没有找到匹配的快捷键
}

ScriptControlRegisterHotkey(prefix, newActionName, oldKeyName) {
    actionValid := HotkeyAction2Function.Has(newActionName)
    keyValid := oldKeyName != ""
    if actionValid && keyValid {
        Hotkey(oldKeyName, HotkeyAction2Function[newActionName])
        myGui[prefix "ActionName"].Text := newActionName
        myGui[prefix "KeyName"].Value := oldKeyName
    } else {  ; 其他所有情况都视为无效
        myGui[prefix "ActionName"].Text := "无"
        myGui[prefix "KeyName"].Value := ""
    }
}

ScriptControlUpdateHotkey(hkGui, prefix) {
    oldKeyName := myGui[prefix "KeyName"].Value
    oldKeyValid := oldKeyName != ""
    newActionName := hkGui["CustomActionName"].Text
    newKeyName := hkGui["CustomKeyName"].Value
    ;; 检查新的快捷键是否已存在
    try {
        if ScriptControlCheckHotkeyExist(newKeyName) {
            throw ValueError("快捷键已存在，请选择其他快捷键")
        }
        ;; 先禁用旧的快捷键
        if oldKeyValid {
            Hotkey(oldKeyName, "Off")
        }
        ;; 设置新的快捷键
        ScriptControlRegisterHotkey(prefix, newActionName, newKeyName)
    } catch Error as e {
        ShowFailureMsgBox("设置自定义快捷键失败", e, true)
    } else {
        UpdateStatusBar("自定义快捷键已更新：" newActionName " -> " newKeyName)
        hkGui.Destroy()
    }
}

/**
 * @description: 自定义快捷键按钮点击回调函数，在一个独立的GUI中更新快捷键
 * @param prefix 自定义快捷键前缀
 */
ScriptControl_CustomHotkeyBtn_Click(prefix, *) {
    currentActionName := myGui[prefix "ActionName"].Text
    currentKeyName := myGui[prefix "KeyName"].Value
    hkGui := Gui(, "自定义快捷键")
    hkGui.AddText("xm+10 ym+10 h22 0x200", "脚本功能：")
    ddl := hkGui.AddDropDownList(
        "yp w140 r10 -Sort vCustomActionName", HotkeyActionNameList)
    ddl.Text := HotkeyAction2Function.Has(currentActionName) ?
        currentActionName : HotkeyActionNameList[1]
    hkGui.AddText("yp hp 0x200", "快捷键：")
    hkGui.AddHotkey("yp hp w80 vCustomKeyName", currentKeyName)
    btn := hkGui.AddButton("yp hp", "确认")
    btn.OnEvent("Click", (*) => ScriptControlUpdateHotkey(hkGui, prefix))
    hkGui.AddText("xm+10 ym+40 w360",
        "如果要清除已经设置的快捷键，可以将功能设置为“无”，或者将快捷键设置为空（按Esc或退格键）。")
    hkGui.Opt("+OwnDialogs")
    myGui.Opt("+Disabled")
    hkGui.Show("AutoSize")
    WinWaitClose("ahk_id " hkGui.Hwnd)
    myGui.Opt("-Disabled")
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
