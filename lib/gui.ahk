#Requires AutoHotkey v2.0

BuildMyGui() {
    try {
        myGui.AddTab3("w300 vMainTab", [])
        _CreateTabBasic()
        _CreateTabCraft()
        _CreateTabCamp()
        _CreateTabGinormosia()
        _CreateTabSetting()
        myGui.AddStatusBar("vStatusBar", "")
    } catch Error as e {
        ShowFailureMsgBox("创建GUI失败", e, true)
        ExitApp()
    }
}

ShowMyGui() {
    ScriptControl_AlwaysOnTopChk_Click()
    GameWindow_PixelInfoUpdateChk_Click()
    ScriptControlRegisterAllHotkeys()
    tabIndex := ScriptControlGetTabIndex()
    myGui["MainTab"].Choose(tabIndex)
    myGuiPos := ScriptControlGetWindowPos()
    myGui.Show(myGuiPos " AutoSize")
}

UpdateStatusBar(text) {
    myGui["StatusBar"].Text := text
}

AppendStatusBar(text) {
    myGui["StatusBar"].Text .= text
}

_AddAndUseTab(name) {
    myGui["MainTab"].Add([name])
    myGui["MainTab"].Choose(name)
    myGui["MainTab"].UseTab(name)
}

_GroupBoxSize(row, firstSection) {
    return "w" 280 " h" (15 + row * 30) " Section" (firstSection ? "" : " xs")
}

_GroupBoxRowPos(row) {
    return "xs" 10 " ys" (15 + (row - 1) * 30)
}

_CreateTabBasic() {
    _AddAndUseTab("基本")
    _CreateSectionGameWindow(true)
    _CreateSectionTeleportationGate()
    _CreateSectionSaveLoad()
}

_CreateTabCraft() {
    _AddAndUseTab("制作")
    _CreateSectionLongCape(true)
    _CreateSectionMiniGame()
}

_CreateTabCamp() {
    _AddAndUseTab("据点")
    _CreateSectionTreasureGrove(true)
    _CreateSectionWeaponAging()
    _CreateSectionOnline()
    _CreateSectionMysteryBox()

}
_CreateTabGinormosia() {
    _AddAndUseTab("无垠大陆")
    _CreateSectionMimic(true)
    _CreateSectionLegendary()
    _CreateSectionFarming()
}

_CreateTabSetting() {
    _AddAndUseTab("设置")
    _CreateSectionScriptWindow(true)
    _CreateSectionScriptNotification()
    _CreateSectionScriptPresetHotkey()
    _CreateSectionScriptCustomHotkey()
    _CreateSectionScriptVersion()
}

_CreateSectionGameWindow(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "游戏窗口")
    btn := myGui.AddButton(
        _GroupBoxRowPos(1) " w80 vGameWindow.CheckBtn", "检查进程")
    callback := TryAndCatch.Bind(GameWindow_CheckBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    myGui.AddText("yp w150 r4 vGameWindow.Status", "")
    btn := myGui.AddButton(
        _GroupBoxRowPos(2) " w80 vGameWindow.ActivateBtn", "打开游戏窗口")
    callback := TryAndCatch.Bind(GameWindow_ActivateBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "像素信息：")
    myGui.AddEdit("yp hp w146 r1 vGameWindow.PixelInfo ReadOnly 0x200", "")
    chk := myGui.AddCheckbox("yp hp vGameWindow.PixelInfoUpdateChk", "刷新")
    chk.OnEvent("Click", GameWindow_PixelInfoUpdateChk_Click)
}

