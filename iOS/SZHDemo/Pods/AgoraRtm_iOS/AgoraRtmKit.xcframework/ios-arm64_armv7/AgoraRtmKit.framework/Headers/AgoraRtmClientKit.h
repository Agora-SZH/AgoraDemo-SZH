//
//  AgoraRtmClientKit.h
//  AgoraRtcKit
//
//  Copyright (c) 2022 Agora. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AgoraRtmObjects.h"

@protocol AgoraRtmClientDelegate <NSObject>
@optional

/**
   * Occurs when receive a message.
   * @param rtmKit the AgoraRtmClientKit Object.  
   * @param event details of message event.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)rtmKit
    onMessageEvent: (AgoraRtmMessageEvent * _Nonnull)event;

  /**
   * Occurs when remote user presence changed
   * 
   * @param rtmKit the AgoraRtmClientKit Object.
   * @param event details of presence event.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)rtmKit
    onPresenceEvent: (AgoraRtmPresenceEvent * _Nonnull)event;

  /**
   * Occurs when lock state changed
   * @param rtmKit the AgoraRtmClientKit Object.
   * @param event details of lock event.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)rtmKit
    onLockEvent: (AgoraRtmLockEvent * _Nonnull)event;

  /**
   * Occurs when receive storage event
   * 
   * @param rtmKit the AgoraRtmClientKit Object
   * @param event details of storage event.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)rtmKit
    onStorageEvent: (AgoraRtmStorageEvent * _Nonnull)event;

  /**
   * Occurs when remote user join/leave topic or when user first join this channel,
   * got snapshot of topics in this channel
   *
   * @param rtmKit the AgoraRtmClientKit Object.
   * @param event details of topic event.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)rtmKit
    onTopicEvent: (AgoraRtmTopicEvent * _Nonnull)event;

  /**
   * Occurs when token will expire in 30 seconds.
   *
   * @param rtmKit the AgoraRtmClientKit Object.
   * @param channelName The name of the channel.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)rtmKit
    onTokenPrivilegeWillExpire: (NSString * _Nullable)channel;

/**
   * Occurs when the connection state changes between rtm sdk and agora service.
   *
   * @param rtmKit the AgoraRtmClientKit Object.
   * @param channelName The Name of the channel.
   * @param state The new connection state.
   * @param reason The reason for the connection state change.
   */
- (void)rtmKit: (AgoraRtmClientKit * _Nonnull)kit
    channel: (NSString * _Nonnull)channelName
    connectionStateChanged: (AgoraRtmClientConnectionState)state
    reason: (AgoraRtmClientConnectionChangeReason)reason;
@end


/**
 * The AgoraRtmClientKit class.
 *
 * This class provides the main methods that can be invoked by your app.
 *
 * AgoraRtmClientKit is the basic interface class of the Agora RTM SDK.
 * Creating an AgoraRtmClientKit object and then calling the methods of
 * this object enables you to use Agora RTM SDK's functionality.
 */
__attribute__((visibility("default"))) @interface AgoraRtmClientKit : NSObject


@property (atomic, weak, nullable) id<AgoraRtmClientDelegate> agoraRtmDelegate;

/**
 * Initializes the rtm client instance.
 *
 * @param [in] config The configurations for RTM Client.
 * @param [in] delegate  The callbacks handler.
 * 
 * @return 
 * - nil: initialize rtm client failed.
 * - not nil: initialize rtm client success.
 */
- (instancetype _Nullable) initWithConfig: (AgoraRtmClientConfig * _Nonnull)config
                                 delegate: (id <AgoraRtmClientDelegate> _Nullable)delegate;
 
/**
   * Login the Agora RTM service. The operation result will be notified by \ref agora::rtm::IRtmEventHandler::onLoginResult callback.
   *
   * @param [in] token Token used to login RTM service.
   * @param [in]  completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) loginByToken: (NSString* _Nullable)token
          completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Logout the Agora RTM service. Be noticed that this method will break the rtm service includeing storage/lock/presence.
   *
   * @param [in]  completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) logout: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Get the storage instance.
   *
   * @return
   * - return nil if error occured
   */
- (AgoraRtmStorage* _Nullable)getStorage;

/**
   * Get the lock instance.
   *
   * @return
   * - return nil if error occured
   */
- (AgoraRtmLock* _Nullable)getLock;

/**
   * Get the presence instance.
   *
   * @return
   * - return nil if error occured
   */
- (AgoraRtmPresence* _Nullable)getPresence;

