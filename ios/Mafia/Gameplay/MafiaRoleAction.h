//
//  Created by ZHENG Zhong on 2015-04-10.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MafiaAction.h"


/*!
 * Abstract class (class cluster) representing an action for a role. The role property is not nil.
 */
@interface MafiaRoleAction : MafiaAction

/*!
 * Returns the role of this action class. This method must be implemented by subclass.
 */
+ (MafiaRole *)roleOfAction;

/*!
 * Returns a concrete action instance by the role.
 */
+ (instancetype)actionWithRole:(MafiaRole *)role
                        player:(MafiaPlayer *)player
                    playerList:(MafiaPlayerList *)playerList;

@end
