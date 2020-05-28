using UnityEngine;
using System.Collections.Generic;
using System;

public class AIhelpService
{
    private IElvaChatServiceSDK sdk;

	private string tag_userName = null;
	private string tag_serverId = "1";
	private string tag_fpid = null;
	private string tag_gameUid = null;
	private string tag_cityLevel = null;
	private string tag_vipLevel = null;
	private int    tag_isPaid = 0;
	private string tag_userLanguage = null;

    private string serverId = "1";

    private static AIhelpService _instance;

    public static AIhelpService Instance
    {
        get{
			if (_instance == null)
			{
				//Debug.LogError ("AIHelp service is not initialized!");

				_instance = new AIhelpService ();
			}
			return _instance;
        }
    }

	public void Initialize(string appid)
    {
        if (sdk != null)
		{
#if UNITY_ANDROID || UNITY_IOS
			sdk.init("funplus_app_725c179c5cee4ebc9ce179ea14b6a87b", "funplus@aihelp.net", appid);
#endif

            postInitSetting();
		}
	}

	public AIhelpService()
    {
#if UNITY_ANDROID
            //if(Application.platform == RuntimePlatform.Android)
			sdk = new ElvaChatServiceSDKAndroid();
#endif
#if UNITY_IOS
			//if(Application.platform == RuntimePlatform.IPhonePlayer)
			sdk = new ElvaChatServiceSDKIOS();
#endif
    }
		
	private void postInitSetting()
    {
//        if(sdk != null)
//        {
//            sdk.setName("AIHelp Demo");
//            sdk.setServerId(serverId);
//			// sdk.setChangeDirection();//设置ios强制竖屏
//        }
    }

	public void setUserInfo(
		string userName, 
		string serverId, 
		string fpid, 
		string gameUid, 
		string cityLevel, 
		string vipLevel, 
		int isPaidUser, 
		string userLanguage)
	{
		this.tag_userName 	  = userName;
		this.tag_serverId 	  = serverId;
		this.tag_fpid 		  = fpid;
		this.tag_gameUid 	  = gameUid;
		this.tag_cityLevel 	  = cityLevel;
		this.tag_vipLevel 	  = vipLevel;
		this.tag_isPaid 	  = isPaidUser;
		this.tag_userLanguage = userLanguage;

		if(this.tag_userName != null) {
			SetUserName (this.tag_userName);
		}

		if(this.tag_fpid != null) {
			SetUserId (this.tag_fpid);
		}

		Debug.Log ("AIHelp UserInfo:" + 
			" userName = " + this.tag_userName +
			" serverId = " + this.tag_serverId + 
			" fpid = " + this.tag_fpid + 
			" gameUid = " + this.tag_gameUid + 
			" cityLevel =" + this.tag_cityLevel + 
			" userLanguage = " + this.tag_userLanguage);
	}

    public void ShowFAQs()
    {
		if(sdk != null) {
			List<string> tag = new List<string>();

			if(this.tag_vipLevel != null) {
				tag.Add ("VIP" + this.tag_vipLevel);
			}

			if(this.tag_isPaid != 0) {
				tag.Add ("Paid User");
			}

			if(this.tag_userLanguage != null) {
				tag.Add (this.tag_userLanguage);
			}

			Dictionary<string, object> tags = new Dictionary<string, object> ();
			tags.Add ("elva-tags", tag);

			if(this.tag_fpid != null) {
				tags.Add ("fpid", this.tag_fpid);
			}

			if(this.tag_gameUid != null) {
				tags.Add ("game_uid", this.tag_gameUid);
			}

			if(this.tag_cityLevel != null) {
				tags.Add ("city_level", this.tag_cityLevel);
			}

			Dictionary<string, object> config = new Dictionary<string, object> ();
			config.Add ("elva-custom-metadata", tags);
			config.Add("showConversationFlag", "1");

			sdk.showFAQs(config);
		}
    }
	public void ShowElva(string playerName,string playerUid,string serverId,string showConversationFlag)
	{
		if(sdk != null)
		{
			sdk.showElva(playerName, playerUid,serverId,showConversationFlag);
		}
	}
	public void ShowElva(string playerName,string playerUid,string serverId,string showConversationFlag,Dictionary<string,object> config)
	{
		if(sdk != null)
		{
			sdk.showElva(playerName, playerUid,serverId,showConversationFlag,config);
		}
	}
	public void ShowElvaOP(string playerName,string playerUid,string serverId,string showConversationFlag)
	{
		if(sdk != null)
		{
			sdk.showElvaOP(playerName, playerUid,serverId,showConversationFlag);
		}
	}

	public void ShowElvaOP(string playerName,string playerUid,string serverId,string showConversationFlag,Dictionary<string,object> config)
	{
		if(sdk != null)
		{
			sdk.showElvaOP(playerName, playerUid,serverId,showConversationFlag,config);
		}
	}

	public void ShowElvaOP(string playerName,string playerUid,string serverId,string showConversationFlag,Dictionary<string,object> config, int tabIndex)
	{
		if(sdk != null)
		{
			sdk.showElvaOP(playerName, playerUid,serverId,showConversationFlag,config, tabIndex);
		}
	}
    //游戏名字
    public void SetName(string game_name)
    {
        if(sdk != null)
        {
            sdk.setName(game_name);
        }
    }

    public void SetUserId(string serverId)
    {
        if(sdk != null)
        {
            sdk.setUserId(serverId);
        }
    }

    public void SetUserName(string userName)
    {
        if(sdk != null)
        {
            sdk.setUserName(userName);
        }
    }

    public void SetServerId(string serverId)
    {
		this.tag_serverId = serverId;

        if(sdk != null)
        {
            sdk.setServerId(serverId);
        }
    }

    public void ShowConversation(string uid)
    {
        if(sdk != null)
        {
            sdk.showConversation(uid,serverId);
        }
    }

    public void SetSDKLanguage(string lang)
    {
        if(sdk != null)
        {
            sdk.setSDKLanguage(lang);
        }
    }

	public void ShowURL(string url)
	{
		if(sdk != null)
		{
			#if UNITY_ANDROID
			sdk.showURL(url);
			#endif
		}
	}

	public void ShowVIPChat(string webAppId, string vipTags)
	{
		if(sdk != null)
		{
			sdk.showVIPChat(webAppId,vipTags);
		}
	}

	public void SetFcmToken(string deviceToken,bool isVip)
	{
		if(sdk != null)
		{
			sdk.setFcmToken(deviceToken,isVip);
		}
	}

	public void ShowStoreReview()
	{
		if(sdk != null)
		{
			sdk.showStoreReview();
		}
	}

	public string GetNotificationMessage()
	{
		if (sdk != null)
		{
			#if UNITY_ANDROID
			return sdk.getNotificationMessage();
			#endif
			#if UNITY_IOS
			return sdk.getNotificationMessageCount().ToString();
			#endif
		}
		return "没有推送信息数据";
	}

	public void SetIOSChangeDirection()
	{
		if(sdk != null)
		{
			#if UNITY_IOS
			sdk.setChangeDirection();
			#endif
		}
	}

	public void RegisterInitializationCallback(string gameObject)
	{
		if(sdk != null)
		{
			sdk.registerInitializationCallback(gameObject);
		}
	}

	public void RegisterMessageArrivedCallback(string gameObject)
	{
		if(sdk != null)
		{
			sdk.registerMessageArrivedCallback(gameObject);
		}
	}

	public void SetUnreadMessageFetchUid(string playerUid)
	{
		if(sdk != null)
		{
			sdk.setUnreadMessageFetchUid(playerUid);
		}
	}
}