/**
   * Renews the token. Once a token is enabled and used, it expires after a certain period of time.
   * You should generate a new token on your server, call this method to renew it.
   *
   * @param [in] token Token used renew.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) renewToken: (NSString* _Nonnull)token
         completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Subscribe a channel.
   *
   * @param [in] channelName The name of the channel.
   * @param [in] subscribeOption The options of subscribe the channel.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) subscribeWithChannel: (NSString* _Nonnull)channelName
                option: (AgoraRtmSubscribeOptions* _Nullable)subscribeOption
                completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Unsubscribe a channel.
   *
   * @param [in] channelName The name of the channel.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) unsubscribeWithChannel: (NSString* _Nonnull)channelName
                     completion: (AgoraRtmOperationBlock _Nullable)completionBlock;
  /**
   * Publish a message in the channel.
   *
   * @param [in] channelName The name of the channel.
   * @param [in] message The content of the raw message.
   * @param [in] publishOption The option of the message.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) publish: (NSString* _Nonnull)channelName
            message: (NSObject* _Nonnull)message
            withOption: (AgoraRtmPublishOptions* _Nullable)publishOption
            completion: (AgoraRtmOperationBlock _Nullable)completionBlock;
  
 /**
   * Set parameters of the sdk or engine
   *
   * @param [in] parameters The parameters in json format
   * @return
   * - AgoraRtmErrorOk: Success.
   * - other: Failure.
   */ 
- (AgoraRtmErrorCode) setParameters: (NSString* _Nonnull)parameter;

/**
   * Convert error code to error string.
   *
   * @param [in] errorCode Received error code
   * @return The error reason
   */ 
+ (NSString* _Nullable) getErrorReason: (AgoraRtmErrorCode)errorCode;

/**
 * Get the version info of the Agora RTM SDK.
 *
 * @return The version info of the Agora RTM SDK.
 */
+ (NSString * _Nonnull)getVersion;
        

/**
 * create a stream channel instance.
 *
 * @param [in] channelName The Name of the channel.
 * @return
 * - nil: create stream channel failed.
 * - not nil: create stream channel success.
 */
- (AgoraRtmStreamChannel * _Nullable)createStreamChannel: (NSString * _Nonnull)channelName;


/**
 * destroy the rtm client instance.
 *
 * @return
 * - AgoraRtmErrorOk: Success.
 * - other: Failure.
 */
- (AgoraRtmErrorCode) destroy;
@end

__attribute__((visibility("default"))) @interface AgoraRtmStreamChannel : NSObject

/**
   * Join the channel.
   *
   * @param [in] option join channel options.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void)joinWithOption: (AgoraRtmJoinChannelOption * _Nonnull)option
           completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Leave the channel.
   *
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void)leave: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Leave the channel.
   *
   * @param [in] token token Token used renew.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void)renewToken:(NSString* _Nonnull)token
        completion:(AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Join a topic.
   *
   * @param [in] topic The name of the topic.
   * @param [in] option The options of the topic.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) joinTopic: (NSString * _Nonnull)topic 
        withOption: (AgoraRtmJoinTopicOption * _Nullable)option
        completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Leave the topic.
   *
   * @param [in] topic The name of the topic.
   * @param [in] completionBlock The operation result will be no  notified by completionBlock.
   * 
   */
- (void) leaveTopic: (NSString * _Nonnull)topic
         completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Subscribe a topic.
   *
   * @param [in] topic The name of the topic.
   * @param [in] option The options of subscribe the topic.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) subscribeTopic: (NSString * _Nonnull)topic 
             withOption: (AgoraRtmTopicOption * _Nullable)option
             completion: (AgoraRtmTopicSubscriptionBlock _Nullable)completionBlock;

             
/**
   * UnsubscribeTopic a topic.
   *
   * @param [in] topic The name of the topic.
   * @param [in] option The options of subscribe the topic.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) unsubscribeTopic: (NSString * _Nonnull)topic 
               withOption: (AgoraRtmTopicOption * _Nullable)option
               completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * publish a message in the topic.
   *
   * @param [in] message The content of message.
   * @param [in] topic The name of the topic. 
   * @param [in] options The option of the message.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) publishTopicMessage: (NSObject * _Nonnull) message
               inTopic: (NSString * _Nonnull) topic
               withOption:(AgoraRtmPublishOptions * _Nullable) options
               completion: (AgoraRtmOperationBlock _Nullable)completionBlock;
  /**
   * Get subscribed user list
   *
   * @param [in] topic The name of the topic.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) getSubscribedUserList:(NSString* _Nonnull)topic
                    completion:(AgoraRtmGetTopicSubscribedUsersBlock _Nullable)completionBlock;

/**
  * return the channel name of this stream channel.
  *
  * @return The channel name.
  */
