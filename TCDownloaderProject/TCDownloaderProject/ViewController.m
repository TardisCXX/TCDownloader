//
//  ViewController.m
//  TCDownloaderProject
//
//  Created by TARDIS on 2017-4-24.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import "ViewController.h"
#import "TCDownloader.h"

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
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"];
    //    [self.downloader setDownloadStateChangedBlock:^(TCDownloaderState state){
    //        NSLog(@"state:%zd", state);
    //    }];
    
    self.downloader.downloadStateChangedBlock = ^(TCDownloaderState state) {
        NSLog(@"state:%zd", state);
    };
    
    [self.downloader downloadWithURL:url];
}

- (IBAction)pause:(id)sender {
    [self.downloader pause];
    
}

- (IBAction)resume:(id)sender {
    [self.downloader resume];
}

- (IBAction)cancel:(id)sender {
    [self.downloader cancel];
}

#pragma mark - private


#pragma mark - setter


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
