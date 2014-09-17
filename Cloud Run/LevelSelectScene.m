//
//  LevelSelectScene.m
//  Cloud Run
//
//  Created by John Goure on 6/21/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import "LevelSelectScene.h"
#import "Level1.h"
#import "Level2.h"
#import "Level3.h"
#import "Level4.h"
#import "MenuScene.h"
#import "GameData.h"

static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static const float BG_POINTS_PER_SEC = 10;

@implementation LevelSelectScene
{
    SKSpriteNode* levelButton1, *levelButton2, *levelButton3, *levelButton4;
    SKSpriteNode* menuButton;
    SKSpriteNode* title;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    SKNode *_bgLayer;
    SKNode *_buttonLayer;
    
    SKAction* _swooshSound;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _swooshSound = [SKAction playSoundFileNamed:@"swooshSound.wav" waitForCompletion:NO];
        
        _bgLayer = [SKNode node];
        _buttonLayer = [SKNode node];
        [self addChild:_bgLayer];
        [self addChild:_buttonLayer];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        [self setupBackground];
        [self setupUI];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:location];
        NSLog(@"%@",n.name);
        if ([n.name isEqualToString:@"levelButton1"]) {
            [levelButton1 runAction:[SKAction scaleTo:.9 duration:.05]];
            
        }
        else if ([n.name isEqualToString:@"levelButton2"]) {
            [levelButton2 runAction:[SKAction scaleTo:.9 duration:.05]];
        }
        else if ([n.name isEqualToString:@"levelButton3"]) {
            [levelButton3 runAction:[SKAction scaleTo:.9 duration:.05]];
        }
        else if ([n.name isEqualToString:@"levelButton4"]) {
            [levelButton4 runAction:[SKAction scaleTo:.9 duration:.05]];
        }
        else if ([n.name isEqualToString:@"menuButton"]) {
            [menuButton runAction:[SKAction scaleTo:.45 duration:0.05]];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode * n = [self nodeAtPoint:location];
        [self playSwooshSound];
        
        if ([n.name isEqualToString:@"levelButton1"]) {
            [levelButton1 runAction:[SKAction scaleTo:1 duration:.05]];
            [self changeToLevel1];
        } else if ([n.name isEqualToString:@"levelButton2"]) {
            [levelButton2 runAction:[SKAction scaleTo:1 duration:.05]];
            [self changeToLevel2];
        }else if ([n.name isEqualToString:@"levelButton3"]) {
            [levelButton3 runAction:[SKAction scaleTo:1 duration:.05]];
            [self changeToLevel3];
        }else if ([n.name isEqualToString:@"levelButton4"]) {
            [levelButton4 runAction:[SKAction scaleTo:1 duration:.05]];
            [self changeToLevel4];
        }
        else if ([n.name isEqualToString:@"menuButton"]) {
            [menuButton runAction:[SKAction scaleTo:.47 duration:0.05]];
            [self loadMenuScene];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    //[self backgroundScroll];
}

- (void)setupBackground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode * bg =
        [SKSpriteNode spriteNodeWithImageNamed:@"clouds"];
        bg.scale = 0.5;
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.name = @"bg";
        [_bgLayer addChild:bg];
    }
}