- (NSString * _Nonnull) getChannelName;

/**
 * release the stream channel instance.
 *
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (AgoraRtmErrorCode) destroy;
              
@end

__attribute__((visibility("default"))) @interface AgoraRtmStorage : NSObject

  /** Creates the metadata object and returns the pointer. This is the only valid way to create AgoraRtmMetadata.
  * @return Pointer of the metadata object.
  */
- (AgoraRtmMetadata * _Nullable) createMetadata;

  /**
   * Set the metadata of a specified channel.
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType Which channel type, RTM_CHANNEL_TYPE_STREAM or RTM_CHANNEL_TYPE_MESSAGE.
   * @param [in] data Metadata data.
   * @param [in] options The options of operate metadata.
   * @param [in] lock lock for operate channel metadata.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) setChannelMetadata: (NSString * _Nonnull)channelName
               channelType: (AgoraRtmChannelType)channelType
                  data: (AgoraRtmMetadata* _Nonnull)data
                  options: (AgoraRtmMetadataOptions* _Nullable)options
                  lock: (NSString * _Nullable)lock
                  completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Update the metadata of a specified channel.
   *
   * @param [in] channelName The channel Name of the specified channel.
   * @param [in] channelType Which channel type, RTM_CHANNEL_TYPE_STREAM or RTM_CHANNEL_TYPE_MESSAGE.
   * @param [in] data Metadata data.
   * @param [in] options The options of operate metadata.
   * @param [in] lock lock for operate channel metadata.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) updateChannelMetadata: (NSString * _Nonnull)channelName
               channelType: (AgoraRtmChannelType)channelType
                  data: (AgoraRtmMetadata* _Nonnull)data
                  options: (AgoraRtmMetadataOptions* _Nullable)options
                  lock: (NSString * _Nullable)lock
                  completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Remove the metadata of a specified channel.
   *
   * @param [in] channelName The channel Name of the specified channel.
   * @param [in] channelType Which channel type, RTM_CHANNEL_TYPE_STREAM or RTM_CHANNEL_TYPE_MESSAGE.
   * @param [in] data Metadata data.
   * @param [in] options The options of operate metadata.
   * @param [in] lock lock for operate channel metadata.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) removeChannelMetadata: (NSString * _Nonnull)channelName
               channelType: (AgoraRtmChannelType)channelType
                  data: (AgoraRtmMetadata* _Nonnull)data
                  options: (AgoraRtmMetadataOptions* _Nullable)options
                  lock: (NSString * _Nullable)lock
                  completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Get the metadata of a specified channel.
   *
   * @param [in] channelName The channel Name of the specified channel.
   * @param [in] channelType Which channel type, RTM_CHANNEL_TYPE_STREAM or RTM_CHANNEL_TYPE_MESSAGE.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) getChannelMetadata: (NSString * _Nonnull)channelName
               channelType: (AgoraRtmChannelType)channelType
               completion: (AgoraRtmGetMetadataBlock _Nullable)completionBlock;

/**
   * Set the metadata of a specified user.
   *
   * @param [in] userId The user ID of the specified user.
   * @param [in] data Metadata data.
   * @param [in] options The options of operate metadata.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   * 
   */
- (void) setUserMetadata: (NSString * _Nonnull)userId
                  data: (AgoraRtmMetadata* _Nonnull)data
                  options: (AgoraRtmMetadataOptions* _Nullable)options
                  completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

