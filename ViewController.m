//
//  ViewController.m
//  IOKIT
//
//  Created by apple on 17/12/26.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ViewController.h"
#import <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#import "UsbMonitor.h"
#import "libusbi.h"
#import "COCOIOKIT.framework/Headers/LibUsbConfig.h"
//#import "LibUsbConfig.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    NSLog(@"%@",[LibUsbConfig shareInstance]);
//    LibUsbConfig *configlib = [[LibUsbConfig alloc] init];
    libusb_device **aa = [[LibUsbConfig shareInstance] getUSBList];
    NSLog(@"%@",aa[0]);
    io_name_t name;
    io_registry_entry_t rootEntry = IORegistryGetRootEntry(kIOMasterPortDefault);
    IORegistryEntryGetName(rootEntry,name); //获取名称
    maDeviceList = [[NSMutableDictionary alloc] initWithCapacity:0];
    [self findChild:rootEntry level:0];
    NSString *filepath = [[NSBundle mainBundle] resourcePath];
    filepath = [NSString stringWithFormat:@"%@/iokitusb.json",filepath];
    NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:filepath append:NO];
    [outStream open];
    [NSJSONSerialization writeJSONObject:maDeviceList toStream:outStream options:NSJSONWritingPrettyPrinted error:nil];
    [outStream close];//将所有USB信息打印到根目录的iokitusb.json下供调用
//     Do any additional setup after loading the view.
}


-(void) findChild:(io_registry_entry_t) parent level:(int) iLevel{
    io_iterator_t iterator;
    io_name_t name;
    IORegistryEntryGetChildIterator(parent,kIOUSBPlane,&iterator);
    io_iterator_t t = IOIteratorNext(iterator);
    while(t!=0){
        IORegistryEntryGetName(t,name);
        for(int i=0;i<iLevel;i++){
            _TextViewDebug.string = [NSString stringWithFormat:@"%@----",_TextViewDebug.string];
            printf("--");
        }
        _TextViewDebug.string = [NSString stringWithFormat:@"%@-%@",_TextViewDebug.string,[NSString stringWithUTF8String:name]];
        printf("|%s\n", name);
        CFMutableDictionaryRef properties=NULL;
        kern_return_t kr = IORegistryEntryCreateCFProperties(t,
                                                             &properties,
                                                             kCFAllocatorDefault,
                                                             kNilOptions);
        if (kr == 0) {
            NSDictionary *resultInfo = (__bridge_transfer NSDictionary *)properties;
            NSLog(@"%@",resultInfo);
            NSMutableDictionary *mdProperty = [[NSMutableDictionary alloc] initWithCapacity:0];
            for (NSString *akey in resultInfo) {
                if ([[resultInfo valueForKey:akey] isKindOfClass:[NSString class]]) {
                    _TextViewDebug.string = [NSString stringWithFormat:@"%@ %@=%@",_TextViewDebug.string,akey,[resultInfo valueForKey:akey]];
                    [mdProperty setObject:[resultInfo valueForKey:akey] forKey:akey];
                }else if ([[resultInfo valueForKey:akey] isKindOfClass:[NSNumber class]]){
                    _TextViewDebug.string = [NSString stringWithFormat:@"%@ %@=0x%x",_TextViewDebug.string,akey,[[resultInfo valueForKey:akey] intValue]];
                    [mdProperty setObject:[resultInfo valueForKey:akey] forKey:akey];
                }
                
            }
            _TextViewDebug.string = [NSString stringWithFormat:@"%@\n\n\n",_TextViewDebug.string];
            [maDeviceList setObject:mdProperty forKey:[NSString stringWithUTF8String:name]];
           
        }
        
        [self findChild:t level:iLevel+1];
        t = IOIteratorNext(iterator);
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
