//
//  GameData.m
//  Tim's Tower
//
//  Created by John Goure on 6/17/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import "GameData.h"

@implementation GameData

static NSString* const SSGameDataStepCountKey = @"stepCount";
static NSString* const SSGameDataGoldCountKey = @"goldCount";
static NSString* const SSGameDataLevelCountKey = @"levelcount";
static NSString* const SSGameDataLevel1HighScore = @"level1highscore";
static NSString* const SSGameDataLevel2HighScore = @"level2highscore";
static NSString* const SSGameDataLevel3HighScore = @"level3highscore";
static NSString* const SSGameDataLevel4HighScore = @"level4highscore";
static NSString* const SSGameDataLevel5HighScore = @"level5highscore";
static NSString* const SSGameDataLevel1Beat = @"level1beat";
static NSString* const SSGameDataLevel2Beat = @"level2beat";
static NSString* const SSGameDataLevel3Beat = @"level3beat";
static NSString* const SSGameDataLevel4Beat = @"level4beat";
static NSString* const SSGameDataLevel5Beat = @"level5beat";
static NSString* const SSGameDataLevel6Beat = @"level6beat";
static NSString* const SSGameDataLevel7Beat = @"level7beat";
static NSString* const SSGameDataLevel8Beat = @"level8beat";
static NSString* const SSGameDataLevel9Beat = @"level9beat";
static NSString* const SSGameDataLevel10Beat = @"level10beat";

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeDouble:self.numberOfStepsCount forKey:SSGameDataStepCountKey];
    [encoder encodeDouble:self.levelCount forKey:SSGameDataLevelCountKey];
    [encoder encodeDouble:self.level1HighScore forKey:SSGameDataLevel1HighScore];
    [encoder encodeDouble:self.level2HighScore forKey:SSGameDataLevel2HighScore];
    [encoder encodeDouble:self.level3HighScore forKey:SSGameDataLevel3HighScore];
    [encoder encodeDouble:self.level4HighScore forKey:SSGameDataLevel4HighScore];
    [encoder encodeDouble:self.level5HighScore forKey:SSGameDataLevel5HighScore];
    
    [encoder encodeDouble:self.level1Beat forKey:SSGameDataLevel1Beat];
    [encoder encodeDouble:self.level2Beat forKey:SSGameDataLevel2Beat];
    [encoder encodeDouble:self.level3Beat forKey:SSGameDataLevel3Beat];
    [encoder encodeDouble:self.level4Beat forKey:SSGameDataLevel4Beat];
    [encoder encodeDouble:self.level5Beat forKey:SSGameDataLevel5Beat];
    [encoder encodeDouble:self.level6Beat forKey:SSGameDataLevel6Beat];
    [encoder encodeDouble:self.level7Beat forKey:SSGameDataLevel7Beat];
    [encoder encodeDouble:self.level8Beat forKey:SSGameDataLevel8Beat];
    [encoder encodeDouble:self.level9Beat forKey:SSGameDataLevel9Beat];
    [encoder encodeDouble:self.level10Beat forKey:SSGameDataLevel10Beat];
}

- (instancetype)initWithCoder:(NSCoder*)decoder {
    
    self = [self init];
    if (self) {
        _numberOfStepsCount = [decoder decodeDoubleForKey:SSGameDataStepCountKey];
        _levelCount = [decoder decodeDoubleForKey:SSGameDataLevelCountKey];
        _level1HighScore = [decoder decodeDoubleForKey:SSGameDataLevel1HighScore];
        _level2HighScore = [decoder decodeDoubleForKey:SSGameDataLevel2HighScore];
        _level3HighScore = [decoder decodeDoubleForKey:SSGameDataLevel3HighScore];
        _level4HighScore = [decoder decodeDoubleForKey:SSGameDataLevel4HighScore];
        _level5HighScore = [decoder decodeDoubleForKey:SSGameDataLevel5HighScore];
        
        _level1Beat = [decoder decodeDoubleForKey:SSGameDataLevel1Beat];
        _level2Beat = [decoder decodeDoubleForKey:SSGameDataLevel2Beat];
        _level3Beat = [decoder decodeDoubleForKey:SSGameDataLevel3Beat];
        _level4Beat = [decoder decodeDoubleForKey:SSGameDataLevel4Beat];
        _level5Beat = [decoder decodeDoubleForKey:SSGameDataLevel5Beat];
        _level6Beat = [decoder decodeDoubleForKey:SSGameDataLevel6Beat];
        _level7Beat = [decoder decodeDoubleForKey:SSGameDataLevel7Beat];
        _level8Beat = [decoder decodeDoubleForKey:SSGameDataLevel8Beat];
        _level9Beat = [decoder decodeDoubleForKey:SSGameDataLevel9Beat];
        _level10Beat = [decoder decodeDoubleForKey:SSGameDataLevel10Beat];
    }
    return self;
}

+ (NSString*)filePath {
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

+ (instancetype)loadInstance {
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    return [[GameData alloc] init];
}

- (void)save {
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
    NSLog(@"saved instance");
}

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

- (void)reset {
    _level1Beat = NO;
    _level1HighScore = 0;
    _level2Beat = NO;
    _level2HighScore = 0;
    _level3Beat = NO;
    _level3HighScore = 0;
    _level4Beat = NO;
    _level4HighScore = 0;
    _level5Beat = NO;
    _level5HighScore = 0;
    [self save];
    NSLog(@"reset and saved");
}
@end
