// SPDX-License-Identifier: MIT
#import <Foundation/Foundation.h>

int main(int argc, char **argv)
{
    if(argc < 2 || argc > 3) {
        fprintf(stderr, "Usage: %s <source> [target]\n", argv[0]);
        return 2;
    }

    @autoreleasepool {
        NSError *error      = nil;
        NSData  *data       = nil;
        NSURL   *source_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]];

        // Generate bookmark data for the source URL
        data = [source_url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                    includingResourceValuesForKeys:nil
                                     relativeToURL:nil
                                             error:&error];
        if(error != nil) {
            fprintf(stderr, "Error creating bookmark data: %s\n", [[error localizedDescription] UTF8String]);
            return 1;
        }

        // Check if the target argument is provided
        if(argc == 3) {
            NSURL *target_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[2]]];

            // Write the bookmark data to the target file
            (void)[NSURL writeBookmarkData:data
                                     toURL:target_url
                                   options:NSURLBookmarkCreationSuitableForBookmarkFile
                                     error:&error];
            if(error != nil) {
                fprintf(stderr, "Error writing bookmark data: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else {
            // Print the bookmark data as a hex string if no target is provided
            const unsigned char *bytes = [data bytes];
            NSUInteger length = [data length];
            NSMutableString *hexString = [NSMutableString stringWithCapacity:length * 2];

            for (NSUInteger i = 0; i < length; i++) {
                [hexString appendFormat:@"%02x", bytes[i]];
            }

            printf("%s\n", [hexString UTF8String]);
        }
    }

    return 0;
}
