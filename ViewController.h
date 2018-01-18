//
//  ViewController.h
//  IOKIT
//
//  Created by apple on 17/12/26.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
{
    NSMutableDictionary *maDeviceList;
}
@property (unsafe_unretained) IBOutlet NSTextView *TextViewDebug;

@end

