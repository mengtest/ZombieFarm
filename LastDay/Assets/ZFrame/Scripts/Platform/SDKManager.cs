
namespace ZFrame.Platform
{
    public class SDKManager : MonoSingleton<SDKManager>
    {
        [UnityEngine.SerializeField]
        private string m_LuaPackage;

        public IPlatform plat { get; private set; }

        protected override void Awaking()
        {
#if UNITY_EDITOR
            plat = new Standalone();
#elif UNITY_STANDALONE_WIN
            plat = new StandaloneWin();
#elif UNITY_ANDROID
            plat = new Android();
#elif UNITY_IOS
            plat = new iOS();
#elif UNITY_STANDALONE
            plat = new Standalone();
#endif

            plat.OnAppLaunch();
        }

        void OnSDKMessage(string message)
        {
            var lua = LuaScriptMgr.Instance.L;
            lua.GetGlobal("PKG", m_LuaPackage, "sdk_message");
            lua.Func(0, message);
        }
    }
}