_CreateSectionTeleportationGate(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "任意门")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "任意门位置：")
    myGui.AddEdit("yp w32 hp")
    myGui.AddUpDown("vTeleportationGate.IconPage Range1-2 0x80", 1)
    myGui.AddText("yp hp 0x200", "页")
    myGui.AddEdit("yp w32 hp hp")
    myGui.AddUpDown("vTeleportationGate.IconRow Range1-3 0x80", 1)
    myGui.AddText("yp hp 0x200", "行")
    myGui.AddEdit("yp w32 hp hp")
    myGui.AddUpDown("vTeleportationGate.IconCol Range1-4 0x80", 1)
    myGui.AddText("yp hp 0x200", "列")
    btn := myGui.AddButton(
        _GroupBoxRowPos(2) " vTeleportationGate.OneWayBtn", "单程")
    callback := TryAndCatch.Bind(TeleportationGate_OneWayBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vTeleportationGate.ReturnTripBtn", "往返")
    callback := TryAndCatch.Bind(TeleportationGate_ReturnTripBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionSaveLoad(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "存档")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " vSaveLoad.SaveBtn", "保存云")
    callback := TryAndCatch.Bind(SaveLoad_SaveBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vSaveLoad.LoadBtn", "加载云")
    callback := TryAndCatch.Bind(SaveLoad_LoadBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionLongCape(firstSection := false) {
    totalRows := 4
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "长披风->重置石")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "数量（1-999）：")
    myGui.AddEdit("xp+110 yp hp w50")
    myGui.AddUpDown("vLongCape.Count Range1-999 0x80", 100)
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "购买间隔（毫秒）：")
    myGui.AddEdit("xp+110 yp hp w50", "30")
    myGui.AddUpDown("vLongCape.BuyInterval Range1-5000 0x80", 750)
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "选择间隔（毫秒）：")
    myGui.AddEdit("xp+110 yp hp w50", "30")
    myGui.AddUpDown("vLongCape.SelectInterval Range1-5000 0x80", 250)
    btn := myGui.AddButton(_GroupBoxRowPos(4) " vLongCape.BuyBtn", "批量购买")
    callback := TryAndCatch.Bind(LongCape_BuyBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vLongCape.SelectBtn", "批量选择")
    callback := TryAndCatch.Bind(LongCape_SelectBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionMiniGame(firstSection := false) {
    totalRows := 6
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "小游戏")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "连按次数：")
    myGui.AddEdit("xp+110 yp hp w50", "10")
    myGui.AddUpDown("vMiniGame.MashCount Range1-99 0x80", 10)
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "连按间隔（毫秒）：")
    myGui.AddEdit("xp+110 yp hp w50", "10")
    myGui.AddUpDown("vMiniGame.MashInterval Range1-1000 0x80", 100)
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "长按延迟（毫秒）：")
    myGui.AddEdit("xp+110 yp hp w50")
    myGui.AddUpDown("vMiniGame.HoldDelay Range1-5000 0x80", 1600)
    myGui.AddText(_GroupBoxRowPos(4) " h22 0x200", "转动次数：")
    myGui.AddEdit("xp+110 yp hp w50")
    myGui.AddUpDown("vMiniGame.SpinCount Range1-99 0x80", 10)
    myGui.AddText(_GroupBoxRowPos(5) " h22 0x200", "转动间隔（毫秒）：")
    myGui.AddEdit("xp+110 yp hp w50", "100")
    myGui.AddUpDown("vMiniGame.SpinInterval Range0-1000 0x80", 0)
    btn := myGui.AddButton(
        _GroupBoxRowPos(6) " vMiniGame.SingleActionBtn", "单次操作")
    callback := TryAndCatch.Bind(MiniGame_SingleActionBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vMiniGame.ContinuousActionBtn", "连续操作")
    callback := TryAndCatch.Bind(MiniGame_ContinuousActionBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionTreasureGrove(firstSection := false) {
    totalRows := 4
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "扭蛋迷宫树")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "年代选择：向")
    myGui.AddDropDownList(
        "yp w36 Choose2 AltSubmit vTreasureGrove.YearMoveDir", ["上", "下"])
    myGui.AddEdit("yp w36")
    myGui.AddUpDown("vTreasureGrove.YearMoveCount Range1-10 0x80", 1)
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "检查特殊房：")
    myGui.AddDropDownList(
        "yp w70 Choose1 AltSubmit vTreasureGrove.TargetSpecialRoom",
        ["全部", "怪物小屋", "熟成祭坛", "惊魂器", "宝物库"])
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "检查Boss：")
    myGui.AddEdit("yp hp w150 0x200 vTreasureGrove.TargetBossName")
    btn := myGui.AddButton(
        _GroupBoxRowPos(4) " vTreasureGrove.ReplantBtn", "重新种植")
    callback := TryAndCatch.Bind(TreasureGrove_ReplantBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vTreasureGrove.CheckRoomBtn", "手动检查地图")
    callback := TryAndCatch.Bind(TreasureGrove_CheckRoomBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vTreasureGrove.NextReplantBtn", "下一次重新种植")
    callback := TryAndCatch.Bind(TreasureGrove_NextReplantBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionWeaponAging(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "武器熟成")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " vWeaponAging.AgeBtn", "熟成")
    callback := TryAndCatch.Bind(WeaponAging_AgeBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vWeaponAging.LoadAndAgeBtn", "SL并熟成")
    callback := TryAndCatch.Bind(WeaponAging_LoadAndAgeBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionOnline(firstSection := false) {
    totalRows := 5
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "联机房间")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "招募目的地：")
    myGui.AddDropDownList(
        "yp w100 Choose1 AltSubmit vOnline.Destination",
        ["皆可", "环岛冒险", "探索大陆", "扭蛋迷宫树"])
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "关键词：")
    myGui.AddEdit("yp hp w60 vOnline.Keyword", "")
    myGui.AddText("yp hp 0x200", "密码：")
    myGui.AddEdit("yp hp w60 vOnline.Password", "")
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "作为房主：")
    btn := myGui.AddButton("xs+76 yp vOnline.RecruitBtn", "招募")
    callback := TryAndCatch.Bind(Online_RecruitBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vOnline.HeadOutBtn", "出发")
    callback := TryAndCatch.Bind(Online_HeadOutBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vOnline.EndBtn", "结束")
    callback := TryAndCatch.Bind(Online_EndBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton(
        _GroupBoxRowPos(4) " xs+76 h22 vOnline.EndLoadRecruitBtn", "结束并SL重新招募")
    callback := TryAndCatch.Bind(Online_EndLoadRecruitBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    myGui.AddText(_GroupBoxRowPos(5) " h22 0x200", "作为成员：")
    btn := myGui.AddButton("yp vOnline.JoinBtn", "加入")
    callback := TryAndCatch.Bind(Online_JoinBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vOnline.LeaveBtn", "离开")
    callback := TryAndCatch.Bind(Online_LeaveBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vOnline.RejoinBtn", "离开并重新加入")
    callback := TryAndCatch.Bind(Online_RejoinBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionMysteryBox(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "盲盒")
    myGui.AddDropDownList(
        _GroupBoxRowPos(1) " w110 Choose1 AltSubmit vMysteryBox.Shop",
        ["女神草交易所", "女神果实交易所"])
    myGui.AddText("yp hp 0x200", " -> 其他类别 -> 第")
    myGui.AddEdit("yp hp w40")
    myGui.AddUpDown("vMysteryBox.ItemIndex Range1-3 0x80", 1)
    myGui.AddText("yp hp 0x200", "项")
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "数量：")
    myGui.AddEdit("yp hp w50")
    myGui.AddUpDown("vMysteryBox.BuyCount Range1-999 0x80", 1)
    btn := myGui.AddButton("yp vMysteryBox.BuyBtn", "购买")
    callback := TryAndCatch.Bind(MysteryBox_BuyBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vMysteryBox.LoadAndBuyBtn", "SL并购买")
    callback := TryAndCatch.Bind(MysteryBox_LoadAndBuyBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionMimic(firstSection := false) {
    totalRows := 7
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "宝箱怪")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "蓄力时间（毫秒）：")
    myGui.AddEdit("xp+140 yp w50 hp")
    myGui.AddUpDown("vMimic.HoldTime Range1-5000 0x80", 1050)
    myGui.AddText(_GroupBoxRowPos(2) " hp 0x200", "等待时间（毫秒）：")
    myGui.AddEdit("xp+140 yp w50 hp")
    myGui.AddUpDown("vMimic.WaitTime Range1-5000 0x80", 2200)
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "复位前进时间（毫秒）：")
    myGui.AddEdit("xp+140 yp hp w50")
    myGui.AddUpDown("vMimic.ResetForwardTime Range1-5000 0x80", 700)
    myGui.AddText(_GroupBoxRowPos(4) " hp 0x200", "复位后退时间（毫秒）：")
    myGui.AddEdit("xp+140 yp hp w50")
    myGui.AddUpDown("vMimic.ResetBackwardTime Range1-5000 0x80", 920)
    myGui.AddText(_GroupBoxRowPos(5) " h22 0x200", "手动复位时间（秒）：")
    myGui.AddEdit("xp+140 yp hp w50")
    myGui.AddUpDown("vMimic.ResetWaitTime Range0-10 0x80", 1)
    myGui.AddText(_GroupBoxRowPos(6) " h22 0x200", "重复击杀数量：")
    myGui.AddEdit("xp+140 yp hp w50")
    myGui.AddUpDown("vMimic.KillCount Range1-99 0x80", 1)
    btn := myGui.AddButton(
        _GroupBoxRowPos(7) " vMimic.TestSkillBtn", "测试技能")
    callback := TryAndCatch.Bind(Mimic_TestSkillBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vMimic.RefreshAndKillBtn", "刷新并击杀")
    callback := TryAndCatch.Bind(Mimic_RefreshAndKillBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionLegendary(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "传奇任务")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "检查任务：")
    myGui.AddCheckbox("yp hp vLegendary.IncludeEnemyChk", "怪")
    myGui.AddCheckbox("yp hp vLegendary.IncludeTreeChk", "树")
    myGui.AddCheckbox("yp hp vLegendary.IncludeDiamondChk", "钻")
    myGui.AddCheckbox("yp hp vLegendary.IncludeFishChk", "鱼")
    myGui.AddCheckbox("yp hp vLegendary.IncludePotatoChk", "豆")
    btn := myGui.AddButton(
        _GroupBoxRowPos(2) " vLegendary.CheckMapBtn", "检查地图")
    callback := TryAndCatch.Bind(Legendary_CheckMapBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    btn := myGui.AddButton("yp vLegendary.RefreshMapBtn", "刷新等级")
    callback := TryAndCatch.Bind(Legendary_RefreshMapBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
    myGui.AddCheckbox("yp hp vLegendary.AutoCheckChk", "刷新后自动检查")
}

_CreateSectionFarming(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "农田")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "重复收获次数：")
    myGui.AddEdit("xp+140 yp w50 hp")
    myGui.AddUpDown("vFarming.HarvestCount Range1-999 0x80", 3)
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "等待时间（秒）：")
    myGui.AddEdit("xp+140 yp w50 hp")
    myGui.AddUpDown("vFarming.HarvestWaitDelay Range1-999 0x80", 30)
    btn := myGui.AddButton(
        _GroupBoxRowPos(3) " vFarming.HarvestBtn", "重复收获")
    callback := TryAndCatch.Bind(Farming_HarvestBtn_Click)
    btn.OnEvent("Click", callback)
    _AddBtnToHotkeyList(btn, callback)
}

_CreateSectionScriptWindow(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "窗口")
    chk := myGui.AddCheckbox(
        _GroupBoxRowPos(1) " h22 vScriptControl.AlwaysOnTopChk", "置顶")
    chk.OnEvent("Click", ScriptControl_AlwaysOnTopChk_Click)
    chk := myGui.AddCheckbox(
        "yp hp vScriptControl.RememberWindowPos", "记住最后位置")
    chk := myGui.AddCheckbox(
        "yp hp vScriptControl.RememberTabIndex", "记住最后标签页")
    myGui.AddEdit("yp w0 hp Hidden Number vScriptControl.WindowPosX", -1)
    myGui.AddEdit("yp w0 hp Hidden Number vScriptControl.WindowPosY", -1)
    myGui.AddEdit("yp w0 hp Hidden Number vScriptControl.TabIndex", 1)
}

_CreateSectionScriptNotification(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "运行结果")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "成功时：")
    MyGui.AddRadio("yp hp vScriptControl.SuccessNoChk", "不提醒")
    chk := myGui.AddRadio(
        "yp hp Checked vScriptControl.SuccessSoundChk", "音效")
    chk.OnEvent("Click", ScriptControl_SuccessSoundChk_Click)
    chk := myGui.AddRadio("yp hp vScriptControl.SuccessMsgBoxChk", "弹窗")
    chk.OnEvent("Click", ScriptControl_SuccessMsgBoxChk_Click)
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "失败时：")
    MyGui.AddRadio("yp hp vScriptControl.FailureNoChk", "不提醒")
    chk := myGui.AddRadio(
        "yp hp Checked vScriptControl.FailureSoundChk", "音效")
    chk.OnEvent("Click", ScriptControl_FailureSoundChk_Click)
    chk := myGui.AddRadio("yp hp vScriptControl.FailureMsgBoxChk", "弹窗")
    chk.OnEvent("Click", ScriptControl_FailureMsgBoxChk_Click)
}

_CreateSectionScriptPresetHotkey(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "预设快捷键")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "暂停：")
    hk := myGui.AddHotkey(
        "yp hp w40 Disabled vScriptControl.PauseHotkey", "F3")
    myGui.AddText("yp hp 0x200", "退出：")
    hk := myGui.AddHotkey(
        "yp hp w40 Disabled vScriptControl.ExitHotkey", "F4")
    myGui.AddText("yp hp 0x200", "重置：")
    hk := myGui.AddHotkey(
        "yp hp w40 Disabled vScriptControl.ReloadHotkey", "F5")
}

