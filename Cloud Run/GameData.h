//
//  GameData.h
//  Tim's Tower
//
//  Created by John Goure on 6/17/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject

@property (assign, nonatomic) long numberOfSteps;
@property (assign, nonatomic) int level;
@property (assign, nonatomic) int score;

@property (assign, nonatomic) long numberOfStepsCount;
@property (assign, nonatomic) long level1HighScore;
@property (assign, nonatomic) long level2HighScore;
@property (assign, nonatomic) long level3HighScore;
@property (assign, nonatomic) long level4HighScore;
@property (assign, nonatomic) long level5HighScore;
@property (assign, nonatomic) long levelCount;

@property (assign, nonatomic) BOOL level1Beat;
@property (assign, nonatomic) BOOL level2Beat;
@property (assign, nonatomic) BOOL level3Beat;
@property (assign, nonatomic) BOOL level4Beat;
@property (assign, nonatomic) BOOL level5Beat;
@property (assign, nonatomic) BOOL level6Beat;
@property (assign, nonatomic) BOOL level7Beat;
@property (assign, nonatomic) BOOL level8Beat;
@property (assign, nonatomic) BOOL level9Beat;
@property (assign, nonatomic) BOOL level10Beat;

+(instancetype)sharedGameData;
-(void)reset;
-(void)save;

@end
