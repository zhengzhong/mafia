//
//  Created by ZHENG Zhong on 2015-04-13.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "TSMessages/TSMessage.h"

#import "MafiaGameplay.h"


/*!
 * Additional methods to show a notification in the game.
 *
 * See: https://github.com/KrauseFx/TSMessages
 */
@interface TSMessage (MafiaAdditions)

/*!
 * Shows the message and details from the given information. Message is shown as the title, and
 * details are shown as subtitle. This should be used in judge-driven mode: judge knows everything.
 * @param information  the information to show.
 */
+ (void)mafia_showMessageAndDetailsOfInformation:(MafiaInformation *)information;

/*!
 * Shows the message of the given information (without details). This should be used in autonomic
 * mode: details should be kept secret for all players.
 * @param information  the information containing the message to show.
 * @param subtitle  the subtitle of the message.
 */
+ (void)mafia_showMessageOfInformation:(MafiaInformation *)information
                              subtitle:(NSString *)subtitle;

/*!
 * Shows a notification about the game result. The game must be over and there must be a winner.
 * @param winner  the winner of the game, cannot be MafiaWinnerUnknown.
 */
+ (void)mafia_showGameResultWithWinner:(MafiaWinner)winner;

/*!
 * Shows a normal message.
 * @param title  the title of the message.
 * @param subtitle  the subtitle of the message.
 */
+ (void)mafia_showMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

/*!
 * Shows a success message.
 * @param title  the title of the message.
 * @param subtitle  the subtitle of the message.
 */
+ (void)mafia_showSuccessWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

/*!
 * Shows an error message.
 * @param title  the title of the error message.
 * @param subtitle  the subtitle of the error message.
 */
+ (void)mafia_showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

/*!
 * Shows a notification with default configurations for the game.
 *
 * This method is called by all the other methods.
 */
+ (void)mafia_showNotificationWithTitle:(NSString *)title
                               subtitle:(NSString *)subtitle
                              imageName:(NSString *)imageName
                                   type:(TSMessageNotificationType)type;

@end
