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
 * @description 显示成功消息框
 * @param {String} text 文本
 * @param {Boolean} force 是否强制显示（默认false）
 */
ShowSuccessMsgBox(text, force := false) {
    if (force || myGui["ScriptControl.SuccessMsgBoxChk"].Value) {
        MsgBox(text, MainTitle, "0x1000 Iconi")
    }
}

/**
 * @description 显示错误消息框
 * @param {String} text 文本
 * @param {Error} e 错误对象
 * @param {Boolean} force 是否强制显示（默认false）
 */
ShowFailureMsgBox(text, e, force := false) {
    if (force || myGui["ScriptControl.FailureMsgBoxChk"].Value) {
        eFileName := StrSplit(e.File, "\")[-1]
        eText := Format(
            "{1}: {2}`nFunction: {3}`nLocation: {4}:{5}`nStack:`n{6}"
            , type(e), e.Message, e.What, eFileName, e.Line, e.Stack)
        MsgBox(text '`n' eText, MainTitle, "0x1000 IconX")
    }
}

MyToolTip(text, x, y, id, enabled := false) {
    if (enabled) {
        ToolTip(text, x, y, id)
        return
    }
}

MyPress(singleKey) {
    Send("{" singleKey " down}")
}

MyRelease(singleKey) {
    Send("{" singleKey " up}")
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
 * @param {Func} function  
 */
TryAndCatch(function, args*) {
    if (Type(function) != "Func") {
        throw TypeError("参数必须是函数对象")
    }
    if (SubStr(function.Name, -9) != "Btn_Click") {
        throw ValueError("函数名必须以'Btn_Click'结尾")
    }
    splits := StrSplit(function.Name, "_", , 3)
    if (splits.Length < 3) {
        throw ValueError("函数名格式不正确，必须包含至少两个下划线")
    }
    btnText := myGui[splits[1] "." splits[2]].Text
    notGameWindow := splits[1] != "GameWindow"
    try {
        ; 如果函数名不以"GameWindow"开头，则先激活游戏窗口
        if (notGameWindow) {
            GameWindowActivate()
        }
        function.Call()
        PlaySuccessSound()
        ShowSuccessMsgBox("操作成功: " btnText)
    } catch Error as e {
        UpdateStatusBar(e.Message)
        PlayFailureSound()
        ShowFailureMsgBox("操作失败: " btnText, e)
    }
}

/**
 * @description 对比指定像素的颜色
 * @param {Integer} x 像素X坐标
 * @param {Integer} y 像素Y坐标
 * @param {String} color 期望的像素颜色
 * @param {Integer} pixelRange 像素匹配范围（默认5）
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @return {Integer} 如果当前像素颜色与期望颜色匹配则返回true，否则返回false
 */
SearchColorMatch(x, y, color, pixelRange := 5, colorVariation := 10) {
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
 * @param {Integer} pixelRange 像素匹配范围（默认5)
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @param {Integer} interval 检查间隔时间（毫秒，默认100）
 * @param {Integer} timeoutCount 超时时间（检查次数，默认50）
 */
WaitUntilColorMatch(x, y, color, title,
    pixelRange := 5, colorVariation := 10,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        match := SearchColorMatch(x, y, color, pixelRange, colorVariation)
        if (match) {
            UpdateStatusBar("检测到" title "结束[" color "]")
            return
        }
        UpdateStatusBar("等待" title "..." count "/" timeoutCount)
        Sleep(interval)
        count++
    }
    throw TimeoutError(title "颜色匹配超时")
}

/**
 * @description 等待指定像素颜色消失
 * @param {Integer} x 像素X坐标
 * @param {Integer} y 像素Y坐标
 * @param {(String)} color 期望的像素颜色
 * @param {String} title 窗口标题
 * @param {Integer} pixelRange 像素匹配范围（默认5)
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @param {Integer} interval 检查间隔时间（毫秒，默认100）
 * @param {Integer} timeoutCount 超时时间（检查次数，默认50）
 */
WaitUntilColorNotMatch(x, y, color, title,
    pixelRange := 5, colorVariation := 10,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        match := SearchColorMatch(x, y, color, pixelRange, colorVariation)
        if (!match) {
            UpdateStatusBar("检测到" title "结束[" color "]")
            return
        }
        UpdateStatusBar("等待" title "..." count "/" timeoutCount)
        Sleep(interval)
        count++
    }
    throw TimeoutError(title "颜色消失超时")
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

_MenuIconPos := [670, 326]  ; 菜单图标1行1列中心位置
_MenuIconOffsetX := 192  ; 菜单图标X偏移量
_MenuIconOffsetY := 234  ; 菜单图标Y偏移量
_MenuCenterPixel := [952, 556, "0xFEED41"]  ; 菜单中心背景像素

OpenMenu() {
    UpdateStatusBar("打开菜单")
    MySend("Escape")
    WaitUntilColorMatch(
        _MenuCenterPixel[1], _MenuCenterPixel[2],
        _MenuCenterPixel[3], "菜单图标加载", 5, 5, 50, 20)
    Sleep(500)  ; 等待菜单稳定
    UpdateStatusBar("已打开菜单")
}

/**
 * @description 打开菜单并移动到指定图标位置
 * @param {Integer} page 页码（1-2）
 * @param {Integer} row 行号（1-3）
 * @param {Integer} col 列号（1-4）
 * @returns {Array} 包含图标位置的数组 [x, y]
 */
OpenMenuAndMoveToIcon(page, row, col) {
    totalRows := 3  ; 每页行数
    totalCols := 4  ; 每页列数
    OpenMenu()
    UpdateStatusBar("移动到" page "页，" row "行，" col "列")
    loop (page - 1) {
        MySend("e", , 100)  ; 翻页
    }
    if (row < totalRows / 2 + 1) {
        loop (row - 1) {
            MySend("s", , 100)  ; 向下
        }
    } else {
        loop (totalRows + 1 - row) {
            MySend("w", , 100)  ; 向上
        }
    }
    if (col < totalCols / 2 + 1) {
        loop (col - 1) {
            MySend("d", , 100)  ; 向右
        }
    } else {
        loop (totalCols + 1 - col) {
            MySend("a", , 100)  ; 向左
        }
    }
    x := _MenuIconPos[1] + _MenuIconOffsetX * (col - 1)
    y := _MenuIconPos[2] + _MenuIconOffsetY * (row - 1)
    return [x, y]
}

WaitUntilSavingIcon() {
    count := 0
    savingIconPos := [85, 370]  ; 保存中图标位置
    savingIconColor := "0xFFDC7E"  ; 保存中图标颜色
    WaitUntilColorMatch(
        savingIconPos[1], savingIconPos[2],
        savingIconColor, "保存中图标", 5, , 100, 500)
}

; 高位“是”按钮位置，用于：离开房间，确认重新种植
UtilsWindowYes1Pos := [706, 885]
; 高位“否”按钮位置，用于：离开房间，确认重新种植
UtilsWindowNo1Pos := [1218, 885]
; 中位“是”按钮位置，用于：注意返回标题，注意加载覆盖，
; 确认在线出发探险，确认在线退出房间，确认在线解散房间
UtilsWindowYes2Pos := [706, 940]
; 中位“否”按钮位置，用于：注意返回标题，注意加载覆盖，
; 确认在线出发探险，确认在线退出房间，确认在线解散房间
UtilsWindowNo2Pos := [1218, 940]
; 低位“是”按钮位置，用于：确认保存覆盖，确认加载覆盖
UtilsWindowYes3Pos := [706, 960]
; 低位“否”按钮位置，用于：确认保存覆盖，确认加载覆盖
UtilsWindowNo3Pos := [1218, 960]
; 超高位“是”按钮位置，用于：女神草交易所交换确认
UtilsWindowYes4Pos := [706, 865]
; 超高位“否”按钮位置，用于：女神草交易所交换确认
UtilsWindowNo4Pos := [1218, 865]
; 中高位“是”按钮位置，用于：女神果交易所交换确认
UtilsWindowYes5Pos := [706, 925]
; 中高位“否”按钮位置，用于：女神果交易所交换确认
UtilsWindowNo5Pos := [1218, 925]
; 高位“OK”按钮位置，用于：加载覆盖完毕
UtilsWindowOK1Pos := [965, 835]
; 低位“OK”按钮位置，用于：Epic账户绑定，保存覆盖完毕
UtilsWindowOK2Pos := [965, 885]
; 超高位“OK”按钮位置，用于：商店选择购买数量
UtilsWindowOK3Pos := [965, 750]
; 超低位“OK”按钮位置，用于：持有量达到上限的道具自动出售结果
UtilsWindowOK4Pos := [965, 895]
; 极低位“OK”按钮位置，用于：房间搜索错误
UtilsWindowOK5Pos := [965, 940]
; 按钮背景颜色
UtilsWindowButtonColor := "0x88FF74"
; 右侧二短选项时首选项位置，用于：在线选择出发
UtilsOptionListTopIn2GlowPos := [1351, 477]
; 右侧三选项时首选项位置，用于：迷宫树对话
UtilsOptionListTopIn3GlowPos := [1293, 403]
; 右侧五选项时首选项位置，用于：迷宫树对话
UtilsOptionListTopIn5GlowPos := [1293, 283]
; 右侧选项发光颜色，用于：迷宫树对话
UtilsOptionListGlowColor := "0xAFF258"
; 交互按键背景颜色
UtilsKeyBackgroundColor := "0x93805B"
; 继续对话空格键像素
UtilsConversationSpacePixel := [1688, 976, UtilsKeyBackgroundColor]

/**
 * @description 等待对话界面交互空格键加载完成
 */
WaitUntilConversationSpace() {
    WaitUntilColorMatch(
        UtilsConversationSpacePixel[1], UtilsConversationSpacePixel[2],
        UtilsConversationSpacePixel[3], "空格按钮")
    Sleep(500)  ; 等待对话界面稳定
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
        if (SubStr(key, -6) == "Hotkey") {
            ; 如果是预设快捷键，直接跳过
            continue
        }
        try {
            myGui[name].Value := IniRead(
                "main.ini", section, key, myGui[name].Value)
        } catch Error as e {
            ; 如果读取失败，保持默认值
            MsgBox("无法读取配置: " section "." key "，保持默认值")
        }
    }
}

SaveConfig() {
    config := myGui.Submit()
    try {
        for name, currentValue in config.OwnProps() {
            sp := StrSplit(name, ".", , 2)
            if (sp.Length < 2) {
                continue
            }
            section := sp[1]
            key := sp[2]
            IniWrite(currentValue, "main.ini.new", section, key)
        }
    } catch Error as e {
        ShowFailureMsgBox("保存配置失败: " e.Message, e)
        return
    }
    FileMove("main.ini.new", "main.ini", 1)  ; 替换旧配置文件
}

SaveAndExit() {
    SaveConfig()
    ExitApp()
}

SaveAndReload() {
    SaveConfig()
    Reload()
}
