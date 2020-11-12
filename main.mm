#import "ac1d.h"

NSArray *commands = [[NSArray alloc] initWithObjects:
    @"home", 
    @"getvol",
    @"dhome",
    @"alert",
    @"say",
    @"setvol",
    @"battery",
    @"state",
    @"location",
    @"player", nil];

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        ac1d *ac1d_base = [[ac1d alloc] init];
        if (argc < 2) printf("Usage: ac1d <option>\n");
        else {
            NSMutableArray *args = [NSMutableArray array];
            for (int i = 0; i < argc; i++) {
                NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
                [args addObject:str];
            }
            if ([args[1] isEqualToString:@"openurl"]) {
                if (argc < 3) printf("Usage: ac1d openurl <url>\n");
                else {
                    [ac1d_base openurl:args[2]];
                }
            } else if ([args[1] isEqualToString:@"openapp"]) {
                if (argc < 3) printf("Usage: ac1d openapp <application>\n");
                else {
                    [ac1d_base openapp:args[2]];
                }
            } else if ([commands containsObject:args[1]]) {
                if ([args[1] isEqualToString:@"alert"]) {
                    if (argc < 4) printf("Usage: ac1d alert <title> <message>\n");
                    else {
                        [ac1d_base send_command:args];
                    }
                } else if ([args[1] isEqualToString:@"player"]) {
                    if (argc < 3) printf("Usage: ac1d player [next|prev|play|pause|info]\n");
                    else {
                        [ac1d_base send_command:args];
                    }
                } else if ([args[1] isEqualToString:@"location"]) {
                    if (argc < 3) printf("Usage: ac1d location [on|off|info]\n");
                    else {
                        [ac1d_base send_command:args];
                    }
                } else if ([args[1] isEqualToString:@"setvol"]) {
                    if (argc < 3) printf("Usage: ac1d setvol <level>\n");
                    else {
                        [ac1d_base send_command:args];
                    }
                } else if ([args[1] isEqualToString:@"say"]) {
                    if (argc < 3) printf("Usage: ac1d say <message>\n");
                    else {
                        [ac1d_base send_command:args];
                    }
                } else {
                    [ac1d_base send_command:args];
                }
            } else printf("Usage: ac1d <option>\n");
        }
    }
    return 0;
}
