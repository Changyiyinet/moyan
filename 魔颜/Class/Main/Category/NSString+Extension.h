//
//  NSString+Extension.h
//  魔颜
//
//  Created by Meiyue on 16/1/14.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/**
 *  自适应高度
 *
 *  @param font  字体
 *  @param width 宽度
 *
 *  @return 返回的高度
 */
- (float) heightWithFont: (UIFont *) font withinWidth: (float) width;
- (float) widthWithFont: (UIFont *) font;

- (long long)fileSize;

//判断字符串中的表情
+ (BOOL)stringContainsEmoji:(NSString *)string;

////unicode---字符串
//+ (NSString*) replaceUnicode:(NSString*)aUnicodeString;
//
////utf8－－－unicode
//+(NSString *) utf8ToUnicode:(NSString *)string;



@end
