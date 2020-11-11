#import <AppSupport/CPDistributedMessagingCenter.h>
#import <UIKit/UIAlertView.h>

#import "mediaremote.h"
#import "ac1d.h"

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.ac1d"];
    [messagingCenter runServerOnCurrentThread];
    [messagingCenter registerForMessageName:@"commandWithNoReply" target:self selector:@selector(commandWithNoReply:withUserInfo:)];
    [messagingCenter registerForMessageName:@"commandWithReply" target:self selector:@selector(commandWithReply:withUserInfo:)];
}

%new
- (NSDictionary *)recieve_command:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
    NSString *command = [userInfo objectForKey:@"cmd"];
    NSString *argument1 = [userInfo objectForKey:@"arg1"];
    NSString *argument2 = [userInfo objectForKey:@"arg2"];
    if ([command isEqual:@"state"]) {
	if ([(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] isUILocked]) return [NSDictionary dictionaryWithObject:@"locked" forKey:@"returnStatus"];
	return [NSDictionary dictionaryWithObject:@"unlocked" forKey:@"returnStatus"];
    } else if ([command isEqual:@"player"]) {
    	if ([argument1 isEqual:@"info"]) {
	    NSString *result = [NSString stringWithFormat:@"Name: %@\nAlbum: %@\nArtist: %@", kMRMediaRemoteNowPlayingInfoTitle, kMRMediaRemoteNowPlayingInfoAlbum, kMRMediaRemoteNowPlayingInfoAuthor];
	    return [NSDictionary dictionaryWithObject:result forKey:@"returnStatus"];
	} else if ([argument1 isEqual:@"play"]) {
	    MRMediaRemoteSendCommand(kMRPlay, nil);
	    return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
	} else if ([argument1 isEqual:@"pause"]) {
	    MRMediaRemoteSendCommand(kMRPause, nil);
	    return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
	} else if ([argument1 isEqual:@"next"]) {
	    MRMediaRemoteSendCommand(kMRNextTrack, nil);
	    return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
	} else if ([argument1 isEqual:@"prev"]) {
	    MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
	    return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
	}
    } else if ([command isEqual:@"location"]) {
    	if ([argument1 isEqual:@"info"]) {
	    return [NSDictionary dictionaryWithObject:"test!" forKey:@"returnStatus"];
	} else if ([argument1 isEqual:@"on"]) {
	    [%c(CLLocationManager) setLocationServicesEnabled:true];
	    return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
	} else if ([argument1 isEqual:@"off"]) {
	    [%c(CLLocationManager) setLocationServicesEnabled:false];
	    return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
	}
    } else if ([command isEqual:@"home"]) {
	if ([(SBUIController *)[%c(SBUIController) sharedInstance] respondsToSelector:@selector(handleHomeButtonSinglePressUp)]) {
	    [(SBUIController *)[%c(SBUIController) sharedInstance] handleHomeButtonSinglePressUp];
	} else if ([(SBUIController *)[%c(SBUIController) sharedInstance] respondsToSelector:@selector(clickedMenuButton)]) {
	    [(SBUIController *)[%c(SBUIController) sharedInstance] clickedMenuButton];
        }
    } else if ([command isEqual:@"dhome"]) {
	if ([(SBUIController *)[%c(SBUIController) sharedInstance] respondsToSelector:@selector(handleHomeButtonDoublePressDown)]) {
	    [(SBUIController *)[%c(SBUIController) sharedInstance] handleHomeButtonDoublePressDown];
        } else if ([(SBUIController *)[%c(SBUIController) sharedInstance] respondsToSelector:@selector(handleMenuDoubleTap)]) {
	    [(SBUIController *)[%c(SBUIController) sharedInstance] handleMenuDoubleTap];
	}
	return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
    } else if ([command isEqual:@"alert"]) {
    	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:argument1 message:argument2 delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	return [NSDictionary dictionaryWithObject:"" forKey:@"returnStatus"];
    }
    return [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"returnStatus"];
}
%end
