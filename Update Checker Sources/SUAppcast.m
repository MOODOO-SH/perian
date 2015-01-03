//
//  SUAppcast.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUUtilities.h"
#import "RSS.h"

@interface SUAppcast ()
@property (readwrite, copy) NSArray *items;
@end

@implementation SUAppcast
@synthesize delegate;
@synthesize items;

- (void)fetchAppcastFromURL:(NSURL *)url
{
	// let's not block the main thread
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		@autoreleasepool {
			RSS *feed;
			@try {
				NSString *userAgent = [NSString stringWithFormat: @"%@/%@ (Mac OS X) Sparkle/1.0", SUHostAppName(), SUHostAppVersion()];
				
				feed = [[RSS alloc] initWithURL:url normalize:YES userAgent:userAgent];
				// Set up all the appcast items
				NSMutableArray *tempItems = [NSMutableArray array];
				for (id current in feed.newsItems) {
					[tempItems addObject:[[SUAppcastItem alloc] initWithDictionary:current]];
				}
				self.items = [NSArray arrayWithArray:tempItems];
				
				if ([delegate respondsToSelector:@selector(appcastDidFinishLoading:)])
					[delegate performSelectorOnMainThread:@selector(appcastDidFinishLoading:) withObject:self waitUntilDone:NO];
				
			} @catch (NSException *e) {
				if ([delegate respondsToSelector:@selector(appcastDidFailToLoad:)])
					[delegate performSelectorOnMainThread:@selector(appcastDidFailToLoad:) withObject:self waitUntilDone:NO];
			}
		}
	});
}

- (SUAppcastItem *)newestItem
{
	return items[0]; // the RSS class takes care of sorting by published date, descending.
}

@end