/**
   * Update the metadata of a specified user.
   *
   * @param [in] userId The user ID of the specified user.
   * @param [in] data Metadata data.
   * @param [in] options The options of operate metadata.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) updateUserMetadata: (NSString * _Nonnull)userId
                  data: (AgoraRtmMetadata* _Nonnull)data
                  options: (AgoraRtmMetadataOptions* _Nullable)options
                  completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Remove the metadata of a specified user.
   *
   * @param [in] userId The user ID of the specified user.
   * @param [in] data Metadata data.
   * @param [in] options The options of operate metadata.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) removeUserMetadata: (NSString * _Nonnull)userId
                  data: (AgoraRtmMetadata* _Nonnull)data
                  options: (AgoraRtmMetadataOptions* _Nullable)options
                  completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Get the metadata of a specified user.
   *
   * @param [in] userId The user ID of the specified user.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) getUserMetadata: (NSString * _Nonnull)userId
               completion: (AgoraRtmGetMetadataBlock _Nullable)completionBlock;

  /**
   * Subscribe the metadata update event of a specified user.
   *
   * @param [in] userId The user ID of the specified user.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) subscribeUserMetadata: (NSString * _Nonnull)userId
                   completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * unsubscribe the metadata update event of a specified user.
   *
   * @param [in] userId The user ID of the specified user.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
- (void) unsubscribeUserMetadata: (NSString * _Nonnull)userId
                      completion: (AgoraRtmOperationBlock _Nullable)completionBlock;
@end

__attribute__((visibility("default"))) @interface AgoraRtmLock : NSObject

/**
   * sets a lock
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] lockName The name of the lock.
   * @param [in] ttl The lock ttl.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) setLock: (NSString * _Nonnull) channelName
   channelType: (AgoraRtmChannelType) channelType
      lockName: (NSString * _Nonnull) lockName
           ttl: (int) ttl
    completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * removes a lock
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] lockName The name of the lock.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) removeLock: (NSString * _Nonnull) channelName
      channelType: (AgoraRtmChannelType)channelType
         lockName: (NSString * _Nonnull) lockName
       completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * acquires a lock
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] lockName The name of the lock.
   * @param [in] retry Whether to automatic retry when acquires lock failed
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) acquireLock: (NSString * _Nonnull) channelName
       channelType: (AgoraRtmChannelType)channelType
          lockName: (NSString * _Nonnull) lockName
             retry: (BOOL) retry
        completion: (AgoraRtmOperationBlock _Nullable)completionBlock;


  /**
   * releases a lock
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] lockName The name of the lock.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   *
   */
-(void) releaseLock: (NSString * _Nonnull) channelName
       channelType: (AgoraRtmChannelType)channelType
          lockName: (NSString * _Nonnull) lockName
        completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * disables a lock
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] lockName The name of the lock.
   * @param [in] owner The lock owner.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) revokeLock: (NSString * _Nonnull) channelName
      channelType: (AgoraRtmChannelType)channelType
         lockName: (NSString * _Nonnull) lockName
           userId: (NSString * _Nonnull) userId
       completion: (AgoraRtmOperationBlock _Nullable)completionBlock;


  /**
   * gets locks in the channel
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [out] requestId The related request id of this operation.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) getLocks: (NSString * _Nonnull) channelName
    channelType: (AgoraRtmChannelType)channelType
     completion: (AgoraRtmGetLocksBlock _Nullable)completionBlock;
@end


/**
 * The IRtmPresence class.
 *
 * This class provides the rtm presence methods that can be invoked by your app.
 */
__attribute__((visibility("default"))) @interface AgoraRtmPresence : NSObject

  /**
   * To query who joined this channel
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] options The query option.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) whoNow: (NSString * _Nonnull) channelName
  channelType: (AgoraRtmChannelType)channelType
      options: (AgoraRtmPresenceOptions* _Nullable)options
   completion: (AgoraRtmWhoNowBlock _Nullable)completionBlock;

  /**
   * To query which channels the user joined
   *
   * @param [in] userId The id of the user.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) whereNow: (NSString * _Nonnull) userId
     completion: (AgoraRtmWhereNowBlock _Nullable)completionBlock;

  /**
   * Set user state
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] items The states item of user.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) setState: (NSString * _Nonnull) channelName
    channelType: (AgoraRtmChannelType)channelType
          items: (NSArray<AgoraRtmStateItem *> * _Nonnull) items
     completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Delete user state
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] keys The keys of state item.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) removeState: (NSString * _Nonnull) channelName
       channelType: (AgoraRtmChannelType) channelType
             items: (NSArray<NSString *> * _Nonnull) keys
        completion: (AgoraRtmOperationBlock _Nullable)completionBlock;

  /**
   * Get user state
   *
   * @param [in] channelName The name of the channel.
   * @param [in] channelType The type of the channel.
   * @param [in] userId The id of the user.
   * @param [in] completionBlock The operation result will be notified by completionBlock.
   * 
   */
-(void) getState: (NSString * _Nonnull) channelName
    channelType: (AgoraRtmChannelType)channelType
         userId: (NSString * _Nonnull) userId
     completion: (AgoraRtmPresenceGetStateBlock _Nullable)completionBlock;
@end
