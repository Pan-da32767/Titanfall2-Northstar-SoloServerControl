global function maxPlayer_Init

int maxPlayers = 2
array < entity > HostTemp
array < string > HostUID = []

void function maxPlayer_Init() {
    AddCallback_OnClientConnected(maxPlayer_Thread)
    AddCallback_OnClientDisconnected(OnPlayerDisconnected)
    AddClientCommandCallback("!cmp", ChangeMaxPlayer)
    AddClientCommandCallback("!close", CloseTheMatch)
    AddClientCommandCallback("!ftr", ForceToReflesh)
    AddClientCommandCallback("!cmd", helpinfo)
}

void function maxPlayer_Thread(entity player) {
    thread maxPlayer_Main(player)
}

void function maxPlayer_Main(entity player) {
    if (GetPlayerArray().len() > maxPlayers) {
        //踢出
        ServerCommand("kickid " + player.GetUID())
        return
    }
    thread UpdateHost()
    if (IsLobby()) {
        wait 5
        try {
            Chat_ServerPrivateMessage(player, "当前房主是" + HostTemp[0], false)
            Chat_ServerPrivateMessage(player, "！cmd以检阅所有指令", false)
            Chat_ServerPrivateMessage(player, "不用查了，其实现在能用的估计就！help和！close(关闭比赛)了QWQ", false)
        } catch (exception){
            print("翻车咯，pl.nut")
        }
    }
    if (IsValid(player)) {
        Chat_ServerPrivateMessage(player, "当前房主是" + HostTemp[0], false)
        Chat_ServerPrivateMessage(player, "！cmd以检阅所有指令", false)
        Chat_ServerPrivateMessage(player, "不用查了，其实现在能用的估计就！help和！close(关闭比赛)了QWQ", false)
        Chat_ServerPrivateMessage(player, "注：显示10人实际只能进2人，主要是为了那个泰坦是否降落了的标识没那么丑", false)
    }
}

void function OnPlayerDisconnected(entity player) {
    HostTemp.remove(0)
    Chat_ServerBroadcast("目前无房主...若没有自动更新请输入！ftr并回报")
    thread UpdateHost()
}

bool function ChangeMaxPlayer(entity player, array < string > args) {
    //if (!CheckHost(player))
    //{
    //    Chat_ServerPrivateMessage( player, "你不是房猪.", false );
    //    return true;
    //}

    if (args.len() != 1) {
        Chat_ServerPrivateMessage(player, "无效值", false);
        Chat_ServerPrivateMessage(player, "食用例 ！cmp 4", false);
        return true;
    }

    switch (args[0]) {
        case ("6"):
            int maxPlayers = 6;
            Chat_ServerBroadcast("最大玩家数被更新为" + maxPlayers);
            break;
        case ("4"):
            int maxPlayers = 4;
            Chat_ServerBroadcast("最大玩家数被更新为" + maxPlayers);
            break;
        case ("2"):
            int maxPlayers = 2;
            Chat_ServerBroadcast("最大玩家数被更新为" + maxPlayers);
            break;
        default:
            Chat_ServerPrivateMessage(player, "无效值,请输入2/4/6", false);
    }
    return true
}

void function UpdateHost() {
    if (HostTemp.len() == 0) {
        HostTemp.append(GetPlayerArray()[0])
        Chat_ServerBroadcast("房主被更新为" + GetPlayerArray()[0].GetPlayerName())
    }
    return
}

bool function CheckHost(entity player) {
    int findIndex = HostTemp.find(player)
    if (findIndex != -1) {
        return true
    }
    int findIndex2 = HostUID.find(player.GetUID())
    if (findIndex2 != -1) {
        return true
    }
    return false
}

bool function CloseTheMatch(entity player, array < string > args) {
    if (IsLobby()) {
        Chat_ServerPrivateMessage(player, "做甚？在大厅里关闭啥子比赛咯", false);
        return true;
    }
    if (!CheckHost(player)) {
        Chat_ServerPrivateMessage(player, "你不是房猪.", false);
        return true;
    }

    if (args.len() != 0) {
        Chat_ServerPrivateMessage(player, "无效值", false);
        Chat_ServerPrivateMessage(player, "食用例 ！close", false);
        return true;
    }
    Chat_ServerBroadcast("房主请求关闭比赛")
    Chat_ServerBroadcast("尝试关闭比赛中...0%")
    SetRoundBased(false)
    SetWinner(0)
    Chat_ServerBroadcast("尝试关闭比赛中...100%")
    return true;
}

bool function ForceToReflesh(entity player, array < string > args) {
    array < entity > HostTemp = []
    if (HostTemp.len() == 0) {
        HostTemp.append(GetPlayerArray()[0])
        Chat_ServerBroadcast("房主被更新为" + GetPlayerArray()[0].GetPlayerName())
    }
    return true;
}

bool function helpinfo(entity player, array < string > args) {
    Chat_ServerBroadcast("其实现在能用的估计就！help和！close(关闭比赛)了QWQ")
    return true;
}