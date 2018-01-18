//
//  DeviceObject.h
//  IOKIT
//
//  Created by apple on 17/12/26.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/IOCFPlugIn.h>

@interface DeviceObject : NSObject

@property(nonatomic,assign)io_object_t              notification;
@property(nonatomic,assign)IOUSBInterfaceInterface  **interface;
@property(nonatomic,assign)UInt32                   locationID;
@property(nonatomic,assign)CFStringRef				deviceName;

@property(nonatomic,assign)IOUSBDeviceInterface     **dev;
@property(nonatomic,assign)UInt8                    pipeIn;
@property(nonatomic,assign)UInt8                    pipeOut;
@property(nonatomic,assign)UInt16                   maxPacketSizeIn;
@property(nonatomic,assign)UInt16                   maxPacketSizeOut;

@end