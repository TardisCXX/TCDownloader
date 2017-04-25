//
//  TCDownloader.h
//  TCDownloaderDemo
//
//  Created by TARDIS on 2017-3-15.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TCDownloaderState) {
    TCDownloaderStatePause,         // 下载暂停
    TCDownloaderStateDownloading,   // 正在下载
    TCDownloaderStateSuccess,       // 已经下载成功
    TCDownloaderStateFailure        // 下载失败
};

typedef void(^TCDownloadStateChangedBlock)(TCDownloaderState state);
typedef void(^TCDownloadMessageBlock)(long long totalSize, NSString *downloadedPath);
typedef void(^TCDownloadProgressBlock)(float progress);
typedef void(^TCDownloadSuccessBlock)(NSString *downloadedPath);
typedef void(^TCDownloadFailureBlock)(NSString *errMsg);


@interface TCDownloader : NSObject

/// 下载状态
@property (nonatomic, assign, readonly) TCDownloaderState state;

/// 下载状态回调
@property (nonatomic, copy) TCDownloadStateChangedBlock downloadStateChangedBlock;
/// 下载信息文件大小、下载路径回调
@property (nonatomic, copy) TCDownloadMessageBlock downloadMessageBlock;
/// 下载进度回调
@property (nonatomic, copy) TCDownloadProgressBlock downloadProgressBlock;
/// 下载成功回调
@property (nonatomic, copy) TCDownloadSuccessBlock downloadSuccessBlock;
/// 下载失败回调
@property (nonatomic, copy) TCDownloadFailureBlock downloadFailureBlock;

/// 给定一个URL就可以下载
- (void)downloadWithURL:(NSURL *)url;


/**
 给定一个URL进行下载，并获得下载信息回调

 @param url             资源路径
 @param messageBlock    下载信息的回调
 @param progressBlock   进度的回调
 @param successBlock    成功的回调
 @param failureBlock    失败的回调
 */
- (void)downloadWithURL:(NSURL *)url message:(TCDownloadMessageBlock)messageBlock progress:(TCDownloadProgressBlock)progressBlock success:(TCDownloadSuccessBlock)successBlock failure:(TCDownloadFailureBlock)failureBlock;

/// 取消
- (void)cancel;

/// 暂停
- (void)pause;

/// 继续
- (void)resume;

/// 取消并清除
- (void)cancelAndClean;

@end
