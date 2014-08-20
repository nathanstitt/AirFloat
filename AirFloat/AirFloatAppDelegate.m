//
//  AirFloatiOSAppDelegate.m
//  AirFloat
//
//  Copyright (c) 2013, Kristian Trenskow All rights reserved.
//
//  Redistribution and use in source and binary forms, with or
//  without modification, are permitted provided that the following
//  conditions are met:
//
//  Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials provided
//  with the distribution. THIS SOFTWARE IS PROVIDED BY THE
//  COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <libairfloat/audioqueue.h>
#import <libairfloat/raopserver.h>

#import "AppViewController.h"

#import "AirFloatAppDelegate.h"

@interface AirFloatAppDelegate () {
    
}

- (void)setSettings;

@end

@implementation AirFloatAppDelegate

@synthesize window=_window;
@synthesize appViewController=_appViewController;
@synthesize server=_server;



- (void)setSettings {
    
    if (self.server) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* password = [defaults objectForKey:@"password"];
        
        raop_server_set_settings(self.server, (struct raop_server_settings_t) { [[defaults objectForKey:@"name"] cStringUsingEncoding:NSASCIIStringEncoding], ([defaults integerForKey:@"authenticationEnabled"] && password && [password length] > 0 ? [password cStringUsingEncoding:NSUTF8StringEncoding] : NULL) });
    }
    
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.appViewController = [[[AppViewController alloc] init] autorelease];
    
    self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    
    
    if ([self.window respondsToSelector:@selector(setRootViewController:)])
        self.window.rootViewController = self.appViewController;
    else {
        self.appViewController.view.frame = CGRectMake(0, 20, 320, 460);
        [self.window addSubview:self.appViewController.view];
    }
     
    
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if (!self.server) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (![[defaults objectForKey:@"firstStart"]isEqualToString:@"F"]) {
            [defaults setObject:@"F" forKey:@"firstStart"];
            [defaults setObject:@"AirFloat" forKey:@"name"];
            [defaults setInteger:0 forKey:@"authenticationEnabled"];
            [defaults setInteger:0 forKey:@"keepScreenLit"];
            [defaults setInteger:0 forKey:@"keepScreenLitOnlyWhenConnectedToPower"];
            [defaults setInteger:0 forKey:@"keepScreenLitOnlyWhenReceiving"];
            [defaults synchronize];
            defaults = [NSUserDefaults standardUserDefaults];
        }
        
        struct raop_server_settings_t settings;
        settings.name = [[defaults objectForKey:@"name"] cStringUsingEncoding:NSUTF8StringEncoding];
        settings.password = ([defaults integerForKey:@"authenticationEnabled"]  ? [[defaults objectForKey:@"password"] cStringUsingEncoding:NSUTF8StringEncoding] : NULL);
        
        self.server = raop_server_create(settings);
        
    }
    
    if (!raop_server_is_running(self.server)) {
        
        uint16_t port = 5000;
        while (port < 5010 && !raop_server_start(_server, port++));
        
        self.appViewController.server = _server;
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if (self.server && !raop_server_is_recording(self.server)) {
        raop_server_stop(self.server);
        raop_server_destroy(self.server);
        self.appViewController.server = self.server = NULL;
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
