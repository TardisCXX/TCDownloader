//
//  NSString+MD5.m
//  TCDownloaderProject
//
//  Created by TARDIS on 2017-4-25.
//  Copyright © 2017年 tardis. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)md5String {
    const char *data = self.UTF8String;
    uint32_t len = (CC_LONG)strlen(data);
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, len, buffer);
    
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", buffer[i]];
    }
    
    return md5String.copy;
}

@end
