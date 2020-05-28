#pragma once

namespace tencent {
namespace av {

// 成功。
const int AV_OK = 0;

/*
名称：AV_ERR_FAIL
取值：1
含义：一般错误。
原因：具体原因需要通过分析日志等来定位。
方案：分析日志。
*/
const int AV_ERR_FAIL = 1;

// 基础共用相关(1001 to 1100)

/*
名称：AV_ERR_REPETITIVE_OPERATION
取值：1001
含义：重复操作。
原因：已经在进行某种操作，再次去做同样的操作，则会产生这个错误。如已经在进入房间过程中，再去做进入房间的操作，就会产生这个错误。
方案：等待上一个操作完成后再进行下一个操作。
*/
const int AV_ERR_REPETITIVE_OPERATION = 1001;
static const char AV_ERR_INFO_REPETITIVE_OPERATION[] = "repetitive operation";

/*
名称：AV_ERR_EXCLUSIVE_OPERATION
取值：1002
含义：互斥操作。
原因：已经在进行某种操作，再次去做同类型的其他操作，则会产生这个错误。如在进入房间过程中，去做退出房间的操作，就会产生这个错误。
方案：等待上一个操作完成后再进行下一个操作。
*/
const int AV_ERR_EXCLUSIVE_OPERATION = 1002;
static const char AV_ERR_EXCLUSIVE_OPERATION_INFO[] = "exclusive operation";


/*
名称：AV_ERR_HAS_IN_THE_STATE
取值：1003
含义：已处于所要状态。
原因：对象已经处于所要状态，无需再操作。如设备已经打开，再次去打开，就返回这个错误码。
方案：由于已经处于所要状态，可以认为该操作已经成功，当作成功来处理。
*/
const int AV_ERR_HAS_IN_THE_STATE = 1003;
static const char AV_ERR_HAS_IN_THE_STATE_INFO[] = "just in the state";


/*
名称：AV_ERR_INVALID_ARGUMENT
取值：1004
含义：错误参数。
原因：调用SDK接口时，传入错误的参数，则会产生这个错误。如进入房间时，传入的房间类型不正确，就会产生这个错误。
方案：详细阅读API文档，搞清楚每个接口的每个参数的有效取值范围，确认哪些参数没有按照规范来取值，保证传入参数的正确性并进行相应的预防处理。
*/
const int AV_ERR_INVALID_ARGUMENT = 1004;
static const char AV_ERR_INVALID_ARGUMENT_INFO[] = "invalid argument";


/*
名称：AV_ERR_TIMEOUT
取值：1005
含义：操作超时。
原因：进行某个操作，在规定的时间内，还未返回操作结果，则会产生这个错误。多数情况下，涉及到信令传输的、且网络出问题的情况下，才容易产生这个错误。如执行进入房间操作时，30s后还没有返回进入房间操作完成的结果的话，就会产生这个错误。
方案：确认网络是否有问题，并尝试重试。
*/
const int AV_ERR_TIMEOUT = 1005;
static const char AV_ERR_TIMEOUT_INFO[] = "waiting timeout, please check your network";


/*
名称：AV_ERR_NOT_IMPLEMENTED
取值：1006
含义：功能未实现。
原因：调用SDK接口时，如果相应的功能还未支持，则会产生这个错误。
方案：暂不支持该功能，找其他替代方案。
*/
const int AV_ERR_NOT_IMPLEMENTED = 1006;
static const char AV_ERR_NOT_IMPLEMENTED_INFO[] = "function not implemented";


/*
名称：AV_ERR_NOT_ON_MAIN_THREAD
取值：1007
含义：没有在主线程中调用。
原因：大部分的SDK接口要求在主线程调用，如果业务侧调用SDK接口时，没有在主线程调用，则会产生这个错误。
方案：修改业务侧逻辑，确保在主线程调用SDK接口。
*/
const int AV_ERR_NOT_ON_MAIN_THREAD = 1007;
static const char AV_ERR_INFO_NOT_ON_MAIN_THREAD[] = "not on the main thread";

//enum Error {

//CONTEXT相关(1101 to 1200)
const int  AV_ERR_CONTEXT_NOT_START = 1101; ///< AVContext没有启动
static const char AV_ERR_INFO_CONTEXT_NOT_START[] = "AVContext did not start";

//房间相关(1201 to 1300)
const int  AV_ERR_ROOM_NOT_EXIST = 1201;///< 房间不存在。
static const char AV_ERR_ROOM_NOT_EXIST_INFO[] = "room not exist";


//设备相关(1301 to 1400)
const int  AV_ERR_DEVICE_NOT_EXIST = 1301;///< 设备不存在。
static const char AV_ERR_DEVICE_NOT_EXIST_INFO[] = "device not exist";


//其他模块错误
/*********服务器错误**********/
const int  AV_ERR_SERVER_FAIL = 10001; ///< 服务器返回一般错误
static const char AV_ERR_SERVER_FAIL_INFO[] = "server response error";

const int  AV_ERR_SERVER_NO_PERMISSION = 10003; ///< 没有权限
static const char AV_ERR_SERVER_NO_PERMISSION_INFO[] = "server refused because of no permission";

const int  AV_ERR_SERVER_REQUEST_ROOM_ADDRESS_FAIL = 10004; ///< 进房间获取房间地址失败
static const char AV_ERR_SERVER_REQUEST_ROOM_ADDRESS_FAIL_INFO[] = "request room server address failed";

const int  AV_ERR_SERVER_CONNECT_ROOM_FAIL = 10005; ///< 进房间连接房间失败
static const char AV_ERR_SERVER_CONNECT_ROOM_FAIL_INFO[] = "connect room server failed";

const int  AV_ERR_SERVER_ROOM_DISSOLVED = 10007; ///< 游戏应用房间超过90分钟，强制下线
static const char AV_ERR_SERVER_ROOM_DISSOLVED_INFO[] = "room dissolved because of overuse";
    
/*********imsdk错误**********/
const int  AV_ERR_IMSDK_FAIL  = 6999;
static const char AV_ERR_IMSDK_FAIL_INFO[] = "imsdk return failed";

const int  AV_ERR_IMSDK_TIMEOUT  = 7000;
static const char AV_ERR_IMSDK_TIMEOUT_INFO[] = "imsdk waiting timeout";

const int  AV_ERR_HTTP_REQ_FAIL  = 7001;
static const char AV_ERR_HTTP_REQ_FAIL_INFO[] = "http request failed";

const int  AV_ERR_UNKNOWN = 65536; ///< 未知错误
static const char AV_ERR_INFO_UNKNOWN[] = "unknown error";
//};
const int VOICE_UPLOAD_FILE_ACCESSERROR       = 0x2001;// 8193 Read	File
const int VOICE_UPLOAD_SIGN_CHECK_FAIL        = 0x2002;// 8194 Sign Check																	
const int VOICE_UPLOAD_NETWORK_FAIL           = 0x2003;// 8195
const int VOICE_UPLOAD_GET_TOKEN_NETWORK_FAIL = 0x2004; // 获取上传参数过程中，http网络失败
const int VOICE_UPLOAD_GET_TOKEN_RESP_NULL    = 0x2005; // 获取上传参数过程中，回包数据为空
const int VOICE_UPLOAD_GET_TOKEN_RESP_INVALID = 0x2006; // 获取上传参数过程中，回包解包失败
const int VOICE_UPLOAD_TOKEN_CHECK_EXPIRED    = 0x2007; // TLS签名校验明确过期，需要重新申请TLS签名
const int VOICE_UPLOAD_APPINFO_UNSET          = 0x2008; // 没有设置 appinfo

} // namespace av
} // namespace tencent
