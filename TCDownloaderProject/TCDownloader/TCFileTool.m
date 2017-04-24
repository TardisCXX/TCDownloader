//
//  TCFileTool.m
//  TCDownloaderDemo
//
//  Created by TARDIS on 2017-3-15.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import "TCFileTool.h"

@implementation TCFileTool

+ (BOOL)createDirecoryIfNotExists:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        NSError *error = nil;
        // 第二个参数如果为NO，那么不会关心中间的路径，只会创建末尾的路径
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:path];
}

+ (long long)fileSizeAtPath:(NSString *)path {
    if (![self fileExistsAtPath:path]) {
        return 0;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileInfo = [manager attributesOfItemAtPath:path error:nil];
    
    return [fileInfo[NSFileSize] longLongValue];
}

+ (void)removeFileAtPath:(NSString *)path {
    if (![self fileExistsAtPath:path]) {
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    if (![self fileExistsAtPath:fromPath]) {
        return;
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

@end
