//
//  ColorArray.m
//  Photo
//
//  Created by zhongyi on 16/3/27.
//  Copyright © 2016年 zhongyi. All rights reserved.
//

#import "ColorArray.h"
#include "UIColor+HexColor.h"

@import UIKit;

@implementation ColorArray

+ (ColorArray *)initWithColor{
    
    ColorArray *colorArray = (ColorArray *) @[
                                              [UIColor colorWithHex:0xFD5B78],
                                              [UIColor colorWithHex:0xFF6347],
                                              [UIColor colorWithHex:0xFE4C40],
                                              [UIColor colorWithHex:0xFFA07B],
                                              
                                              [UIColor colorWithHex:0xD6A78B],
                                              [UIColor colorWithHex:0xED859A],
                                              [UIColor colorWithHex:0xFF69B4],
                                              [UIColor colorWithHex:0xEE82EE],

                                              [UIColor colorWithHex:0x9966CC],
                                              [UIColor colorWithHex:0x6A5ACD],
                                              [UIColor colorWithHex:0x9999FF],
                                              [UIColor colorWithHex:0x7bbfea],

                                              [UIColor colorWithHex:0x1E90FF],
                                              [UIColor colorWithHex:0x06B9D1],
                                              [UIColor colorWithHex:0x00BFFF],
                                              [UIColor colorWithHex:0x209E85],
                                              
                                              [UIColor colorWithHex:0x15AD66],
                                              [UIColor colorWithHex:0x48D1CC],
                                              [UIColor colorWithHex:0xA2A3A2]
     
                                   ];
    
    return colorArray;
}

+ (ColorArray *)initWithHexColor{
    
    ColorArray *colorArray = (ColorArray *) @[
                                              [UIColor colorWithHex:0xFD5B78 withAlpha:0.5],
                                              [UIColor colorWithHex:0xFF6347 withAlpha:0.5],
                                              [UIColor colorWithHex:0xFE4C40 withAlpha:0.5],
                                              [UIColor colorWithHex:0xFFA07B withAlpha:0.5],
                                              
                                              [UIColor colorWithHex:0xD6A78B withAlpha:0.5],
                                              [UIColor colorWithHex:0xED859A withAlpha:0.5],
                                              [UIColor colorWithHex:0xFF69B4 withAlpha:0.5],
                                              [UIColor colorWithHex:0xEE82EE withAlpha:0.5],

                                              [UIColor colorWithHex:0x9966CC withAlpha:0.5],
                                              [UIColor colorWithHex:0x6A5ACD withAlpha:0.5],
                                              [UIColor colorWithHex:0x9999FF withAlpha:0.5],
                                              [UIColor colorWithHex:0x7bbfea withAlpha:0.5],
                                              
                                              [UIColor colorWithHex:0x1E90FF withAlpha:0.5],
                                              [UIColor colorWithHex:0x06B9D1 withAlpha:0.5],
                                              [UIColor colorWithHex:0x00BFFF withAlpha:0.5],
                                              [UIColor colorWithHex:0x209E85 withAlpha:0.5],
                                              
                                              [UIColor colorWithHex:0x15AD66 withAlpha:0.5],
                                              [UIColor colorWithHex:0x48D1CC withAlpha:0.5],
                                              [UIColor colorWithHex:0xA2A3A2 withAlpha:0.5]

                                              ];
    
    return colorArray;
}


+ (NSArray *)initWithColorHex{
    
    NSArray *colorArray = @[@0xFF9500,@0xFFCD02,@0x4CD964,@0x37E7BA,@0x5AC8FB,@0x1AD6FD,
                            @0x1D77EF,@0xC644FC,@0xEF4DB6,@0xE4DDCA,@0xE4B7F0,@0xD7D7D7,@0x4A4A4A
                                              ];
    
    return colorArray;
}



@end
