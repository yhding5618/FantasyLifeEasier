#Requires AutoHotkey v2.0

BuildMyGui() {
    myTab := myGui.AddTab3("w300 vMainTab", [])
    _CreateTabBasic()
    _CreateTabCraft()
    _CreateTabCamp()
    _CreateTabGinormosia()
    myTab.Choose(1)
    myGui.AddStatusBar("vStatusBar", "")
}

ShowMyGui() {
    ScriptControlAlwaysOnTopChkClick()
    GameWindowPixelInfoUpdateChkClick()
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
    _CreateSectionScriptControl()
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
}

_CreateSectionGameWindow(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "游戏窗口")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " w80 vGameWindow.CheckBtn", "检查进程")
    btn.OnEvent("Click", GameWindowCheckBtnClick)
    myGui.AddText("yp w150 r4 vGameWindow.Status", "")
    btn := myGui.AddButton(_GroupBoxRowPos(2) " w80 vGameWindow.ActivateBtn", "打开游戏窗口")
    btn.OnEvent("Click", GameWindowActivateBtnClick)
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "像素信息：")
    myGui.AddEdit("yp hp w120 r1 vGameWindow.PixelInfo ReadOnly 0x200", "")
    chk := myGui.AddCheckbox("yp hp vGameWindow.PixelInfoUpdateChk", "刷新")
    chk.OnEvent("Click", GameWindowPixelInfoUpdateChkClick)
}

_CreateSectionScriptControl(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "脚本控制")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "窗口位置：")
    myGui.AddEdit("yp w80 hp ReadOnly vScriptControl.WindowPos", "")
    chk := myGui.AddCheckbox(_GroupBoxRowPos(2) " h22 vScriptControl.RememberPos", "记住窗口位置")
    chk := myGui.AddCheckbox("yp hp vScriptControl.AlwaysOnTopChk", "脚本窗口置顶")
    chk.OnEvent("Click", ScriptControlAlwaysOnTopChkClick)
    chk := myGui.AddCheckbox(_GroupBoxRowPos(3) " hp vScriptControl.SuccessSoundChk", "启用成功提示音")
    chk.OnEvent("Click", ScriptControlSuccessSoundChkClick)
    chk := myGui.AddCheckbox("yp hp vScriptControl.FailureSoundChk", "启用失败提示音")
    chk.OnEvent("Click", ScriptControlFailureSoundChkClick)
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
    btn.OnEvent("Click", LongCapeBuyBtnClick)
    btn := myGui.AddButton("yp vLongCape.SelectBtn", "批量选择")
    btn.OnEvent("Click", LongCapeSelectBtnClick)
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
    btn := myGui.AddButton(_GroupBoxRowPos(6) " vMiniGame.SingleActionBtn", "单次操作")
    btn.OnEvent("Click", MiniGameSingleActionBtnClick)
    btn := myGui.AddButton("yp vMiniGame.ContinuousActionBtn", "连续操作")
    btn.OnEvent("Click", MiniGameContinuousActionBtnClick)
}

_CreateSectionTreasureGrove(firstSection := false) {
    totalRows := 2
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "扭蛋迷宫树")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "年代选择：向")
    myGui.AddDropDownList("yp w36 Choose2 vTreasureGrove.YearMoveDir", ["上", "下"])
    myGui.AddEdit("yp w36")
    myGui.AddUpDown("vTreasureGrove.YearMoveCount Range1-10 0x80", 1)
    btn := myGui.AddButton(_GroupBoxRowPos(2) " vTreasureGrove.ReplantBtn", "重新种植")
    btn.OnEvent("Click", TreasureGroveReplantBtnClick)
    btn := myGui.AddButton("yp vTreasureGrove.ContinueReplantBtn", "下一次重新种植")
    btn.OnEvent("Click", TreasureGroveContinueReplantBtnClick)
}

_CreateSectionWeaponAging(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "武器熟成")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " vWeaponAging.StartBtn", "开始熟成")
    btn.OnEvent("Click", WeaponAgingStartBtnClick)
    btn := myGui.AddButton("yp vWeaponAging.NextBtn", "下一次熟成")
    btn.OnEvent("Click", WeaponAgingNextBtnClick)
}

