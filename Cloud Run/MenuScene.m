//
//  MenuScene.m
//  Cloud Run
//
//  Created by John Goure on 6/21/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import "MenuScene.h"
#import "LevelSelectScene.h"
#import "ViewController.h"
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


@implementation MenuScene
{
    SKSpriteNode * title;
    SKSpriteNode * playButton;
    SKSpriteNode* resetButton;
    SKLabelNode * tryHard;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    SKNode *_bgLayer;
    SKNode *_buttonLayer;
    
    SKAction* _swooshSound;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        _swooshSound = [SKAction playSoundFileNamed:@"swooshSound.wav" waitForCompletion:NO];
        
        _bgLayer = [SKNode node];
        _buttonLayer = [SKNode node];
        [self addChild:_bgLayer];
        [self addChild:_buttonLayer];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        [self setupBackground];
        [self setupUI];
        [self setupPlayButtonBounce];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode * n = [self nodeAtPoint:location];
        NSLog(@"%@",n.name);
        if ([n.name isEqualToString:@"playButton"]) {
            [playButton removeAllActions];
            
            SKAction *scale = [SKAction scaleTo:.7 duration:.05];
            [playButton runAction:scale];
        }
        if ([n.name isEqualToString:@"resetButton"]) {
            [[GameData sharedGameData]reset];
            NSLog(@"reset");
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touched");
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode * n = [self nodeAtPoint:location];
        NSLog(@"touched");
        
        if ([n.name isEqualToString:@"playButton"]) {
            [self playSwooshSound];
            
            [self removeTitleAndButton];
        }
        SKAction *scale = [SKAction scaleTo:.8 duration:.05];
        [playButton runAction:scale];
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
    [self backgroundScroll];

}

- (void)setupLoadScreen {
    tryHard = [SKLabelNode labelNodeWithFontNamed:@"Haveltica"];
    tryHard.text = @"THGames";
    tryHard.fontSize = 34;
    tryHard.fontColor = [SKColor orangeColor];
    tryHard.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:tryHard];
    
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
    title = [SKSpriteNode spriteNodeWithImageNamed:@"menuTitle.png"];
    playButton = [SKSpriteNode spriteNodeWithImageNamed:@"playButton.png"];
    resetButton = [SKSpriteNode spriteNodeWithImageNamed:@"resetButton"];
    
    title.name = @"title";
    playButton.name = @"playButton";
    resetButton.name = @"resetButton";
    
    title.position = CGPointMake(self.size.width + title.size.width, self.size.height - 70);
    playButton.position = CGPointMake(-self.size.width / 2, self.size.height / 2);
    resetButton.position = CGPointMake(-30, 30);
    
    resetButton.scale = .3;
    
    [self addChild:title];
    [_buttonLayer addChild:playButton];
    //[_buttonLayer addChild:resetButton];
    
    SKAction *titleMoveIntoScene = [SKAction moveTo:CGPointMake(self.size.width / 2, self.size.height -  70) duration:.8];
    SKAction *playButtonMoveIntoScene = [SKAction moveTo:CGPointMake(self.size.width / 2, self.size.height/ 2) duration:1];
    SKAction *wait = [SKAction waitForDuration:.3];
    SKAction *resetMove = [SKAction moveTo:CGPointMake(30, 30) duration:0.5];
    
    //[tryHard runAction:[SKAction sequence:@[wait,fade, remove]]];
    [title runAction:[SKAction sequence:@[wait, titleMoveIntoScene]]];
    [playButton runAction:[SKAction sequence:@[wait, playButtonMoveIntoScene]]];
    [resetButton runAction:resetMove];
    
    title.scale = .4;
    
    
    
    doneLoadingScene = YES;
    
}

- (void)setupPlayButtonBounce {
    SKAction *scale = [SKAction scaleTo:.7 duration:.13];
    SKAction *scaleStretch = [SKAction scaleTo:.9 duration:.1];
    SKAction *scaleNormal = [SKAction scaleTo:.8 duration:.1];
    SKAction *wait = [SKAction waitForDuration:2.4];
    SKAction *wait2 = [SKAction waitForDuration:1];
    SKAction *sequence = [SKAction sequence:@[scale, scaleStretch,scaleNormal, wait]];
    
    [playButton runAction:[SKAction sequence:@[wait2,[SKAction repeatActionForever:sequence]]]];
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

- (void)removeTitleAndButton {
    SKAction *titleMoveOutScene = [SKAction moveTo:CGPointMake(self.size.width + title.size.width, self.size.height -  70) duration:1];
    SKAction *playButtonMoveOutScene = [SKAction moveTo:CGPointMake(-self.size.width - playButton.size.width, self.size.height/ 2) duration:.7];
    //SKAction *wait = [SKAction waitForDuration:.0];
    
    SKAction *blockMan = [SKAction runBlock:^ {
        SKScene * levelSelectScene =[[LevelSelectScene alloc] initWithSize:self.size];
        SKTransition *reveal =[SKTransition flipVerticalWithDuration:0.5];
        [self.view presentScene:levelSelectScene transition:reveal];
    }];
    
    [playButton runAction:playButtonMoveOutScene];
    [resetButton runAction:playButtonMoveOutScene];
    [title runAction:[SKAction sequence:@[titleMoveOutScene, blockMan]]];
}

- (void)playSwooshSound {
    [self runAction:_swooshSound];
}



@end
