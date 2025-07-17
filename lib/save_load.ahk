#Requires AutoHotkey v2.0

DebugSaveLoad := false

SaveLoad_SaveBtn_Click() {
    SaveToCloud()
}

SaveLoad_LoadBtn_Click() {
    LoadFromCloud()
}

; 共享存档打勾位置
_SaveLoadCloudCheckPos := [1234, 442]
; 共享存档已打勾颜色
_SaveLoadCloudCheckedColor := "0x5CE93F"
; 共享存档未打勾颜色
_SaveLoadCloudUncheckedColor := "0xB39770"
; Epic账户绑定OK文字位置
_SaveLoadEpicAccountTextPos := [720, 500]
; 保存覆盖完毕OK文字位置
_SaveLoadSaveDoneTextPos := [921, 524]
; 加载覆盖完毕OK文字位置
_SaveLoadLoadDoneTextPos := [921, 381]
; 文字颜色
_SaveLoadTextColor := "0x88613B"
; 标题界面幻想生活i图标
_SaveLoadLogoPixel := [955, 332, "0xF9BD00"]
; 标题界面[X]共享存档确认
_SaveLoadXBtnPixel := [1357, 964, "0x75674E"]

SaveToCloud() {
    OutputDebug("Info.save_load.SaveToCloud: 保存到共享存档")
    UpdateStatusBar("保存到共享存档...")

    OpenMenu()
    MySend("x")  ; 点击存档
    WaitUntilColorMatch(
        UtilsWindowNo3Pos[1], UtilsWindowNo3Pos[2],
        UtilsWindowButtonColor, "确认保存覆盖“否”")
    Sleep(200)  ; 等待界面稳定

    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes3Pos[1], UtilsWindowYes3Pos[2],
        UtilsWindowButtonColor, "确认保存覆盖“是”")
    
    OutputDebug("Debug.save_load.SaveToCloud: 选择共享存档")
    if SearchColorMatch(  ; 未选择共享存档
        _SaveLoadCloudCheckPos[1], _SaveLoadCloudCheckPos[2],
        _SaveLoadCloudUncheckedColor, 2
    ) {
        MySend("c", , 200)
    }
    if !SearchColorMatch(  ; 选择共享存档
        _SaveLoadCloudCheckPos[1], _SaveLoadCloudCheckPos[2],
        _SaveLoadCloudCheckedColor, 2
    ) {
        OutputDebug("Error.save_load.SaveToCloud: 共享存档无法选择")
        throw ValueError("共享存档无法选择")
    }

    OutputDebug("Debug.save_load.SaveToCloud: 确认保存")
    Sleep(200)  ; 等待界面稳定
    MySend("Space")  ; 确认保存
    loop (2) {  ; 有可能需要两次OK
        WaitUntilColorMatch(
            UtilsWindowOK2Pos[1], UtilsWindowOK2Pos[2],
            UtilsWindowButtonColor, "OK", , , 1000, 60)
        if SearchColorMatch(
            _SaveLoadEpicAccountTextPos[1], _SaveLoadEpicAccountTextPos[2],
            _SaveLoadTextColor, 2
        ) {
            OutputDebug("Debug.save_load.SaveToCloud: Epic账户已绑定")
            Sleep(200)  ; 等待界面稳定
            MySend("Space")  ; 确认Epic账户绑定
            Sleep(1000)  ; 等待按钮消失，防止下一次WaitUntilColorMatch误触发
        } else if SearchColorMatch(
            _SaveLoadSaveDoneTextPos[1], _SaveLoadSaveDoneTextPos[2],
            _SaveLoadTextColor, 2
        ) {
            OutputDebug("Debug.save_load.SaveToCloud: 保存覆盖完毕")
            Sleep(200)  ; 等待界面稳定
            MySend("Space")  ; 确认保存覆盖完毕
            break
        }
    }
    Sleep(1000)
    MySend("Escape")  ; 退出菜单
    OutputDebug("Info.save_load.SaveToCloud: 共享存档保存完成")
    UpdateStatusBar("共享存档保存完成")
}

LoadFromCloud() {
    OutputDebug("Info.save_load.LoadFromCloud: 读取共享存档")
    OpenMenu()
    MySend("Ctrl")  ; 返回标题画面
    WaitUntilColorMatch(
        UtilsWindowNo2Pos[1], UtilsWindowNo2Pos[2],
        UtilsWindowButtonColor, "注意返回标题“否”")
    Sleep(200)  ; 等待界面稳定
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "注意返回标题“是”")
    MySend("Space")  ; 确认返回
    WaitUntilColorMatch(
        _SaveLoadLogoPixel[1], _SaveLoadLogoPixel[2],
        _SaveLoadLogoPixel[3], "标题界面加载", 30, , 1000, 60)
    Sleep(1000)  ; 等待界面稳定
    MySend("Space")  ; 任意键继续
    WaitUntilColorMatch(
        _SaveLoadXBtnPixel[1], _SaveLoadXBtnPixel[2],
        _SaveLoadXBtnPixel[3], "[X]共享存档确认", , 20)
    Sleep(1000)  ; 等待界面稳定
    MySend("x")  ; 共享存档确认
    count := 0
    timeOutCount := 60
    while (count < timeOutCount) {
        ; 这里需要同时检测Epic账户绑定OK和确认加载覆盖“否”
        if SearchColorMatch(  ; 检测Epic账户绑定OK
            UtilsWindowOK2Pos[1], UtilsWindowOK2Pos[2],
            UtilsWindowButtonColor
        ) {
            OutputDebug("Debug.save_load.LoadFromCloud: Epic账户已绑定")
            MySend("Space")  ; 确认Epic账户绑定
            count := 0  ; 重置计数器
        }
        if SearchColorMatch(  ; 检测确认加载覆盖“否”
            UtilsWindowNo3Pos[1], UtilsWindowNo3Pos[2],
            UtilsWindowButtonColor
        ) {
            OutputDebug("Debug.save_load.LoadFromCloud: 检测确认加载覆盖“否”")
            break
        }
        OutputDebug("Info.save_load.LoadFromCloud: 等待加载界面" count "/" timeOutCount)
        UpdateStatusBar("等待加载界面..." count "/" timeOutCount)
        Sleep(1000)
        count++
    }
    if (count >= timeOutCount) {
        throw TimeoutError("等待加载界面超时")
    }
    Sleep(200)  ; 等待界面稳定
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes3Pos[1], UtilsWindowYes3Pos[2],
        UtilsWindowButtonColor, "确认加载覆盖“是”")
    MySend("Space")  ; 确认加载覆盖
    WaitUntilColorMatch(
        UtilsWindowNo2Pos[1], UtilsWindowNo2Pos[2],
        UtilsWindowButtonColor, "注意加载覆盖“否”")
    Sleep(200)  ; 等待界面稳定
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        UtilsWindowYes2Pos[1], UtilsWindowYes2Pos[2],
        UtilsWindowButtonColor, "注意加载覆盖“是”")
    MySend("Space")  ; 确认加载覆盖
    WaitUntilColorMatch(
        UtilsWindowOK1Pos[1], UtilsWindowOK1Pos[2],
        UtilsWindowButtonColor, "加载覆盖完毕OK", , , 1000, 60)
    Sleep(200)  ; 等待界面稳定
    MySend("Space")  ; 确认加载覆盖完毕OK
    WaitUntilSavingIcon()  ; 等待保存中图标（进入游戏操作界面）
    OutputDebug("Info.save_load.LoadFromCloud: 共享存档加载完成")
    UpdateStatusBar("共享存档加载完成")
}
