//
//  Level1.m
//  Cloud Run
//
//  Created by John Goure on 6/22/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "Level1.h"
#import "LevelSelectScene.h"
#import "GameData.h"
#import "Level2.h"
#import "SoundManager.h"


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

static const int highestTimeScore = 500;
static const int highestMoveScore = 500;
static const int subtractPerSecond = 25;
static const int subtractPerMove = 125;

static const float sunBounce = 0.19;
static const float sunBounceBack = 0.21;
static const float sunNormal = .2;
static const int bestMovesBy = 3;

static const float stormNormal = .2;
static const float stormBounce = .21;
static const float stormBounceBack = .25;

static const float emptyPlatformScale = .35;

static const int lineWidth = 30;


@implementation Level1
{
    long numberOfSteps;
    BOOL introOf;
    BOOL startCount;
    BOOL outOfTime;
    BOOL intro1Off;
    BOOL intro2Off;
    BOOL introOff;
    
    int time, _moveCount;
    float sunSpeed;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint endLocation, beginLocation, sunStartPosition, stormStartPosition, storm2StartPosition;
    CGPoint rainPosition;
    SKAction *_sunAnimation;
    
    SKAction* _clickSound;
    SKAction* _swooshSound;
    SKAction* _winSound;
    Sound* _loseSound;
    
    SKTexture* whiteCloud;
    
    SKSpriteNode* stormCloud1;
    SKSpriteNode* endCloud;
    SKSpriteNode* lineNode;
    SKSpriteNode* lineNode2;
    SKSpriteNode* lineNode3;
    SKSpriteNode* introNode;
    SKSpriteNode* intro2Node;
    SKSpriteNode* sun;
    SKSpriteNode* emptyPlatform;
    SKSpriteNode* emptyPlatform2;
    SKSpriteNode* emptyPlatform3;
    SKSpriteNode* whiteCloud1;
    SKSpriteNode* whiteCloud2;
    
    SKTexture* _menuButtonTexture;
    
    SKSpriteNode* _hudBar;
    SKSpriteNode* _stepButton;
    SKSpriteNode* _menuButton;
    SKSpriteNode* _resumeButton;
    SKSpriteNode* _resetButton;
    SKSpriteNode* _quitButton;
    SKSpriteNode* _retryButton;
    SKSpriteNode* _quitButton2;
    SKSpriteNode* _winNode;
    SKSpriteNode* _nextButton;
    SKLabelNode* _stepCount;
    SKLabelNode* _timeNode;
    SKLabelNode* _timeUsed;
    SKLabelNode* _score;
    SKLabelNode* _numberOfMoves;
    SKLabelNode* _highScore;
    
    SKNode* _bgLayer;
    SKNode* _lineNodeLayer;
    SKNode* _menuLayer;
    SKNode* _playerLayer;
    SKNode* _stormLayer;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        _clickSound = [SKAction playSoundFileNamed:@"clickSound.mp3" waitForCompletion:NO];
        _swooshSound = [SKAction playSoundFileNamed:@"swooshSound.wav" waitForCompletion:NO];
        _winSound = [SKAction playSoundFileNamed:@"winSound.wav" waitForCompletion:NO];
        _loseSound = [Sound soundNamed:@"loseSound.wav"];
        
        
        
        _bgLayer = [SKNode node];
        _lineNodeLayer = [SKNode node];
        _menuLayer = [SKNode node];
        _playerLayer = [SKNode node];
        
        [self addChild:_bgLayer];
        [self addChild:_lineNodeLayer];
        [self addChild:_playerLayer];
        [self addChild:_menuLayer];
        
        rainPosition = CGPointMake(-17, 0);
        sunSpeed = .3;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"clouds"];
        [_bgLayer addChild:bg];
        
        
        // Init menuButton Here, because it slows down the Scene Transition if init in SetupHud Method
       _menuButtonTexture = [SKTexture textureWithImageNamed:@"menuButton"];
        
        // Code for Scrolling Cloud background
