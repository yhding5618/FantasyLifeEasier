#Requires AutoHotkey v2.0

DebugSaveLoad := false

SaveLoadSaveBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !SaveToCloud() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

SaveLoadLoadBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !LoadFromCloud() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

_SaveLoadInfoPos := [1204, 342]  ; 幻想生活"i"图标位置
_SaveLoadInfoColor := "0x030300"  ; 幻想生活"i"图标颜色
_SaveLoadCloudPos := [1352, 963]  ; 云存档"X"位置
_SaveLoadCloudColor := "0xFFF8E4"  ; 云存档"X"颜色
_SaveLoadExclamationPos := [961, 177]  ; 顶部感叹号背景位置
_SaveLoadExclamationColor := "0xFFB914"  ; 顶部感叹号背景颜色
_SaveLoadTextPos := [954, 525]  ; "覆盖完毕"文字位置
_SaveLoadTextColor := "0x704216"  ; "覆盖完毕"文字颜色
_SaveLoadOK1Pos := [975, 863]  ; "OK"位置
_SaveLoadOK2Pos := [975, 915]  ; "OK"位置
_SaveLoadOKColor := "0xF8F0DC"  ; "OK"颜色
_SaveLoadCloudCheckedPos := [1234, 442]  ; 云存档选择位置
_SaveLoadCloudCheckedColor := "0x5CE93F"  ; 云存档选择颜色
_SaveLoadCloudUncheckedColor := "0xB39770"  ; 云存档未选择颜色

SaveToCloud() {
    MySend("Escape", , 750)  ; 打开菜单
    MySend("x", , 1000)  ; 点击存档
    color := PixelGetColor(_SaveLoadExclamationPos[1], _SaveLoadExclamationPos[2])
    if (color != _SaveLoadExclamationColor) {
        UpdateStatusBar("感叹号颜色不匹配: " color)
        return false
    }
    color := PixelGetColor(_SaveLoadCloudCheckedPos[1], _SaveLoadCloudCheckedPos[2])
    if (color == _SaveLoadCloudUncheckedColor) {
        UpdateStatusBar("未选择云存档，正在选择")
        MySend("c", , 500)  ; 选择云存档
        color := PixelGetColor(_SaveLoadCloudCheckedPos[1], _SaveLoadCloudCheckedPos[2])
    }
    if (color != _SaveLoadCloudCheckedColor) {
        UpdateStatusBar("云存档未选中，颜色不匹配: " color)
        return false
    }
    UpdateStatusBar("确认保存")
    MySend("a", , 1500)
    MySend("Space")  ; 确认保存
    counter := 0
    while (true) {
        color := PixelGetColor(_SaveLoadTextPos[1], _SaveLoadTextPos[2])
        MyToolTip("覆盖完毕 " color, _SaveLoadTextPos[1], _SaveLoadTextPos[2], 18, DebugSaveLoad)
        if (color == _SaveLoadTextColor) {
            UpdateStatusBar("云存档覆盖完毕")
            break
        }
        color := PixelGetColor(_SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2])
        MyToolTip("OK2 " color, _SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2], 17, DebugSaveLoad)
        if (color == _SaveLoadOKColor) {
            UpdateStatusBar("确认Epic账户绑定")
            Sleep(200)
            MySend("Space", , 1000)  ; 确认绑定
        }
        counter++
        UpdateStatusBar("等待云存档保存..." counter)
        if (counter > 50) {
            UpdateStatusBar("云存档保存超时")
            return false
        }
        Sleep(1000)
    }
    Sleep(1000)
    MySend("Space", , 1000)
    MySend("Escape", , 750)  ; 退出菜单
    return true
}

LoadFromCloud() {
    MySend("Escape", , 750)  ; 打开菜单
    MySend("Ctrl", , 500)  ; 返回标题画面
    MySend("a", , 500)
    MySend("Space") ; 确认返回
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
    color := PixelGetColor(_SaveLoadCloudPos[1], _SaveLoadCloudPos[2])
    if (color != _SaveLoadCloudColor) {
        UpdateStatusBar("未找到云存档按钮")
        return false
    }
    MySend("x", , 2000)  ; 点击云存档按钮
    counter := 0
    while (true) {
        color := PixelGetColor(_SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2])
        MyToolTip(color, _SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2], 17, DebugSaveLoad)
        if (color == _SaveLoadOKColor) {
            UpdateStatusBar("确认Epic账户绑定")
            Sleep(200)
            MySend("Space", , 1000)  ; 确认绑定
        }
        color := PixelGetColor(_SaveLoadExclamationPos[1], _SaveLoadExclamationPos[2])
        if (color == _SaveLoadExclamationColor) {
            UpdateStatusBar("检测到云存档")
            break
        }
        counter++
        UpdateStatusBar("等待云存档检测..." counter)
        if (counter > 50) {
            UpdateStatusBar("云存档检测超时")
            return false
        }
        Sleep(1000)
    }
    UpdateStatusBar("首次确认覆盖")
    MySend("a", , 500)
    MySend("Space", , 1000)
    UpdateStatusBar("再次确认覆盖")
    MySend("a", , 500)
    MySend("Space", , 1000)
    counter := 0
    while (true) {
        color := PixelGetColor(_SaveLoadOK1Pos[1], _SaveLoadOK1Pos[2])
        if (color == _SaveLoadOKColor) {
            UpdateStatusBar("云存档加载完成")
            break
        }
        counter++
        UpdateStatusBar("等待云存档加载..." counter)
        if (counter > 50) {
            UpdateStatusBar("云存档加载超时")
            return false
        }
        Sleep(1000)
    }
    MySend("Space", , 500)  ; 确认完成
    return true
}
