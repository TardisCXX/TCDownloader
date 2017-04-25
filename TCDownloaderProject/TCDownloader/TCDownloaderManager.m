//
//  TCDownloaderManager.m
//  TCDownloaderProject
//
//  Created by TARDIS on 2017-4-25.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import "TCDownloaderManager.h"
#import "NSString+MD5.h"

@interface TCDownloaderManager () <NSCopying, NSMutableCopying>

/// 存放下载信息的字典(key:url, value:下载器)
@property (nonatomic, strong) NSMutableDictionary<NSString*, TCDownloader*> *downloadInfo;

@end

@implementation TCDownloaderManager

#pragma mark - init

static TCDownloaderManager *instance;

+ (instancetype)sharedManager {
    if (!instance) {
        instance = [[self alloc] init];
    }
    
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return instance;
}


#pragma mark - public

- (void)downloadWithURL:(NSURL *)url {
    // 获取下载器
    TCDownloader *downloader = [self getDownloaderWithUrl:url];
    
    // 调用下载器下载
    [downloader downloadWithURL:url];
}

- (void)downloadWithURL:(NSURL *)url
                message:(TCDownloadMessageBlock)messageBlock
               progress:(TCDownloadProgressBlock)progressBlock
                success:(TCDownloadSuccessBlock)successBlock
                failure:(TCDownloadFailureBlock)failureBlock {
    // 获取下载器
    TCDownloader *downloader = [self getDownloaderWithUrl:url];
    
    // 获取key
    NSString *key = [self getUrlMD5KeyWithUrl:url];
    
    // 下载
    [downloader downloadWithURL:url
                        message:messageBlock
                       progress:progressBlock
                        success:^(NSString *downloadedPath) {
                            [self.downloadInfo removeObjectForKey:key];
                            if (successBlock) {
                                successBlock(downloadedPath);
                            }
                        }
                        failure:failureBlock];
}

- (void)pauseWithUrl:(NSURL *)url {
    TCDownloader *downloader = [self getDownloaderWithUrl:url];
    [downloader pause];
}

- (void)pauseAll {
    [self.downloadInfo.allValues performSelector:@selector(pause) withObject:nil withObject:nil];
}


#pragma mark - private

/// 获取下载器
- (TCDownloader *)getDownloaderWithUrl:(NSURL *)url {
    NSString *urlStr = [self getUrlMD5KeyWithUrl:url];
    TCDownloader *downloader = self.downloadInfo[urlStr];
    if (!downloader) {
        downloader = [[TCDownloader alloc] init];
        self.downloadInfo[urlStr] = downloader;
    }
    
    return downloader;
}

/// 获取url key
- (NSString *)getUrlMD5KeyWithUrl:(NSURL *)url {
    return url.absoluteString.md5String;
}


#pragma mark - getter

- (NSMutableDictionary<NSString *,TCDownloader *> *)downloadInfo {
    if (!_downloadInfo) {
        _downloadInfo = [NSMutableDictionary dictionary];
    }
    
    return _downloadInfo;
}

@end
