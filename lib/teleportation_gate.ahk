#Requires AutoHotkey v2.0

DebugLegendary := false
_MenuDebugID := 8

TeleportationGate_OneWayBtn_Click() {
    TeleportationGateOneWay()
}

TeleportationGate_ReturnTripBtn_Click() {
    TeleportationGateOneWay()
    TeleportationGateOneWay()
}

_TeleportationGateInProgressPos := [50, 50]  ; 传送中白色背景
VarScaleHandler.Register("_TeleportationGateInProgressPos" , [[1], [2]])
_TeleportationGateInProgressColor := "0xFFFFFF"  ; 传送中白色背景颜色

TeleportationGateOneWay() {
    OutputDebug("Info.telepotation_gate.GateOneWay: 开始单向传送")
    _MoveToMenuTeleportationGate()
    MySend("Space", , 750)
    MySend("Space")
    WaitUntilColorMatch(
        _TeleportationGateInProgressPos[1],
        _TeleportationGateInProgressPos[2],
        _TeleportationGateInProgressColor,
        "开门动画", , 0, 200, 100)
    WaitUntilColorNotMatch(
        _TeleportationGateInProgressPos[1],
        _TeleportationGateInProgressPos[2],
        _TeleportationGateInProgressColor,
        "白屏加载", , 0, 200, 100)
    WaitUntilSavingIcon()
    OutputDebug("Info.telepotation_gate.GateOneWay: 传送完成")
    UpdateStatusBar("传送完成")
}

_TeleportationGateIconCheckedColor := "0xD4B1EB"  ; 传送图标已选择颜色
_TeleportationGateIconDisabledColor := "0x935986"  ; 传送图标不可选颜色

_MoveToMenuTeleportationGate() {
    OutputDebug("Info.telepotation_gate.MoveToMenuTeleportationGate: 移动到传送图标")
    page := myGui["TeleportationGate.IconPage"].Value
    row := myGui["TeleportationGate.IconRow"].Value
    col := myGui["TeleportationGate.IconCol"].Value
    ret := OpenMenuAndMoveToIcon(page, row, col)
    x := ret[1]
    y := ret[2]
    if SearchColorMatch(x, y, _TeleportationGateIconCheckedColor) {
        OutputDebug("Debug.telepotation_gate.MoveToMenuTeleportationGate: 传送图标就位")
        return
    }
    if SearchColorMatch(x, y, _TeleportationGateIconDisabledColor) {
        throw ValueError("传送图标不可选")
    }
    throw ValueError("传送图标颜色不匹配")
}
