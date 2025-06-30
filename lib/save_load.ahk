#Requires AutoHotkey v2.0

DebugSaveLoad := false

SaveLoadSaveBtnClick() {
    SaveToCloud()
}

SaveLoadLoadBtnClick() {
    LoadFromCloud()
}

_SaveLoadLogoPos := [1204, 342]  ; 幻想生活"i"图标位置
_SaveLoadLogoColor := "0x030300"  ; 幻想生活"i"图标颜色
_SaveLoadCloudPos := [1352, 963]  ; 云存档"X"位置
_SaveLoadCloudColor := "0xFFF8E4"  ; 云存档"X"颜色

_SaveLoadConfirmNoPos := [1218, 960]  ; 确认“否”按钮（保存覆盖/加载覆盖）
_SaveLoadConfirmYesPos := [706, 960]  ; 确认“是”按钮（保存覆盖/加载覆盖）
_SaveLoadWarningNoPos := [1218, 940]  ; 注意“否”按钮（返回标题/加载覆盖）
_SaveLoadWarningYesPos := [706, 940]  ; 注意“是”按钮（返回标题/加载覆盖）
_SaveLoadOK1Pos := [965, 885]  ; “OK”按钮（Epic账户绑定OK/保存覆盖完毕OK）
_SaveLoadOK2Pos := [965, 835]  ; “OK”按钮（加载覆盖完毕OK）
_ButtonBackgroundColor := "0x88FF74"  ; 按钮背景颜色
_SaveLoadCloudCheckPos := [1234, 442]  ; 共享存档打勾位置
_SaveLoadCloudCheckedColor := "0x5CE93F"  ; 共享存档已打勾颜色
_SaveLoadCloudUncheckedColor := "0xB39770"  ; 共享存档未打勾颜色
_SaveLoadEpicAccountTextPos := [720, 500]  ; Epic账户绑定OK文字位置
_SaveLoadSaveDoneTextPos := [921, 524]  ; 保存覆盖完毕OK文字位置
_SaveLoadLoadDoneTextPos := [921, 381]  ; 加载覆盖完毕OK文字位置
_SaveLoadTextColor := "0x88613B"  ; 文字颜色
_SaveLoadLogoPixel := [1202, 348, "0xFFE000"]  ; 标题幻想生活"i"图标
_SaveLoadXBtnPixel := [1357, 964, "0x75674E"]  ; 标题[X]共享存档确认

SaveToCloud() {
    OpenMenu()
    MySend("x")  ; 点击存档
    WaitUntilColorMatch(
        _SaveLoadConfirmNoPos[1], _SaveLoadConfirmNoPos[2],
        _ButtonBackgroundColor, "确认保存覆盖“否”", 5
    )
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        _SaveLoadConfirmYesPos[1], _SaveLoadConfirmYesPos[2],
        _ButtonBackgroundColor, "确认保存覆盖“是”", 5
    )
    if SearchColorMatch(  ; 未选择共享存档
        _SaveLoadCloudCheckPos[1], _SaveLoadCloudCheckPos[2],
        _SaveLoadCloudUncheckedColor, 5
    ) {
        UpdateStatusBar("选择共享存档")
        MySend("c", , 200)
    }
    if !SearchColorMatch(  ; 选择共享存档
        _SaveLoadCloudCheckPos[1], _SaveLoadCloudCheckPos[2],
        _SaveLoadCloudCheckedColor, 5
    ) {
        color := PixelGetColor(_SaveLoadCloudCheckPos*)
        throw ValueError("共享存档无法选择[" color "]")
    }
    UpdateStatusBar("确认保存")
    MySend("Space")  ; 确认保存
    loop (2) {  ; 有可能需要两次OK
        WaitUntilColorMatch(
            _SaveLoadOK1Pos[1], _SaveLoadOK1Pos[2],
            _ButtonBackgroundColor, "OK", 5, , 1000, 60
        )
        if SearchColorMatch(
            _SaveLoadEpicAccountTextPos[1], _SaveLoadEpicAccountTextPos[2],
            _SaveLoadTextColor, 5
        ) {
            UpdateStatusBar("检测到Epic账户绑定OK")
            MySend("Space")  ; 确认Epic账户绑定
        }
        if SearchColorMatch(
            _SaveLoadSaveDoneTextPos[1], _SaveLoadSaveDoneTextPos[2],
            _SaveLoadTextColor, 5
        ) {
            UpdateStatusBar("检测到保存覆盖完毕OK")
            MySend("Space")  ; 确认保存覆盖完毕
            break
        }
    }
    Sleep(1000)
    MySend("Escape")  ; 退出菜单
    UpdateStatusBar("共享存档保存完成")
}

