local L = libugui.GetLoc

local P = {
    StagePlayTabs = {
        [1] = L"play.single",
        [2] = L"play.team",
        [3] = L"play.fighting",
    },
    ChatChannelName = {
        [1] = L"chat.maillist",
        [2] = L"chat.ch_world",
        [3] = L"Title_Guild",
        [4] = L"chat.ch_team",
        [5] = L"chat.ch_nearby",
        [6] = L"chat.stranger",
        [7] = L"chat.blacklist",
    },
    TipTimeLast = {
        day = L"time.day",
        hour = L"time.hour",
        min = L"time.min",
        sec = L"time.sec",
        fmtLessOneUnit = L"time.fmtLess",
    },
    DefServerTabs = {
        [1] = L"server.recommend",
        [2] = L"server.has_role",
    },
    BuildOp = {
        nameBuild = L"v.build",
        nameUpgrade = L"v.upgrade",
    },
    LogoffTips = {
        [1] = L"account.other_login",
        [2] = L"account.kick_off",
        [3] = L"account.being_ban",
        [4] = L"account.no_service",
    },
    AskOperation = {
        Logout = {
            title = L"account.logout",
            content = L"account.ask_logout",
        },
        DeleteBuildingAskAgain = {
            title = L"building.destroy_building",
            content = L"building.warn_destroy_building",
            btnConfirm = L"building.destroy",
        },
        PresidentQuitGuildCountdown = {
            title = L"guild.quit_guild",
            content = L"guild.ask_dismiss_cd",
        },
        PresidentCancelQuitGuildCountdown = {
            title = L"guild.cancel_quit",
            content = L"guild.ask_cancel_quit",
            btnConfirm = L"guild.cancel_dismiss",
        },
        PresidentCancelQuitGuild = {
            title = L"guild.cancel_quit",
            content = L"guild.ask_cancel_disimiss",
            btnConfirm = L"guild.cancel_dismiss",
        },
        RepairBuilding = {
            title = L"building.repair",
            tips = L"building.repair_tips",
            btnConfirm = L"building.v.repair",
        },
        LeaveSquad = {
            title = L"team.leave_team",
            content = L"team.ask_leave_team",
        },
        DeleteItem = {
            title = L"item.delete_item",
            content = L"item.ask_delete_item",
        },
        TeamKickMember = {
            title = L"team.kick",
        },
        GeneralAlert = {
            title = L"AskOperation.GeneralAlert.title",
            fmtContent = L"AskOperation.GeneralAlert.fmtContent",
            btnCancel = L"AskOperation.GeneralAlert.btnCancel",
            btnConfirm = L"AskOperation.GeneralAlert.btnConfirm",
        },
        PresidentQuitGuild = {
            title = L"guild.quit_guild",
            content = L"guild.ask_dismiss_guild",
            btnConfirm = L"guild.confirm_dismiss",
            btnCancel = L"guild.cancel_dismiss",
        },
        TeamPromoteCaptain = {
            title = L"team.promote",
        },
        PlayerRelive = {
            btnConfirm = L"death.givup",
            content = L"death.your_are_dead",
        },
        NormalQuitGuild = {
            title = L"guild.quit_guild",
            content = L"guild.ask_quit_guild",
            btnConfirm = L"guild.quit",
        },
        DeleteReadMail = {
            title = L"mail.delete_read",
            content = L"mail.ask_delete_all_read",
        },
        ReceiveAllMailAtta = {
            title = L"mail.receive_all",
            content = L"mail.ask_receive_all",
        },
        DeleteBuilding = {
            title = L"building.destroy_building",
            content = L"building.ask_destroy_building",
            btnConfirm = L"building.destroy",
        },
        AskRequestClaim = {
            title = L"AskRequestClaimTitle",
            content = L"fmtAskRequestClaim",
        },
        JoinGuildAlert = {
            title = L"JoinGuildAlertTitle",
            content = L"JoinGuildAlert",
        },
        QuitGuildAlert = {
            title = L"QuitGuildAlertTitle",
            content = L"QuitGuildAlert",
        },
        AskGuildWorkBagSwitchCancel = {
            title = L"GuildWorkBagSwitchCancelTitle",
            content = L"GuildWorkBagSwitchCancelAlert",
        },
        VoteRefreshStage = {
            title = L"team.refresh_vote", btnConfirm = L"agree", btnCancel = L"refuse",
        },
        TryWorldEntrance = {
            title = " ",
            content = L"tipLeaveTeam2Move",
        },
        SelectServerAlert = {
            title = L"SelectServerTitle",
            content = L"SelectServerContent",
        },
        LeaveNeighborAlert = {
            title = L"LeaveNeighborTitle",
            content = L"LeaveNeighborContent",
        },
        ReloginAlert = {
            title = L"ReloginAlertTitle",
            content = L"ReloginAlertContent",
        },
    },
    IllegalName = {
        tooLong = L"IllegalName.tooLong",
        unchanged = L"IllegalName.unchanged",
        tooShort = L"IllegalName.tooShort",
    },
    AskConsumption = {
        ResetEnergy = {
            title = L"energy.reset",
            fmtOper = L"energy.fmtReset",
        },
        ChangeName = {
            title = L"rename.change_your_name",
            oper = L"rename.change_your_name",
            firstTips = L"rename.first_time_tips",
        },
        HastenWork = {
            title = L"working.finish",
            oper = L"working.hasten_finish",
        },
        Return2Start = {
            title = L"travel.turn_around",
            oper = L"travel.turn_around",
        },
        ResetTalent = {
            title = L"talent.reset",
            oper = L"talent.reset",
            tips = L"talent.reset_description",
        },
        Rush2Finish = {
            title = L"travel.rush_destination",
            oper = L"travel.rush_destination",
        },
        RefreshGuildList = {
            title = L"RefreshGuildList.reset",
            oper = L"RefreshGuildList.fmtReset",
        },
        BuyMBPass = {
            title = L"buymbpass.title",
            oper = L"buymbpass.fmtpay",
        }
    },
    InviteTabs = {
        [1] = L"chat.friend",
        [2] = L"team.recently",
    },
    RightMenu = {
        PrivateChat = L"RightMenu.PrivateChat",
        AddFriend = L"RightMenu.AddFriend",
        Guild_KickOut = L"RightMenu.Guild_KickOut",
        Guild_AdjAdmin = L"RightMenu.Guild_AdjAdmin",
        Guild_TnfPresident = L"RightMenu.Guild_TnfPresident",
        Guild_AdjNormal = L"RightMenu.Guild_AdjNormal",
        Guild_AdjNormal = L"RightMenu.Guild_AdjNormal",
        Guild_AdjNormal = L"RightMenu.Guild_AdjNormal",
        Guild_AdjNormal = L"RightMenu.Guild_AdjNormal",
        AddBlack = L"RightMenu.AddBlack",
        InviteLocation = L"RightMenu.InviteLocation",
        RemoveFriend = L"RightMenu.RemoveFriend",
        Guild_Invite = L"RightMenu.Guild_Invite",
        PlayerInfo = L"RightMenu.PlayerInfo",
    },
    SettingsMenu = {
        [1] = L"settings.base",
        [2] = L"settings.operation",
        [3] = L"settings.others",
    },
    WeaponReload = {
        BulletClip = L"WeaponReload.BulletClip",
        Reload = L"WeaponReload.Reload",
    },
    fmtClanInfo = {
        IdLv = L"fmtClanInfo.IdLv",
        MantenanceCost = L"fmtClanInfo.MantenanceCost",
        Members = L"fmtClanInfo.Members",
        ClanCptial = L"fmtClanInfo.ClanCptial",
        Activity = L"fmtClanInfo.Activity",
    },
    MapTravelTool = {
        drive = L"travel.drive",
        walk = L"travel.walk",
        rush = L"travel.run",
    },
    BuildPosError = {
        [-1] = L"building.err_place_blocked",
        [-2] = L"building.err_place_occupied",
        [-3] = L"building.err_wall_occupied",
        [-4] = L"building.err_need_floor_edge",
        [-5] = L"building.err_maximum_amount",
        [-6] = L"building.err_level_low",
        [-99] = L"building.err_no_material",
    },
    HealthyComplain = {
        [8] = L"player.say_hungry",
        [9] = L"player.say_thirsty",
        [10] = L"player.say_dirty",
    },
    fmtGuildDonate = {
        addCapital = L"fmtGuildDonate.addCapital",
        addConribution = L"fmtGuildDonate.addConribution",
        addExp = L"fmtGuildDonate.addExp",
    },
    ContactTypeName = {
        [0] = L"chat.stranger",
        [1] = L"chat.friend",
        [2] = L"chat.teammate",
        [3] = L"chat.guildmember",
    },
    CFG_FIELD_NAME = {
        def = L"attr.def",
        fast = L"attr.fast",
        Damage = L"attr.attack",
        move = L"attr.move",
    },
    ServerFlags = {
        [1] = L"server.flag_new",
        [2] = L"server.flag_hot",
    },
    DeathReason = {
        [0] = L"DeathByUnknown",
        [1] = L"DeathByStarve",
        [2] = L"DeathByThirst",
        [3] = L"DeathByHunger",
        [4] = L"DeathByOtherUser",
        [5] = L"DeathByYourself",
        [6] = L"DeathByMonster",
    },
    DeathReasonTitle = {
        [0] = L"DeathByUnknownTitle",
        [1] = L"DeathByStarveTitle",
        [2] = L"DeathByThirstTitle",
        [3] = L"DeathByHungerTitle",
        [4] = L"DeathByOtherUserTitle",
        [5] = L"DeathByYourselfTitle",
        [6] = L"DeathByMonsterTitle",
    },
}

return setmetatable(P, {
    __index = function (t, k)
        local txt = L(k) or k
        t[k] = txt
        return txt
    end
})