//        for (int i = 0; i < 2; i++) {
//            SKSpriteNode * bg =
//            [SKSpriteNode spriteNodeWithImageNamed:@"clouds"];
//            bg.scale = 0.5;
//            bg.anchorPoint = CGPointZero;
//            bg.position = CGPointMake(i * bg.size.width, 0);
//            bg.name = @"bg";
//            [_bgLayer addChild:bg];
//        }
        
        NSMutableArray *textures =[NSMutableArray arrayWithCapacity:11];
       
        for (int i = 1; i < 11; i++) {
            NSString *textureName =[NSString stringWithFormat:@"sun%d", i];
            SKTexture *texture =[SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
            _sunAnimation =[SKAction animateWithTextures:textures timePerFrame:0.35];
        }
        
        [self setupHud];
    
        _sunAnimation =[SKAction animateWithTextures:textures timePerFrame:0.35];
    
        [self setupLevel];
        [self startSunAnimation];
        
        numberOfSteps = 0;
        time = 20;
        _moveCount = 0;
 
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        beginLocation = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:beginLocation];
        NSLog(@"%@",n.name);
        
        intro1Off = YES;
        
        if (introOff == YES) {
            
            if ([n.name isEqualToString:@"linenode2"] && ![stormCloud1 intersectsNode:emptyPlatform]) {
                [self playClickSound];
                lineNode2.name = @"linenode4";
                SKAction *bounce = [SKAction scaleTo:stormBounce duration:.1];
                SKAction *bounceBack = [SKAction scaleTo:stormBounceBack duration:.1];
                SKAction *normalSize = [SKAction scaleTo:stormNormal duration:.1];
                SKAction *move = [SKAction moveTo:CGPointMake(emptyPlatform.position.x ,emptyPlatform.position.y - 10) duration:.4];
                SKAction *sequence = [SKAction sequence:@[bounce, bounceBack, normalSize, bounce, bounceBack, normalSize]];
                [stormCloud1 runAction:[SKAction group:@[sequence, move]]];
                lineNode.color = [SKColor greenColor];
                //moveCount += 1;
                _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                
            }
            
            if ([n.name isEqualToString:@"linenode1" ] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![sun intersectsNode:emptyPlatform2]) {
                if ([sun intersectsNode:emptyPlatform3]) {
                    [self playClickSound];
                    SKAction *moveToEmptyPlatform = [SKAction moveTo:emptyPlatform2.position duration:sunSpeed];
                    SKAction *bounce = [SKAction scaleTo:sunBounce duration:.1];
                    SKAction *bounceBack = [SKAction scaleTo:sunBounceBack duration:.1];
                    SKAction *normalSize = [SKAction scaleTo:sunNormal duration:.1];
                    [sun runAction:[SKAction group:@[[SKAction sequence:@[bounce, bounceBack, normalSize, bounce, bounceBack, normalSize]], moveToEmptyPlatform]]];
                    lineNode3.color = [SKColor greenColor];
                    lineNode2.color = [SKColor blackColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
            }
            
            if ([n.name isEqualToString:@"linenode1"] && [sun intersectsNode:emptyPlatform2]) {
                [self playClickSound];
                SKAction *moveTo = [SKAction moveTo:emptyPlatform3.position duration:sunSpeed];
                SKAction *bounce = [SKAction scaleTo:sunBounce duration:.1];
                SKAction *bounceBack = [SKAction scaleTo:sunBounceBack duration:.1];
                SKAction *normalSize = [SKAction scaleTo:sunNormal duration:.1];
                [sun runAction:[SKAction group:@[[SKAction sequence:@[bounce, bounceBack, normalSize]], moveTo]]];
                _moveCount += 1;
                _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                lineNode.color = [SKColor greenColor];
                lineNode2.color = [SKColor greenColor];
                lineNode3.color = [SKColor blackColor];
            }
            
            if ([n.name isEqualToString:@"linenode4"] && ![sun intersectsNode:emptyPlatform2] && [stormCloud1 intersectsNode:emptyPlatform]) {
                [self playClickSound];
                SKAction *bounce = [SKAction scaleTo:stormBounce duration:.1];
                SKAction *bounceBack = [SKAction scaleTo:stormBounceBack duration:.1];
                SKAction *normalSize = [SKAction scaleTo:stormNormal duration:.1];
                SKAction *move = [SKAction moveTo:CGPointMake(emptyPlatform2.position.x ,emptyPlatform2.position.y - 10) duration:.4];
                SKAction *sequence = [SKAction sequence:@[bounce, bounceBack, normalSize, bounce, bounceBack, normalSize]];
                [stormCloud1 runAction:[SKAction group:@[sequence, move]]];
                _moveCount += 1;
                _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                lineNode.color = [SKColor blackColor];
            }
            if ([n.name isEqualToString:@"linenode4"] && ![stormCloud1 intersectsNode:emptyPlatform]) {
                [self playClickSound];
                SKAction *bounce = [SKAction scaleTo:stormBounce duration:.1];
                SKAction *bounceBack = [SKAction scaleTo:stormBounceBack duration:.1];
                SKAction *normalSize = [SKAction scaleTo:stormNormal duration:.1];
                SKAction *move = [SKAction moveTo:CGPointMake(emptyPlatform.position.x ,emptyPlatform.position.y - 10) duration:.4];
                SKAction *sequence = [SKAction sequence:@[bounce, bounceBack, normalSize, bounce, bounceBack, normalSize]];
                [stormCloud1 runAction:[SKAction group:@[sequence, move]]];
                lineNode.color = [SKColor greenColor];
                _moveCount += 1;
                _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
            }
            
            if ([n.name isEqualToString:@"linenode3" ] && [sun intersectsNode:emptyPlatform2]) {
                [self playClickSound];
                SKAction *moveToEnd = [SKAction moveTo:endCloud.position duration:sunSpeed];
                SKAction *bounce = [SKAction scaleTo:sunBounce duration:.1];
                SKAction *bounceBack = [SKAction scaleTo:sunBounceBack duration:.1];
                SKAction *normalSize = [SKAction scaleTo:sunNormal duration:.1];
                [sun runAction:[SKAction group:@[[SKAction sequence:@[bounce, bounceBack, normalSize]], moveToEnd]]];
                _moveCount += 1;
                _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
            }

        }
        
        if ([n.name isEqualToString:@"resumeButton"]) {
            [self playSwooshSound];
            [self resumeGame];
        }
        
        else if ([n.name isEqualToString:@"resetButton"]) {
            [self restartLevel];
        }
        
        else if ([n.name isEqualToString:@"quitButton"]) {
            [self runQuit];
        }
        
        else if ([n.name isEqualToString:@"menuButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.45 duration:0.05];
            [_menuButton runAction:scaleDown];
        }
        
        else if ([n.name isEqualToString:@"retrybutton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.35 duration:0.05];
            [_retryButton runAction:scaleDown];
        }
        
        else if ([n.name isEqualToString:@"levelEndRetryButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:0.05];
            [_retryButton runAction:scaleDown];
        }
        
        else if ([n.name isEqualToString:@"quitbutton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.35 duration:0.05];
            [_quitButton runAction:scaleDown];
        }
        
        else if ([n.name isEqualToString:@"levelEndQuitButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:0.05];
            [_quitButton2 runAction:scaleDown];
        }
        
        else if ([n.name isEqualToString:@"nextButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:0.05];
            [_nextButton runAction:scaleDown];
        }

        else if ([n.name isEqualToString:@"intronode"]) {
            SKAction *flip = [SKAction rotateByAngle:M_PI * 2 duration:0.5];
            SKAction *scale = [SKAction scaleTo:0 duration:.5];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *group = [SKAction group:@[flip, scale]];
            SKAction *sequence = [SKAction sequence:@[group, remove]];
            [intro2Node runAction:sequence];
            
            SKAction *flipIntoView = [SKAction rotateByAngle:M_PI * -2 duration:0.5];
            SKAction *scaleIntoView = [SKAction scaleTo:0.5 duration:0.5];
            SKAction *moveToCenter = [SKAction moveTo:CGPointMake(self.size.width / 2, self.size.height / 2) duration:0.5];
            SKAction *revealGroup = [SKAction group:@[flipIntoView, scaleIntoView, moveToCenter]];
            [introNode runAction: revealGroup];
                                      
        }
        
        else if ([n.name isEqualToString:@"intronode2"]) {
            NSLog(@"touched");
            SKAction *flip = [SKAction rotateByAngle:M_PI * 2 duration:0.5];
            SKAction *scale = [SKAction scaleTo:0 duration:.5];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *group = [SKAction group:@[flip, scale]];
            SKAction *sequence = [SKAction sequence:@[group, remove]];
            [introNode runAction:sequence];
            introOff = YES;
            [self runTimer];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    beginLocation = [touch locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        beginLocation = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:beginLocation];
        
        if ([n.name isEqualToString:@"retrybutton"]) {
            [self playSwooshSound];
            SKAction *scaleBack = [SKAction scaleTo:0.4 duration:0.05];
            SKAction *loadBlock = [SKAction runBlock:^ {
                [self restartLevel];
            }];
            [_retryButton runAction:[SKAction sequence:@[scaleBack,loadBlock]]];
        }
        if ([n.name isEqualToString:@"levelEndRetryButton"]) {
            [self playSwooshSound];
            SKAction *scaleBack = [SKAction scaleTo:0.3 duration:0.05];
            SKAction *loadBlock = [SKAction runBlock:^ {
                [self restartLevel];
            }];
            [_retryButton runAction:[SKAction sequence:@[scaleBack,loadBlock]]];
        }
        if ([n.name isEqualToString:@"quitbutton2"]) {
            [self playSwooshSound];
            [_loseSound fadeOut:0.5];
            SKAction *scaleBack = [SKAction scaleTo:0.4 duration:0.05];
            SKAction *loadBlock = [SKAction runBlock:^ {
                [self loadLevelSelect];
            }];
            [_quitButton2 runAction:[SKAction sequence:@[scaleBack,loadBlock]]];
        }
        if ([n.name isEqualToString:@"levelEndQuitButton"]) {
            [self playSwooshSound];
            SKAction *scaleBack = [SKAction scaleTo:0.3 duration:0.05];
            SKAction *loadBlock = [SKAction runBlock:^ {
                [self loadLevelSelect];
            }];
            [_quitButton2 runAction:[SKAction sequence:@[scaleBack,loadBlock]]];
        }
        if ([n.name isEqualToString:@"nextButton"]) {
            [self playSwooshSound];
            SKAction *scaleBack = [SKAction scaleTo:0.3 duration:0.05];
            SKAction *loadBlock = [SKAction runBlock:^ {
                [self loadNextLevel];
            }];
            [_nextButton runAction:[SKAction sequence:@[scaleBack,loadBlock]]];
        }
        
        if ([n.name isEqualToString:@"menuButton"]) {
            SKAction *scaleBack = [SKAction scaleTo:0.5 duration:0.05];
            [_menuButton runAction:scaleBack];
            [self loadMenu];
        }
        
    }
}

//- (void)handleSwipe:(UISwipeGestureRecognizerDirection *)sender
//{
//    
//}

- (void)setupHud {
    _hudBar = [SKSpriteNode spriteNodeWithImageNamed:@"HUD.png"];
    _stepButton = [SKSpriteNode spriteNodeWithImageNamed:@"stepButton.png"];
    _menuButton = [SKSpriteNode spriteNodeWithTexture:_menuButtonTexture];
    _timeNode = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    
    _stepCount = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _stepCount.fontColor = [SKColor blackColor];
    _stepCount.text = [NSString stringWithFormat:@"0"];
    _stepCount.fontSize = 30;
    _stepCount.name = @"stepCount";
    
    _timeNode.position = CGPointMake(self.size.width / 2 + 10, self.size.height - 30);
    _timeNode.fontSize = 25;
    _timeNode.text = @":20";
    _timeNode.name = @"timenode";
    
    _stepButton.scale = .7;
    _stepCount.scale = .7;
    
    _hudBar.name = @"hud";
    _hudBar.position = CGPointMake(self.size.width/2, self.size.height - 20);
    
    _stepButton.name = @"stepButton";
    _stepButton.position = CGPointMake(15, self.size.height - 20);
    
    _stepCount.position = CGPointMake(34, self.size.height - 30);
    
    _menuButton.position = CGPointMake(self.size.width - 30, self.size.height - 20);
    _menuButton.name = @"menuButton";
    _menuButton.scale = .5;
    
    [_menuLayer addChild:_hudBar];
    [_menuLayer addChild:_stepButton];
    [_menuLayer addChild:_stepCount];
    [_menuLayer addChild:_menuButton];
    [_menuLayer addChild:_timeNode];
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    //[self backgroundScroll];

    if ([sun intersectsNode:endCloud] && _winNode == nil) {
        
        [self runWinScene];
    }
    
    if (time == 0 && _retryButton == nil) {
        [self outOfTime];
    }
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

- (void)setupLevel {
    sun = [SKSpriteNode spriteNodeWithImageNamed:@"sun1.png"];
    endCloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloudPlatforms"];
    whiteCloud = [SKTexture textureWithImageNamed:@"cloudPlatforms"];
    whiteCloud1 = [SKSpriteNode spriteNodeWithTexture:whiteCloud];
    whiteCloud2 = [SKSpriteNode spriteNodeWithTexture:whiteCloud];
    stormCloud1 = [SKSpriteNode spriteNodeWithImageNamed:@"stormcloud"];
    
    emptyPlatform = [SKSpriteNode spriteNodeWithImageNamed:@"emptyplatform.png"];
    emptyPlatform2 = [SKSpriteNode spriteNodeWithImageNamed:@"emptyplatform.png"];
    emptyPlatform3 = [SKSpriteNode spriteNodeWithImageNamed:@"emptyplatform.png"];
    
    introNode = [SKSpriteNode spriteNodeWithImageNamed:@"intro.png"];
    intro2Node = [SKSpriteNode spriteNodeWithImageNamed:@"intro2.png"];
    
    stormCloud1.name = @"stormcloud1";
    stormCloud1.scale = stormNormal;
    
    emptyPlatform.name = @"emptyplatform";
    emptyPlatform.position = CGPointMake(self.size.width - 30, (self.size.height / 2) - 50);
    emptyPlatform.scale = emptyPlatformScale;
    
    emptyPlatform2.position = CGPointMake(self.size.width / 2, emptyPlatform.position.y);
    emptyPlatform2.name = @"emptyplatform2";
    emptyPlatform2.scale = emptyPlatformScale;
    
    emptyPlatform3.position = CGPointMake(emptyPlatform2.position.x, emptyPlatform2.position.y - 150);
    emptyPlatform3.scale = emptyPlatformScale;
    
    sun.position = CGPointMake(emptyPlatform3.position.x, emptyPlatform3.position.y + 10);
    sunStartPosition = sun.position;
    sun.name = @"sun";
    sun.scale = sunNormal;
    
    endCloud.position = CGPointMake(emptyPlatform2.position.x - 10, emptyPlatform2.position.y + 170);
    endCloud.Name = @"endcloud";
    endCloud.scale = .5;
    
    whiteCloud1.position = CGPointMake(endCloud.position.x - 20, endCloud.position.y - 5);
    whiteCloud1.scale = 0.5;
    
    whiteCloud2.position = CGPointMake(endCloud.position.x + 20, endCloud.position.y - 5);
    whiteCloud2.scale = 0.5;
    
    lineNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(lineWidth, emptyPlatform2.position.y - emptyPlatform3.position.y)];
    lineNode2 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(emptyPlatform.position.x - emptyPlatform2.position.x - 20, lineWidth)];
    lineNode3 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(lineWidth, endCloud.position.y - emptyPlatform2.position.y)];
    
    lineNode.position = CGPointMake(emptyPlatform3.position.x - 20, emptyPlatform3.position.y);
    lineNode.anchorPoint = CGPointMake(0, 0);
    lineNode.name = @"linenode1";
    lineNode.alpha = 0.62;
    lineNode.color = [SKColor blackColor];
    
    lineNode2.position = CGPointMake(emptyPlatform2.position.x + 10, emptyPlatform2.position.y - 10);
    lineNode2.anchorPoint = CGPointMake(0, 0);
    lineNode2.name = @"linenode2";
    lineNode2.alpha = 0.62;
    lineNode2.color = [SKColor greenColor];
    
    lineNode3.position = CGPointMake(emptyPlatform2.position.x - 20, emptyPlatform2.position.y);
    lineNode3.anchorPoint = CGPointMake(0, 0);
    lineNode3.name = @"linenode3";
    lineNode3.alpha = 0.62;
    
    stormCloud1.position = CGPointMake(emptyPlatform2.position.x, emptyPlatform2.position.y - 10);
    stormStartPosition = stormCloud1.position;
    
    
    SKEmitterNode *rain =
    [NSKeyedUnarchiver unarchiveObjectWithFile:
     [[NSBundle mainBundle] pathForResource:@"MyParticle"
                                     ofType:@"sks"]];
    rain.position = rainPosition;
    rain.scale = 1;
    rain.name = @"rain";
    
    intro2Node.name = @"intronode";
    intro2Node.scale = 0;
    intro2Node.position = CGPointMake(self.size.width + 50, self.size.height / 2);
    
    introNode.name = @"intronode2";
    introNode.scale = 0;
    introNode.position = CGPointMake(_stepButton.position.x, _stepButton.position.y);
    
    
    
    [_menuLayer addChild:lineNode];
    [_menuLayer addChild:lineNode2];
    [_menuLayer addChild:lineNode3];
    
    [_menuLayer addChild:emptyPlatform];
    [_menuLayer addChild:emptyPlatform3];
    [_menuLayer addChild:emptyPlatform2];
    
    [_menuLayer addChild:whiteCloud1];
    [_menuLayer addChild:whiteCloud2];
    [_menuLayer addChild:endCloud];
    
    [_menuLayer addChild:stormCloud1];
    [stormCloud1 addChild:rain];
    
    [_menuLayer addChild:sun];
    [_menuLayer addChild:intro2Node];
    [_menuLayer addChild:introNode];
    
    SKAction *wait = [SKAction waitForDuration:.3];
    SKAction *move = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height/2) duration:.4];
    SKAction *flip = [SKAction rotateByAngle:M_PI * 2 duration:0.5];
    SKAction *scale = [SKAction scaleTo:.5 duration:.5];
    SKAction *group = [SKAction group:@[flip, scale, move]];
    [intro2Node runAction:[SKAction sequence:@[wait,group]]];
    
    SKAction *startCloudWait = [SKAction waitForDuration:4.5];
    SKAction *bounce = [SKAction scaleTo:sunBounce duration:.1];
    SKAction *bounceBack = [SKAction scaleTo:sunBounceBack duration:.15];
    SKAction *normalSize = [SKAction scaleTo:sunNormal duration:.1];
    [sun runAction:[SKAction repeatActionForever:[SKAction sequence:@[startCloudWait,bounce, bounceBack, normalSize]]]];
    
}

- (void)loadMenu {
    
    [self playSwooshSound];
    
    SKAction *move = [SKAction moveToX:self.size.width / 2 duration:.2];
    SKAction *bounce = [SKAction scaleTo:.2 duration:.1];
    SKAction *bounceBack = [SKAction scaleTo:.4 duration:.13];
    SKAction *bounceNormal = [SKAction scaleTo:.3 duration:.1];
    SKAction *sequence = [SKAction sequence:@[bounce, bounceBack, bounceNormal, bounce, bounceBack, bounceNormal]];
    SKAction *group = [SKAction group:@[sequence, move]];
    
    _resumeButton = [SKSpriteNode spriteNodeWithImageNamed:@"resumeButton"];
    _resumeButton.name = @"resumeButton";
    _resumeButton.position = CGPointMake(self.size.width + 30, self.size.height / 2 + 50);
    _resumeButton.scale = .2;
    
    _resetButton = [SKSpriteNode spriteNodeWithImageNamed:@"resetButton"];
    _resetButton.name = @"resetButton";
    _resetButton.position = CGPointMake(self.size.width + 30, self.size.height / 2);
    _resetButton.scale = .2;
    
    _quitButton = [SKSpriteNode spriteNodeWithImageNamed:@"quitButton"];
    _quitButton.name = @"quitButton";
    _quitButton.position = CGPointMake(self.size.width + 30, self.size.height / 2 - 50);
    _quitButton.scale = .2;
    
    [_menuLayer addChild:_resumeButton];
    [_menuLayer addChild:_resetButton];
    [_menuLayer addChild:_quitButton];
    
    [_resumeButton runAction:group];
    [_resetButton runAction:group];
    [_quitButton runAction:group];
    _timeNode.paused = YES;
    _menuButton.userInteractionEnabled = YES;
}

- (void)runTimer {
    SKAction *wait = [SKAction waitForDuration:1.0];
    SKAction *timeBlock = [SKAction runBlock:^ {
        time -= 1;
        _timeNode.text = [NSString stringWithFormat:@":%d", time];
    }];
    SKAction *timersequence = [SKAction sequence:@[wait, timeBlock]];
    [_timeNode runAction:[SKAction repeatActionForever:timersequence]];
}

- (void)resumeGame {
    _timeNode.paused = NO;
    _menuButton.userInteractionEnabled = NO;
    SKAction *moveRight = [SKAction moveToX:self.size.width + 30 duration:.2];
    SKAction *remove = [SKAction removeFromParent];
    
    [_resumeButton runAction:[SKAction sequence:@[moveRight, remove]]];
    [_resetButton runAction:[SKAction sequence:@[moveRight, remove]]];
    [_quitButton runAction:[SKAction sequence:@[moveRight, remove]]];
    
}

- (void)loadLevelSelect {
    [_loseSound fadeOut:0.5];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:.5];
    SKScene *levelSelect = [[LevelSelectScene alloc]initWithSize:self.size];
    [self.view presentScene:levelSelect transition:reveal];
}

- (void)runQuit {
    [_loseSound fadeOut:0.5];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
    
    SKScene *level1 = [[LevelSelectScene alloc] initWithSize:self.size];
    [self.view presentScene:level1 transition:reveal];
}

- (void)startSunAnimation
{
    if (![sun actionForKey:@"animation"]) {
        [sun runAction:
         [SKAction repeatActionForever:_sunAnimation]
                   withKey:@"animation"];
    }
}

- (void)runWinScene {
    
    [self playWinSound];
    
    _timeNode.paused = YES;
    lineNode.paused = YES;
    lineNode2.paused = YES;
    
    _winNode = [SKSpriteNode spriteNodeWithImageNamed:@"winscene.png"];
    _winNode.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    _winNode.name = @"winnode";
    _winNode.scale = 0.0;
    
    [_menuLayer addChild:_winNode];
    
    if (![GameData sharedGameData].level1Beat) {
        [GameData sharedGameData].level1Beat = YES;
        [[GameData sharedGameData]save];
    }
    
    
    SKAction *scaleTo = [SKAction scaleTo:0.4 duration:0.1];
    [_winNode runAction:scaleTo];
    
    CGPoint retryButtonPosition = CGPointMake(self.size.width / 2, self.size.height / 2 - 150);
    _retryButton = [SKSpriteNode spriteNodeWithImageNamed:@"retrybutton.png"];
    _retryButton.name = @"levelEndRetryButton";
    _retryButton.scale = 0.0;
    _retryButton.position = retryButtonPosition;
    [_menuLayer addChild:_retryButton];
    
    CGPoint quitButtonPosition = CGPointMake(self.size.width / 2 - 90, self.size.height / 2 - 150);
    _quitButton2 = [SKSpriteNode spriteNodeWithImageNamed:@"quitbutton2.png"];
    _quitButton2.name = @"levelEndQuitButton";
    _quitButton2.scale = 0.0;
    _quitButton2.position = quitButtonPosition;
    [_menuLayer addChild:_quitButton2];
    
    CGPoint nextButtonPosition = CGPointMake(self.size.width / 2 + 90, self.size.height / 2 - 150);
    _nextButton = [SKSpriteNode spriteNodeWithImageNamed:@"nextbutton"];
    _nextButton.name = @"nextButton";
    _nextButton.scale = 0.0;
    _nextButton.position = nextButtonPosition;
    [_menuLayer addChild:_nextButton];
    
    SKAction *retryScale = [SKAction scaleTo:0.3 duration:0.2];
    [_retryButton runAction:retryScale];
    [_quitButton2 runAction:retryScale];
    [_nextButton runAction:retryScale];
    
    int moveScore;
    int timeScore;
    
    moveScore = highestMoveScore;
    NSLog(@"%d", highestMoveScore);

    if (_moveCount > bestMovesBy) {
        moveScore = (highestMoveScore - (subtractPerMove * (_moveCount - bestMovesBy)));
    }
    
    int x = 20 - time;
    timeScore = (highestTimeScore - (subtractPerSecond * x));
    NSLog(@"%d",timeScore);
    _timeUsed = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _timeUsed.text = [NSString stringWithFormat:@"%d seconds",x];
    _timeUsed.fontColor = [SKColor whiteColor];
    _timeUsed.fontSize = 20.0;
    _timeUsed.position = CGPointMake(self.size.width / 2 + 40, self.size.height / 2 - 26);
    [_menuLayer addChild:_timeUsed];

    _numberOfMoves = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _numberOfMoves.text = [NSString stringWithFormat:@"%d",_moveCount];
    _numberOfMoves.fontColor = [SKColor whiteColor];
    _numberOfMoves.fontSize = 20.0;
    _numberOfMoves.position = CGPointMake(self.size.width / 2, self.size.height /2 - 4);
    [_menuLayer addChild:_numberOfMoves];
    
    int scoreTotal = moveScore + timeScore;
    
    if (scoreTotal >= 0) {
        _score = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
        _score.text = [NSString stringWithFormat:@"%d",scoreTotal];
        _score.fontColor = [SKColor whiteColor];
        _score.fontSize = 20.0;
        _score.position = CGPointMake(self.size.width /2 + 10, self.size.height / 2 - 50);
        [_menuLayer addChild:_score];
        NSLog(@"%d",scoreTotal);
    }else {
        scoreTotal = 0;
        _score = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
        _score.text = [NSString stringWithFormat:@"%d",scoreTotal];
        _score.fontColor = [SKColor whiteColor];
        _score.fontSize = 20.0;
        _score.position = CGPointMake(self.size.width /2 + 10, self.size.height / 2 - 50);
        [_menuLayer addChild:_score];
    }
    
    if ([GameData sharedGameData].level1HighScore > 1000)
    {
        [[GameData sharedGameData]reset];
    }
    
    if (![GameData sharedGameData].level1HighScore) {
            [GameData sharedGameData].level1HighScore = scoreTotal;
        [[GameData sharedGameData]save];
    }
    
    if ([GameData sharedGameData].level1HighScore) {
        if (scoreTotal > [GameData sharedGameData].level1HighScore) {
            [GameData sharedGameData].level1HighScore = scoreTotal;
            [[GameData sharedGameData]save];
        }
    }
    
    _highScore = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _highScore.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].level1HighScore];
    _highScore.fontColor = [SKColor whiteColor];
    _highScore.fontSize = 20.0;
    _highScore.position = CGPointMake(self.size.width / 2 + 10, self.size.height / 2 - 95);
    [_menuLayer addChild:_highScore];
}

