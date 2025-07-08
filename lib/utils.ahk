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

MyPaste(text) {
    oldClipboard := A_Clipboard
    A_Clipboard := text
    Sleep(200)  ; 等待剪贴板更新
    MyPress("Ctrl")
    MySend("v")
    MyRelease("Ctrl")
    Sleep(200)  ; 等待粘贴完成
    A_Clipboard := oldClipboard
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
 * @description 获取指定像素的颜色
 * @param {Integer} x 像素X坐标
 * @param {Integer} y 像素Y坐标
 * @return {String} 返回像素颜色字符串（例如 "0xFF0000"）
 */
UtilsGetColor(x, y) {
    return PixelGetColor(x, y)
}

/**
 * @description 对比两个颜色是否匹配
 * @param {String} color1 匹配颜色字符串（例如 "0xFF0000"）
 * @param {String} color2 基准颜色字符串（例如 "0xFF0000"）
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @return {Boolean} 如果颜色匹配则返回true，否则返回false
 */
UtilsMatchColorRGB(color1, color2, colorVariation := 10) {
    rgb1 := Integer(color1)
    rgb2 := Integer(color2)
    rDiff := Abs((rgb1 & 0xFF0000) - (rgb2 & 0xFF0000)) >> 16
    gDiff := Abs((rgb1 & 0x00FF00) - (rgb2 & 0x00FF00)) >> 8
    bDiff := Abs((rgb1 & 0x0000FF) - (rgb2 & 0x0000FF))
    match := rDiff <= colorVariation &&
        gDiff <= colorVariation &&
        bDiff <= colorVariation
    return match
}

/**
 * @description 将RGB颜色转换为HSV颜色
 * @param {String} color RGB颜色字符串（例如 "0xFF0000"）
 * @return {Object} 返回包含H、S、V的对象
 */
UtilsRGB2HSV(color) {
    rgb := Integer(color)
    r := ((rgb & 0xFF0000) >> 16) / 255.0
    g := ((rgb & 0x00FF00) >> 8) / 255.0
    b := (rgb & 0x0000FF) / 255.0
    cMax := Max(r, g, b)
    cMin := Min(r, g, b)
    delta := cMax - cMin
    if delta = 0 {
        h := 0
    } else if cMax = r {
        h := Mod((g - b) / delta, 6)
    } else if cMax = g {
        h := (b - r) / delta + 2
    } else {
        h := (r - g) / delta + 4
    }
    h *= 60  ; 转换为度数
    s := cMax = 0 ? 0 : (delta / cMax) * 100  ; 饱和度百分比
    v := cMax * 100  ; 明度百分比
    return [Round(h), Round(s), Round(v)]
}

; /**
;  * @description 对比指定颜色的HSV值是否在给定范围内
;  * @param {Array} hsv1 匹配颜色HSV
;  * @param {Array} hsv2 基准颜色HSV
;  * @param {Array} hsvVariation 匹配范围数组（默认[15, 15, 15]）
;  * @return {Boolean} 如果颜色匹配则返回true，否则返回false
;  */
; UtilsMatchColorHSV(hsv1, hsv2, hsvVariation := [15, 15, 15]) {
;     hMatch := hsv1[1] >= hsv2[1] - hsvVariation[1] &&
;         hsv1[1] <= hsv2[1] + hsvVariation[1]
;     sMatch := hsv1[2] >= hsv2[2] - hsvVariation[2] &&
;         hsv1[2] <= hsv2[2] + hsvVariation[2]
;     vMatch := hsv1[3] >= hsv2[3] - hsvVariation[3] &&
;         hsv1[3] <= hsv2[3] + hsvVariation[3]
;     return (hMatch && sMatch && vMatch)
; }

/**
 * @description 对比指定颜色的HSV值是否在给定范围内
 * @param {(String|Array)} color1 匹配颜色RGB字符串或HSV数组
 * @param {(String|Array)} color2 基准颜色RGB字符串或HSV数组
 * @param {(Integer|Array)} hsvVar 颜色变化范围（默认10）
 * @param {Boolean} debug 是否启用调试模式（默认false）
 * @return {Boolean} 如果颜色匹配则返回true，否则返回false
 */
UtilsMatchColorHSV(color1, color2, hsvVar := 10, debug := false) {
    if (Type(color1) = "String") {
        hsv1 := UtilsRGB2HSV(color1)
    } else {
        hsv1 := color1
    }
    if (Type(color2) = "String") {
        hsv2 := UtilsRGB2HSV(color2)
    } else {
        hsv2 := color2
    }
    if (Type(hsvVar) = "Integer") {
        hVar := hsvVar
        sVar := hsvVar * 2
        vVar := hsvVar * 3
    } else {
        hVar := hsvVar[1]
        sVar := hsvVar[2]
        vVar := hsvVar[3]
    }
    hMatch := hsv1[1] >= hsv2[1] - hVar && hsv1[1] <= hsv2[1] + hVar
    sMatch := hsv1[2] >= hsv2[2] - sVar && hsv1[2] <= hsv2[2] + sVar
    vMatch := hsv1[3] >= hsv2[3] - vVar && hsv1[3] <= hsv2[3] + vVar
    if (debug) {
        MsgBox(
            "HSV1: " hsv1[1] ", " hsv1[2] ", " hsv1[3] "`n"
            "HSV2: " hsv2[1] ", " hsv2[2] ", " hsv2[3]
        )
    }
    return (hMatch && sMatch && vMatch)
}

/**
 * @description 对比指定像素的颜色
 * @param {Integer} x 像素X坐标
 * @param {Integer} y 像素Y坐标
 * @param {String} color 期望的像素颜色
 * @param {(Integer|Array)} pixelRange 像素匹配范围，Integer表示正方形范围，Array表示[X, Y]（默认5）
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @return {Integer} 如果当前像素颜色与期望颜色匹配则返回true，否则返回false
 */
SearchColorMatch(x, y, color, pixelRange := 5, colorVariation := 10) {
    if (Type(pixelRange) == "Integer") {
        pixelRange := [pixelRange, pixelRange]
    } else if (Type(pixelRange) != "Array" || pixelRange.Length != 2) {
        throw ValueError("pixelRange必须是整数或包含两个整数的数组")
    }
    return PixelSearch(&xf, &yf,
        x - pixelRange[1], y - pixelRange[2],
        x + pixelRange[1], y + pixelRange[2],
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
 * @description 等待两个指定像素颜色的其中一个出现
 * @param {Array} pos1 第一个像素位置数组 [x, y]
 * @param {String} color1 第一个像素颜色
 * @param {Array} pos2 第二个像素位置数组 [x, y]
 * @param {String} color2 第二个像素颜色
 * @param {String} title 窗口标题
 * @param {Integer} pixelRange 像素匹配范围（默认5)
 * @param {Integer} colorVariation 颜色变化范围（默认10）
 * @param {Integer} interval 检查间隔时间（毫秒，默认100）
 * @param {Integer} timeoutCount 超时时间（检查次数，默认50）
 * @returns {Integer} 返回匹配的像素索引（1或2）
 */
WaitUntil2ColorMatch(pos1, color1, pos2, color2, title,
    pixelRange := 5, colorVariation := 10,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        match1 := SearchColorMatch(
            pos1[1], pos1[2], color1, pixelRange, colorVariation)
        match2 := SearchColorMatch(
            pos2[1], pos2[2], color2, pixelRange, colorVariation)
        if (match1 ^ match2) {
            match := match1 ? 1 : 2
            UpdateStatusBar("检测到" title "结束[" match "]"
            )
            return match
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

/**
 * @description 从指定区域获取Bitmap对象并进行标准OCR识别
 * @param {Integer} x 区域左上角X坐标
 * @param {Integer} y 区域左上角Y坐标
 * @param {Integer} w 区域宽度
 * @param {Integer} h 区域高度
 * @return {OCR.Result} 返回OCR识别结果对象
 */
UtilsOCRFromRegion(x, y, w, h) {
    if (Type(OCR) != "Class") {
        throw TypeError("OCR类未正确加载")
    }
    WinGetClientPos(&gx, &gy, , , GameWindowTitle)
    result := OCR.FromRect(x + gx, y + gy, w, h, "zh-CN", {
        scale: 1.0,
        grayscale: true,
        invertcolors: false,
        rotate: 0
    })
    MyToolTip(result.Text, x, y + h, 20)
    return result
}

/**
 * @description 从指定区域获取Bitmap对象并进行颜色增强OCR识别
 * @param {Integer} x 区域左上角X坐标
 * @param {Integer} y 区域左上角Y坐标
 * @param {Integer} w 区域宽度
 * @param {Integer} h 区域高度
 * @param {String} color 字体颜色
 * @param {Integer} hsvVar HSV颜色变化范围（默认8）
 * @return {OCR.Result} 返回OCR识别结果对象
 */
UtilsOCRFromRegionEnhanced(x, y, w, h, color, hsvVar := 8) {
    if !pToken := Gdip_Startup() {
        throw Error("Gdi+启动失败")
    }
    WinGetClientPos(&gx, &gy, , , GameWindowTitle)
    region := (gx + x) "|" (gy + y) "|" w "|" h  ; x|y|w|h
    pBitmap := Gdip_BitmapFromScreen(region)
    E := Gdip_LockBits(pBitmap, 0, 0, w, h, &stride, &scan0, &bitmapData)
    loop w {
        iw := A_Index - 1
        loop h {
            ih := A_Index - 1
            p := scan0 + (ih * stride) + (iw * 4)
            argb := NumGet(p, 0, "UInt")
            rgb := Format("0x{:X}", argb & 0x00FFFFFF)
            match := UtilsMatchColorHSV(rgb, color, hsvVar)
            c := match ? "0xFF0000" : "0x00FFFF"
            NumPut('UInt', c, p)
        }
    }
    Gdip_UnlockBits(pBitmap, &bitmapData)
    Gdip_SaveBitmapToFile(pBitmap, "ocr.png")
    result := OCR.FromBitmap(pBitmap, "zh-CN")
    MyToolTip(result.Text, x, y + h, 20)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    return result
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

WaitUntilSavingIcon(interval := 100, timeoutCount := 500) {
    count := 0
    savingIconPos := [85, 370]  ; 保存中图标位置
    savingIconColor := "0xFFDC7E"  ; 保存中图标颜色
    WaitUntilColorMatch(
        savingIconPos[1], savingIconPos[2],
        savingIconColor, "保存中图标", 5, , interval, timeoutCount)
}

; 高位“是”按钮位置，用于：离开房间，确认重新种植
UtilsWindowYes1Pos := [706, 885]
; 高位“否”按钮位置，用于：离开房间，确认重新种植
UtilsWindowNo1Pos := [1218, 885]
; 中位“是”按钮位置，用于：注意返回标题，注意加载覆盖，
; 确认在线出发探险，确认在线退出房间，确认在线解散房间，确认前往迷宫楼层
UtilsWindowYes2Pos := [706, 940]
; 中位“否”按钮位置，用于：注意返回标题，注意加载覆盖，
; 确认在线出发探险，确认在线退出房间，确认在线解散房间，确认前往迷宫楼层
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
; 极低位“OK”按钮位置，用于：房间搜索错误，消息发送错误
UtilsWindowOK5Pos := [965, 940]
; “OK”“是”“否”按钮选中时的背景绿色
UtilsWindowButtonColor := "0x88FF74"
UtilsOptionListWidePosX := 1293  ; 宽边距选项列表X坐标
UtilsOptionListNarrowPosX := 1351  ; 窄边距选项列表X坐标
UtilsOptionList2WidePosY := 436  ; 2宽选项列表Y坐标
UtilsOptionList2NarrowPosY := 477  ; 2窄选项列表Y坐标
UtilsOptionList3PosY := 403  ; 3宽选项列表Y坐标
UtilsOptionList5PosY := 283  ; 5宽选项列表Y坐标
; 单个选项高度
UtilsOptionListItemHeight := 80
; 右侧选项选中时的发光绿色，用于：大部分对话选项
UtilsOptionListGlowColor := "0xA8F255"
; 交互按键背景灰色
UtilsKeyBackgroundColor := "0x93805B"
; 继续对话空格键像素
UtilsConversationSpacePixel := [1688, 976, UtilsKeyBackgroundColor]

/**
 * @description 返回选项列表检查点
 * @param {Integer} marginType 选项列表边距类型<br>
 *   1（宽）：科隆对话，迷宫树对话，是否再次制作<br>
 *   2（窄）：在线选择出发
 * @param {Integer} index 选项索引（从1开始）
 * @param {Integer} total 选项总数<br>
 *    2：科隆对话，在线选择出发<br>
 *    3：迷宫树对话，科隆对话，是否再次制作<br>
 *    5：迷宫树对话
 * @param {String} title 选项标题
 * @param {Integer} pixelRange 像素匹配范围（默认5）
 * @param {Integer} colorVariation 颜色变化范围（默认20）
 */
UtilsGetOptionListPosition(marginType, index, total) {
    switch (marginType) {
        case 1:
            x := UtilsOptionListWidePosX
        case 2:
            x := UtilsOptionListNarrowPosX
        default:
            throw ValueError("不支持的选项列表边距类型: " marginType)
    }
    switch (total) {
        case 2:
            ys := (marginType == 1) ?
                UtilsOptionList2WidePosY :
                UtilsOptionList2NarrowPosY
        case 3:
            ys := UtilsOptionList3PosY
        case 5:
            ys := UtilsOptionList5PosY
        default:
            throw ValueError("不支持的选项总数: " total)
    }
    y := ys + (index - 1) * UtilsOptionListItemHeight
    return [x, y]
}

/**
 * @description 检查选项列表是否被选中
 * @param {Integer} marginType 选项列表边距类型<br>
 *   1（宽）：科隆对话，迷宫树对话，是否再次制作<br>
 *   2（窄）：在线选择出发
 * @param {Integer} index 选项索引（从1开始）
 * @param {Integer} total 选项总数<br>
 *    2：科隆对话，在线选择出发<br>
 *    3：迷宫树对话，科隆对话，是否再次制作<br>
 *    5：迷宫树对话
 * @param {Integer} pixelRange 像素匹配范围（默认5）
 * @param {Integer} colorVariation 颜色变化范围（默认20）
 */
UtilsOptionListSelected(listType, index, total,
    pixelRange := 5, colorVariation := 20
) {
    pos := UtilsGetOptionListPosition(listType, index, total)
    return SearchColorMatch(
        pos[1], pos[2], UtilsOptionListGlowColor,
        pixelRange, colorVariation
    )
}

/**
 * @description 等待选项列表被选中的绿色加载完成
 * @param {Integer} marginType 选项列表边距类型<br>
 *   1（宽）：科隆对话，迷宫树对话，是否再次制作<br>
 *   2（窄）：在线选择出发
 * @param {Integer} index 选项索引（从1开始）
 * @param {Integer} total 选项总数<br>
 *    2：科隆对话，在线选择出发<br>
 *    3：迷宫树对话，科隆对话，是否再次制作<br>
 *    5：迷宫树对话
 * @param {String} title 选项标题
 * @param {Integer} pixelRange 像素匹配范围（默认5）
 * @param {Integer} colorVariation 颜色变化范围（默认20）
 * @param {Integer} interval 检查间隔时间（毫秒，默认50）
 * @param {Integer} timeoutCount 超时时间（检查次数，默认100）
 */
UtilsWaitUntilOptionListSelected(listType, index, total, title,
    pixelRange := 5, colorVariation := 20,
    interval := 100, timeoutCount := 50
) {
    if (index < 1 || index > total) {
        throw ValueError("选项索引必须在1到" total "之间")
    }
    pos := UtilsGetOptionListPosition(listType, index, total)
    WaitUntilColorMatch(
        pos[1], pos[2], UtilsOptionListGlowColor, title,
        pixelRange, colorVariation, interval, timeoutCount
    )
}

/**
 * @description 等待对话界面交互空格键加载完成
 */
WaitUntilConversationSpace(interval := 100, timeoutCount := 50) {
    WaitUntilColorMatch(
        UtilsConversationSpacePixel[1], UtilsConversationSpacePixel[2],
        UtilsConversationSpacePixel[3], "空格按钮", , , interval, timeoutCount)
    Sleep(500)  ; 等待对话界面稳定
}

/**
 * @description 等待指定按钮加载完成
 * @param {Integer} x 按钮X坐标
 * @param {Integer} y 按钮Y坐标
 * @param {String} title 按钮标题
 * @param {(Integer|Array)} pixelRange 像素匹配范围，Integer表示正方形范围，Array表示[X, Y]（默认20）
 * @param {Integer} colorVariation 颜色变化范围（默认3）
 * @param {Integer} interval 检查间隔时间（毫秒，默认100）
 * @param {Integer} timeoutCount 超时时间（检查次数，默认50）
 */
WaitUntilButton(
    x, y, title,
    pixelRange := 20, colorVariation := 3,
    interval := 100, timeoutCount := 50
) {
    count := 0
    while (count < timeoutCount) {
        found := SearchColorMatch(
            x, y, UtilsKeyBackgroundColor,
            pixelRange, colorVariation)
        if (found) {
            UpdateStatusBar("检测到" title "按钮加载完成")
            return
        }
        UpdateStatusBar("等待" title "按钮加载完成..." count "/" timeoutCount)
        Sleep(interval)
        count++
    }
    throw TimeoutError(title "按钮加载超时")
}

UtilsMapPixel := [1635, 74, "0x0373FF"]  ; 地图右上角标记logo
/**
 * @description 检测是否在地图界面
 * @return {Boolean} 如果在地图界面返回true，否则返回false
 */
UIIsInMap() {
    found := SearchColorMatch(
        UtilsMapPixel[1], UtilsMapPixel[2], UtilsMapPixel[3], 20)
    return found
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
