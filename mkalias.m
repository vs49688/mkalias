// SPDX-License-Identifier: MIT
#include <unistd.h>
#import <Foundation/Foundation.h>

typedef enum OutputFormat {
    OUTPUT_FORMAT_HEX    = 0,
    OUTPUT_FORMAT_BINARY = 1,
    OUTPUT_FORMAT_BASE64 = 2,
} OutputFormat;

typedef struct Arguments {
    const char  *source;
    const char  *target;
    int          verbose;
    OutputFormat format;
    int          help;
} Arguments;

static int parse_arguments(Arguments *args, int argc, char **argv)
{
    int c;
    int errflag  = 0;
    int npos     = 0;
    int max_posn = 2;

    *args = (Arguments){
        .source  = NULL,
        .target  = NULL,
        .verbose = 0,
        .format  = OUTPUT_FORMAT_HEX,
        .help    = 0,
    };

    while((c = getopt(argc, argv, "vf:hV")) != -1) {
        switch(c) {
            case 'v':
                ++args->verbose;
                break;
            case 'f':
                if(strcmp(optarg, "bin") == 0) {
                    args->format = OUTPUT_FORMAT_BINARY;
                } else if(strcmp(optarg, "hex") == 0) {
                    args->format = OUTPUT_FORMAT_HEX;
                } else if(strcmp(optarg, "base64") == 0) {
                    args->format = OUTPUT_FORMAT_BASE64;
                } else {
                    fprintf(stderr, "Invalid '-f' value: %s\n", optarg);
                    ++errflag;
                }
                break;
            case 'h':
                args->help = 1;
                max_posn   = 0;
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

    if(npos > max_posn)
        return -1;

    if(max_posn > 0) {
        if(args->source == NULL)
            return -1;
    }

    return 0;
}

NSData *format_data(NSData *data, OutputFormat format)
{
    switch(format) {
        case OUTPUT_FORMAT_BINARY:
            return data;
        case OUTPUT_FORMAT_BASE64:
            return [data base64EncodedDataWithOptions:0];
        case OUTPUT_FORMAT_HEX: {
            const char    *alphabet = "0123456789abcdef";
            const uint8_t *inb      = [data bytes];

            NSMutableData *nd   = [NSMutableData dataWithLength:[data length] * 2];
            uint8_t       *outb = [nd mutableBytes];

            for(NSUInteger i = 0; i < [data length]; ++i, outb += 2) {
                outb[0] = alphabet[(inb[i] & 0xF0) >> 4];
                outb[1] = alphabet[(inb[i] & 0x0F) >> 0];
            }
            return nd;
        }

        default:
            break;
    }

    return NULL;
}

static void print_usage(const char *argv0)
{
    fprintf(stderr, "Usage: %s [-v] <source_file> <target_file>\n", argv0);
    fprintf(stderr, "       %s [-v] [-f bin|hex|base64] <source_file>\n", argv0);
    fprintf(stderr, "       %s -h\n", argv0);
}

int main(int argc, char **argv)
{
    Arguments args;

    if(parse_arguments(&args, argc, argv) < 0) {
        print_usage(argv[0]);
        return 2;
    }

    if(args.help) {
        print_usage(argv[0]);
        return 0;
    }

    @autoreleasepool {
        NSError *error      = nil;
        NSData  *data       = nil;
        NSURL   *source_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:args.source]];

        data = [source_url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                    includingResourceValuesForKeys:nil
                                     relativeToURL:nil
                                             error:&error];
        if(error != nil) {
            fprintf(stderr, "Error creating bookmark data: %s\n", [[error localizedDescription] UTF8String]);
            return 1;
        }

        /*
         * If a target file is specified, write the alias.
         * Otherwise, we dump the data in the given format to stdout. Some tools can use this.
         */
        if(args.target != NULL) {
            NSURL *target_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:args.target]];

            if(args.verbose) {
                fprintf(stderr, "%s -> %s\n", [[source_url absoluteString] UTF8String],
                        [[target_url absoluteString] UTF8String]);
            }

            (void)[NSURL writeBookmarkData:data
                                     toURL:target_url
                                   options:NSURLBookmarkCreationSuitableForBookmarkFile
                                     error:&error];
            if(error != nil) {
                fprintf(stderr, "Error writing bookmark data: %s\n", [[error localizedDescription] UTF8String]);
                return 1;
            }
        } else {
            NSData *d = format_data(data, args.format);

            /* Potentially slow, but stdout should be buffered. */
            fwrite([d bytes], [d length], 1, stdout);

            if(isatty(fileno(stdout))) {
                fputc('\n', stdout);
            }
        }
    }

    return 0;
}
