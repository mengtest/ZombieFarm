#pragma once

#import <Foundation/Foundation.h>

#define QAV_RESULT(label, value) QAV_Result_##label = value

/*!
 @discussion    错误码，方法的返回值和异步回调请参考该错误码
 */
typedef NS_ENUM(NSInteger, QAVResult) {

    QAV_OK = 0,       ///< QAV_OK 成功操作。

///---------------------------------------------------------------------------------------
/// @name 客户端错误
///---------------------------------------------------------------------------------------

    QAV_ERR_FAIL = 1, ///< QAV_ERR_FAIL 一般错误。

    QAV_ERR_REPETITIVE_OPERATION = 1001,    ///< 重复操作。已经在进行某种操作，再次去做同样的操作，则返回这个错误。
    QAV_ERR_EXCLUSIVE_OPERATION  = 1002,    ///< 互斥操作。已经在进行某种操作，再次去做同类型的其他操作，则返回这个错误。
    QAV_ERR_HAS_IN_THE_STATE     = 1003,    ///< 已经处于所要状态，无需再操作。如设备已经打开，再次去打开，就返回这个错误码。
    QAV_ERR_INVALID_ARGUMENT     = 1004,    ///< 错误参数。
    QAV_ERR_TIMEOUT              = 1005,    ///< 操作超时。
    QAV_ERR_NOT_IMPLEMENTED      = 1006,    ///< 功能未实现。
    QAV_ERR_NOT_IN_MAIN_THREAD   = 1007,    ///< 不在主线程中执行操作

    QAV_ERR_CONTEXT_NOT_START    = 1101,    ///< AVContext没有启动。
    QAV_ERR_ROOM_NOT_EXIST       = 1201,    ///< 房间不存在。

    QAV_ERR_DEVICE_NOT_EXIST     = 1301,    ///< 设备不存在。

    QAV_ERR_SERVER_FAILED                    = 10001,   ///< 服务器返回一般错误
    QAV_ERR_SERVER_NO_PERMISSION             = 10003,   ///< 没有权限
    QAV_ERR_SERVER_REQUEST_ROOM_ADDRESS_FAIL = 10004,   ///< 进房间获取房间地址失败
    QAV_ERR_SERVER_CONNECT_ROOM_FAIL_INFO    = 10005,   ///< 进房间连接房间失败
    QAV_ERR_SERVER_FREE_FLOW_AUTH_FAIL       = 10006,   ///< 免流情况下，免流签名校验失败，导致进房获取房间地址失败
    QAV_ERR_SERVER_ROOM_DISSOLVED            = 10007,   ///< 游戏应用房间超过90分钟，强制下线

///---------------------------------------------------------------------------------------
/// @name IMSDK内部错误
///---------------------------------------------------------------------------------------
    QAV_ERR_IMSDK_RET_ERR_HTTP_REQ_FAILED                  = 6010,          ///< HTTP 请求失败
    QAV_ERR_IMSDK_RET_ERR_TO_USER_INVALID                  = 6011,          ///< 消息接收方无效，对方用户不存在
    QAV_ERR_IMSDK_RET_ERR_REQUEST_TIMEOUT                  = 6012,          ///< 请求超时，请等网络恢复后重试
    QAV_ERR_IMSDK_RET_ERR_SDK_NOT_INITIALIZED              = 6013,          ///< IMSDK 未初始化或者用户未登陆成功
    QAV_ERR_IMSDK_RET_ERR_SDK_NOT_LOGGED_IN                = 6014,          ///< IMSDK 未登录，请先登陆
    QAV_ERR_IMSDK_FAIL                                     = 6999,          ///< IMSDK失败
    QAV_ERR_IMSDK_TIMEOUT                                  = 7000,          ///< IMSDK超时
    QAV_ERR_UNKNOWN                                        = 65536,         ///< 无效值

    
///---------------------------------------------------------------------------------------
/// @name 伴奏错误
///---------------------------------------------------------------------------------------
    QAV_ERR_ACC_OPENFILE_FAILED            = 4001,        ///< 打开文件失败
    QAV_ERR_ACC_FILE_FORAMT_NOTSUPPORT     = 4002,        ///< 不支持的文件格式
    QAV_ERR_ACC_DECODER_FAILED             = 4003,        ///< 解码失败
    QAV_ERR_ACC_BAD_PARAM                  = 4004,        ///< 参数错误
    QAV_ERR_ACC_MEMORY_ALLOC_FAILED        = 4005,        ///< 内存分配失败
    QAV_ERR_ACC_CREATE_THREAD_FAILED       = 4006,        ///< 创建线程失败
    QAV_ERR_ACC_STATE_ILLIGAL              = 4007,        ///< 状态非法
};


