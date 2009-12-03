//
//  ODGridItemView.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/12/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "ODGridItemView.h"

#define NameLabelFontSize 14.0
#define ImageWidth 150.0
#define ImageHeight 150.0
#define ImageLabelDiff 5.0

@implementation ODGridItemView

@synthesize selectedImage=_selectedImage;
@synthesize image=_image;
@synthesize index=_index;

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Initialization code
	self.backgroundColor = [UIColor clearColor];
}

+ (id)gridItem
{
	ODGridItemView *item = [[[ODGridItemView alloc]initWithFrame:CGRectZero]autorelease];
	return item;
}

- (UILabel *)nameLabel
{
	if (!_nameLabel) {
		_nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_nameLabel.font = [UIFont boldSystemFontOfSize:NameLabelFontSize];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.highlightedTextColor = [UIColor whiteColor];
		_nameLabel.numberOfLines = 0;
		_nameLabel.textAlignment = UITextAlignmentCenter;
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_nameLabel];
	}
	return _nameLabel;
}

- (UIImageView *)imageView
{
	if (!_imageView) {
		_imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
	}
	return _imageView;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Get the frame where you can place your subviews
	CGRect rect = self.bounds;
	
	NSInteger difference = (self.bounds.size.width - ImageWidth) / 2;
	
	// Place the image view
	if (_imageView) {
		self.imageView.frame = CGRectIntegral(CGRectMake(rect.origin.x + difference, 
														 rect.origin.y + difference, 
														 ImageWidth, 
														 ImageHeight));
	}
	
	if (_nameLabel) {
		self.nameLabel.frame = CGRectIntegral(CGRectMake(rect.origin.x + difference, 
														 rect.origin.y + difference  + ImageHeight + ImageLabelDiff, 
														 ImageWidth, 
														 (NameLabelFontSize + 4.0) * 2.0));
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	if (self.selectedImage) {
		self.imageView.image = self.selectedImage;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	if (self.image) {
		self.imageView.image = self.image;
	}
}




- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[_image release];
	[_selectedImage release];
	[_imageView release];
	[_nameLabel release];
	
    [super dealloc];
}

@end