- (void)setupUI {
    title = [SKSpriteNode spriteNodeWithImageNamed:@"levelSelect"];
    menuButton = [SKSpriteNode spriteNodeWithImageNamed:@"menuButton.png"];
    levelButton1 = [SKSpriteNode spriteNodeWithImageNamed:@"cloudButton1.png"];
    levelButton2 = [SKSpriteNode spriteNodeWithImageNamed:@"cloudButton2.png"];
    levelButton3 = [SKSpriteNode spriteNodeWithImageNamed:@"cloudButton3.png"];
    levelButton4 = [SKSpriteNode spriteNodeWithImageNamed:@"cloudButton4.png"];
    
    title.name = @"title";
    title.scale = .70;
    title.position = CGPointMake(self.size.width + title.size.width, self.size.height - 70);
    
    menuButton.name = @"menuButton";
    menuButton.scale = .52;
    menuButton.position = CGPointMake(-self.size.width - menuButton.size.width, self.size.height - menuButton.size.height);
    
    levelButton1.name = @"levelButton1";
    levelButton1.position = CGPointMake(-self.size.width / 2, self.size.height - 120);
    levelButton1.scale = 0.5;
    
    levelButton2.position = CGPointMake(-self.size.width / 2, levelButton1.position.y - 90);
    levelButton2.scale = 0.5;
    
    levelButton3.position = CGPointMake(-self.size.width /2, levelButton2.position.y - 90);
    levelButton3.scale = 0.5;
    
    levelButton4.position = CGPointMake(-self.size.width / 2, levelButton3.position.y - 90);
    levelButton4.scale = 0.5;
    
    if ([GameData sharedGameData].level1Beat == NO) {
        levelButton2.color = [SKColor blackColor];
        levelButton2.colorBlendFactor = 0.7;
        levelButton2.userInteractionEnabled = YES;
    }
    if ([GameData sharedGameData].level2Beat == NO) {
        levelButton3.color = [SKColor blackColor];
        levelButton3.colorBlendFactor = 0.7;
        levelButton3.userInteractionEnabled = YES;
    }
    
    if ([GameData sharedGameData].level3Beat == NO) {
        levelButton4.color = [SKColor blackColor];
        levelButton4.colorBlendFactor = 0.7;
        levelButton4.userInteractionEnabled = YES;
    }
    
    
    SKAction *titleMoveIntoScene = [SKAction moveTo:CGPointMake(self.size.width / 2, self.size.height -  70) duration:.8];
    SKAction *playButtonMoveIntoScene = [SKAction moveToX:self.size.width /2 duration:1];
    SKAction *menuButtonReveal = [SKAction moveTo:CGPointMake(40, self.size.height - menuButton.size.height) duration:1.4];
    
    [self addChild:title];
    [_buttonLayer addChild:levelButton1];
    [_buttonLayer addChild:menuButton];
    [_buttonLayer addChild:levelButton2];
    [_buttonLayer addChild:levelButton3];
    [_buttonLayer addChild:levelButton4];
    [title runAction:titleMoveIntoScene];
    [menuButton runAction:menuButtonReveal];
    [levelButton1 runAction:[SKAction sequence:@[playButtonMoveIntoScene,[SKAction repeatActionForever:self.buttonBounce]]]];
    
    if ([GameData sharedGameData].level1Beat == NO) {
        [levelButton2 runAction:playButtonMoveIntoScene];
    } else {
        [levelButton2 runAction:[SKAction sequence:@[playButtonMoveIntoScene,[SKAction repeatActionForever:self.buttonBounce]]]];
        levelButton2.userInteractionEnabled = NO;
        levelButton2.name = @"levelButton2";
    }
    
    if ([GameData sharedGameData].level2Beat == NO) {
        [levelButton3 runAction:playButtonMoveIntoScene];
    } else {
        [levelButton3 runAction:[SKAction sequence:@[playButtonMoveIntoScene,[SKAction repeatActionForever:self.buttonBounce]]]];
        levelButton3.userInteractionEnabled = NO;
        levelButton3.name = @"levelButton3";
    }
    
    if ([GameData sharedGameData].level3Beat == NO) {
        [levelButton4 runAction:playButtonMoveIntoScene];
    } else {
        [levelButton4 runAction:[SKAction sequence:@[playButtonMoveIntoScene,[SKAction repeatActionForever:self.buttonBounce]]]];
        levelButton4.userInteractionEnabled = NO;
        levelButton4.name = @"levelButton4";
    }
    
    
}

-(SKAction*)buttonBounce {
    SKAction *scale = [SKAction scaleTo:0.47 duration:.13];
    SKAction *scaleStretch = [SKAction scaleTo:0.52 duration:.1];
    SKAction *scaleNormal = [SKAction scaleTo:0.5 duration:.1];
    SKAction *wait = [SKAction waitForDuration:2.4];
    SKAction *sequence = [SKAction sequence:@[scale, scaleStretch,scaleNormal, wait]];
    return sequence;
}

- (void)backgroundScroll {
    CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
    _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);
    
    [_bgLayer enumerateChildNodesWithName:@"bg"
                               usingBlock:^(SKNode *node, BOOL *stop){
                                   SKSpriteNode * bg = (SKSpriteNode *) node;
                                   CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position
                                                                         toNode:self];
                                   if (bgScreenPos.x <= -bg.size.width) {
                                       bg.position = CGPointMake(bg.position.x+bg.size.width*2,
                                                                 bg.position.y);
                                   }
                               }];
    
}

- (void)changeToLevel1 {
    SKAction *titleMoveOutScene = [SKAction moveTo:CGPointMake(self.size.width + title.size.width, self.size.height -  70) duration:1];
    SKAction *playButtonMoveOutScene = [SKAction moveTo:CGPointMake(-self.size.width - levelButton1.size.width, self.size.height/ 2) duration:.7];
    SKAction *menuButtonLeaveScene = [SKAction moveTo:CGPointMake(-self.size.width - menuButton.size.width, self.size.height - menuButton.size.height) duration:1.4];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
    SKAction *runMan = [SKAction runBlock:^ {
        SKScene *level1 = [[Level1 alloc] initWithSize:self.size];
        [self.view presentScene:level1 transition:reveal];
    }];
    
    [levelButton1 runAction:playButtonMoveOutScene];
    [levelButton2 runAction:playButtonMoveOutScene];
    [levelButton3 runAction:playButtonMoveOutScene];
    [levelButton4 runAction:playButtonMoveOutScene];
    [menuButton runAction:menuButtonLeaveScene];
    [title runAction:[SKAction sequence:@[titleMoveOutScene, runMan]]];
    
}

