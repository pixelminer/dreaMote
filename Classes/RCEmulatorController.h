//
//  RCEmulatorController.h
//  dreaMote
//
//  Created by Moritz Venn on 23.07.08.
//  Copyright 2008-2010 Moritz Venn. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @brief Basic Emulated Remote Control.
 
 Generic remote control screen which only needs the rcView to be set up by extending
 classes. Screenshot functionality is already included.
 */
@interface RCEmulatorController : UIViewController <UIScrollViewDelegate>
{
@private
	BOOL _shouldVibrate; /*!< @brief Vibrate as response to successfully sent RC code? */

	UIView *_screenView; /*!< @brief Screenshot View. */
	UIScrollView *_scrollView; /*!< @brief Container of Screenshot View. */
	UIImageView *_imageView; /*!< @brief Actual Screenshot UI Item. */
	UIToolbar *_toolbar; /*!< @brief Toolbar. */
	UIBarButtonItem *_screenshotButton; /*!< @brief Button to quickly change to Screenshot View. */

	NSInteger _screenshotType; /*!< @brief Selected Screenshot type. */
@protected
	IBOutlet UIView *rcView; /*!< @brief Remote Controller view. */
}

/*!
 @brief Actual RC Emulator.
 */
@property (nonatomic,retain) IBOutlet UIView *rcView;

/*!
 @brief Create custom Button.
 
 @param frame Button Frame.
 @param imagePath Path to Button Image.
 @param keyCode RC Code.
 @return UIButton instance.
 */
- (UIButton*)newButton:(CGRect)frame withImage:(NSString*)imagePath andKeyCode:(int)keyCode;

/*!
 @brief Load Image.
 
 @param dummy Unused parameter required by Buttons.
 */
- (void)loadImage:(id)dummy;

/*!
 @brief Flip Views.
 
 @param sender Unused parameter required by Buttons.
 */
- (IBAction)flipView:(id)sender;

/*!
 * @brief Send RC code.
 *
 * @param rcCode Code to send.
 */
- (void)sendButton: (NSNumber *)rcCode;

/*!
 * @brief Button from xib pressed.
 *
 * @param sender Button instance triggering this action.
 */
- (IBAction)buttonPressedIB: (id)sender;

@end
