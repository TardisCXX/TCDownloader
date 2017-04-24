//
//  TCFileTool.h
//  TCDownloaderDemo
//
//  Created by TARDIS on 2017-3-15.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCFileTool : NSObject

/// 判断path是否存在，不存在就创建
+ (BOOL)createDirecoryIfNotExists:(NSString *)path;

/// 判断path下文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path;

/// 计算path下文件大小
+ (long long)fileSizeAtPath:(NSString *)path;

/// 删除path下的文件
+ (void)removeFileAtPath:(NSString *)path;

+ (void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

@end
