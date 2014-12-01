//
//  NSDictionary+KeyConversion.m
//  MC HW
//
//  Created by Eric Lubin on 1/26/13.
//
//

#import "NSDictionary+KeyConversion.h"

@implementation NSDictionary (KeyConversion)
-(NSDictionary*)convertKeysTo:(NSDictionary*)keyMap{
    //keyMap represents a map mapping each old key, as it exists on self, to the new key as it will exist on the output
    
    
    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:[keyMap count]];
    
    for(id key in keyMap) {
        output[keyMap[key]] = self[key];
    }
    return output;
}
@end
