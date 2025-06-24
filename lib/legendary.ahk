#Requires AutoHotkey v2.0

DebugLegendary := false
_MapDebugID := 5

LegendaryCheckMapBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    if !LegendaryCheckMap() {
        PlayFailureSound()
        return
    }
    PlaySuccessSound()
}

LegendaryRefreshMapBtnClick(*) {
    if !GameWIndowActivate() {
        PlayFailureSound()
        return
    }
    MySend("Escape", , 500)  ; 退出地图
    if !LegendaryRefreshMap() {
        PlayFailureSound()
        return
    }
    autoCheck := myGui["Legendary.AutoCheckChk"].Value
    if (autoCheck) {
        if !LegendaryCheckMap() {
            PlayFailureSound()
            return
        }
    }
    PlaySuccessSound()
}

_LegendaryQuestType := ["Enemy", "Tree", "Diamond", "Fish", "Potato"]
_LegendaryQuestBlueColor := 0x13A6CD  ; 传奇任务蓝色
_LegendaryQuestList := [
    ["龙瞳山地", 1, 960, 152, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["龙鼻山地", 1, 336, 749, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["蜿蜒山峰", 1, 1146, 153, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["落羽之森", 2, 1775, 589, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["菇菇秘境", 2, 1630, 314, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["翼尖峡谷", 2, 1538, 260, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["干涸沙漠西部", 3, 1200, 947, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["干涸沙漠东部", 3, 1546, 845, _LegendaryQuestBlueColor],  ; 传奇任务蓝色
    ["龙牙群岛", 4, 1233, 170, 0x089ACA],
    ["绿意台地", 5, 1733, 687, 0x3BE2AE],
    ["巨腹大平原南部", 5, 1861, 944, 0xF2A057],  ; 胡萝卜颜色
    ["巨腹大平原西部", 5, 1544, 264, _LegendaryQuestBlueColor],  ; 传奇任务蓝色，和翼尖峡谷有overlap
]

LegendaryCheckMap() {
    posRange := 10
    colorRange := 10
    foundQuestList := []
    anyIncludedAndFound := false
    for index, quest in _LegendaryQuestList {
        included := myGui["Legendary.Include" _LegendaryQuestType[quest[2]] "Chk"].Value
        xs := quest[3]
        ys := quest[4]
        color := quest[5]
        found := PixelSearch(&x, &y,
            xs - posRange, ys - posRange,
            xs + posRange, ys + posRange,
            color, colorRange)
        anyIncludedAndFound := anyIncludedAndFound || (included && found)
        if (found) {
            foundQuestList.Push(index)
        }
        MyToolTip(
            included found " " quest[1],
            xs, ys, _MapDebugID + index, DebugLegendary)
    }
    if (!anyIncludedAndFound) {
        UpdateStatusBar("未找到任何传奇任务")
        return false
    }
    if (foundQuestList.Length == 1) {
        UpdateStatusBar("在" _LegendaryQuestList[foundQuestList[1]][1] "找到传奇任务")
    }
    else {
        UpdateStatusBar("找到" foundQuestList.Length "个冲突的传奇任务")
    }
    return true
}

_LegendaryText1Pos := [1327, 337]  ; "区域"位置
_LegendaryText2Pos := [975, 913]  ; "OK"位置
_LegendaryTextColor := "0xF8F0DC"  ; "区域"颜色
_LegendaryLevelPos := [151, 295]  ; 等级标识位置
_LegendaryLevelLockedColor := "0x978056"  ; 等级标识未解锁颜色
_LegendaryLevelSelectedColor := "0x086400" ; 等级标识已选中颜色
_LegendaryLevelValidColor := "0x3C2918"  ; 等级标识有效颜色

LegendaryRefreshMap() {
    MySend("f", , 500)
    MySend("Space", , 500)
    color := PixelGetColor(_LegendaryText1Pos[1], _LegendaryText1Pos[2])
    if (color != _LegendaryTextColor) {
        UpdateStatusBar("对话颜色不匹配: " color)
        return false
    }
    MySend("Space", , 1000)
    counter := 0
    while (true) {
        color := PixelGetColor(_LegendaryLevelPos[1], _LegendaryLevelPos[2])
        switch (color) {
            case _LegendaryLevelLockedColor:
                UpdateStatusBar("该等级未解锁")
            case _LegendaryLevelSelectedColor:
                UpdateStatusBar("该等级已选中")
            case _LegendaryLevelValidColor:
                UpdateStatusBar("该等级有效")
                break
            default:
                UpdateStatusBar("异常等级颜色: " color)
                return false
        }
        MySend("e", , 500)  ; 切换等级
        counter++
        if (counter == 6) {
            UpdateStatusBar("未找到可选择等级")
            return false
        }
    }
    MySend("Space", , 500)  ; 确认选择
    color := PixelGetColor(_LegendaryText2Pos[1], _LegendaryText2Pos[2])
    if (color != _LegendaryTextColor) {
        UpdateStatusBar("确认颜色不匹配: " color)
        return false
    }
    MySend("Space", , 1000)  ; 确认切换
    MySend("Escape", , 500)  ; 退出对话
    MySend("m") ; 打开地图
    UpdateStatusBar("地图刷新完成")
    return true
}