- (void)restartLevel {
    [_loseSound fadeOut:0.5];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:.5];
    SKScene *level1 = [[Level1 alloc]initWithSize:self.size];
    [self.view presentScene:level1 transition:reveal];
}

- (void)loadNextLevel {
    [_loseSound fadeOut:0.5];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:.5];
    SKScene *level2 = [[Level2 alloc]initWithSize:self.size];
    [self.view presentScene:level2 transition:reveal];
}

- (void)outOfTime {
    [self playLoseSound];
    
    _timeNode.paused = YES;
    
    CGPoint retryButtonPosition = CGPointMake(-self.size.width - 30, self.size.height / 2 + 20);
    CGPoint quitButton2Position = CGPointMake(-self.size.width - 30, self.size.height / 2 - 42);
    
    CGPoint retryPositionInScene = CGPointMake(self.size.width / 2, self.size.height / 2 + 20);
    CGPoint quitButton2PositionInScene = CGPointMake(self.size.width / 2, self.size.height / 2 - 42);
    
    _retryButton = [SKSpriteNode spriteNodeWithImageNamed:@"retrybutton.png"];
    _quitButton2 = [SKSpriteNode spriteNodeWithImageNamed:@"quitbutton2.png"];
    
    _retryButton.position = retryButtonPosition;
    _retryButton.name = @"retrybutton";
    _retryButton.scale = 0.4;
    
    _quitButton2.position = quitButton2Position;
    _quitButton2.name = @"quitbutton2";
    _quitButton2.scale = 0.4;
    
    [_menuLayer addChild:_retryButton];
    [_menuLayer addChild:_quitButton2];
    
    SKAction *moveRetryIntoScene = [SKAction moveTo:retryPositionInScene duration:0.4];
    SKAction *moveQuitIntoScene = [SKAction moveTo:quitButton2PositionInScene duration:0.4];
    
    [_retryButton runAction:moveRetryIntoScene];
    [_quitButton2 runAction:moveQuitIntoScene];
    
}

- (void)playClickSound {
    [self runAction:_clickSound];
}

- (void)playSwooshSound {
    [self runAction:_swooshSound];
}

- (void)playWinSound {
    [self runAction:_winSound];
}

- (void)playLoseSound {
    [_loseSound play];
}

@end
