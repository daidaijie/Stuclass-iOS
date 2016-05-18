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
#import "Exam.h"
#import "Document.h"
#import "Define.h"

@interface ClassParser ()

@property (strong, nonatomic) NSMutableArray *colorArray;

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
    
    NSMutableArray *boxData = [NSMutableArray array];
    
    classData = [NSMutableArray arrayWithArray:classData];
    
    for (NSDictionary *class in classData) {
        
        NSDictionary *days = class[@"days"];
        
        // color
        NSUInteger order = [class[@"order"] integerValue];
        UIColor *color = _colorArray[order % 14];
        
        for (NSString *key in days) {
            
            if (![days[key] isEqualToString:@"None"]) {
                
                // 找到课
                
                // 基本信息
                
                ClassBox *box = [[ClassBox alloc] init];
                
                box.box_id = class[@"class_id"];
                box.box_number = class[@"id"];
                box.box_name = class[@"name"];
                box.box_room = class[@"room"];
                
                // Span
                NSString *spanStr = [class[@"duration"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSArray *spanArray = [spanStr componentsSeparatedByString:@"-"];
                NSInteger start = [spanArray[0] integerValue];
                NSInteger end = [spanArray[1] integerValue];
                NSArray *spanData = @[[NSNumber numberWithInt:start], [NSNumber numberWithInt:end]];
                box.box_span = spanData;
                
                box.box_teacher = class[@"teacher"];
                box.box_credit = class[@"credit"];
                box.box_color = color;
                
                box.box_isColorful = [class[@"isColorful"] boolValue];
                box.box_isClass  = [class[@"isClass"] boolValue];
                box.box_description = class[@"description"];
                
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
                    ClassBox *newBox = [box copyClassBox];
                    newBox.box_y = [yAndLength[0] integerValue];
                    newBox.box_length = [yAndLength[1] integerValue];
                    [boxData addObject:newBox];
                }
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
    // 去掉中文开头 // 3467
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
    float gpaFloat = [gradeData[@"GPA"] floatValue];
    int gpaInt = (gpaFloat * 1000);
    NSString *gpa = [NSString stringWithFormat:@"%.3f", gpaInt / 1000.0];
    
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
            
            if (grade.name) {
                [gradeArray addObject:grade];
            }
        }
        
        if (gradeArray.count > 0) {
            [semesterArray addObject:@{@"year": year, @"semester": semester, @"grades": gradeArray}];
        }
    }
    
    NSDictionary *resultData = @{@"gpa": gpa, @"semesters": semesterArray};
    
    return resultData;
}


#pragma mark - Exam Parser

- (NSMutableArray *)parseExamData:(NSDictionary *)examData
{
    // parse
    
    NSMutableArray *examArray = [NSMutableArray array];
    
    for (NSDictionary *dict in examData[@"EXAMS"]) {
        
        Exam *exam = [[Exam alloc] init];
        
        exam.name = dict[@"exam_class"];
        exam.number = dict[@"exam_class_number"];
        exam.teacher = dict[@"exam_main_teacher"];
        exam.invigilator = dict[@"exam_invigilator"];
        exam.location = dict[@"exam_location"];
        
        exam.comment = [dict[@"exam_comment"] isEqualToString:@""] ? @"无" : dict[@"exam_comment"];
        
        exam.amount = dict[@"exam_stu_numbers"];
        exam.position = dict[@"exam_stu_position"];
        exam.time = dict[@"exam_time"];
        
        [examArray addObject:exam];
    }
    
    return examArray;
}


#pragma mark - OA Parser

- (NSMutableArray *)parseDocumentData:(NSArray *)documentData
{
    // parse
    
    NSMutableArray *documentArray = [NSMutableArray array];
    
    for (NSDictionary *dict in documentData) {
        
        NSString *date = dict[@"DOCVALIDDATE"];
        
        if (![date isEqual:[NSNull null]]) {
            
            Document *document = [[Document alloc] init];
            
            NSString *title = dict[@"DOCSUBJECT"];
            if (![title isEqual:[NSNull null]]) {
                document.title = title;
            } else {
                document.title = @"没有标题";
            }
            
            NSString *content = dict[@"DOCCONTENT"];
            if (![content isEqual:[NSNull null]]) {
                
                // 去掉!@#$%^&*
                NSArray *seperates = [content componentsSeparatedByString:@"!@#$\%^&*"];
                
                document.content = [seperates lastObject]
                ;
            } else {
                document.content = @"没有内容";
            }
            
            NSString *department = dict[@"SUBCOMPANYNAME"];
            if (![department isEqual:[NSNull null]]) {
                document.department = department;
            } else {
                document.department = @"没有部门";
            }
            
            document.date = dict[@"DOCVALIDDATE"];
            
            [documentArray addObject:document];
        }
    }
    
    return documentArray;
}


@end


















