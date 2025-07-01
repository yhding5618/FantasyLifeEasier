#Requires AutoHotkey v2.0

BuildMyGui() {
    myTab := myGui.AddTab3("w300 vMainTab", [])
    _CreateTabBasic()
    _CreateTabCraft()
    _CreateTabCamp()
    _CreateTabGinormosia()
    _CreateTabSetting()
    myTab.Choose(1)
    myGui.AddStatusBar("vStatusBar", "")
}

ShowMyGui() {
    ScriptControl_AlwaysOnTopChk_Click()
    GameWindow_PixelInfoUpdateChk_Click()
    if myGui["ScriptControl.RememberPos"].Value {
        pos := StrSplit(myGui["ScriptControl.WindowPos"].Value, ",")
        myGuiPos := "x" pos[1] " y" pos[2]
    } else {
        myGuiPos := "Center"
    }
    myGui.Show(myGuiPos " AutoSize")
}

UpdateStatusBar(text) {
    myGui["StatusBar"].Text := text
}

AppendStatusBar(text) {
    myGui["StatusBar"].Text .= text
}

_AddAndUseTab(name) {
    myTab := myGui["MainTab"]
    myTab.Add([name])
    myTab.UseTab(name)
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
    _CreateSectionScriptHotkey()
}

_CreateSectionGameWindow(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "游戏窗口")
    btn := myGui.AddButton(
        _GroupBoxRowPos(1) " w80 vGameWindow.CheckBtn", "检查进程")
    btn.OnEvent("Click", (*) => TryAndCatch(GameWindow_CheckBtn_Click))
    myGui.AddText("yp w150 r4 vGameWindow.Status", "")
    btn := myGui.AddButton(
        _GroupBoxRowPos(2) " w80 vGameWindow.ActivateBtn", "打开游戏窗口")
    btn.OnEvent("Click", (*) => TryAndCatch(GameWindow_ActivateBtn_Click))
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "像素信息：")
    myGui.AddEdit("yp hp w146 r1 vGameWindow.PixelInfo ReadOnly 0x200", "")
    chk := myGui.AddCheckbox("yp hp vGameWindow.PixelInfoUpdateChk", "刷新")
    chk.OnEvent("Click", (*) => GameWindow_PixelInfoUpdateChk_Click())
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
    btn.OnEvent("Click", (*) => TryAndCatch(TeleportationGate_OneWayBtn_Click))
    btn := myGui.AddButton("yp vTeleportationGate.ReturnTripBtn", "往返")
    btn.OnEvent(
        "Click", (*) => TryAndCatch(TeleportationGate_ReturnTripBtn_Click))
}

_CreateSectionSaveLoad(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "存档")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " vSaveLoad.SaveBtn", "保存云")
    btn.OnEvent("Click", (*) => TryAndCatch(SaveLoad_SaveBtn_Click))
    btn := myGui.AddButton("yp vSaveLoad.LoadBtn", "加载云")
    btn.OnEvent("Click", (*) => TryAndCatch(SaveLoad_LoadBtn_Click))
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
    btn.OnEvent("Click", (*) => TryAndCatch(LongCape_BuyBtn_Click))
    btn := myGui.AddButton("yp vLongCape.SelectBtn", "批量选择")
    btn.OnEvent("Click", (*) => TryAndCatch(LongCape_SelectBtn_Click))
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
    btn.OnEvent("Click", (*) => TryAndCatch(MiniGame_SingleActionBtn_Click))
    btn := myGui.AddButton("yp vMiniGame.ContinuousActionBtn", "连续操作")
    btn.OnEvent("Click", (*) => TryAndCatch(MiniGame_ContinuousActionBtn_Click))
}

_CreateSectionTreasureGrove(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "扭蛋迷宫树")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "年代选择：向")
    myGui.AddDropDownList(
        "yp w36 Choose2 vTreasureGrove.YearMoveDir", ["上", "下"])
    myGui.AddEdit("yp w36")
    myGui.AddUpDown("vTreasureGrove.YearMoveCount Range1-10 0x80", 1)
    btn := myGui.AddButton(
        _GroupBoxRowPos(2) " vTreasureGrove.ReplantBtn", "重新种植")
    btn.OnEvent("Click", (*) => TryAndCatch(TreasureGrove_ReplantBtn_Click))
    btn := myGui.AddButton("yp vTreasureGrove.ContinueReplantBtn", "下一次重新种植")
    btn.OnEvent("Click", (*) =>
        TryAndCatch(TreasureGrove_ContinueReplantBtn_Click))
}

_CreateSectionWeaponAging(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "武器熟成")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " vWeaponAging.StartBtn", "熟成")
    btn.OnEvent("Click", (*) => TryAndCatch(WeaponAging_StartBtn_Click))
    btn := myGui.AddButton("yp vWeaponAging.NextBtn", "下一次熟成")
    btn.OnEvent("Click", (*) => TryAndCatch(WeaponAging_NextBtn_Click))
}

