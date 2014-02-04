//
//  KBNumber.m
//  Kibble
//
//  Created by Joe on 2/1/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KBNumber.h"

@implementation KBNumberType

#ifdef DONOTCOMPILETHISTEMPCODE
+(void)debugPrintTypes{
    [self printClassInfo:[NSNumber class]];
    [self printClassInfo:[NSString class]];
    [self printClassInfo:[UIButton class]];
    [self printClassInfo:[NSDate class]];
    //NSLog(@"%@", [self classPropsFor:[UIViewController class]]);
    
}

#import "objc/runtime.h"

+(void)printClassInfo:(Class)thisClass{
    
    // print class
    NSLog(@"-------%@-------", [thisClass class]);
    
    // print methods
    id t = [[thisClass alloc] init];
    
    while (t) {
        int i=0;
        unsigned int mc = 0;
        Method * mlist = class_copyMethodList(object_getClass(t), &mc);
        NSLog(@"%d methods", mc);
        for(i=0;i<mc;i++)
            NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
        
        free(mlist);
       
        if ([[t class] superclass]) {
            t = [[[[t class] superclass] alloc] init];
        }
    }
    
    // print properties
    NSLog(@"%@", [self classPropsFor:thisClass]);
    
    
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}


+ (NSDictionary *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}
#endif


@end

//-------------------------------------------------------
@interface KBNumber ()
@end

@implementation KBNumber

-(Kibble*)initWithNumber:(NSNumber*)thisNumber
                      at:(CGPoint)pos
                   after:(float)delay
           addToParentVC:(UIViewController*)thisParentVC
                maxWidth:(float)maxWidth
        blockWhenClicked:(void (^)(Kibble* thisKibble))wasClickedBlock{
    
    self =  [super initType:[KBNumberType type]
                 withString:[NSString stringWithFormat:@"%@", thisNumber]
                         at:pos
                      after:delay
              addToParentVC:thisParentVC
                   maxWidth:maxWidth
           blockWhenClicked:wasClickedBlock];
    
    return self;
    
}

@end
