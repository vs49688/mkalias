// SPDX-License-Identifier: MIT
#include <unistd.h>
#import <Foundation/Foundation.h>

typedef struct Arguments {
    const char *source;
    const char *target;
    int         verbose;
} Arguments;

static int parse_arguments(Arguments *args, int argc, char **argv)
{
    int c;
    int errflag = 0;
    int npos    = 0;

    *args = (Arguments){
        .source  = NULL,
        .target  = NULL,
        .verbose = 0,
    };

    while((c = getopt(argc, argv, "v")) != -1) {
        switch(c) {
            case 'v':
                ++args->verbose;
                break;
            case '?':
            case ':':
                ++errflag;
            default:
                break;
        }
    }

    if(errflag > 0)
        return -1;

    for(; optind < argc; ++optind, ++npos) {
        if(npos == 0)
            args->source = argv[optind];
        else if(npos == 1)
            args->target = argv[optind];
    }

    if(npos != 2)
        return -1;

    return 0;
}

int main(int argc, char **argv)
{
    Arguments args;

    if(parse_arguments(&args, argc, argv) < 0) {
        fprintf(stderr, "Usage: %s [-v] <source_file> <target_file>\n", argv[0]);
        return 2;
    }

    @autoreleasepool {
        NSError *error      = nil;
        NSData  *data       = nil;
        NSURL   *source_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:args.source]];
        NSURL   *target_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:args.target]];

        if(args.verbose) {
            fprintf(stderr, "%s -> %s\n", [[source_url absoluteString] UTF8String], [[target_url absoluteString] UTF8String]);
        }

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
