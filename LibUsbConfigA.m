//
//  LibUsbConfig.m
//  IOKIT
//
//  Created by apple on 18/1/2.
//  Copyright © 2018年 coco. All rights reserved.
//

#import "LibUsbConfigA.h"
#import "libusbi.h"

static LibUsbConfigA *shareInstance = NULL;
@implementation LibUsbConfigA
+(LibUsbConfigA *)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareInstance = [[LibUsbConfigA alloc] init];
//        NSLog(@"%@",[self getUSBList]);
    });
    return shareInstance;
}
-(instancetype)init{
    self =[super init];
    libusb_device **aa = [self getUSBList];
    NSLog(@"%@",aa[0]);
    return self;
}

-(libusb_device **)getUSBList{
    libusb_context *ctx;
    ssize_t usb_list_len=0,idx = 0;
    libusb_device **listDevice=NULL;
    
    libusb_init(&ctx);
    usb_list_len = libusb_get_device_list(NULL,&listDevice);
    
    return listDevice;
}
-(NSDictionary *)getPropertyWithDevice:(libusb_device *)device{
    struct libusb_device_descriptor desca={0};
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (device != nil) {
        memset(&desca,sizeof(struct libusb_device_descriptor),0);
        uint8_t busnumber =libusb_get_bus_number(device);
        uint8_t portnumber =libusb_get_port_number(device);
        NSString *portname = [NSString stringWithFormat:@"%x",portnumber];
        NSString *locationid = [NSString stringWithFormat:@"0x%x",busnumber];
        NSString *result =[self getLocationIDWithDevice:device andPortName:portname];
        int portlen = (int)result.length;
        NSString *zero = @"";
        for (int i = 0; i < 6-portlen; i++) {
            zero = [NSString stringWithFormat:@"%@0",zero];
        }
        locationid = [NSString stringWithFormat:@"%@%@%@",locationid,result,zero];
        NSLog(@"xxxxxx%@",locationid);
        [md setObject:locationid forKey:@"locationid"];
        if(libusb_get_device_descriptor(device,&desca)!=0){
            perror("can't find usb list information");
            //            return 0;
        }else{
            NSLog(@"vid = 0x%04x====pid=0x%04x",desca.idVendor,desca.idProduct);
            [md setObject:[NSString stringWithFormat:@"0x%04x",desca.idVendor] forKey:@"idVendor"];
            [md setObject:[NSString stringWithFormat:@"0x%04x",desca.idProduct] forKey:@"idProduct"];
        }
        
    }
    return md;
}

-(libusb_device_handle *)openWithUSBVID:(int)vid andPID:(int)pid{
    libusb_device_handle *devh = NULL;
    devh = libusb_open_device_with_vid_pid(NULL, vid, pid);
    int r =1 ;
    r = libusb_claim_interface(devh, 0);
    if (r < 0) {
        return NULL;
    }
    return devh;
}

-(int)writeWithUSBHandle:(libusb_device_handle *)handle andWriteString:(NSString *)strWrite{
    int transferred = 0;
    int status = libusb_bulk_transfer(handle,0x01,strWrite.UTF8String,5,&transferred, 1000);
    return status;
}

-(NSString *)readWithUSBHandle:(libusb_device_handle *)handle{
    
    int transferred = 0;
    unsigned char *cData;
    cData =malloc(64 + 1);
    memset(cData, '\0', 64);
    int ret = libusb_bulk_transfer(handle,0x82,cData,64,&transferred, 0);
    if (ret < 0) {
        return @"error";
    }
    return [NSString stringWithUTF8String:cData];
    
}

-(NSString *)getLocationIDWithDevice:(libusb_device *)dev andPortName:(NSString *)portName{
    libusb_device *parentDev = libusb_get_parent(dev);
    if (parentDev != NULL) {
        uint8_t portnumber =libusb_get_port_number(parentDev);
        portName = [NSString stringWithFormat:@"%x%@",portnumber,portName];
        return([self getLocationIDWithDevice:parentDev andPortName:portName]);
    }else{
        return portName;
    }
}

@end
