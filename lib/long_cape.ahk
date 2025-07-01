#Requires AutoHotkey v2.0

LongCape_BuyBtn_Click() {
    LongCapeBuy()
}

LongCape_SelectBtn_Click() {
    LongCapeSelect()
}

LongCapeBuy() {
    count := myGui["LongCape.Count"].Value
    buyInterval := myGui["LongCape.BuyInterval"].Value
    loop count {
        UpdateStatusBar("购买长披风..." A_Index " / " count)
        MySend("Space")
        Sleep(buyInterval)
        MySend("Space")
        Sleep(buyInterval)
    }
    UpdateStatusBar("已购买 " count " 个长披风。")
}

LongCapeSelect() {
    count := myGui["LongCape.Count"].Value
    selectInterval := myGui["LongCape.SelectInterval"].Value
    loop count {
        UpdateStatusBar("选择长披风..." A_Index " / " count)
        MySend("Space")
        Sleep(selectInterval)
        MySend("s")
        Sleep(selectInterval)
    }
    UpdateStatusBar("已选择 " count " 个长披风。")
}