- (void)changeToLevel2 {
    SKAction *titleMoveOutScene = [SKAction moveTo:CGPointMake(self.size.width + title.size.width, self.size.height -  70) duration:1];
    SKAction *playButtonMoveOutScene = [SKAction moveTo:CGPointMake(-self.size.width - levelButton1.size.width, self.size.height/ 2) duration:.7];
    SKAction *menuButtonLeaveScene = [SKAction moveTo:CGPointMake(-self.size.width - menuButton.size.width, self.size.height - menuButton.size.height) duration:1.4];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
    SKAction *runMan = [SKAction runBlock:^ {
        SKScene *level = [[Level2 alloc] initWithSize:self.size];
        [self.view presentScene:level transition:reveal];
    }];
    
    [levelButton1 runAction:playButtonMoveOutScene];
    [levelButton2 runAction:playButtonMoveOutScene];
    [levelButton3 runAction:playButtonMoveOutScene];
    [levelButton4 runAction:playButtonMoveOutScene];
    [menuButton runAction:menuButtonLeaveScene];
    [title runAction:[SKAction sequence:@[titleMoveOutScene, runMan]]];
    
}

- (void)changeToLevel3 {
    SKAction *titleMoveOutScene = [SKAction moveTo:CGPointMake(self.size.width + title.size.width, self.size.height -  70) duration:1];
    SKAction *playButtonMoveOutScene = [SKAction moveTo:CGPointMake(-self.size.width - levelButton1.size.width, self.size.height/ 2) duration:.7];
    SKAction *menuButtonLeaveScene = [SKAction moveTo:CGPointMake(-self.size.width - menuButton.size.width, self.size.height - menuButton.size.height) duration:1.4];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
    SKAction *runMan = [SKAction runBlock:^ {
        SKScene *level = [[Level3 alloc] initWithSize:self.size];
        [self.view presentScene:level transition:reveal];
    }];
    
    [levelButton1 runAction:playButtonMoveOutScene];
    [levelButton2 runAction:playButtonMoveOutScene];
    [levelButton3 runAction:playButtonMoveOutScene];
    [levelButton4 runAction:playButtonMoveOutScene];
    [menuButton runAction:menuButtonLeaveScene];
    [title runAction:[SKAction sequence:@[titleMoveOutScene, runMan]]];
    
}

- (void)changeToLevel4 {
    SKAction *titleMoveOutScene = [SKAction moveTo:CGPointMake(self.size.width + title.size.width, self.size.height -  70) duration:1];
    SKAction *playButtonMoveOutScene = [SKAction moveTo:CGPointMake(-self.size.width - levelButton1.size.width, self.size.height/ 2) duration:.7];
    SKAction *menuButtonLeaveScene = [SKAction moveTo:CGPointMake(-self.size.width - menuButton.size.width, self.size.height - menuButton.size.height) duration:1.4];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
    SKAction *runMan = [SKAction runBlock:^ {
        SKScene *level = [[Level4 alloc] initWithSize:self.size];
        [self.view presentScene:level transition:reveal];
    }];
    
    [levelButton1 runAction:playButtonMoveOutScene];
    [levelButton2 runAction:playButtonMoveOutScene];
    [levelButton3 runAction:playButtonMoveOutScene];
    [levelButton4 runAction:playButtonMoveOutScene];
    [menuButton runAction:menuButtonLeaveScene];
    [title runAction:[SKAction sequence:@[titleMoveOutScene, runMan]]];
    
}

- (void)loadMenuScene {
    SKAction *titleMoveOutScene = [SKAction moveTo:CGPointMake(self.size.width + title.size.width, self.size.height -  70) duration:1];
    SKAction *playButtonMoveOutScene = [SKAction moveTo:CGPointMake(-self.size.width - levelButton1.size.width, self.size.height/ 2) duration:.7];
    SKAction *menuButtonLeaveScene = [SKAction moveTo:CGPointMake(-self.size.width - menuButton.size.width, self.size.height - menuButton.size.height) duration:1.4];
    
    SKAction *runMan = [SKAction runBlock:^ {
        SKScene *menu = [[MenuScene alloc] initWithSize:self.size];
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        
        [self.view presentScene:menu transition:reveal];
    }];
    
    [levelButton1 runAction:playButtonMoveOutScene];
    [levelButton2 runAction:playButtonMoveOutScene];
    [levelButton3 runAction:playButtonMoveOutScene];
    [levelButton4 runAction:playButtonMoveOutScene];
    [menuButton runAction:menuButtonLeaveScene];
    [title runAction:[SKAction sequence:@[titleMoveOutScene, runMan]]];
}

- (void)playSwooshSound {
    [self runAction:_swooshSound];
}

@end
