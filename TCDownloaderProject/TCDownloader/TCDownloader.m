//
//  TCDownloader.m
//  TCDownloaderDemo
//
//  Created by TARDIS on 2015-3-15.
//  Copyright © 2015年 tardis. All rights reserved.
//

#import "TCDownloader.h"
#import "TCFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface TCDownloader () <NSURLSessionDataDelegate> {
    
    /// 文件临时大小
    long long _fileTmpSize;
    /// 文件总大小
    long long _totalSize;
    
}

/// 下载完成后转移文件的路径
@property (nonatomic,copy) NSString *downloadedFilePath;
/// 下载时接收文件路径
@property (nonatomic,copy) NSString *downloadingFilePath;
/// session
@property (nonatomic,strong) NSURLSession *session;
/// 输出流
@property (nonatomic,strong) NSOutputStream *stream;
/// 任务
@property (nonatomic,weak) NSURLSessionDataTask *task;


@end

@implementation TCDownloader


#pragma mark - public

- (void)cancel {
    // 取消所有的请求，并且会销毁资源
    self.state = TCDownloaderStateFailure;
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)pause {
    if (self.state == TCDownloaderStateDownloading) {
        [self.task suspend];
        self.state = TCDownloaderStatePause;
    }
    
}

- (void)resume {
    if ((self.task && self.state == TCDownloaderStatePause) || self.state == TCDownloaderStateFailure) {
        [self.task resume];
        self.state = TCDownloaderStateDownloading;
    }
    
}

- (void)cancelAndClean {
    [self cancel];
    [TCFileTool removeFileAtPath:self.downloadingFilePath];
}

/// 下载方法内部，涵盖了继续下载的动作
- (void)downloadWithURL:(NSURL *)url {
    // 0. 存储机制
    // 下载完成 cache/downloader/downloaded/url.lastCompent
    // 下载中 cache/downloader/downloading/url.lastCompent
    self.downloadedFilePath = [self.downloadedPath stringByAppendingPathComponent:url.lastPathComponent];
    self.downloadingFilePath = [self.downloadingPath stringByAppendingPathComponent:url.lastPathComponent];
    
    // 容错处理，判断任务是否已经存在
    if ([url isEqual:self.task.originalRequest.URL]) {
        // 任务存在，判断下载状态
        if (self.state == TCDownloaderStatePause) {
            [self resume];
            return;
        }
        
        if (self.state == TCDownloaderStateDownloading) {
            return;
        }
        
        if (self.state == TCDownloaderStateSuccess) {
            NSLog(@"告知外界，下载完成");
            
            if (self.downloadSuccessBlock) {
                self.downloadSuccessBlock(self.downloadedFilePath);
            }
            return;
        }
    }
    
    // 状态为TCDownloaderStateFailure就走以下下载代码

    
    // 1. 判断当前url对应的资源是否已经下载完毕，如果已经下载完毕，直接返回
    // 1.1 通过一些辅助信息，去记录哪些文件已经下载完毕（额外维护信息文件）
    // 1.2 下载完成的路径和临时下载的文件路径分离
    if ([TCFileTool fileExistsAtPath:self.downloadedFilePath]) {
        NSLog(@"当前资源已经下载完毕");
        
        if (self.downloadSuccessBlock) {
            self.downloadSuccessBlock(self.downloadedFilePath);
        }
        
        return;
    }
    
    // 2. 检测，本地有没有下载过临时缓存
    // 2.1 没有本地缓存，从0字节开始下载（断点下载 http, range "bytes=开始-"）
    if (![TCFileTool fileExistsAtPath:self.downloadingFilePath]) {
        [self downloadWithURL:url offset:_fileTmpSize];
        return;
    }
    
    // 当使用NSURLSession时 判断放在了其代理里面
    // 2.2 获取本地缓存的大小ls ：文件真正正确的总大小rs
    // 2.2.1 ls < rs => 直接接着下载ls
    // 2.2.2 ls == rs => 移动到下载完成文件夹
    // 2.2.3 ls > rs => 删除本地临时缓存，从0开始下载
    // 取消所有下载操作
    [self cancel];
    _fileTmpSize = [TCFileTool fileSizeAtPath:self.downloadingFilePath];
    [self downloadWithURL:url offset:_fileTmpSize];
}

- (void)downloadWithURL:(NSURL *)url message:(TCDownloadMessageBlock)messageBlock progress:(TCDownloadProgressBlock)progressBlock success:(TCDownloadSuccessBlock)successBlock failure:(TCDownloadFailureBlock)failureBlock {
    self.downloadMessageBlock = messageBlock;
    self.downloadProgressBlock = progressBlock;
    self.downloadSuccessBlock = successBlock;
    self.downloadFailureBlock = failureBlock;
    
    // 执行下载
    [self downloadWithURL:url];
}

#pragma mark - action



