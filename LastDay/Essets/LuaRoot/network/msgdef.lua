-- File Name : network/msgdef.lua

local P = {}

do
    local CS_BASE_BS, CS_BASE_GS, SC_ADD = 0, 10000, 5000

    local Funcs = {}

    local function codes_maker(module, start, CSCodes, SCCodes)
        local Module = { BASE = start }
        Funcs[module] = Module
        Module.cs = function (self)
            local BASE = self.BASE
            local Codes = {}
            for k,v in pairs(CSCodes) do
                Codes[k] = BASE + v
            end
            return Codes
        end
        Module.sc = function (self)
            local BASE = self.BASE + SC_ADD
            local Codes = {}
            for k,v in pairs(SCCodes) do
                Codes[k] = BASE + v
            end
            return Codes
        end
    end

    -- CS_BASE_GS ---------------------------------------------------------------------
    Funcs.COM = { BASE = CS_BASE_GS + 10, }
    function Funcs.COM:cs()
        local ID_BASE = self.BASE
        return {
            KEEP_HEART = ID_BASE + 1,
            GET_ERROR_INFO = ID_BASE + 2,
            COM_EXIT = ID_BASE + 3,
            CLIENT_DATA_GET = ID_BASE + 4,
            CLIENT_DATA_UPDATE = ID_BASE + 5,
            EXEC_GM_CMD = ID_BASE + 20,
        }
    end
    function Funcs.COM:sc()
        local ID_BASE = self.BASE + SC_ADD
        return {
            COM_ERR = ID_BASE + 1,
            GET_ERROR_INFO = ID_BASE + 2,
            CLIENT_DATA_GET = ID_BASE + 4,
            CLIENT_DATA_UPDATE = ID_BASE + 5,
            SYNC_EVENT = ID_BASE + 10,
            EXEC_GM_CMD = ID_BASE + 20,
        }
    end

    Funcs.LOGIN = { BASE = CS_BASE_GS + 100 }
    function Funcs.LOGIN:cs()
        local ID_BASE = self.BASE
        return {
            LOGIN = ID_BASE + 1,
            RELOGIN = ID_BASE + 2,
            ENTER_GAME = ID_BASE + 3,
            KEEP_HEART = ID_BASE + 5,
            SWITCH_NOHUP = ID_BASE + 6,
            SUSPEND_HEARTBEAT = ID_BASE + 7,
        }
    end
    function Funcs.LOGIN:sc()
        local ID_BASE = self.BASE + SC_ADD
        return {
            LOGIN = ID_BASE + 1,
            RELOGIN = ID_BASE + 2,
            ENTER_GAME = ID_BASE + 3,
            LOGOFF_GAME = ID_BASE + 4,
        }
    end

    Funcs.PLAYER = { BASE = CS_BASE_GS + 200 }
    function Funcs.PLAYER:cs()
        local ID_BASE = self.BASE
        return {
            GET_ROLE_INFO = ID_BASE + 1,
            ROLE_ASSET_GET = ID_BASE + 2,
            NAME_CHANGE = ID_BASE + 3,
            ROLE_HEAD_CHANGE = ID_BASE + 4,
            ROLE_RANDOM_NAME = ID_BASE + 5,
            GET_OTHER_ROLE_INFO = ID_BASE + 7,
        }
    end
    function Funcs.PLAYER:sc()
        local ID_BASE = self.BASE + SC_ADD
        return {
            GET_ROLE_INFO = ID_BASE + 1,
            ROLE_ASSET_GET = ID_BASE + 2,
            NAME_CHANGE = ID_BASE + 3,
            ROLE_HEAD_CHANGE = ID_BASE + 4,
            ROLE_RANDOM_NAME = ID_BASE + 5,
            GET_OTHER_ROLE_INFO = ID_BASE + 7,
        }
    end

    codes_maker("TASK", CS_BASE_GS + 300, {
            TASK_GET = 1,
            REWARD_GET = 2,
            GAIN_GROUP_REWARD = 3,
            ACHIEVEMENT_GET = 5,

            CDKEY_USE = 10,
        }, {
            TASK_GET = 1,
            REWARD_GET = 2,
            GAIN_GROUP_REWARD = 3,
            TASK_CHAPTER_GET = 4,
            ACHIEVEMENT_GET = 5,
            DAILY_TASK_RESET_TIME = 6,

            CDKEY_USE = 10,
        })

    Funcs.PACKAGE = { BASE = CS_BASE_GS + 2200, }
    function Funcs.PACKAGE:cs()
        local BASE = self.BASE
        return {
            ROLE_PACKAGE_GET = BASE + 0,
            PACKAGE_OPEN = BASE + 1,
            PACKAGE_CLOSE = BASE + 2,
            PACKAGE_PICKUP = BASE + 3,
            PACKAGE_INTO = BASE + 4,
            ITEM_MOVE = BASE + 10,
            ITEM_DEL = BASE + 12,
            ITEM_COMPOSE = BASE + 13,
            ITEM_USE = BASE + 14,
            NEATEN_PACKET = BASE + 16,
        }
    end
    function Funcs.PACKAGE:sc()
        local BASE = self.BASE + SC_ADD
        return {
            PACKAGE_OPEN = BASE + 1,
            PACKAGE_PICKUP = BASE + 3,
            PACKAGE_INTO = BASE + 4,
            ITEM_MOVE = BASE + 5,
            ITEM_DEL = BASE + 12,
            ITEM_COMPOSE = BASE + 13,
            ITEM_USE = BASE + 14,
            NEATEN_PACKET = BASE + 16,
            SYNC_ITEM_STAT = BASE + 17,

            SYNC_PACKAGE = BASE + 40,
            SYNC_ITEM = BASE + 41,
        }
    end

    Funcs.BUILD = { BASE = CS_BASE_GS + 1400, }
    function Funcs.BUILD:cs()
        local BASE = self.BASE
        return {
            BUILDING = BASE + 0,
            DESTORY = BASE + 1,
            REPAIR = BASE + 2,
            OPERATION = BASE + 3,
        }
    end
    function Funcs.BUILD:sc()
        local BASE = self.BASE + SC_ADD
        return {
            BUILDING = BASE + 0,
            DESTORY = BASE + 1,
            REPAIR = BASE + 2,
            OPERATION = BASE + 3,
        }
    end

    Funcs.PRODUCE = { BASE = CS_BASE_GS + 1450, }
    function Funcs.PRODUCE:cs()
        local BASE = self.BASE
        return {
            PRODUCEINFO = BASE + 0,
            MODIFY_COUNT = BASE + 1,
            ITEM_STAT = BASE + 2,
            PRODUCE_FRIEND_HELP = BASE + 3,
        }
    end
    function Funcs.PRODUCE:sc()
        local BASE = self.BASE + SC_ADD
        return {
            PRODUCEINFO = BASE + 0,
            MODIFY_COUNT = BASE + 1,
            ITEM_STAT = BASE + 2,
            PRODUCE_FRIEND_HELP = BASE + 3,
        }
    end

    Funcs.TALENT = { BASE = CS_BASE_GS + 1500, }
    function Funcs.TALENT:cs()
        local BASE = self.BASE
        return {
            LIST = BASE + 0,
            LOCK = BASE + 1,
            RESET = BASE + 2,
        }
    end
    function Funcs.TALENT:sc()
        local BASE = self.BASE + SC_ADD
        return {
            LIST = BASE + 0,
            LOCK = BASE + 1,
            RESET = BASE + 2,
        }
    end


    Funcs.WORLD_MAP = { BASE = CS_BASE_GS + 1600, }
    function Funcs.WORLD_MAP:cs()
        local BASE = self.BASE
        return {
            WORLD_INFO = BASE,
            WORLD_MOVE = BASE + 1,
            STAGE_GROUP_INFO = BASE + 2,
            GET_TARGET_PATH_INFO = BASE + 3,
            SELECT_MOVE_TOOL = BASE + 4,
            WORLD_ARRIVE = BASE + 5,
            WORLD_WEATHER = BASE + 6,

        }
    end
    function Funcs.WORLD_MAP:sc()
        local BASE = self.BASE + SC_ADD
        return {
            WORLD_INFO = BASE,
            WORLD_MOVE = BASE + 1,
            STAGE_GROUP_INFO = BASE + 2,
            GET_TARGET_PATH_INFO = BASE + 3,
            SELECT_MOVE_TOOL = BASE + 4,
            WORLD_ARRIVE = BASE + 5,
            WORLD_WEATHER = BASE + 6,
        }
    end

    codes_maker("MULTI_MAP",  CS_BASE_GS + 600, {
            ALONE_APPLY = 1,
            TEAM_APPLY = 2,
            GET_ROOM_TOKEN = 4,
            ATTACK_ROLE_HOME = 5,
            BS_APPLY_JOIN = 10,
            CANCEL_ALONE_APPLY = 11,
        }, {
            ALONE_APPLY = 1,
            TEAM_APPLY = 2,
            APPLY_ROOM = 3,
            GET_ROOM_TOKEN = 4,
            ATTACK_ROLE_HOME = 5,

            BS_APPLY_JOIN = 10,

            SYNC_CROSS_BATTLE_INFO = 51,
            SYNC_ROOM_INFO = 52,
            SYNC_BEGIN_MATCH = 53,
        })

    codes_maker("HOME", CS_BASE_GS + 800, {
            GET_HOME_INFO = 1,
        }, {
            GET_HOME_INFO = 1,
        })

    Funcs.MAIL = { BASE = CS_BASE_GS + 400, }
    function Funcs.MAIL:cs()
        local BASE = self.BASE
        return {
            GET_LIST = BASE + 1,
            GET_CONTENT = BASE + 2,
            SET_READED = BASE + 3,
            GET_AFFIX = BASE + 4,
        }
    end
    function Funcs.MAIL:sc()
        local BASE = self.BASE + SC_ADD
        return {
            GET_LIST = BASE + 1,
            GET_CONTENT= BASE + 2,
            GET_AFFIX = BASE + 4,
        }
    end

    codes_maker("TEAM", CS_BASE_GS + 700, {
            TEAM_CREATE = 0,
            DROP_MEMBER = 2,
            MOVE_LEADER = 3,
            SET_STATUS = 4,
            EXIT_TEAM = 5,
            JOIN_PUBLIC = 6,
            SET_READY = 7,

            TEAM_INVITE = 10,
            INVITE_ACT = 11,
            TEAM_CLOSE_BATTLE_POLL = 12,
            TEAM_CLOSE_BATTLE_ACT = 13,

            PUBLIC_LIST_ADD_LISTEN = 20,
            PUBLIC_LIST_REMOVE_LISTEN = 21,
        }, {
            TEAM_CREATE = 0,
            DROP_MEMBER = 2,
            MOVE_LEADER = 3,
            SET_STATUS = 4,
            EXIT_TEAM = 5,
            JOIN_PUBLIC = 6,
            SET_READY = 7,

            TEAM_INVITE = 10,
            INVITE_ACT = 11,
            TEAM_CLOSE_BATTLE_POLL = 12,
            TEAM_CLOSE_BATTLE_ACT = 13,

            PUBLIC_LIST = 23,

            SYNC_TEAM_INFO = 50,
            SYNC_TEAM_BASE = 51,
            SYNC_MEMBER_JOIN = 52,
            SYNC_MEMBER_OUT = 53,
            SYNC_INVITE = 60,
            SYNC_REFUSE_INVITE = 61,
            SYNC_ROLE_JOIN = 62,
            SYNC_ROLE_EXIT = 63,
            SYNC_READY_GO = 64,
            SYNC_READY_GO_FAIL = 65,
            SYNC_MEMBERS_STATUS = 66,
            SYNC_CLOSE_BATTLE_POLL = 67,
            SYNC_CLOSE_BATTLE_POLL_INFO = 68,
            SYNC_CLOSE_BATTLE_POLL_RESULT = 69,
        })

    Funcs.CHAT = { BASE = CS_BASE_GS + 1350}
    function Funcs.CHAT:cs()
        local ID_BASE = self.BASE
        return {
            SEND = ID_BASE,
            CHAT_SET_GET = ID_BASE + 1,
            CHAT_SET_MODIFY = ID_BASE + 2,
            AUDIO_GET = ID_BASE + 11,
        }
    end
    function Funcs.CHAT:sc()
        local ID_BASE = self.BASE + SC_ADD
        return {
            SEND = ID_BASE,
            CHAT_SET_GET = ID_BASE + 1,
            CHAT_SET_MODIFY = ID_BASE + 2,
            CHAT_BROADCAST = ID_BASE + 10,
            AUDIO_GET = ID_BASE + 11,
        }
    end

    Funcs.GUILD = { BASE = CS_BASE_GS + 1650, }
    function Funcs.GUILD:cs()
        local BASE = self.BASE
        return {
            GET_GUILD_LIST = BASE + 1,
            SEARCH_GUILD = BASE + 2,
            APPLY_JOIN_GUILD = BASE + 3,
            GUILD_CHANGE_DESC = BASE + 4,
            GUILD_QUIT = BASE + 5,
            GUILD_MY_INFO = BASE + 6,
            GUILD_DONATE = BASE + 7,
            GET_GUILD_LOG_LIST = BASE + 8,
            GUILD_CLAIM_LIST = BASE + 9,
            GUILD_CLAM = BASE + 10,
            GUILD_CLAIM_COMPLETE = BASE + 11,
            GUILD_CHANGE_ICON = BASE + 13,
            GUILD_BUILD_INFO = BASE + 16,
            GUILD_BUILD_PRODUCE = BASE + 17,
            GUILD_BUILD_MANAGER = BASE + 18,
        }
    end
    function Funcs.GUILD:sc()
        local BASE = self.BASE + SC_ADD
        return {
            GET_GUILD_LIST = BASE + 1,
            SEARCH_GUILD = BASE + 2,
            APPLY_JOIN_GUILD = BASE + 3,
            GUILD_CHANGE_DESC = BASE + 4,
            GUILD_QUIT = BASE + 5,
            GUILD_MY_INFO = BASE + 6,
            GUILD_DONATE = BASE + 7,
            GET_GUILD_LOG_LIST = BASE + 8,
            GUILD_CLAIM_LIST = BASE + 9,
            GUILD_CLAM = BASE + 10,
            GUILD_CLAIM_COMPLETE = BASE + 11,
            SYN_CLAIM_INFO = BASE + 12,
            GUILD_CHANGE_ICON = BASE + 13,
            MEMBER_INFO = BASE + 14,
            SYN_GUILD_INFO = BASE + 15,
            GUILD_BUILD_INFO = BASE + 16,
            GUILD_BUILD_PRODUCE = BASE + 17,
            SYN_MY_GUILD_INFO = BASE + 19,
        }
    end

    Funcs.VENDUE = { BASE = CS_BASE_GS + 1700, }
    function Funcs.VENDUE:cs()
        local BASE = self.BASE
        return {
            VENDUE_LIST = BASE,
            VENDUE_OWNER = BASE + 1,
            VENDUE_SELL = BASE + 2,
            VENDUE_OPE = BASE + 3,
            ITEM_SELL_INFO = BASE + 4,
            VENDUE_BUY = BASE + 5,
        }
    end
    function Funcs.VENDUE:sc()
        local BASE = self.BASE + SC_ADD
        return {
            VENDUE_LIST = BASE,
            VENDUE_OWNER = BASE + 1,
            VENDUE_SELL = BASE + 2,
            VENDUE_OPE = BASE + 3,
            ITEM_SELL_INFO = BASE + 4,
            VENDUE_BUY = BASE + 5,
        }
    end

    Funcs.SHOP = { BASE = CS_BASE_GS + 1100, }
    function Funcs.SHOP:cs()
        local BASE = self.BASE
        return {
            GET = BASE + 1,
            REFLASH = BASE + 5,
            BUY_GOODS = BASE + 10,
        }
    end
    function Funcs.SHOP:sc()
        local BASE = self.BASE + SC_ADD
        return {
            GET = BASE + 1,
            SHOP_CHANGE = BASE + 2,
            GOODS_CHANGE = BASE + 3,
            REFLASH = BASE + 5,
            BUY_GOODS = BASE + 10,
        }
    end


    Funcs.FRIEND = { BASE = CS_BASE_GS + 1000, }
    function Funcs.FRIEND:cs()
        local BASE = self.BASE
        return {
            FRIEND_LIST = BASE,
            FRIEND_APPLY_LIST = BASE + 1,
            FRIEND_APPLY_OPERATE = BASE + 2,
            FRIEND_APPLY_ADD = BASE + 3,
            FRIEND_RECOMMEND_LIST = BASE + 4,
            FRIEND_REMOVE = BASE + 5,
            FRIEND_ONLINE_STATE = BASE + 6,
            JOIN_BLACKLIST = BASE + 8,
            REMOVE_BLACKLIST = BASE + 9,
            FRIEND_SEARCH = BASE + 10,
            FRIEND_BLACK_LIST = BASE + 11,
            FRIEND_STRANGE_LIST = BASE + 12,
        }
    end
    function Funcs.FRIEND:sc()
        local BASE = self.BASE + SC_ADD
        return {
            FRIEND_LIST = BASE,
            FRIEND_APPLY_LIST = BASE + 1,
            FRIEND_APPLY_OPERATE = BASE + 2,
            FRIEND_APPLY_ADD = BASE + 3,
            FRIEND_RECOMMEND_LIST = BASE + 4,
            FRIEND_REMOVE = BASE + 5,
            FRIEND_ONLINE_STATE = BASE + 6,
            FRIEND_MEMBER_INFO = BASE + 7,
            JOIN_BLACKLIST = BASE + 8,
            REMOVE_BLACKLIST = BASE + 9,
            FRIEND_SEARCH = BASE + 10,
            FRIEND_BLACK_LIST = BASE + 11,
            FRIEND_STRANGE_LIST = BASE + 12
        }
    end

    -- CS_BASE_BS ---------------------------------------------------------------------
    Funcs.MAP = { BASE = CS_BASE_BS + 100, }
    function Funcs.MAP:cs()
        local BASE = self.BASE
        return {
            APPLY_JOIN = BASE + 1,
            JOIN = BASE + 2,
            EXIT = BASE + 3,
        }
    end
    function Funcs.MAP:sc()
        local BASE = self.BASE + SC_ADD
        return {
            APPLY_JOIN = BASE + 1,
            JOIN = BASE + 2,
            EXIT = BASE + 3,
            SYNC_MAP_EVENT = BASE + 84,
            SYNC_ROLE_SURVIVE_INFO = BASE + 85,
            SYNC_OBJ_ADD = BASE + 86,
            SYNC_OBJ_INFO = BASE + 87,
            SYNC_OBJ_ADD_JOIN = BASE + 88,
            SYNC_OBJ_REMOVE = BASE + 89,
            SYNC_MAP_TEAMPLATE = BASE + 91,
            SYNC_OBJ_SPEED = BASE + 92,
			SYNC_OBJ_APPEND = BASE + 93,
            SYNC_OBJ_ATT = BASE + 94,
        }
    end

    Funcs.BATTLE = { BASE = CS_BASE_BS + 200, }
    function Funcs.BATTLE:cs()
        local BASE = self.BASE
        return {
            SYNC_ROLE_ACTION = BASE + 1,
            ATTACK_OBJ = BASE + 2,
            OBJ_HITED = BASE + 3,
            ROLE_SKILL_FIRE = BASE + 4,
            ROLE_INTO_REED = BASE + 5,
            ROLE_OUT_REED = BASE + 6,
        }
    end
    function Funcs.BATTLE:sc()
        local BASE = self.BASE + SC_ADD
        return {
            SYNC_OBJ_ACTION = BASE + 1,
            ATTACK_OBJ = BASE + 2,
            OBJ_HITED = BASE + 3,
            ROLE_SKILL_FIRE = BASE + 4,
            ROLE_INTO_REED = BASE + 5,
            ROLE_OUT_REED = BASE + 6,
            SYNC_OBJ_HITED = BASE + 10,
            SYNC_OBJ_BASE_INFO = BASE + 11,
            SYNC_REED_DEAD = BASE + 12,
            SYNC_OBJ_BUFF_INFO = BASE + 13,
        }
    end

    Funcs.SUB_BATTLE = { BASE = CS_BASE_BS + 2000, }
    function Funcs.SUB_BATTLE:cs()
        local BASE = self.BASE
        return {
            SYNC_CLIENT = BASE + 0,
            SYNC_OBJ_ACTION = BASE + 1,
            EXCHANGE_OBJ = BASE + 3,
            OBJ_PICKUP = BASE + 10,
            OBJ_COLLECT = BASE + 11,
            OBJ_GEAR_TRIGGER = BASE + 12,
            OBJ_TALK_NPC = BASE + 14,
            ROLE_URINATE = BASE + 15,
        }
    end
    function Funcs.SUB_BATTLE:sc()
        local BASE = self.BASE + SC_ADD
        return {
            EXCHANGE_OBJ = BASE + 3,
            OBJ_PICKUP = BASE + 10,
            OBJ_COLLECT = BASE + 11,
            OBJ_GEAR_TRIGGER = BASE + 12,
            OBJ_TALK_NPC = BASE + 14,
            ROLE_URINATE = BASE + 15,
        }
    end

    Funcs.ROLE = { BASE = CS_BASE_BS + 400, }
    function Funcs.ROLE:cs()
        local BASE = self.BASE
        return {
            GET_ROLE_INFO = BASE + 1,
            GET_ROLE_LOCAL = BASE + 2,
            ROLE_REVIVAL = BASE + 11,
        }
    end
    function Funcs.ROLE:sc()
        local BASE = self.BASE + SC_ADD
        return {
            GET_ROLE_INFO = BASE + 1,
            GET_ROLE_LOCAL = BASE + 2,
            ROLE_REVIVAL = BASE + 11,
        }
    end

    Funcs.TRANSPORT = { BASE = CS_BASE_BS + 2300, }
    function Funcs.TRANSPORT:cs()
        local BASE = self.BASE
        return {
            TRANSPORT = BASE,
        }
    end
    function Funcs.TRANSPORT:sc()
        local BASE = self.BASE + SC_ADD
        return {
            TRANSPORT = BASE,
            TRANSPORT_INFO = BASE + 1,
        }
    end

    -- 这个是自定义的
    Funcs.CLIENT = { BASE = 100000 }
    function Funcs.CLIENT:cs() return {} end
    function Funcs.CLIENT:sc()
        local BASE = self.BASE
        return {
            -- 账号验证
            VERIFY = BASE + 1,
            -- 服务器列表更新
            SERVER_LIST = BASE + 2,
            -- 资源下载
            DOWNLOADING_ASSET = BASE + 3,
            -- 资源解压
            UNPACKING_ASSET = BASE + 4,

            -- 角色装备更换
            EQUIP_CHANGED = BASE + 101,
            -- 窗口打开
            WND_OPEN = BASE + 102,
            -- 窗口关闭
            WND_CLOSE = BASE + 103,
            -- 设置窗口关闭：系统设置发生变化
            SETTINGS = BASE + 104,
            -- 自己的健康值发生变化
            SELF_HEALTHY = BASE + 106,
            -- 设置关注任务
            TASK_FORCUS = BASE + 107,

            -- topbar窗口切换
            TOPBAR_SWITCH = BASE + 110,
            TOPBAR_WND_SHOW = BASE + 111,
            TOPBAR_WND_HIDE = BASE + 112,

            -- sdk社交账户绑定or解绑
            SDK_SOCIAL_ACCCOUNT_BIND = BASE + 113,
            SDK_SOCIAL_ACCCOUNT_UNBIND = BASE + 114,
        }
    end

    for module,Module in pairs(Funcs) do
        for k,v in pairs(Module:cs()) do P[module..".CS."..k] = v end
        for k,v in pairs(Module:sc()) do P[module..".SC."..k] = v end
    end

