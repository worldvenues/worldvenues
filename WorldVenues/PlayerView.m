//
//  PlayerView.m
//  Skoobidz
//
//  Created by Yehuda Cohen on 7/24/12.
//  Copyright (c) 2012 KUSC Interactive. All rights reserved.
//

#import "PlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface PlayerView()
{
	NSString *_itemStatusContext;
	
}

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
//@property (nonatomic, strong) NSString *itemStatusContext;
@property (nonatomic, strong) UIView* shieldView;
@property (nonatomic, strong) UIButton* closeButton;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;

@end

@implementation PlayerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code
		self.transform = CGAffineTransformMakeRotation(-M_PI_2);
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(0, 0);
		self.layer.shadowOpacity = 1.0;
		self.layer.shadowRadius	= 40;
		self.opaque = YES;
		
		UIWindow* window = [[UIApplication sharedApplication] keyWindow];
		self.center = window.center;
		self.shieldView = [[UIView alloc] initWithFrame:window.bounds];
		self.shieldView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
		self.shieldView.userInteractionEnabled = YES;
		
		self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.closeButton.frame = CGRectMake(10, 10, 30, 30);
		self.closeButton.userInteractionEnabled = NO;
		[self.closeButton setImage:[UIImage imageNamed:@"VideoCloseButton"] forState:UIControlStateNormal];
		[self addSubview:self.closeButton];

		
		self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
		[self.shieldView addGestureRecognizer:self.tapGestureRecognizer];
		[self addGestureRecognizer:self.tapGestureRecognizer];
		
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

-(void)playWithURL:(NSURL*)fileURL
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
	
	__block PlayerView* myself = self;
	
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
		 // Completion handler block.
         dispatch_async(dispatch_get_main_queue(),
		^{
			self.shieldView.alpha = 0;
			self.alpha = 1;
			UIWindow* window = [[UIApplication sharedApplication] keyWindow];
			[window addSubview:myself.shieldView];
			[window addSubview:myself];
//			[UIView animateWithDuration:0.25 animations:^{
				self.shieldView.alpha = 1;
//			} completion:^(BOOL finished) {
//			}];
			
			NSError *error = nil;
			AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
			
			if (status == AVKeyValueStatusLoaded)
			{
				self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
//				[self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&(_itemStatusContext)];
				[[NSNotificationCenter defaultCenter] addObserver:self
														 selector:@selector(playerItemDidReachEnd:)
															 name:AVPlayerItemDidPlayToEndTimeNotification
														   object:self.playerItem];
				self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
			}
			else
			{
				// TODO: just close the view
				[self removeView];
				NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
			}
			
			// immediately start the video
			[self.player play];
//			[self.player performSelector:@selector(play) withObject:nil afterDelay:5.0];
										
			
		});

		 
     }];
	
}

-(void)removeView
{
	[self.player pause];
    [self.player seekToTime:kCMTimeZero];
	
	self.player = nil;
//	UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
//    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);

	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: &setCategoryError];
	if (setCategoryError) { /* handle the error condition */ }
	

//	[UIView animateWithDuration:0.5 animations:^{
//		self.shieldView.alpha = 0;
//		self.alpha = 0;
//	} completion:^(BOOL finished) {
		[self.shieldView removeFromSuperview];
		[self removeFromSuperview];
//	}];
	
}

/*
 
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
					   context:(void *)context
{
	
    if (context == &_itemStatusContext)
	{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}
*/
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
//	DLog(@"playerItemDidReachEnd");
    [self.player seekToTime:kCMTimeZero];
	
	[self removeView];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)tapAction:(UITapGestureRecognizer*)tapGestureRecognizer
{
	[self removeView];
}

@end


