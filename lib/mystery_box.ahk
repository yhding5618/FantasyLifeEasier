#Requires AutoHotkey v2.0

MysteryBox_BuyBtn_Click() {
    _MysteryBoxBuy()
}

MysteryBox_LoadAndBuyBtn_Click() {
    MySend("Escape", , 1200)  ; 关闭盲盒结果
    if SearchColorMatch(
        UtilsWindowOK4Pos[1], UtilsWindowOK4Pos[2],
        UtilsWindowButtonColor
    ) {
        UpdateStatusBar("检测到持有量达到上限的道具自动出售结果")
        MySend("Space", , 1200)  ; 确认自动出售结果
    }
    MySend("Escape", , 700)  ; 关闭商店界面
    UtilsWaitUntilOptionListSelected(1, 1, 3, "对话界面")
    Sleep(300)  ; 等待对话界面稳定
    MySend("Escape", , 1000)  ; 关闭对话界面
    MySend("Space", , 800)  ; 加速对话
    MySend("Space", , 800)  ; 结束对话
    LoadFromCloud()
    _MysteryBoxBuy()
}

_MysteryBoxShopCoinPixel := [1591, 65, "0xFBE003"]  ; 商店界面金币像素

_MysteryBoxBuy() {
    shop := myGui["MysteryBox.Shop"].Value
    itemIndex := myGui["MysteryBox.ItemIndex"].Value
    buyCount := myGui["MysteryBox.BuyCount"].Value
    MySend("f")
    UtilsWaitUntilOptionListSelected(1, 1, 3, "购买选项")
    Sleep(300)  ; 等待对话界面稳定
    UpdateStatusBar("选择“购买”")
    MySend("Space")  ; 选择“购买”
    WaitUntilColorMatch(
        _MysteryBoxShopCoinPixel[1], _MysteryBoxShopCoinPixel[2],
        _MysteryBoxShopCoinPixel[3], "商店界面加载", , 5, 100, 20)
    Sleep(300)  ; 等待商店界面稳定
    UpdateStatusBar("选择商店")
    loop shop {
        MySend("3", , 200)  ; 移动到对应商店
    }
    UpdateStatusBar("选择“其他”类别")
    MySend("q", , 200)  ; 移动到“其他”类别
    UpdateStatusBar("选择物品")
    loop (itemIndex - 1) {
        MySend("s", , 200)  ; 移动到对应物品
    }
    MySend("Space")  ; 选择物品
    WaitUntilColorMatch(
        UtilsWindowOK3Pos[1], UtilsWindowOK3Pos[2],
        UtilsWindowButtonColor, "选择购买数量")
    Sleep(300)
    plus10 := (buyCount + 3) // 10
    plus1 := buyCount - (plus10 * 10 + 1)
    loop plus10 {
        MySend("w", , 100)  ; 数量+10
    }
    loop Abs(plus1) {
        key := plus1 > 0 ? "d" : "a"  ; 数量+1或-1
        MySend(key, , 100)
    }
    MySend("Space")  ; 确认数量
    yesPos := shop == 1 ? UtilsWindowYes4Pos : UtilsWindowYes5Pos
    yesText := shop == 1 ? "女神草交换确认" : "女神果交换确认"
    WaitUntilColorMatch(
        yesPos[1], yesPos[2], UtilsWindowButtonColor, yesText)
    Sleep(300)
    MySend("Space")  ; 确认购买
    UpdateStatusBar("购买了" buyCount "个盲盒")
}