LoadFromCloud() {
    OpenMenu()
    MySend("Ctrl")  ; 返回标题画面
    WaitUntilColorMatch(
        _SaveLoadWarningNoPos[1], _SaveLoadWarningNoPos[2],
        _ButtonBackgroundColor, "注意返回标题“否”", 5)
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        _SaveLoadWarningYesPos[1], _SaveLoadWarningYesPos[2],
        _ButtonBackgroundColor, "注意返回标题“是”", 5)
    MySend("Space")  ; 确认返回
    WaitUntilColorMatch(
        _SaveLoadLogoPixel[1], _SaveLoadLogoPixel[2],
        _SaveLoadLogoPixel[3], "标题界面加载", 5, , 1000, 60)
    Sleep(1000)  ; 等待界面稳定
    MySend("Space")  ; 任意键继续
    WaitUntilColorMatch(
        _SaveLoadXBtnPixel[1], _SaveLoadXBtnPixel[2],
        _SaveLoadXBtnPixel[3], "[X]共享存档确认", 5, 20)
    Sleep(1000)  ; 等待界面稳定
    MySend("x")  ; 共享存档确认
    count := 0
    timeOutCount := 60
    while (count < timeOutCount) {
        ; 这里需要同时检测Epic账户绑定OK和确认加载覆盖“否”
        ; WaitUntilColorMatch()不支持同时检测多个位置
        if SearchColorMatch(  ; 检测Epic账户绑定OK
            _SaveLoadOK1Pos[1], _SaveLoadOK1Pos[2],
            _ButtonBackgroundColor, 5
        ) {
            UpdateStatusBar("检测到Epic账户绑定OK")
            MySend("Space")  ; 确认Epic账户绑定
            count := 0  ; 重置计数器
        }
        if SearchColorMatch(  ; 检测确认加载覆盖“否”
            _SaveLoadConfirmNoPos[1], _SaveLoadConfirmNoPos[2],
            _ButtonBackgroundColor, 5
        ) {
            UpdateStatusBar("检测到确认加载覆盖“否”")
            break
        }
        UpdateStatusBar("等待加载界面..." count "/" timeOutCount)
        Sleep(1000)
        count++
    }
    if (count >= timeOutCount) {
        throw TimeoutError("等待加载界面超时")
    }
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        _SaveLoadConfirmYesPos[1], _SaveLoadConfirmYesPos[2],
        _ButtonBackgroundColor, "确认加载覆盖“是”", 5)
    MySend("Space")  ; 确认加载覆盖
    WaitUntilColorMatch(
        _SaveLoadWarningNoPos[1], _SaveLoadWarningNoPos[2],
        _ButtonBackgroundColor, "注意加载覆盖“否”", 5)
    MySend("a")  ; 移动到“是”按钮
    WaitUntilColorMatch(
        _SaveLoadWarningYesPos[1], _SaveLoadWarningYesPos[2],
        _ButtonBackgroundColor, "注意加载覆盖“是”", 5)
    MySend("Space")  ; 确认加载覆盖
    WaitUntilColorMatch(
        _SaveLoadOK2Pos[1], _SaveLoadOK2Pos[2],
        _ButtonBackgroundColor, "加载覆盖完毕OK", 5, , 1000, 60)
    MySend("Space")  ; 确认加载覆盖完毕OK
    UpdateStatusBar("共享存档加载完成")
}
