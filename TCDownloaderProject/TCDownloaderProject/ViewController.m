//
//  ViewController.m
//  TCDownloaderProject
//
//  Created by TARDIS on 2017-4-24.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import "ViewController.h"
#import "TCDownloaderManager.h"

@interface ViewController ()

@property (nonatomic,strong) TCDownloader *downloader;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    [self timer];
}


#pragma mark - UI


#pragma mark - networking method


#pragma mark - action

//- (void)update {
//    NSLog(@"下载器状态：%ld", (long)self.downloader.state);
//}

- (IBAction)download:(id)sender {
    // 测试URL
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"];
    
    self.downloader.downloadStateChangedBlock = ^(TCDownloaderState state) {
        NSLog(@"下载状态：%zd", state);
    };
    
    [[TCDownloaderManager sharedManager] downloadWithURL:url
                                                 message:^(long long totalSize, NSString *downloadedPath) {
                                                     NSLog(@"下载文件总大小:%lld,下载路径:%@", totalSize, downloadedPath);
                                                 }
                                                progress:^(float progress) {
                                                    NSLog(@"下载进度:%f", progress);
                                                }
                                                 success:^(NSString *downloadedPath) {
                                                     NSLog(@"下载成功");
                                                 }
                                                 failure:^(NSString *errMsg) {
                                                     NSLog(@"下载失败:%@", errMsg);
                                                 }];
    
}

- (IBAction)pause:(id)sender {
    [[TCDownloaderManager sharedManager] pauseAll];
    // 或
    // [[TCDownloaderManager sharedManager] pauseWithUrl:url];
}

- (IBAction)resume:(id)sender {
    [[TCDownloaderManager sharedManager] resumeAll];
}

- (IBAction)cancel:(id)sender {
    [[TCDownloaderManager sharedManager] cancelAll];
}

#pragma mark - getter

- (TCDownloader *)downloader {
    if (!_downloader) {
        _downloader = [[TCDownloader alloc] init];
    }
    
    return _downloader;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
