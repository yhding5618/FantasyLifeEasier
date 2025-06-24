#Requires AutoHotkey v2.0

MimicTestSkillBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !_MimicKillWithSkill() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

MimicRefreshAndKillBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    count := myGui["Mimic.KillCount"].Value
    loop count {
        if !TeleportationGateOneWay() {
            PlayFailureSound()
            return
        }
        if !TeleportationGateOneWay() {
            PlayFailureSound()
            return
        }
        prefix := A_Index "/" count
        if !_MimicKillWithSkill(prefix) {
            PlayFailureSound()
            return
        }
    }
    PlaySuccessSound()
}

_MimicKillWithSkill(prefix := "") {
    holdTime := myGui["Mimic.HoldTime"].Value
    waitTime := myGui["Mimic.WaitTime"].Value
    resetForwardTime := myGui["Mimic.ResetForwardTime"].Value
    resetBackwardTime := myGui["Mimic.ResetBackwardTime"].Value
    resetWaitTime := myGui["Mimic.ResetWaitTime"].Value
    UpdateStatusBar(prefix "前进同时蓄力")
    MyPress("e")
    MyPress("w")
    Sleep(holdTime)
    UpdateStatusBar(prefix "释放技能")
    MyRelease("e")
    MyRelease("w")
    Sleep(waitTime)
    UpdateStatusBar(prefix "自动复位")
    MySend("w", resetForwardTime)
    MySend("s", resetBackwardTime)
    if (resetWaitTime > 0) {
        loop resetWaitTime {
            remainingTime := resetWaitTime - A_Index + 1
            UpdateStatusBar(prefix "手动复位..." remainingTime)
            sleep(1000)
        }
    }
    UpdateStatusBar(prefix "完成击杀")
    return true
}
