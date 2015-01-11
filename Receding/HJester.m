//
//  HJester.m
//  Receding
//
//  Created by matte on 10/14/14.
//  Copyright (c) 2014 MXTTE. All rights reserved.
//

#import "HJester.h"

@implementation HJester

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)load {
    [super load];
    self.gestureRec = @"swipeLR";
    self.name = @"Jester";
    self.xScale = self.yScale = 1.25;
    
    self.texture1 = [SKTexture textureWithImageNamed:@"spiral1"];
    self.texture2 = [SKTexture textureWithImageNamed:@"jester1"];
    self.texture3 = nil;
    [SKTexture preloadTextures:@[self.texture1, self.texture2] withCompletionHandler:^(void){
        [self positionAndRun];
    }];
}


-(void)positionAndRun {
    [super positionAndRun];
    [self removeAllActions];
    
    self.backNode = [[SKSpriteNode node] initWithTexture:self.texture1];
    self.middleNode = [[SKSpriteNode node] initWithTexture:self.texture1];
    self.frontNode = [[SKSpriteNode node] initWithTexture:self.texture2];
    [self idleAnimation];
    self.backNode.xScale = self.backNode.yScale = 3;
    self.middleNode.xScale = self.middleNode.yScale = 2;
    self.frontNode.xScale = self.frontNode.yScale = 1;
    self.backNode.name = self.name;
    self.middleNode.name = self.name;
    self.frontNode.name = self.name;
    self.backNode.alpha = 0.25;
    self.middleNode.alpha = 0.25;
    self.frontNode.alpha = 0;
    
    [self addChild:self.backNode];
    [self addChild:self.middleNode];
    [self addChild:self.frontNode];
    [self recede];
    
    [self.backNode runAction:[SKAction rotateByAngle:-5 duration:self.duration]];
    [self.middleNode runAction:[SKAction rotateByAngle:5 duration:self.duration]];
    
    [self runAction:[SKAction fadeAlphaTo:1 duration:self.duration/8] completion:^(void){
        [self.audioPlayer play];
        [self.frontNode runAction:[SKAction fadeAlphaTo:1 duration:self.duration/8] completion:^(void){
        }];
    }];
}

-(void)handleInteraction:(NSDictionary *)interactionData {
    if (!self.actionLock) {
        self.actionLock = YES;
        [self exitAudioPlayer];
        [self removeAllActions];
        int moveBy = self.parent.scene.view.frame.size.width;
        UISwipeGestureRecognizer *recognizer = [interactionData objectForKey:@"recognizer"];
        if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            moveBy *= -1;
        }
        [self runAction:[SKAction fadeOutWithDuration:0.5]];
        [self.exitPlayer play];
        [self runAction:[SKAction moveTo:CGPointMake(self.position.x + moveBy, self.position.y) duration:0.2]];
        [self runAction:[SKAction scaleTo:0.25 duration:0.2
                         ] completion:^(void){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.exitPlayer = nil;
                self.audioPlayer = nil;
            });
            [self removeAllChildren];
            self.texture1 = nil;
            self.texture2 = nil;
            self.texture3 = nil;
            [self removeFromParent];
        }];
    }
}

- (void)idleAnimation {
    SKAction *slideAction = [SKAction moveToX:((UIScreen.mainScreen.bounds.size.width/10) * -1) duration:0.5];
    slideAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *backAction = [SKAction moveToX:UIScreen.mainScreen.bounds.size.width/10 duration:0.5];
    backAction.timingMode = SKActionTimingEaseInEaseOut;
    [self.frontNode runAction:slideAction completion:^(void){
        [self.frontNode runAction:backAction completion:^(void){
            [self idleAnimation];
        }];
    }];
}

- (void)recede {
    [super recede];
    [self.frontNode runAction:self.scaleAction];
    [self.middleNode runAction:self.scaleAction];
    [self.backNode runAction:self.scaleAction];
}

@end
