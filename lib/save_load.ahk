#Requires AutoHotkey v2.0

DebugSaveLoad := false

SaveLoadSaveBtnClick() {
    GameWIndowActivate()
    SaveToCloud()
}

SaveLoadLoadBtnClick() {
    GameWIndowActivate()
    LoadFromCloud()
}

_SaveLoadInfoPos := [1204, 342]  ; 幻想生活"i"图标位置
_SaveLoadInfoColor := "0x030300"  ; 幻想生活"i"图标颜色
_SaveLoadCloudPos := [1352, 963]  ; 云存档"X"位置
_SaveLoadCloudColor := "0xFFF8E4"  ; 云存档"X"颜色
; _SaveLoadExclamationPos := [961, 177]  ; 顶部感叹号背景位置
; _SaveLoadExclamationColor := "0xFFB914"  ; 顶部感叹号背景颜色
_SaveLoadExclamationPixel := [961, 177, "0xFFB914"]  ; 顶部感叹号背景像素
_SaveLoadTextPos := [954, 525]  ; "覆盖完毕"文字位置
_SaveLoadTextColor := "0x704216"  ; "覆盖完毕"文字颜色
_SaveLoadOKColor := "0xF8F0DC"  ; "OK"颜色
_SaveLoadOK1Pixel := [975, 863, _SaveLoadOKColor]  ; "OK"1像素
_SaveLoadOK2Pixel := [975, 915, _SaveLoadOKColor]  ; "OK"2像素
_SaveLoadOK1Pos := [975, 863]  ; "OK"位置
_SaveLoadOK2Pos := [975, 915]  ; "OK"位置
_SaveLoadCloudCheckedPos := [1234, 442]  ; 云存档选择位置
_SaveLoadCloudCheckedColor := "0x5CE93F"  ; 云存档选择颜色
_SaveLoadCloudUncheckedColor := "0xB39770"  ; 云存档未选择颜色

SaveToCloud() {
    OpenMenu()
    Sleep(500)
    MySend("x", , 500)  ; 点击存档
    WaitUntilColorMatch(
        _SaveLoadExclamationPixel[1],
        _SaveLoadExclamationPixel[2],
        _SaveLoadExclamationPixel[3],
        "感叹号颜色", 100, 10
    )
    Sleep(500)  ; 等待界面稳定
    if SearchColorMatch(
        _SaveLoadCloudCheckedPos[1],
        _SaveLoadCloudCheckedPos[2],
        _SaveLoadCloudUncheckedColor,
    ) {
        UpdateStatusBar("正在选择云存档")
        MySend("c", , 500)  ; 选择云存档
    }
    if !SearchColorMatch(
        _SaveLoadCloudCheckedPos[1],
        _SaveLoadCloudCheckedPos[2],
        _SaveLoadCloudCheckedColor,
    ) {
        throw ValueError("云存档选择颜色不匹配")
    }
    UpdateStatusBar("确认保存")
    MySend("a", , 500)
    MySend("Space")  ; 确认保存
    counter := 0
    while (true) {
        if SearchColorMatch(
            _SaveLoadTextPos[1], _SaveLoadTextPos[2],
            _SaveLoadTextColor
        ) {
            UpdateStatusBar("云存档覆盖完毕")
            break
        }
        if SearchColorMatch(
            _SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2],
            _SaveLoadOKColor
        ) {
            UpdateStatusBar("确认Epic账户绑定")
            Sleep(200)
            MySend("Space", , 1000)  ; 确认绑定
        }
        counter++
        UpdateStatusBar("等待云存档保存..." counter)
        if (counter > 50) {
            throw TimeoutError("云存档保存超时")
        }
        Sleep(1000)
    }
    Sleep(1000)
    MySend("Space", , 1000)
    MySend("Escape", , 750)  ; 退出菜单
}

LoadFromCloud() {
    OpenMenu()
    Sleep(500)
    MySend("Ctrl", , 500)  ; 返回标题画面
    MySend("a", , 500)
    MySend("Space") ; 确认返回
    WaitUntilColorMatch(
        _SaveLoadInfoPos[1],
        _SaveLoadInfoPos[2],
        _SaveLoadInfoColor,
        "标题界面加载", 1000, 50
    )
    counter := 0
    while (true) {
        color := PixelGetColor(_SaveLoadInfoPos[1], _SaveLoadInfoPos[2])
        if (color == _SaveLoadInfoColor) {
            UpdateStatusBar("标题界面加载完成")
            break
        }
        counter++
        UpdateStatusBar("等待标题界面加载..." counter)
        if (counter > 50) {
            UpdateStatusBar("标题界面加载超时")
            return false
        }
        Sleep(1000)
    }
    Sleep(1000)  ; 等待界面稳定
    MySend("Space", , 1000)  ; 任意键继续
    if !SearchColorMatch(_SaveLoadCloudPos[1], _SaveLoadCloudPos[2],
        _SaveLoadCloudColor
    ) {
        throw ValueError("云存档按钮颜色不匹配")
    }
    MySend("x", , 2000)  ; 点击云存档按钮
    counter := 0
    while (true) {
        if SearchColorMatch(_SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2], _SaveLoadOKColor) {
            UpdateStatusBar("确认Epic账户绑定")
            Sleep(200)
            MySend("Space", , 1000)  ; 确认绑定
        }
        if SearchColorMatch(
            _SaveLoadExclamationPixel[1],
            _SaveLoadExclamationPixel[2],
            _SaveLoadExclamationPixel[3]
        ) {
            UpdateStatusBar("检测到云存档")
            break
        }
        counter++
        UpdateStatusBar("等待云存档检测..." counter)
        if (counter > 60) {
            throw TimeoutError("云存档检测超时")
        }
        Sleep(1000)
    }
    UpdateStatusBar("首次确认覆盖")
    MySend("a", , 500)
    MySend("Space", , 1000)
    UpdateStatusBar("再次确认覆盖")
    MySend("a", , 500)
    MySend("Space", , 1000)
    UpdateStatusBar("等待云存档加载")
    WaitUntilColorMatch(
        _SaveLoadOK1Pixel[1],
        _SaveLoadOK1Pixel[2],
        _SaveLoadOK1Pixel[3],
        "云存档加载", 1000, 50
    )
    Sleep(1000)
    MySend("Space")  ; 确认完成
    UpdateStatusBar("云存档加载完成")
}
