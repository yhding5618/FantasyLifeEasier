#Requires AutoHotkey v2.0

Mimic_TestSkillBtn_Click() {
    _MimicKillWithSkill()
}

Mimic_RefreshAndKillBtn_Click() {
    count := myGui["Mimic.KillCount"].Value
    loop count {
        TeleportationGateOneWay()
        TeleportationGateOneWay()
        _MimicKillWithSkill(A_Index "/" count)
    }
}

_MimicKillWithSkill(prefix := "") {
    OutputDebug("Info.mimic.KIllWithSkill: " prefix "开始攻击")
    UpdateStatusBar(prefix "开始攻击")
    holdTime := myGui["Mimic.HoldTime"].Value
    waitTime := myGui["Mimic.WaitTime"].Value
    resetForwardTime := myGui["Mimic.ResetForwardTime"].Value
    resetBackwardTime := myGui["Mimic.ResetBackwardTime"].Value
    resetWaitTime := myGui["Mimic.ResetWaitTime"].Value
    OutputDebug("Debug.mimic.KIllWithSkill: " prefix "前进同时蓄力")
    MyPress("e")
    MyPress("w")
    Sleep(holdTime)
    OutputDebug("Debug.mimic.KIllWithSkill: " prefix "释放技能")
    MyRelease("e")
    MyRelease("w")
    Sleep(waitTime)
    OutputDebug("Debug.mimic.KIllWithSkill: " prefix "自动复位")
    MySend("w", resetForwardTime)
    MySend("s", resetBackwardTime)
    if (resetWaitTime > 0) {
        loop resetWaitTime {
            remainingTime := resetWaitTime - A_Index + 1
            OutputDebug("Info.mimic.KIllWithSkill: " prefix "手动复位..." remainingTime)
            UpdateStatusBar(prefix "手动复位..." remainingTime)
            sleep(1000)
        }
    }
    OutputDebug("Info.mimic.KIllWithSkill: " prefix "完成击杀")
    UpdateStatusBar(prefix "完成击杀")
}
