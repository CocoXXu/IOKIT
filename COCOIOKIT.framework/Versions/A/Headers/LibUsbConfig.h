//
//  LibUsbConfig.h
//  IOKIT
//
//  Created by apple on 18/1/2.
//  Copyright © 2018年 coco. All rights reserved.
//
#import "libusbi.h"
#import <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#import <Foundation/Foundation.h>

@interface LibUsbConfig : NSObject{
    NSMutableDictionary *maDeviceList;
}
+(LibUsbConfig *)shareInstance;

-(libusb_device **)getUSBList;
-(NSDictionary *)getPropertyWithDevice:(libusb_device *)device;

-(libusb_device_handle *)openWithUSBVID:(int)vid andPID:(int)pid;

-(int)writeWithUSBHandle:(libusb_device_handle *)handle andWriteString:(NSString *)strWrite;

-(NSString *)readWithUSBHandle:(libusb_device_handle *)handle;

-(NSString *)getLocationIDWithDevice:(libusb_device *)dev andPortName:(NSString *)portName;

-(void)writeMessageToJSON:(NSString *)file;
-(void) findChild:(io_registry_entry_t) parent level:(int) iLevel;

@end
