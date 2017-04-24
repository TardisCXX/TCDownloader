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

@property (nonatomic,copy) TCDownloadStateChangedBlock downloadStateChangedBlock;

/// 给定一个URL就可以下载
- (void)downloadWithURL:(NSURL *)url;

/// 取消
- (void)cancel;

/// 暂停
- (void)pause;

/// 继续
- (void)resume;

/// 取消并清除
- (void)cancelAndClean;

@end
