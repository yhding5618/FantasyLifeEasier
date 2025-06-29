#Requires AutoHotkey v2.0

PlaySuccessSound() {
    if (myGui["ScriptControl.SuccessSoundChk"].Value) {
        SoundPlay("*64", 1)
    }
}

PlayFailureSound() {
    if (myGui["ScriptControl.FailureSoundChk"].Value) {
        SoundPlay("*16", 1)
    }
}

MyToolTip(text, x, y, id, enabled := true) {
    if (enabled) {
        ToolTip(text, x, y, id)
        return
    }
}

MyPress(singleKey) {
    Send "{" singleKey " down}"
}

MyRelease(singleKey) {
    Send "{" singleKey " up}"
}

MySend(singleKey, pressDelay := 30, postDelay := 0) {
    MyPress(singleKey)
    Sleep(pressDelay)
    MyRelease(singleKey)
    if (postDelay > 0) {
        Sleep(postDelay)
    }
}

TryAndCatch(function, args*) {
    try {
        return function(args*)
    } catch Error as e {
        MsgBox("函数调用失败: " e.Message)
        return false
    }
}

WaitUntilPixelGetColor(
    x, y, color,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        currentColor := PixelGetColor(x, y)
        if (currentColor == color) {
            return true
        }
        Sleep(interval)
        count++
    }
    return false
}

WaitUntilPixelSearch(
    x, y, color,
    range := 10, colorVariation := 0,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        found := PixelSearch(&x, &y,
            x - range, y - range,
            x + range, y + range, color, colorVariation)
        if (found) {
            return true
        }
        Sleep(interval)
        count++
    }
    return false
}

MenuIconPos := [670, 326]  ; 菜单图标1行1列中心位置
MenuIconOffsetX := 192  ; 菜单图标X偏移量
MenuIconOffsetY := 234  ; 菜单图标Y偏移量
MenuUIStickPixel := [341, 431, "0xC4B694"]  ; 菜单UI摇杆

OpenMenuAndGetIconColor(page, row, col) {
    UpdateStatusBar("打开菜单")
    MySend("Escape")
    foundUIStick := WaitUntilPixelSearch(MenuUIStickPixel*)
    if !foundUIStick {
        return false
    }
    UpdateStatusBar("移动到" page "页，" row "行，" col "列")
    loop (page - 1) {
        MySend("e", , 100)  ; 翻页
    }
    loop (row - 1) {
        MySend("s", , 100)  ; 向下
    }
    loop (col - 1) {
        MySend("d", , 100)  ; 向右
    }
    Sleep(300)  ; 等待颜色稳定
    x := MenuIconPos[1] + MenuIconOffsetX * (col - 1)
    y := MenuIconPos[2] + MenuIconOffsetY * (row - 1)
    color := PixelGetColor(x, y)
    return color
}

LoadConfig() {
    if !FileExist("main.ini") {
        return
    }
    config := myGui.Submit(0)
    for name, defaultValue in config.OwnProps() {
        sp := StrSplit(name, ".", , 2)
        if (sp.Length < 2) {
            continue
        }
        section := sp[1]
        key := sp[2]
        newValue := IniRead("main.ini", section, key, defaultValue)
        try {
            myGui[name].Value := newValue
        } catch Error as e {
            ; 如果读取失败，保持默认值
            MsgBox("无法读取配置: " section "." key "`n" e.Message)
        }
    }
}

SaveConfig() {
    config := myGui.Submit(0)
    FileMove("main.ini", "main.ini.old", 1)  ; 备份旧配置文件
    for name, currentValue in config.OwnProps() {
        sp := StrSplit(name, ".", , 2)
        if (sp.Length < 2) {
            continue
        }
        section := sp[1]
        key := sp[2]
        switch (name) {
            ; 处理特殊情况，DropDownList需要保存Value而不是Text
            case "TreasureGrove.YearMoveDir":
                currentValue := myGui[name].Value
            case "Online.CreateType":
                currentValue := myGui[name].Value
        }
        IniWrite(currentValue, "main.ini", section, key)
    }
    FileDelete("main.ini.old")  ; 删除备份文件
}

SaveAndExit() {
    SaveConfig()
    ExitApp()
}

SaveAndReload() {
    SaveConfig()
    Reload()
}
