//
//  Define.h
//  stuclass
//
//  Created by JunhaoWang on 10/9/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

// Theme Color
#define MAIN_COLOR [UIColor colorWithRed:0.745 green:0.298 blue:0.235 alpha:1.000]

#define MAIN_COLOR_BAR [UIColor colorWithRed:0.706 green:0.184 blue:0.114 alpha:1.000]

#define BOTTOM_LINE_COLOR [UIColor colorWithRed:0.867 green:0.878 blue:0.886 alpha:1.000]

#define TABLEVIEW_BACKGROUN_COLOR [UIColor colorWithWhite:0.9 alpha:1.000]

#define TASKLIST_LEVEL_0_COLOR [UIColor colorWithRed:0.318 green:0.729 blue:0.949 alpha:1.000]

#define TASKLIST_LEVEL_1_COLOR [UIColor colorWithRed:0.957 green:0.804 blue:0.337 alpha:1.000]

#define TASKLIST_LEVEL_2_COLOR [UIColor colorWithRed:0.992 green:0.392 blue:0.380 alpha:1.000]

#define TASKLIST_DONE [UIColor colorWithRed:0.443 green:0.792 blue:0.345 alpha:1.000]

#define TASKLIST_DELETE [UIColor colorWithRed:0.992 green:0.392 blue:0.380 alpha:1.000]

#define TASKLIST_REDO [UIColor colorWithRed:0.969 green:0.651 blue:0.314 alpha:1.000]

#define GRAY_BOX_COLOR [UIColor colorWithWhite:0.72 alpha:1.0]

// Notice Title
static NSString *global_connection_failed = @"噫，服务器出了点问题T^T";

static NSString *global_connection_wrong_token = @"该账号曾在别处登录，请重新登录";

static NSString *global_connection_wrong_user_password = @"账号或密码有误，请重新登录";

static NSString *global_connection_credit_broken = @"天哪！学分制系统崩溃了！";

// Constant
static const NSTimeInterval global_hud_delay = 1.2;

static const NSTimeInterval global_hud_short_delay = 1.0;

static const NSTimeInterval global_hud_long_delay = 1.6;

static const NSTimeInterval global_timeout = 8.0;

static const NSTimeInterval global_like_timeout = 4.0;

static const NSTimeInterval member_timeout = 4.0;

static const NSTimeInterval login_timeout = 2.0;

static const CGFloat global_BarViewHeight = 43.0;

static const CGFloat global_textView_RowHeightFor4 = 118;

static const CGFloat global_textView_RowHeightFor5 = 206;

static const CGFloat global_textView_RowHeightFor6 = 298;

static const CGFloat global_textView_RowHeightFor6p = 354;


// url
static NSString *global_old_host = @"http://121.42.175.83:8084/";

static NSString *global_host = @"http://119.29.95.245:8080/";

static NSString *login_host = @"http://192.168.31.4:8080";

// v2

// message
static NSString *message_posts_url = @"/interaction/api/v2/posts";
static NSString *message_post_url = @"/interaction/api/v2/post";
static NSString *message_latest_url = @"/interaction/api/v2/latest";
static NSString *message_interaction_url = @"/interaction/api/v2/post";
static NSString *message_like_url = @"/interaction/api/v2/like";
static NSString *message_comments_url = @"/interaction/api/v2/post_comments";
static NSString *message_comment_url = @"/interaction/api/v2/comment";
static NSString *message_unread_url = @"/interaction/api/v2/unread";

// activity
static NSString *banner_url = @"/interaction/api/v2/banner";

// credit
static NSString *login_url = @"/credit/api/v2/syllabus";

static NSString *exam_url = @"/credit/api/v2/exam";

static NSString *grade_url = @"/credit/api/v2/grade";

static NSString *oa_url = @"/credit/api/v2/oa";

static NSString *member_url = @"/credit/api/v2/member";

// user
static NSString *nickname_url = @"/interaction/api/v2/user";
static NSString *avatar_url = @"/interaction/api/v2/user";

// v1
static NSString *discuss_post_url = @"/api/v1.0/discuss";

static NSString *course_url = @"/api/course";

static NSString *homework_post_url = @"/api/v1.0/homework";

static NSString *homework_url = @"/api/course_info/0"; // homework - 0

static NSString *homework_delete_url = @"/api/v1.0/delete/0";

static NSString *discuss_url = @"/api/course_info/1"; // discuss - 1

static NSString *discuss_delete_url = @"/api/v1.0/delete/1";

// oa
static NSString *oa_wechat_url = @"http://wechat.stu.edu.cn//webservice_oa/OA";

static NSString *oa_wechat_get_url = @"/GetDOCDetail";

static NSString *jump_app_url = @"http://chuckwo.com:81/app/jump.html";


#define UPDATE_CONTENT @"1. 欢迎医学院本科生及研究生👏！校本部研究生👏🏻！还有老师们👏🏼！加入汕大课程表👏🏽！(部分功能正在装备中)\n2. 办公自动化体验Up！支持条文搜索，还能外网查看哦！\n3. 全面改进消息圈，图文并茂非常棒！\n4. 微信分享新功能~三指触屏转课表、考试安排谁更少~🌚\n5. 噫！这不是汕大邮箱吗！？！？📩\n6. 优化了好多功能，如允许修改格子、访问速度更快等等。\n7. 改进多个页面的UI，界面更美观、更精致！🎉\n8. 修复了部分用户闪退等一大堆Bugs！\n【还有很多小细节，慢慢发现吧！】"

// Cell Color
#define COLOR_0 [UIColor colorWithRed:0.275 green:0.729 blue:0.902 alpha:1.000]
#define COLOR_1 [UIColor colorWithRed:0.365 green:0.749 blue:0.655 alpha:1.000]
#define COLOR_2 [UIColor colorWithRed:0.424 green:0.851 blue:0.573 alpha:1.000]
#define COLOR_3 [UIColor colorWithRed:0.600 green:0.804 blue:0.341 alpha:1.000]
#define COLOR_4 [UIColor colorWithRed:0.745 green:0.573 blue:0.518 alpha:1.000]
#define COLOR_5 [UIColor colorWithRed:0.953 green:0.596 blue:0.435 alpha:1.000]
#define COLOR_6 [UIColor colorWithRed:0.482 green:0.678 blue:0.843 alpha:1.000]
#define COLOR_7 [UIColor colorWithRed:0.616 green:0.545 blue:0.867 alpha:1.000]
#define COLOR_8 [UIColor colorWithRed:0.902 green:0.729 blue:0.431 alpha:1.000]
#define COLOR_9 [UIColor colorWithRed:1.000 green:0.483 blue:0.395 alpha:1.000]
#define COLOR_10 [UIColor colorWithRed:0.871 green:0.498 blue:0.522 alpha:1.000]
#define COLOR_11 [UIColor colorWithRed:0.875 green:0.490 blue:0.643 alpha:1.000]
#define COLOR_12 [UIColor colorWithRed:0.431 green:0.600 blue:0.918 alpha:1.000]
#define COLOR_13 [UIColor colorWithRed:0.342 green:0.811 blue:0.332 alpha:1.000]
#define COLOR_14 [UIColor colorWithRed:1.000 green:0.584 blue:0.749 alpha:1.000]

#define COLOR_ARRAY @[COLOR_0, COLOR_1, COLOR_2, COLOR_3, COLOR_4, COLOR_5, COLOR_6, COLOR_7, COLOR_8, COLOR_9, COLOR_10, COLOR_11, COLOR_12, COLOR_13, COLOR_14]