#pragma mark - private

/// 从偏移量offset处开始继续下载
- (void)downloadWithURL:(NSURL *)url offset:(long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0]; // 0表示不限时间，如果有时间，那么就是在这个时间内下载，否则就没了
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:request];
//    [self.task resume];
    [self resume];
}

#pragma mark - NSURLSessionDataDelegate


/**
 第一次接收到下载信息 响应头信息的时候调用

 @param session             会话
 @param dataTask            任务
 @param response            响应头
 @param completionHandler   系统回调，可以通过这个回调，传递不同的参数，来决定是否需要继续接收后续数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"%@", response);
    // 2.2 获取本地缓存的大小ls ：文件真正正确的总大小rs
    // 2.2.1 ls < rs => 直接接着下载ls
    // 2.2.2 ls == rs => 移动到下载完成文件夹
    // 2.2.3 ls > rs => 删除本地临时缓存，从0开始下载
    
    // 本地大小
    
    // 总大小
    // "bytes 0-21574061/21574062"
    NSString *rangeStr = response.allHeaderFields[@"Content-Range"];
    _totalSize = [[rangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    
    if (_fileTmpSize == _totalSize) {
        // 大小相等，不一定代表文件完整正确
        // 验证文件的完整性 -> 移动操作
        NSLog(@"下载完成，执行移动操作");
        [TCFileTool moveFileFromPath:self.downloadingFilePath toPath:self.downloadedFilePath];
        completionHandler(NSURLSessionResponseCancel);
        
        if (self.downloadSuccessBlock) {
            self.downloadSuccessBlock(self.downloadedFilePath);
        }
        
        return;
    }
    
    if (_fileTmpSize > _totalSize) {
        NSLog(@"清除本地缓存，然后从0开始下载，并且取消本次请求");
        // 清除本地缓存
        [TCFileTool removeFileAtPath:self.downloadingFilePath];
        // 取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        // 从0开始下载
        [self downloadWithURL:response.URL];
        
        return;
    }
    
    if (self.downloadMessageBlock) {
        self.downloadMessageBlock(_totalSize, self.downloadedFilePath);
    }
    
    // _fileTmpSize < totalSize
    // NSLog(@"继续接收数据");
    
    // 创建文件输出流
    // append 意思是是否是以追加的形式
    self.stream = [NSOutputStream outputStreamToFileAtPath:self.downloadingFilePath append:YES];
    // 打开输出流（就像打开管子）
    [self.stream open];
    
    // NSURLSessionResponseCancel 表示任务取消，不再接收数据
    // NSURLSessionResponseAllow 表示任务继续，继续接收数据
    completionHandler(NSURLSessionResponseAllow);
}


/**
 如果可以接收后续数据，那么在接收的过程中，就会调用这个方法

 @param session     会话
 @param dataTask    任务
 @param data        接收到的数据，一段
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 追加临时文件大小
    _fileTmpSize += data.length;
    
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock((float)_fileTmpSize / _totalSize);
    }
    
    [self.stream write:data.bytes maxLength:data.length];
}


/**
 请求完毕 ！= 下载完毕

 @param session     会话
 @param task        任务
 @param error       错误
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        // 开始字节 - 最后
        NSLog(@"本次请求完成");
        // 为了严谨，再次验证
        // 应该还有文件完整性验证(暂时不做，因为需要服务器配置)
        if (_fileTmpSize == _totalSize) {
            // 移动文件夹
            [TCFileTool moveFileFromPath:self.downloadingFilePath toPath:self.downloadedFilePath];
            self.state = TCDownloaderStateSuccess;
            
            if (self.downloadSuccessBlock) {
                self.downloadSuccessBlock(self.downloadedFilePath);
            }
        }
    } else {
        NSLog(@"有错误--%@ ---code:%zd", error, error.code);
        self.state = TCDownloaderStateFailure;
        
        if (self.downloadFailureBlock) {
            self.downloadFailureBlock(error.localizedDescription);
        }
    }
}

#pragma mark - setter

- (void)setState:(TCDownloaderState)state {
    _state = state;
    
    if (self.downloadStateChangedBlock) {
        self.downloadStateChangedBlock(_state);
    }
}

#pragma mark - getter

// 获得正在下载路径
- (NSString *)downloadingPath {
    NSString *path = [kCachePath stringByAppendingPathComponent:@"downloader/downloading"];
    BOOL res = [TCFileTool createDirecoryIfNotExists:path];
    if (res) {
        return path;
    }
    
    return @"";
}

// 获得已下载完成路径
- (NSString *)downloadedPath {
    NSString *path = [kCachePath stringByAppendingPathComponent:@"downloader/downloaded"];
    BOOL res = [TCFileTool createDirecoryIfNotExists:path];
    if (res) {
        return path;
    }
    
    return @"";
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    
    return _session;
}



@end