_CreateSectionOnline(firstSection := false) {
    totalRows := 3
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "联机房间")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "创建类型：")
    myGui.AddDropDownList("yp w100 Choose3 vOnline.CreateType", ["环岛冒险", "探索大陆", "扭蛋迷宫树"])
    myGui.AddText(_GroupBoxRowPos(2) " h22 0x200", "关键词：")
    myGui.AddEdit("yp hp w60 vOnline.Keyword", "")
    myGui.AddText("yp hp 0x200", "密码：")
    myGui.AddEdit("yp hp w60 vOnline.Password", "")
    btn := myGui.AddButton(_GroupBoxRowPos(3) " vOnline.CreateBtn", "创建")
    btn.OnEvent("Click", OnlineCreateBtnClick)
    btn := myGui.AddButton("yp vOnline.JoinBtn", "加入")
    btn.OnEvent("Click", OnlineJoinBtnClick)
    btn := myGui.AddButton("yp vOnline.ExitBtn", "退出")
    btn.OnEvent("Click", OnlineExitBtnClick)
    btn := myGui.AddButton("yp vOnline.RejoinBtn", "退出并重新加入")
    btn.OnEvent("Click", OnlineRejoinBtnClick)
}

_CreateSectionMimic(firstSection := false) {
    totalRows := 7
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "宝箱怪")
    myGui.AddText(_GroupBoxRowPos(1) " h22 0x200", "蓄力时间（毫秒）：")
    myGui.AddEdit("yp w50 hp")
    myGui.AddUpDown("vMimic.HoldTime Range1-5000 0x80", 1050)
    myGui.AddText(_GroupBoxRowPos(2) " hp 0x200", "等待时间（毫秒）：")
    myGui.AddEdit("yp w50 hp")
    myGui.AddUpDown("vMimic.WaitTime Range1-5000 0x80", 2200)
    myGui.AddText(_GroupBoxRowPos(3) " h22 0x200", "复位前进时间（毫秒）：")
    myGui.AddEdit("yp yp hp w50")
    myGui.AddUpDown("vMimic.ResetForwardTime Range1-5000 0x80", 700)
    myGui.AddText(_GroupBoxRowPos(4) " hp 0x200", "复位后退时间（毫秒）：")
    myGui.AddEdit("yp yp hp w50")
    myGui.AddUpDown("vMimic.ResetBackwardTime Range1-5000 0x80", 920)
    myGui.AddText(_GroupBoxRowPos(5) " h22 0x200", "手动复位时间（秒）：")
    myGui.AddEdit("yp yp hp w50")
    myGui.AddUpDown("vMimic.ResetWaitTime Range0-10 0x80", 1)
    myGui.AddText(_GroupBoxRowPos(6) " h22 0x200", "重复击杀数量：")
    myGui.AddEdit("yp yp hp w50")
    myGui.AddUpDown("vMimic.KillCount Range1-99 0x80", 1)
    btn := myGui.AddButton(_GroupBoxRowPos(7) " vMimic.TestSkillBtn", "测试技能")
    btn.OnEvent("Click", MimicTestSkillBtnClick)
    btn := myGui.AddButton("yp vMimic.RefreshAndKillBtn", "刷新并击杀")
    btn.OnEvent("Click", MimicRefreshAndKillBtnClick)
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
    btn := myGui.AddButton(_GroupBoxRowPos(2) " vLegendary.CheckMapBtn", "检查地图")
    btn.OnEvent("Click", LegendaryCheckMapBtnClick)
    btn := myGui.AddButton("yp vLegendary.StartBtn", "刷新等级")
    btn.OnEvent("Click", LegendaryRefreshMapBtnClick)
    myGui.AddCheckbox("yp hp vLegendary.AutoCheckChk", "刷新后自动检查")
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
    btn := myGui.AddButton(_GroupBoxRowPos(2) " vTeleportationGate.OneWayBtn", "单程")
    btn.OnEvent("Click", TeleportationGateOneWayBtnClick)
    btn := myGui.AddButton("yp vTeleportationGate.ReturnTripBtn", "往返")
    btn.OnEvent("Click", TeleportationGateReturnTripBtnClick)
}

_CreateSectionSaveLoad(firstSection := false) {
    totalRows := 1
    myGui.AddGroupBox(_GroupBoxSize(totalRows, firstSection), "存档")
    btn := myGui.AddButton(_GroupBoxRowPos(1) " vSaveLoad.SaveBtn", "保存云")
    btn.OnEvent("Click", SaveLoadSaveBtnClick)
    btn := myGui.AddButton("yp vSaveLoad.LoadBtn", "加载云")
    btn.OnEvent("Click", SaveLoadLoadBtnClick)
}