_CreateSectionOnline(firstSection := false) {
    totalRows := 4
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "联机房间")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "招募目的地：")
    myGui.AddDropDownList(
        "yp w100 Choose1 vOnline.Destination",
        ["皆可", "环岛冒险", "探索大陆", "扭蛋迷宫树"])
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "关键词：")
    myGui.AddEdit("yp hp w60 vOnline.Keyword", "")
    myGui.AddText("yp hp 0x200", "密码：")
    myGui.AddEdit("yp hp w60 vOnline.Password", "")
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "作为房主：")
    btn := myGui.AddButton("yp vOnline.RecruitBtn", "招募")
    btn.OnEvent("Click", (*) => TryAndCatch(Online_RecruitBtn_Click))
    btn := myGui.AddButton("yp vOnline.ExitBtn", "退出")
    btn.OnEvent("Click", (*) => TryAndCatch(Online_ExitBtn_Click))
    btn := myGui.AddButton("yp vOnline.DismissBtn", "解散")
    btn.OnEvent("Click", (*) => TryAndCatch(Online_DismissBtn_Click))
    myGui.AddText(_GroupBoxRowPos(4) " h22 0x200", "作为队友：")
    btn := myGui.AddButton("yp vOnline.JoinBtn", "加入")
    btn.OnEvent("Click", (*) => TryAndCatch(Online_JoinBtn_Click))
    btn := myGui.AddButton("yp vOnline.LeaveBtn", "离开")
    btn.OnEvent("Click", (*) => TryAndCatch(Online_LeaveBtn_Click))
    btn := myGui.AddButton("yp vOnline.RejoinBtn", "离开并重新加入")
    btn.OnEvent("Click", (*) => TryAndCatch(Online_RejoinBtn_Click))
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
    btn := myGui.AddButton(_GroupBoxRowPos(7) " vMimic.TestSkillBtn", "测试技能")
    btn.OnEvent("Click", (*) => TryAndCatch(Mimic_TestSkillBtn_Click))
    btn := myGui.AddButton("yp vMimic.RefreshAndKillBtn", "刷新并击杀")
    btn.OnEvent("Click", (*) => TryAndCatch(Mimic_RefreshAndKillBtn_Click))
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
    btn.OnEvent("Click", (*) => TryAndCatch(Legendary_CheckMapBtn_Click))
    btn := myGui.AddButton("yp vLegendary.RefreshMapBtn", "刷新等级")
    btn.OnEvent("Click", (*) => TryAndCatch(Legendary_RefreshMapBtn_Click))
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
    btn := myGui.AddButton(_GroupBoxRowPos(3) " vFarming.HarvestBtn", "重复收获")
    btn.OnEvent("Click", (*) => TryAndCatch(Farming_HarvestBtn_Click))
}

_CreateSectionScriptWindow(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "脚本窗口")
    chk := myGui.AddCheckbox(
        _GroupBoxRowPos(1) " h22 vScriptControl.RememberPos", "记住位置：")
    myGui.AddEdit("yp w60 hp ReadOnly vScriptControl.WindowPos", "")
    chk := myGui.AddCheckbox("xp+80 yp hp vScriptControl.AlwaysOnTopChk", "置顶")
    chk.OnEvent("Click", (*) => ScriptControl_AlwaysOnTopChk_Click())
}

_CreateSectionScriptNotification(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "运行结果")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "成功时：")
    MyGui.AddRadio("yp hp Checked vScriptControl.SuccessNoChk", "不提醒")
    chk := myGui.AddRadio("yp hp vScriptControl.SuccessSoundChk", "音效")
    chk.OnEvent("Click", (*) => ScriptControl_SuccessSoundChk_Click())
    chk := myGui.AddRadio("yp hp vScriptControl.SuccessMsgBoxChk", "弹窗")
    chk.OnEvent("Click", (*) => ScriptControl_SuccessMsgBoxChk_Click())
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "失败时：")
    MyGui.AddRadio("yp hp Checked vScriptControl.FailureNoChk", "不提醒")
    chk := myGui.AddRadio("yp hp vScriptControl.FailureSoundChk", "音效")
    chk.OnEvent("Click", (*) => ScriptControl_FailureSoundChk_Click())
    chk := myGui.AddRadio("yp hp vScriptControl.FailureMsgBoxChk", "弹窗")
    chk.OnEvent("Click", (*) => ScriptControl_FailureMsgBoxChk_Click())
}

_CreateSectionScriptHotkey(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "快捷键")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "暂停：")
    hk := myGui.AddHotkey("yp hp Disabled vScriptControl.PauseHotkey", "F3")
    hk.OnEvent("Change", (*) => ScriptControl_PauseHotkey_Change())
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "退出：")
    hk := myGui.AddHotkey("yp hp Disabled vScriptControl.ExitHotkey", "F4")
    hk.OnEvent("Change", (*) => ScriptControl_ExitHotkey_Change())
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "重置：")
    hk := myGui.AddHotkey("yp hp Disabled vScriptControl.ResetHotkey", "F5")
    hk.OnEvent("Change", (*) => ScriptControl_ResetHotkey_Change())
}