end

local Code2Name = {}
for k,v in pairs(P) do
    Code2Name[v] = k
end

function P.get_msg_name(code)
    local name = Code2Name[code]
    if name then
        return name.."("..code..")"
    end

	return "Unkown code: "..code
end

do
    -- 要先访问一次，触发lazy wrap，元表才会生成
    local NetMsg = CS.clientlib.net.NetMsg
	local NetMsgMT = lgetmetatable "clientlib.net.NetMsg"

    rawset(NetMsgMT, "__tostring", function (nm)
        local nmType = nm.type
        return string.format("[%s %d bytes]",
            P.get_msg_name(nmType), math.max(nm.readSize, nm.writeSize))
    end)

    local NetMsgMethods = {
        readArray = function (self, Array, unpacker, ...)
            local n = self:readU32()
            for i=1,n do
                local Elm = unpacker(self, ...)
                if Elm then table.insert(Array, Elm) end
            end
            return Array, n
        end,
        writeArray = function (self, Array, packer, ...)
            local n = #Array
            self:writeU32(n)
            for i=1,n do
                packer(self, Array[i], ...)
            end
        end,
    }

    local NetMsgIndexer = NetMsgMT.__index
    local NewNetMsgIndexer = function (t, k)
        return NetMsgMethods[k] or NetMsgIndexer(t, k)
    end
    rawset(NetMsgMT, "__index", NewNetMsgIndexer)
    rawset(lgetmetatable("LuaIndexs"), typeof(NetMsg), NewNetMsgIndexer)
end

return P