_CreateSectionScriptCustomHotkey(firstSection := false) {
    totalRows := HotkeyMaxNum
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "自定义快捷键")
    loop totalRows {
        hotkeyIndex := A_Index
        prefix := "ScriptControl.CustomHotkey" hotkeyIndex
        myGui.AddText(
            _GroupBoxRowPos(hotkeyIndex) " w10 h22 0x200", hotkeyIndex)
        myGui.AddEdit("yp hp w120 Disabled v" prefix "ActionName", "无")
        myGui.AddHotkey("yp hp w80 Disabled v" prefix "KeyName", "")
        btn := myGui.AddButton("yp hp v" prefix "Btn", "更改")
        btn.OnEvent("Click", ScriptControl_CustomHotkeyBtn_Click.Bind(prefix))
    }
}

_CreateSectionScriptVersion(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "版本信息")
    myGui.AddText(
        _GroupBoxRowPos(1) " h22 0x200", "当前版本：" ScriptControlVersion)
    btn := myGui.AddButton("yp hp", "查看最新版本")
    btn.OnEvent("Click", Run.Bind(ScriptControlLatestReleaseURL))
}

_AddBtnToHotkeyList(btn, function) {
    actionName := myGui["MainTab"].Text "-" btn.Text
    HotkeyActionNameList.Push(actionName)
    HotkeyAction2Function[actionName] := function
}
