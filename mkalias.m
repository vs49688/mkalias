// SPDX-License-Identifier: MIT
#import <Foundation/Foundation.h>

int main(int argc, char **argv)
{
    if(argc != 3) {
        fprintf(stderr, "Usage: %s <source> <target>\n", argv[0]);
        return 2;
    }

    @autoreleasepool {
        NSError *error      = nil;
        NSData  *data       = nil;
        NSURL   *source_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]];
        NSURL   *target_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[2]]];

        printf("%s -> %s\n", [[source_url absoluteString] UTF8String], [[target_url absoluteString] UTF8String]);

        data = [source_url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                    includingResourceValuesForKeys:nil
                                     relativeToURL:nil
                                             error:&error];
        if(error != nil) {
            fprintf(stderr, "Error creating bookmark data: %s\n", [[error localizedDescription] UTF8String]);
            return 1;
        }

        (void)[NSURL writeBookmarkData:data
                                 toURL:target_url
                               options:NSURLBookmarkCreationSuitableForBookmarkFile
                                 error:&error];
        if(error != nil) {
            fprintf(stderr, "Error writing bookmark data: %s\n", [[error localizedDescription] UTF8String]);
            return 1;
        }
    }

    return 0;
}
