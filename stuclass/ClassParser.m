//
//  ClassParser.m
//  stuclass
//
//  Created by JunhaoWang on 10/14/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassParser.h"
#import "NSMutableArray+Shuffle.h"
#import "ClassBox.h"
#import "Grade.h"
#import "Define.h"

@interface ClassParser ()

@property (strong, nonatomic) NSMutableArray *colorArray;

@property (assign, nonatomic) NSInteger colorIndex;

@end

@implementation ClassParser

+ (instancetype)sharedInstance {
    
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initColorArray];
    }
    
    return self;
}



- (void)initColorArray
{
    _colorArray = [NSMutableArray arrayWithArray:COLOR_ARRAY];
}


#pragma mark - ParseClassData - BoxData

- (NSMutableArray *)parseClassData:(NSArray *)classData
{
    _colorIndex = 0;
    
    NSMutableArray *boxData = [NSMutableArray array];
    
    for (NSDictionary *class in classData) {
        
        NSDictionary *days = class[@"days"];
        
        // color
        UIColor *color = (_colorIndex < _colorArray.count) ? _colorArray[_colorIndex] : [UIColor orangeColor];
        
        _colorIndex++;
        
        for (NSString *key in days) {
            
            if (![days[key] isEqualToString:@"None"]) {
                
                // 找到课
                
                // 基本信息
                
                ClassBox *box = [[ClassBox alloc] init];
                
                box.box_id = class[@"class_id"];
                box.box_number = class[@"id"];
                box.box_name = class[@"name"];
                box.box_room = class[@"room"];
                box.box_span = [class[@"duration"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                box.box_teacher = class[@"teacher"];
                box.box_credit = class[@"credit"];
                box.box_color = color;
                
                
                NSString *weekStr = key;
                box.box_x = [self generateCoordinateX:weekStr];
                
                
                NSString *numStr = days[key];
                
                // weekType
                NSString *weekType = @"";
                if ([numStr hasPrefix:@"单"]) {
                    weekType = @"单";
                } else if ([numStr hasPrefix:@"双"]) {
                    weekType = @"双";
                }
                box.box_weekType = weekType;
                
                NSArray *yAndLengthArray = [self generateCoordinateYAndLengthArray:numStr];
                
                for (NSArray *yAndLength in yAndLengthArray) {
                    
                    box.box_y = [yAndLength[0] integerValue];
                    box.box_length = [yAndLength[1] integerValue];
                    
                    [boxData addObject:box];
                }
//                NSLog(@"%@ - %@", box.box_name, yAndLengthArray);
            }
        }
    }
    
    return boxData;
}

- (NSInteger)generateCoordinateX:(NSString *)weekStr
{
    // week
    NSInteger week = 0;
    
    if ([weekStr isEqualToString:@"w1"]) {
        week = 0;
    } else if ([weekStr isEqualToString:@"w2"]) {
        week = 1;
    } else if ([weekStr isEqualToString:@"w3"]) {
        week = 2;
    } else if ([weekStr isEqualToString:@"w4"]) {
        week = 3;
    } else if ([weekStr isEqualToString:@"w5"]) {
        week = 4;
    } else if ([weekStr isEqualToString:@"w6"]) {
        week = 5;
    } else if ([weekStr isEqualToString:@"w0"]) {
        week = 6;
    }
    
    return week;
}



- (NSMutableArray *)generateCoordinateYAndLengthArray:(NSString *)numStr
{
    // 去掉中文开头
    if ([numStr hasPrefix:@"单"] || [numStr hasPrefix:@"双"]) {
        numStr = [numStr substringWithRange:NSMakeRange(1, numStr.length-1)];
    }
    
    // numArray C
    NSInteger numCount = numStr.length;
    NSInteger numArray[numCount];
    
    // numStr -> numArray
    for (NSInteger i = 0; i < numCount; i++) {
        // 取到字符
        NSString *ch = [numStr substringWithRange:NSMakeRange(i, 1)];
        
        // 替换成数字
        if ([ch isEqualToString:@"0"]) {
            ch = @"10";
        } else if ([ch isEqualToString:@"A"]) {
            ch = @"11";
        } else if ([ch isEqualToString:@"B"]) {
            ch = @"12";
        } else if ([ch isEqualToString:@"C"]) {
            ch = @"13";
        }
        
        NSInteger num = [ch integerValue];
        
        num--; // 索引从0开始
        
        numArray[i] = num;
    }
    
    // YAndLength
    NSMutableArray *result = [NSMutableArray array];
    
    // 看看这天有多少不是连续的分块
    NSInteger lastNum = 0;  // 上一个数字
    NSInteger length = 0;   // 积累长度
    NSInteger startNum = 0;
    
    for (NSInteger i = 0; i < numCount; i++) {
        
        NSInteger num = numArray[i];
        
        // 长度累增
        length++;
        
        // 第一个
        if (i == 0) {
            startNum = num;
        } else if ((num - lastNum) != 1) {
            // 断了
            [result addObject:@[[NSNumber numberWithInteger:startNum], [NSNumber numberWithInteger:length - 1]]];
            startNum = num;
            length = 1;
        }
        
        // 最后一个
        if (i == (numStr.length - 1)) {
            [result addObject:@[[NSNumber numberWithInteger:startNum], [NSNumber numberWithInteger:length]]];
        }
        
        // 记录上一个数
        lastNum = num;
    }
    
    
    return result;
}

- (NSArray *)generateCollectionCoordinateWithWeekStr:(NSString *)weekStr numStr:(NSString *)numStr
{
    // 去掉中文开头
    if ([numStr hasPrefix:@"单"] || [numStr hasPrefix:@"双"]) {
        numStr = [numStr substringWithRange:NSMakeRange(1, numStr.length-1)];
    }
    
    // week
    NSInteger week = 0;
    
    if ([weekStr isEqualToString:@"w1"]) {
        week = 0;
    } else if ([weekStr isEqualToString:@"w2"]) {
        week = 1;
    } else if ([weekStr isEqualToString:@"w3"]) {
        week = 2;
    } else if ([weekStr isEqualToString:@"w4"]) {
        week = 3;
    } else if ([weekStr isEqualToString:@"w5"]) {
        week = 4;
    } else if ([weekStr isEqualToString:@"w6"]) {
        week = 5;
    } else if ([weekStr isEqualToString:@"w0"]) {
        week = 6;
    }
    
    // length
    NSInteger length = numStr.length;
    
    // num
    NSInteger num = 1;
    
    // 取第一个字符
    numStr = [numStr substringWithRange:NSMakeRange(0, 1)];
    
    // 针对特殊处理
    if ([numStr isEqualToString:@"0"]) {
        numStr = @"10";
    } else if ([numStr isEqualToString:@"A"]) {
        numStr = @"11";
    } else if ([numStr isEqualToString:@"B"]) {
        numStr = @"12";
    } else if ([numStr isEqualToString:@"C"]) {
        numStr = @"13";
    }
    
    num = [numStr integerValue];
    
    num--;  // 索引从0开始
    
    return @[[NSNumber numberWithInteger:week], [NSNumber numberWithInteger:num], [NSNumber numberWithInteger:length]];
}


#pragma mark - Class_ID
- (NSArray *)generateClassIDForOriginalData:(NSMutableArray *)originalData withYear:(NSInteger)year semester:(NSInteger)semester
{
    NSMutableArray *classData = [NSMutableArray array];
    
    for (NSDictionary *dict in originalData) {
        
        NSMutableDictionary *class = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSString *class_id = [NSString stringWithFormat:@"%d_%d_%d_%@", year, year + 1, semester, class[@"id"]];
        
        [class setValue:class_id forKey:@"class_id"];  // 和id不同
        
        [classData addObject:class];
    }
    
    return classData;
}


#pragma mark - Grade Parser

- (NSDictionary *)parseGradeData:(NSDictionary *)gradeData
{
    // parse
    float gpa = [gradeData[@"GPA"] floatValue];
    
    NSMutableArray *semesterArray = [NSMutableArray array];
    
    for (NSArray *gradeOfSemester in gradeData[@"GRADES"]) {
        // semester
        
        NSString *year = @"";
        NSString *semester = @"";
        
        NSMutableArray *gradeArray = [NSMutableArray array];
        
        for (NSDictionary *gradeDict in gradeOfSemester) {
            // grade
            Grade *grade = [[Grade alloc] init];
            
            grade.credit = gradeDict[@"class_credit"];
            grade.grade = gradeDict[@"class_grade"];
            grade.name = gradeDict[@"class_name"];
            
            year = gradeDict[@"years"];
            semester = gradeDict[@"semester"];
            
            [gradeArray addObject:grade];
        }
        
        [semesterArray addObject:@{@"year": year, @"semester": semester, @"grades": gradeArray}];
    }
    
    NSDictionary *resultData = @{@"gpa": [NSString stringWithFormat:@"%.3f", gpa], @"semesters": semesterArray};
    
    NSLog(@"%@", resultData);
    
    return resultData;
}

@end


















