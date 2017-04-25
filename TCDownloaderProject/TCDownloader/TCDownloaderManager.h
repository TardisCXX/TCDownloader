//
//  TCDownloaderManager.h
//  TCDownloaderProject
//
//  Created by TARDIS on 2017-4-25.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCDownloader.h"

@interface TCDownloaderManager : NSObject

+ (instancetype)sharedManager;

/// 给定一个URL就可以下载(单任务下载)
- (void)downloadWithURL:(NSURL *)url;

/**
 给定一个URL进行下载，并获得下载信息回调(多任务下载)
 
 @param url             资源路径
 @param messageBlock    信息的回调
 @param progressBlock   进度的回调
 @param successBlock    成功的回调
 @param failureBlock    失败的回调
 */
- (void)downloadWithURL:(NSURL *)url message:(TCDownloadMessageBlock)messageBlock progress:(TCDownloadProgressBlock)progressBlock success:(TCDownloadSuccessBlock)successBlock failure:(TCDownloadFailureBlock)failureBlock;

/// 暂停下载
- (void)pauseWithUrl:(NSURL *)url;

/// 继续下载
- (void)resumeWithUrl:(NSURL *)url;

/// 取消下载
- (void)cancelWithUrl:(NSURL *)url;

/// 暂停所有
- (void)pauseAll;

/// 继续所有
- (void)resumeAll;

/// 取消所有
- (void)cancelAll;

@end
