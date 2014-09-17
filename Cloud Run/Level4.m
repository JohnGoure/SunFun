//
//  Level4.m
//  Sun Run
//
//  Created by John Goure on 7/21/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import "Level4.h"
#import "LevelSelectScene.h"
#import "GameData.h"
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
static const int subtractPerSecond = 12;
static const int subtractPerMove = 125;
static const int bestMovesBy = 4;

static const int gameTime = 12;

static const float sunBounce = 0.19;
static const float sunBounceBack = 0.21;
static const float sunNormal = .2;

static const float stormNormal = .2;
static const float stormBounce = .21;
static const float stormBounceBack = .25;

static const float emptyPlatformScale = .35;

static const int lineWidth = 30;

@implementation Level4
{
    long numberOfSteps;
    BOOL introOff, startCount, outOfTime;
    int time, _moveCount;
    float sunSpeed;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint endLocation, beginLocation, sunStartPosition, storm1StartPosition, storm2StartPosition;
    CGPoint rainPosition;
    SKAction *_sunAnimation;
    SKTexture *sunTexture;
    
    SKAction* _clickSound;
    SKAction* _swooshSound;
    SKAction* _winSound;
    Sound* _loseSound;
    
    SKSpriteNode* stormCloud1;
    SKSpriteNode* stormCloud2;
    SKSpriteNode* stormCloud3;
    SKSpriteNode* stormCloud4;
    SKSpriteNode* stormCloud5;
    SKSpriteNode* stormCloud6;
    SKSpriteNode* endCloud;
    SKSpriteNode* lineNode;
    SKSpriteNode* lineNode2;
    SKSpriteNode* lineNode3;
    SKSpriteNode* lineNode4;
    SKSpriteNode* lineNode5;
    SKSpriteNode* lineNode6;
    SKSpriteNode* lineNode7;
    SKSpriteNode* lineNode8;
    SKSpriteNode* lineNode9;
    SKSpriteNode* lineNode10;
    SKSpriteNode* lineNode11;
    SKSpriteNode* introNode;
    SKSpriteNode* sun;
    SKSpriteNode* emptyPlatform;
    SKSpriteNode* emptyPlatform2;
    SKSpriteNode* emptyPlatform3;
    SKSpriteNode* emptyPlatform4;
    SKSpriteNode* emptyPlatform5;
    SKSpriteNode* emptyPlatform6;
    SKTexture* whiteCloud;
    SKSpriteNode* whiteCloud1;
    SKSpriteNode* whiteCloud2;
    
    SKTexture* platform;
    
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
        _playerLayer = [SKNode node];
        _menuLayer = [SKNode node];
        
        [self addChild:_bgLayer];
        [self addChild:_lineNodeLayer];
        [self addChild:_playerLayer];
        [self addChild:_menuLayer];
        
        platform = [SKTexture textureWithImageNamed:@"emptyplatform.png"];
        
        rainPosition = CGPointMake(-17, 0);
        sunSpeed = .3;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        for (int i = 0; i < 2; i++) {
            SKSpriteNode * bg =
            [SKSpriteNode spriteNodeWithImageNamed:@"clouds"];
            bg.scale = 0.5;
            bg.anchorPoint = CGPointZero;
            bg.position = CGPointMake(i * bg.size.width, 0);
            bg.name = @"bg";
            [_bgLayer addChild:bg];
        }
        
        NSMutableArray *textures =[NSMutableArray arrayWithCapacity:11];
        
        for (int i = 1; i < 11; i++) {
            NSString *textureName =[NSString stringWithFormat:@"sun%d", i];
            SKTexture *texture =[SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
            _sunAnimation =[SKAction animateWithTextures:textures timePerFrame:0.35];
        }
        
        sunTexture = [SKTexture textureWithImageNamed:@"sun1"];
        
        // Init menuButton Here, because it slows down the Scene Transition if init in SetupHud Method
        _menuButtonTexture = [SKTexture textureWithImageNamed:@"menuButton"];
        
        [self setupHud];
        
        _sunAnimation =[SKAction animateWithTextures:textures timePerFrame:0.35];
        
        [self setupLevel];
        [self startSunAnimation];
        numberOfSteps = 0;
        time = gameTime;
        _moveCount = 0;
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        beginLocation = [touch locationInNode:self];
        SKNode *n = [self nodeAtPoint:beginLocation];
        NSLog(@"%@",n.name);
        
#pragma mark Menu Touch Setup
        
        if ([n.name isEqualToString:@"resumeButton"]) {
            [self resumeGame];
        }
        
        if ([n.name isEqualToString:@"resetButton"]) {
            [self restartLevel];
        }
        
        if ([n.name isEqualToString:@"quitButton"]) {
            [self runQuit];
        }
        
        if ([n.name isEqualToString:@"menuButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.45 duration:0.05];
            [_menuButton runAction:scaleDown];
        }
        
        if ([n.name isEqualToString:@"retrybutton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.35 duration:0.05];
            [_retryButton runAction:scaleDown];
        }
        if ([n.name isEqualToString:@"levelEndRetryButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:0.05];
            [_retryButton runAction:scaleDown];
        }
        if ([n.name isEqualToString:@"quitbutton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.35 duration:0.05];
            [_quitButton runAction:scaleDown];
        }
        if ([n.name isEqualToString:@"levelEndQuitButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:0.05];
            [_quitButton2 runAction:scaleDown];
        }
        if ([n.name isEqualToString:@"nextButton"]) {
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:0.05];
            [_nextButton runAction:scaleDown];
        }
        
        if ([n.name isEqualToString:@"intronode"]) {
            NSLog(@"touched");
            SKAction *flip = [SKAction rotateByAngle:M_PI * 2 duration:0.5];
            SKAction *scale = [SKAction scaleTo:0 duration:.5];
            SKAction *move = [SKAction moveTo:_stepCount.position duration:0.5];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *group = [SKAction group:@[flip, scale, move]];
            SKAction *sequence = [SKAction sequence:@[group, remove]];
            [introNode runAction:sequence];
            introOff = YES;
            [self runTimer];
            
        }
        
        if (introOff == YES) {
#pragma mark Line touch
            
            if ([n.name isEqualToString:@"linenode1" ]) {
                if (![stormCloud1 intersectsNode:emptyPlatform2] && [sun intersectsNode:emptyPlatform3] && ![stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud3 intersectsNode:emptyPlatform2]) {
                    
                    
                    CGPoint position = CGPointMake(emptyPlatform2.position.x, emptyPlatform2.position.y);
                    
                    [self sunMove:sun moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    lineNode3.color = [SKColor greenColor];
                    
                    if ([stormCloud1 intersectsNode:emptyPlatform] || [stormCloud2 intersectsNode:emptyPlatform] || [stormCloud3 intersectsNode:emptyPlatform]) {
                        lineNode2.color = [SKColor blackColor];
                    } else {
                        lineNode2.color = [SKColor greenColor];
                    }
                    if ([stormCloud1 intersectsNode:endCloud] || [stormCloud2 intersectsNode:endCloud] || [stormCloud3 intersectsNode:endCloud]) {
                        lineNode3.color = [SKColor blackColor];
                    } else {
                        lineNode3.color = [SKColor greenColor];
                    }
                    if ([stormCloud1 intersectsNode:emptyPlatform5] || [stormCloud2 intersectsNode:emptyPlatform5] || [stormCloud3 intersectsNode:emptyPlatform5]) {
                        lineNode5.color = [SKColor blackColor];
                    } else {
                        lineNode5.color = [SKColor greenColor];
                    }
                    
                }
                else if ([sun intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform3] && ![stormCloud2 intersectsNode:emptyPlatform3] && ![stormCloud3 intersectsNode:emptyPlatform3]) {
                    
                    CGPoint position = CGPointMake(emptyPlatform3.position.x, emptyPlatform3.position.y);
                    
                    [self sunMove:sun moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    lineNode.color = [SKColor greenColor];
                    lineNode2.color = [SKColor greenColor];
                    lineNode3.color = [SKColor greenColor];
                    lineNode5.color = [SKColor greenColor];
                }
            }
            
            else if ([n.name isEqualToString:@"linenode2"]) {
                if ([stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud2 intersectsNode:emptyPlatform] && ![stormCloud3 intersectsNode:emptyPlatform] && ![sun intersectsNode:emptyPlatform]) {
                    CGPoint position = emptyPlatform.position;
                    
                    [self stormMove:stormCloud1 moveTo:position];
                    
                    lineNode.color = [SKColor greenColor];
                    lineNode4.color = [SKColor blackColor];
                    lineNode5.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if (![sun intersectsNode:emptyPlatform2] && [stormCloud1 intersectsNode:emptyPlatform]) {
                    CGPoint position = emptyPlatform2.position;
                    
                    [self stormMove:stormCloud1 moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    lineNode.color = [SKColor blackColor];
                    lineNode4.color = [SKColor greenColor];
                    lineNode5.color = [SKColor blackColor];
                }
                else if ([stormCloud2 intersectsNode:emptyPlatform] && ![sun intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud3 intersectsNode:emptyPlatform2]) {
                    CGPoint position = emptyPlatform2.position;
                    
                    [self stormMove:stormCloud2 moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    lineNode.color = [SKColor blackColor];
                    lineNode3.color = [SKColor greenColor];
                    lineNode4.color = [SKColor greenColor];
                }
                else if ([stormCloud3 intersectsNode:emptyPlatform2] && ![sun intersectsNode:emptyPlatform] && ![stormCloud1 intersectsNode:emptyPlatform] && ![stormCloud2 intersectsNode:emptyPlatform]) {
                    CGPoint position = emptyPlatform.position;
                    
                    [self stormMove:stormCloud3 moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    lineNode.color = [SKColor greenColor];
                    lineNode2.color = [SKColor greenColor];
                    lineNode3.color = [SKColor greenColor];
                    lineNode4.color = [SKColor blackColor];
                }
                else if ([stormCloud3 intersectsNode:emptyPlatform] && ![sun intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud2 intersectsNode:emptyPlatform2]) {
                    CGPoint position = emptyPlatform2.position;
                    
                    [self stormMove:stormCloud3 moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    
                    if ([stormCloud2 intersectsNode:emptyPlatform3] || [sun intersectsNode:emptyPlatform3] || [stormCloud1 intersectsNode:emptyPlatform3]) {
                        lineNode.color = [SKColor blackColor];
                    }else {
                        lineNode.color = [SKColor greenColor];
                    }
                    
                    lineNode2.color = [SKColor greenColor];
                    lineNode3.color = [SKColor blackColor];
                    lineNode4.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
            }
            
            else if ([n.name isEqualToString:@"linenode3"]) {
                if ([sun intersectsNode:emptyPlatform2]) {
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    CGPoint position = CGPointMake(endCloud.position.x, endCloud.position.y);
                    [self sunMove:sun moveTo:position];
                }
                else if ([stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform6] && ![stormCloud3 intersectsNode:emptyPlatform6] && ![sun intersectsNode:emptyPlatform6]) {
                    [self stormMove:stormCloud2 moveTo:emptyPlatform6.position];
                    
                    lineNode.color = [SKColor greenColor];
                    lineNode2.color = [SKColor greenColor];
                    lineNode5.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                
                else if ([sun intersectsNode:emptyPlatform6] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud3 intersectsNode:emptyPlatform2]) {
                    
                    CGPoint position = CGPointMake(emptyPlatform2.position.x, emptyPlatform2.position.y);
                    
                    [self sunMove:sun moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([stormCloud1 intersectsNode:emptyPlatform6] && ![stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud3 intersectsNode:emptyPlatform2] && ![sun intersectsNode:emptyPlatform2]) {
                    [self stormMove:stormCloud1 moveTo:emptyPlatform2.position];
                    if ([stormCloud2 intersectsNode:emptyPlatform3] || [sun intersectsNode:emptyPlatform3] || [stormCloud3 intersectsNode:emptyPlatform3]) {
                        lineNode.color = [SKColor blackColor];
                    } else {
                        lineNode.color = [SKColor greenColor];
                    }
                    if ([stormCloud2 intersectsNode:emptyPlatform] || [sun intersectsNode:emptyPlatform] || [stormCloud3 intersectsNode:emptyPlatform]) {
                        lineNode2.color = [SKColor blackColor];
                    }else {
                        lineNode2.color = [SKColor greenColor];
                    }
                    if ([stormCloud2 intersectsNode:emptyPlatform5] || [sun intersectsNode:emptyPlatform5] || [stormCloud3 intersectsNode:emptyPlatform5]) {
                        lineNode5.color = [SKColor blackColor];
                    }else {
                        lineNode5.color = [SKColor greenColor];
                    }
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([stormCloud2 intersectsNode:emptyPlatform6] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud3 intersectsNode:emptyPlatform2] && ![sun intersectsNode:emptyPlatform2]) {
                    [self stormMove:stormCloud2 moveTo:emptyPlatform2.position];
                    if ([stormCloud1 intersectsNode:emptyPlatform3] || [sun intersectsNode:emptyPlatform3] || [stormCloud3 intersectsNode:emptyPlatform3]) {
                        lineNode.color = [SKColor blackColor];
                    } else {
                        lineNode.color = [SKColor greenColor];
                    }
                    if ([stormCloud1 intersectsNode:emptyPlatform] || [sun intersectsNode:emptyPlatform] || [stormCloud3 intersectsNode:emptyPlatform]) {
                        lineNode2.color = [SKColor blackColor];
                    }else {
                        lineNode2.color = [SKColor greenColor];
                    }
                    if ([stormCloud1 intersectsNode:emptyPlatform5] || [sun intersectsNode:emptyPlatform5] || [stormCloud3 intersectsNode:emptyPlatform5]) {
                        lineNode5.color = [SKColor blackColor];
                    }else {
                        lineNode5.color = [SKColor greenColor];
                    }
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([stormCloud3 intersectsNode:emptyPlatform6] && ![stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![sun intersectsNode:emptyPlatform2]) {
                    [self stormMove:stormCloud1 moveTo:emptyPlatform2.position];
                    if ([stormCloud2 intersectsNode:emptyPlatform3] || [sun intersectsNode:emptyPlatform3] || [stormCloud1 intersectsNode:emptyPlatform3]) {
                        lineNode.color = [SKColor blackColor];
                    } else {
                        lineNode.color = [SKColor greenColor];
                    }
                    if ([stormCloud2 intersectsNode:emptyPlatform] || [sun intersectsNode:emptyPlatform] || [stormCloud1 intersectsNode:emptyPlatform]) {
                        lineNode2.color = [SKColor blackColor];
                    }else {
                        lineNode2.color = [SKColor greenColor];
                    }
                    if ([stormCloud2 intersectsNode:emptyPlatform5] || [sun intersectsNode:emptyPlatform5] || [stormCloud1 intersectsNode:emptyPlatform5]) {
                        lineNode5.color = [SKColor blackColor];
                    }else {
                        lineNode5.color = [SKColor greenColor];
                    }
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                
            }
            
            else if ([n.name isEqualToString:@"linenode4"]) {
                if ([stormCloud2 intersectsNode:emptyPlatform]) {
                    
                    CGPoint position = emptyPlatform4.position;
                    
                    [self stormMove:stormCloud2 moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    
                    lineNode2.color = [SKColor greenColor];
                    lineNode4.color = [SKColor greenColor];
                }
                else if ([stormCloud2 intersectsNode:emptyPlatform4] && ![stormCloud2 intersectsNode:emptyPlatform] && ![stormCloud3 intersectsNode:emptyPlatform] && ![sun intersectsNode:emptyPlatform]) {
                    CGPoint position = emptyPlatform.position;
                    
                    [self stormMove:stormCloud2 moveTo:position];
                    
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                    
                    if ([stormCloud2 intersectsNode:emptyPlatform2] || [sun intersectsNode:emptyPlatform2] || [stormCloud3 intersectsNode:emptyPlatform2]) {
                        lineNode2.color = [SKColor blackColor];
                    }else {
                        lineNode2.color = [SKColor greenColor];
                    }
                    lineNode4.color = [SKColor greenColor];
                }
            }
            
            else if ([n.name isEqualToString:@"linenode5"]) {
                if ([stormCloud3 intersectsNode:emptyPlatform5] && ![stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![sun intersectsNode:emptyPlatform2]) {
                    [self stormMove:stormCloud3 moveTo:emptyPlatform2.position];
                    lineNode.color = [SKColor blackColor];
                    if ([stormCloud2 intersectsNode:emptyPlatform] || [sun intersectsNode:emptyPlatform] || [stormCloud1 intersectsNode:emptyPlatform]) {
                        lineNode2.color = [SKColor blackColor];
                    }else {
                        lineNode2.color = [SKColor greenColor];
                    }
                    if ([stormCloud2 intersectsNode:emptyPlatform6] || [sun intersectsNode:emptyPlatform6] || [stormCloud1 intersectsNode:emptyPlatform6]) {
                        lineNode3.color = [SKColor blackColor];
                    }else {
                        lineNode3.color = [SKColor greenColor];
                    }
                    lineNode5.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([sun intersectsNode:emptyPlatform2] && ![stormCloud2 intersectsNode:emptyPlatform5] && ![stormCloud1 intersectsNode:emptyPlatform5] && ![stormCloud3 intersectsNode:emptyPlatform5]) {
                    [self sunMove:sun moveTo:CGPointMake(emptyPlatform5.position.x,emptyPlatform5.position.y + 10)];
                    
                    lineNode2.color = [SKColor greenColor];
                    if ([stormCloud2 intersectsNode:emptyPlatform6] || [sun intersectsNode:emptyPlatform6] || [stormCloud1 intersectsNode:emptyPlatform6]) {
                        lineNode3.color = [SKColor greenColor];
                    }else {
                        lineNode3.color = [SKColor blackColor];
                    }
                    lineNode5.color = [SKColor greenColor];
                    lineNode6.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([stormCloud3 intersectsNode:emptyPlatform2] && ![stormCloud2 intersectsNode:emptyPlatform5] && ![stormCloud1 intersectsNode:emptyPlatform5] && ![sun intersectsNode:emptyPlatform5]) {
                    [self stormMove:stormCloud3 moveTo:emptyPlatform5.position];
                    lineNode.color = [SKColor greenColor];
                    lineNode2.color = [SKColor greenColor];
                    lineNode3.color = [SKColor greenColor];
                    lineNode5.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud2 intersectsNode:emptyPlatform5] && ![stormCloud3 intersectsNode:emptyPlatform5] && ![sun intersectsNode:emptyPlatform5]) {
                    [self stormMove:stormCloud1 moveTo:emptyPlatform5.position];
                    lineNode.color = [SKColor greenColor];
                    lineNode2.color = [SKColor greenColor];
                    lineNode3.color = [SKColor greenColor];
                    lineNode5.color = [SKColor greenColor];
                    lineNode6.color = [SKColor blackColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
                else if ([sun intersectsNode:emptyPlatform5] && ![stormCloud2 intersectsNode:emptyPlatform2] && ![stormCloud1 intersectsNode:emptyPlatform2] && ![stormCloud3 intersectsNode:emptyPlatform2]) {
                    [self sunMove:sun moveTo:CGPointMake(emptyPlatform2.position.x,emptyPlatform2.position.y + 10)];
                    
                    lineNode2.color = [SKColor blackColor];
                    if ([stormCloud2 intersectsNode:emptyPlatform6] || [sun intersectsNode:emptyPlatform6] || [stormCloud1 intersectsNode:emptyPlatform6]) {
                        lineNode3.color = [SKColor blackColor];
                    }else {
                        lineNode3.color = [SKColor greenColor];
                    }
                    lineNode5.color = [SKColor greenColor];
                    lineNode6.color = [SKColor blackColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
            }
            
            else if ([n.name isEqualToString:@"linenode6"]) {
                if ([stormCloud3 intersectsNode:emptyPlatform5]) {
                    [self stormMove:stormCloud3 moveTo:emptyPlatform6.position];
                    lineNode5.color = [SKColor greenColor];
                    _moveCount += 1;
                    _stepCount.text = [NSString stringWithFormat:@"%d", _moveCount];
                }
            }

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
//                [self loadNextLevel];
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
    _timeNode.text = [NSString stringWithFormat:@"%d",time];
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
    sun = [SKSpriteNode spriteNodeWithTexture:sunTexture];
    endCloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloudPlatforms"];
    whiteCloud = [SKTexture textureWithImageNamed:@"cloudPlatforms"];
    whiteCloud1 = [SKSpriteNode spriteNodeWithTexture:whiteCloud];
    whiteCloud2 = [SKSpriteNode spriteNodeWithTexture:whiteCloud];
    stormCloud1 = [SKSpriteNode spriteNodeWithImageNamed:@"stormCloudThirdEye"];
    stormCloud2 = [SKSpriteNode spriteNodeWithImageNamed:@"stormCloudThirdEye"];
    stormCloud3 = [SKSpriteNode spriteNodeWithImageNamed:@"stormCloudThirdEye"];
    stormCloud4 = [SKSpriteNode spriteNodeWithImageNamed:@"stormCloudThirdEye"];
    stormCloud5 = [SKSpriteNode spriteNodeWithImageNamed:@"stormCloudThirdEye"];
    stormCloud6 = [SKSpriteNode spriteNodeWithImageNamed:@"stormCloud"];
    
    emptyPlatform = [SKSpriteNode spriteNodeWithTexture:platform];
    emptyPlatform2 = [SKSpriteNode spriteNodeWithTexture:platform];
    emptyPlatform3 = [SKSpriteNode spriteNodeWithTexture:platform];
    emptyPlatform4 = [SKSpriteNode spriteNodeWithTexture:platform];
    emptyPlatform5 = [SKSpriteNode spriteNodeWithTexture:platform];
    emptyPlatform6 = [SKSpriteNode spriteNodeWithTexture:platform];
    
    introNode = [SKSpriteNode spriteNodeWithImageNamed:@"introLevel2"];
    introNode.name = @"intronode";
    introNode.scale = 0;
    introNode.position = CGPointMake(_stepButton.position.x, _stepButton.position.y);
    
    sun.position = CGPointMake(self.size.width / 2 + 10, 40);
    sunStartPosition = sun.position;
    sun.name = @"sun";
    sun.scale = sunNormal;
    
    endCloud.position = CGPointMake(self.size.width/2 + 10, self.size.height - 100);
    endCloud.Name = @"endcloud";
    endCloud.scale = .5;
    
    whiteCloud1.position = CGPointMake(endCloud.position.x - 20, endCloud.position.y - 5);
    whiteCloud1.scale = 0.5;
    
    whiteCloud2.position = CGPointMake(endCloud.position.x + 20, endCloud.position.y - 5);
    whiteCloud2.scale = 0.5;
    
    emptyPlatform.name = @"emptyplatform";
    emptyPlatform.scale = emptyPlatformScale;
    emptyPlatform.position = CGPointMake(self.size.width - 30, (self.size.height / 2) - 60);
    
    emptyPlatform2.name = @"emptyplatform2";
    emptyPlatform2.scale = emptyPlatformScale;
    emptyPlatform2.position = CGPointMake(self.size.width / 2 + 10, self.size.height/2 - 40);
    
    emptyPlatform3.name = @"emptyplatform3";
    emptyPlatform3.scale = emptyPlatformScale;
    emptyPlatform3.position = CGPointMake(sun.position.x, sun.position.y - 10);
    
    emptyPlatform4.name = @"emptyplatform4";
    emptyPlatform4.scale = emptyPlatformScale;
    emptyPlatform4.position = CGPointMake(emptyPlatform.position.x, emptyPlatform.position.y - 150);
    
    emptyPlatform5.name = @"emptyplatform5";
    emptyPlatform5.scale = emptyPlatformScale;
    emptyPlatform5.position = CGPointMake(emptyPlatform2.position.x - 140, emptyPlatform.position.y);
    
    emptyPlatform6.position = CGPointMake(emptyPlatform5.position.x + 5, emptyPlatform4.position.y);
    emptyPlatform6.name = @"emptyplatform6";
    emptyPlatform6.scale = emptyPlatformScale;
    
    stormCloud1.name = @"stormcloud1";
    stormCloud1.scale = stormNormal;
    stormCloud1.position = CGPointMake(emptyPlatform2.position.x, emptyPlatform2.position.y - 10);
    storm1StartPosition = stormCloud1.position;
    
    stormCloud2.name = @"stormcloud2";
    stormCloud2.scale = stormNormal;
    stormCloud2.position = CGPointMake(emptyPlatform.position.x, emptyPlatform.position.y - 10);
    
    stormCloud3.name = @"stormcloud3";
    stormCloud3.scale = stormNormal;
    stormCloud3.position = CGPointMake(emptyPlatform5.position.x, emptyPlatform5.position.y - 10);
    
    lineNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(lineWidth, emptyPlatform2.position.y - emptyPlatform3.position.y)];
    lineNode2 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(emptyPlatform.position.x - emptyPlatform2.position.x - 30, lineWidth)];
    lineNode3 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(lineWidth, endCloud.position.y - emptyPlatform2.position.y)];
    lineNode4 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(lineWidth, emptyPlatform.position.y - emptyPlatform4.position.y)];
    lineNode5 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(emptyPlatform2.position.x - emptyPlatform5.position.x - 24, lineWidth)];
    lineNode6 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(lineWidth, emptyPlatform5.position.y - emptyPlatform6.position.y)];
    
    lineNode.position = CGPointMake(self.size.width /2, emptyPlatform3.position.y);
    lineNode.alpha = 0.62;
    lineNode.anchorPoint = CGPointMake(0, 0);
    lineNode.name = @"linenode1";
    lineNode.color = [SKColor blackColor];
    
    lineNode2.position = CGPointMake(emptyPlatform2.position.x + 15, emptyPlatform2.position.y - 17);
    lineNode2.alpha = 0.62;
    lineNode2.anchorPoint = CGPointMake(0, 0);
    lineNode2.zRotation = M_PI * 1.94;
    lineNode2.name = @"linenode2";
    lineNode2.color = [SKColor blackColor];
    
    lineNode3.position = CGPointMake(self.size.width / 2, emptyPlatform2.position.y);
    lineNode3.alpha = 0.62;
    lineNode3.anchorPoint = CGPointMake(0, 0);
    lineNode3.name = @"linenode3";
    lineNode3.color = [SKColor blackColor];
    
    lineNode4.position = CGPointMake(emptyPlatform4.position.x - 15, emptyPlatform4.position.y );
    lineNode4.alpha = 0.62;
    lineNode4.anchorPoint = CGPointMake(0, 0);
    lineNode4.color = [SKColor greenColor];
    lineNode4.name = @"linenode4";
    
    lineNode5.position = CGPointMake(emptyPlatform5.position.x + 16, emptyPlatform5.position.y - 20);
    lineNode5.alpha = 0.62;
    lineNode5.anchorPoint = CGPointMake(0,0);
    lineNode5.zRotation = M_PI * 2.055;
    lineNode5.name = @"linenode5";
    
    lineNode6.position = CGPointMake(emptyPlatform6.position.x - 15, emptyPlatform6.position.y);
    lineNode6.alpha = 0.62;
    lineNode6.anchorPoint = CGPointMake(0, 0);
    lineNode6.name = @"linenode6";
    lineNode6.color = [SKColor greenColor];
    
    
    
    SKEmitterNode *rain =
    [NSKeyedUnarchiver unarchiveObjectWithFile:
     [[NSBundle mainBundle] pathForResource:@"MyParticle"
                                     ofType:@"sks"]];
    rain.position = rainPosition;
    rain.scale = 1;
    rain.name = @"rain";
    
    SKEmitterNode *rain2 =
    [NSKeyedUnarchiver unarchiveObjectWithFile:
     [[NSBundle mainBundle] pathForResource:@"MyParticle"
                                     ofType:@"sks"]];
    rain2.position = rainPosition;
    rain2.scale = 1;
    rain2.name = @"rain";
    
    SKEmitterNode *rain3 =
    [NSKeyedUnarchiver unarchiveObjectWithFile:
     [[NSBundle mainBundle] pathForResource:@"MyParticle"
                                     ofType:@"sks"]];
    rain3.position = rainPosition;
    rain3.scale = 1;
    rain3.name = @"rain";
    
    [_menuLayer addChild:lineNode];
    [_menuLayer addChild:lineNode2];
    [_menuLayer addChild:lineNode3];
    [_menuLayer addChild:lineNode4];
    [_menuLayer addChild:lineNode5];
    [_menuLayer addChild:lineNode6];
    
    [_menuLayer addChild:emptyPlatform];
    [_menuLayer addChild:emptyPlatform3];
    [_menuLayer addChild:emptyPlatform2];
    [_menuLayer addChild:emptyPlatform4];
    [_menuLayer addChild:emptyPlatform5];
    [_menuLayer addChild:emptyPlatform6];
    
    [_menuLayer addChild:whiteCloud1];
    [_menuLayer addChild:whiteCloud2];
    [_menuLayer addChild:endCloud];
    
    [_menuLayer addChild:stormCloud1];
    [stormCloud1 addChild:rain];
    [_menuLayer addChild:stormCloud2];
    [stormCloud2 addChild:rain2];
    [_menuLayer addChild:stormCloud3];
    [stormCloud3 addChild:rain3];
    
    [_menuLayer addChild:sun];
    [_menuLayer addChild:introNode];
    
    SKAction *wait = [SKAction waitForDuration:.3];
    SKAction *move = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height/2) duration:.4];
    SKAction *flip = [SKAction rotateByAngle:M_PI * 2 duration:0.5];
    SKAction *scale = [SKAction scaleTo:.4 duration:.5];
    SKAction *group = [SKAction group:@[flip, scale, move]];
    [introNode runAction:[SKAction sequence:@[wait,group]]];
    
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

- (void)sunMove:(SKSpriteNode*)node moveTo:(CGPoint)position {
    [self playClickSound];
    
    SKAction *moveTo = [SKAction moveTo:position duration:sunSpeed];
    SKAction *bounce = [SKAction scaleTo:sunBounce duration:.1];
    SKAction *bounceBack = [SKAction scaleTo:sunBounceBack duration:.1];
    SKAction *normalSize = [SKAction scaleTo:sunNormal duration:.1];
    
    [node runAction:[SKAction group:@[[SKAction sequence:@[bounce, bounceBack, normalSize]], moveTo]]];
}

- (void)stormMove:(SKSpriteNode*)node moveTo:(CGPoint)position {
    [self playClickSound];
    
    SKAction *bounce = [SKAction scaleTo:stormBounce duration:.1];
    SKAction *bounceBack = [SKAction scaleTo:stormBounceBack duration:.1];
    SKAction *normalSize = [SKAction scaleTo:stormNormal duration:.1];
    SKAction *move = [SKAction moveTo:position duration:.4];
    SKAction *sequence = [SKAction sequence:@[bounce, bounceBack, normalSize, bounce, bounceBack, normalSize]];
    
    [node runAction:[SKAction group:@[sequence, move]]];
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
    
    [self playSwooshSound];
    
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
    
    if (![GameData sharedGameData].level3Beat) {
        [GameData sharedGameData].level3Beat = YES;
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
    
//    CGPoint nextButtonPosition = CGPointMake(self.size.width / 2 + 90, self.size.height / 2 - 150);
//    _nextButton = [SKSpriteNode spriteNodeWithImageNamed:@"nextbutton"];
//    _nextButton.name = @"nextButton";
//    _nextButton.scale = 0.0;
//    _nextButton.position = nextButtonPosition;
//    [_menuLayer addChild:_nextButton];
    
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
    
    int x = gameTime - time;
    timeScore = (highestTimeScore - (subtractPerSecond * x));
    NSLog(@"%d",timeScore);
    _timeUsed = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _timeUsed.text = [NSString stringWithFormat:@"%d seconds",x];
    _timeUsed.fontColor = [SKColor whiteColor];
    _timeUsed.fontSize = 20.0;
    _timeUsed.position = CGPointMake(self.size.width / 2 + 40, self.size.height / 2 - 26);
    [self addChild:_timeUsed];
    
    _numberOfMoves = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _numberOfMoves.text = [NSString stringWithFormat:@"%d",_moveCount];
    _numberOfMoves.fontColor = [SKColor whiteColor];
    _numberOfMoves.fontSize = 20.0;
    _numberOfMoves.position = CGPointMake(self.size.width / 2, self.size.height /2 - 4);
    [self addChild:_numberOfMoves];
    
    int scoreTotal = moveScore + timeScore;
    
    _score = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _score.text = [NSString stringWithFormat:@"%d",scoreTotal];
    _score.fontColor = [SKColor whiteColor];
    _score.fontSize = 20.0;
    _score.position = CGPointMake(self.size.width /2 + 10, self.size.height / 2 - 50);
    [self addChild:_score];
    NSLog(@"%d",scoreTotal);
    
    if (![GameData sharedGameData].level4HighScore) {
        [GameData sharedGameData].level4HighScore = scoreTotal;
        [[GameData sharedGameData]save];
    }
    
    if ([GameData sharedGameData].level4HighScore) {
        if (scoreTotal > [GameData sharedGameData].level4HighScore) {
            [GameData sharedGameData].level4HighScore = scoreTotal;
            [[GameData sharedGameData]save];
        }
    }
    
    _highScore = [SKLabelNode labelNodeWithFontNamed:@"haveltica"];
    _highScore.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].level4HighScore];
    _highScore.fontColor = [SKColor whiteColor];
    _highScore.fontSize = 20.0;
    _highScore.position = CGPointMake(self.size.width / 2 + 10, self.size.height / 2 - 95);
    [self addChild:_highScore];
}

- (void)restartLevel {
    [_loseSound fadeOut:0.5];
    SKTransition *reveal = [SKTransition flipVerticalWithDuration:.5];
    SKScene *level = [[Level4 alloc]initWithSize:self.size];
    [self.view presentScene:level transition:reveal];
}

//- (void)loadNextLevel {
//    SKTransition *reveal = [SKTransition flipVerticalWithDuration:.5];
//    SKScene *level = [[Level5 alloc]initWithSize:self.size];
//    [self.view presentScene:level transition:reveal];
//}

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
