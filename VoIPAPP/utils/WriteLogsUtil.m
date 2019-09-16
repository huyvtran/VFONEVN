//
//  WriteLogsUtil.m
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "WriteLogsUtil.h"

AppDelegate *writeLogsUtilDelegate;

@implementation WriteLogsUtil

+ (void)startWriteLogsUtil {
    writeLogsUtilDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (void)writeForGoToScreen: (NSString *)screen {
    
    NSString *content = SFM(@"\n\n>>>>>>>>>>>>>>> GO TO SCREEN %@ <<<<<<<<<<<<<<<", screen);
    [self writeLogContent:content];
}

+ (void)writeLogContent: (NSString *)logContent
{
    return;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:writeLogsUtilDelegate.logFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:writeLogsUtilDelegate.logFilePath contents:nil attributes:nil];
    }
    
    NSString *content = [self getLogContentIfExistsFromFile: writeLogsUtilDelegate.logFilePath isFullPath: YES];
    content = SFM(@"%@\n%@: %@", content, [AppUtil getCurrentDateTimeToStringWithLanguage:key_vi], content);
    NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        [data writeToFile:writeLogsUtilDelegate.logFilePath atomically:YES];
    }
}

+ (NSString *)getLogContentIfExistsFromFile: (NSString *)filePath isFullPath: (BOOL)isFullPath{
    if (!isFullPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *url = [paths objectAtIndex:0];
        filePath = SFM(@"%@/%@", url, filePath);
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        return contents;
    }
    return @"";
}

+ (NSString *)makeFilePathWithFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *url = [paths objectAtIndex:0];
    
    NSString *filePath = SFM(@"%@/%@", url, fileName);
    return filePath;
}

+ (NSArray *)getAllFilesInDirectory: (NSString *)subPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent: subPath];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    return directoryContent;
}

+ (void)clearLogFilesAfterExpireTime: (long)expireTime
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pathDir = [documentDir stringByAppendingPathComponent: logsFolderName];
    NSArray *pFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathDir error:NULL];
    for (int count = 0; count < (int)[pFiles count]; count++)
    {
        NSString *filePath = SFM(@"%@/%@", pathDir, [pFiles objectAtIndex: count]);
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate *createdDate = [fileAttribs objectForKey:NSFileCreationDate]; //or NSFileModificationDate
        if (createdDate != nil) {
            NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:createdDate];
            if (secondsBetween >= expireTime) {
                [self removeFileWithPath: filePath];
                NSLog(@"Expire");
            }
        }
    }
}

+ (NSString *)getPathOfFileWithSubDir: (NSString *)subDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *result = [[paths objectAtIndex:0] stringByAppendingPathComponent: subDir];
    return result;
}

+ (void)removeFileWithPath: (NSString *)path {
    // remove file if exist
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath: path];
    if (fileExists) {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (success) {
            NSLog(@"Deleted file of event");
        }
    }
}

+ (void) createDirectory:(NSString*)directory
{
    NSString *path1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:directory];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path1])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path1
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

+ (void) createDirectoryAndSubDirectory:(NSString *)directory
{
    NSString* filePath= @"";
    NSArray* pathcoms= [directory componentsSeparatedByString:@"/"];
    if([pathcoms count]>1)
    {
        for(int i=0;i<[pathcoms count]-1;i++)
        {
            filePath=[filePath stringByAppendingPathComponent:[pathcoms objectAtIndex:i]];
            [self createDirectory:filePath];
        }
    }
    filePath = [filePath stringByAppendingPathComponent:[pathcoms objectAtIndex:[pathcoms count]-1]];
    [self createDirectory:filePath];
}

@end
