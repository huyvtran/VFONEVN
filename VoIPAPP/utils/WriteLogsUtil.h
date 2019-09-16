//
//  WriteLogsUtil.h
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WriteLogsUtil : NSObject

+ (void)startWriteLogsUtil;
+ (void)writeForGoToScreen: (NSString *)screen;
+ (void)writeLogContent: (NSString *)logContent;
+ (NSString *)getLogContentIfExistsFromFile: (NSString *)fileName isFullPath: (BOOL)isFullPath;
+ (NSString *)makeFilePathWithFileName:(NSString *)fileName;
+ (NSArray *)getAllFilesInDirectory: (NSString *)subPath;
+ (void)clearLogFilesAfterExpireTime: (long)expireTime;
+ (NSString *)getPathOfFileWithSubDir: (NSString *)subDir;
+ (void)removeFileWithPath: (NSString *)path;
+ (void) createDirectory:(NSString*)directory;
+ (void) createDirectoryAndSubDirectory:(NSString *)directory;

@end

NS_ASSUME_NONNULL_END
