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

/**
 * @description 显示错误消息框
 * @param {Error} e 错误对象
 */
ShowFailureMsgBox(e) {
    if (myGui["ScriptControl.FailureMsgBoxChk"].Value) {
        eFileName := StrSplit(e.File, "\")[-1]
        MsgBox(eFileName ":" e.Line "`n" e.Message, "错误")
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

/**
 * @description 运行函数并捕获异常，如果函数执行成功则播放成功音效，否则弹出错误信息并播放失败音效
 * @param {FuncObj} function  
 */
TryAndCatch(function) {
    try {
        function.Call()
        PlaySuccessSound()
    } catch Error as e {
        UpdateStatusBar(e.Message)
        ShowFailureMsgBox(e)
        PlayFailureSound()
    }
}

/**
 * @description 对比指定像素的颜色
 * @param {Integer} x 像素X坐标
 * @param {Integer} y 像素Y坐标
 * @param {(String|Integer)} color 期望的像素颜色
 * @param {Integer} pixelRange 像素匹配范围（默认0)
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @return {Integer} 如果当前像素颜色与期望颜色匹配则返回true，否则返回false
 */
SearchColorMatch(x, y, color,
    pixelRange := 0, colorVariation := 10
) {
    return PixelSearch(&xf, &yf,
        x - pixelRange, y - pixelRange,
        x + pixelRange, y + pixelRange,
        color, colorVariation)
}

/**
 * @description 等待指定像素颜色出现
 * @param {Integer} x 像素X坐标
 * @param {Integer} y 像素Y坐标
 * @param {(String)} color 期望的像素颜色
 * @param {String} title 窗口标题
 * @param {Integer} interval 检查间隔时间（毫秒）
 * @param {Integer} timeoutCount 超时时间（检查次数）
 */
WaitUntilColorMatch(x, y, color, title,
    pixelRange := 0, colorVariation := 10,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        currentColor := PixelGetColor(x, y)
        if (currentColor == color) {
            UpdateStatusBar("检测到" title "颜色: " currentColor)
            return
        }
        UpdateStatusBar("等待" title "..." count "/" timeoutCount)
        Sleep(interval)
        count++
    }
    throw TimeoutError(title "颜色匹配超时")
}

WaitUntilPixelSearch(
    x, y, color,
    range := 10, colorVariation := 0,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        found := PixelSearch(&xf, &yf,
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

OpenMenu() {
    UpdateStatusBar("打开菜单")
    MySend("Escape")
    WaitUntilColorMatch(
        MenuUIStickPixel[1],
        MenuUIStickPixel[2],
        MenuUIStickPixel[3],
        "菜单UI摇杆", 100, 10
    )
    UpdateStatusBar("已打开菜单")
}

MenuIconPos := [670, 326]  ; 菜单图标1行1列中心位置
MenuIconOffsetX := 192  ; 菜单图标X偏移量
MenuIconOffsetY := 234  ; 菜单图标Y偏移量
MenuUIStickPixel := [341, 431, "0xC4B694"]  ; 菜单UI摇杆

/**
 * @description 打开菜单并获取指定图标的颜色
 * @param {Integer} page 页码
 * @param {Integer} row 行号
 * @param {Integer} col 列号
 * @returns {Array} 包含图标位置和颜色的数组 [x, y, color]
 */
OpenMenuAndGetIconColor(page, row, col) {
    OpenMenu()
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
    return [x, y, color]
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
