//
//  KTObject.m
//  Kibble
//
//  Created by Joe on 4/11/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTObject.h"
#import "KTClassRnD.h"

@implementation KTObject
+(instancetype)objectFor:(id)aObject from:(Class)aClass{
    KTObject *o = [KTObject alloc];
    o = [o initWithObjectFor:aObject from:aClass];
    return o;
}
-(instancetype)initWithObjectFor:(id)aObject from:(Class)aClass{
    self = [super init];
    
    if (self) {
        _theObject = aObject;
        _theObjectClass = aClass;
        
        if (aObject == aClass) {
            // is a class object
            _isClassObject = YES;
        } else {
            // is an instance object
            _isClassObject = NO;
        }
    }
    return self;
}
+(instancetype)objectForValue:(NSValue*)aValue ofType:(KTType*)aType{
    KTObject *o = [KTObject alloc];
    o = [o initWithValueFor:aValue ofType:aType];
    return o;
}
-(instancetype)initWithValueFor:(NSValue*)aValue ofType:(KTType*)aType{
    self = [super init];
    
    if (self) {
        _isCType = YES;
        _theValue = aValue;
        _theObject = aValue;
        _theObjectClass = [NSValue class];
        _theValueCType = aType;
    }
    return self;
}
-(NSString*)description{
    NSString *res = nil;
    static void* bbuff = nil;
    if (bbuff == nil) {
        bbuff = malloc(64);
    }
    
    if (self.isCType) {
        res = [self valueAsString];
        res = [NSString stringWithFormat:@"%@\n(cType'%s')", res, [self.theValue objCType]];
    } else {
        res = [self.theObject description];
        res = [NSString stringWithFormat:@"%@\n(%@)", res, NSStringFromClass(self.theObjectClass)];
    }
    return res;
}
-(NSString*)debugDescription{return self.description;}


#define _C_ID		'@'
#define _C_CLASS	'#'
#define _C_SEL		':'
#define _C_CHR		'c'
#define _C_UCHR		'C'
#define _C_SHT		's'
#define _C_USHT		'S'
#define _C_INT		'i'
#define _C_UINT		'I'
#define _C_LNG		'l'
#define _C_ULNG		'L'
#define _C_LNG_LNG	'q'
#define _C_ULNG_LNG	'Q'
#define _C_FLT		'f'
#define _C_DBL		'd'
#define _C_BFLD		'b'
#define _C_VOID		'v'
#define _C_UNDEF	'?'
#define _C_PTR		'^'
#define _C_CHARPTR	'*'
#define _C_ARY_B	'['
#define _C_ARY_E	']'
#define _C_UNION_B	'('
#define _C_UNION_E	')'
#define _C_STRUCT_B	'{'
#define _C_STRUCT_E	'}'

-(NSString*)valueAsString{
    NSString *valStr = @"error";
    

    
    const char type = *[self.theValue objCType];
    
    switch(type)
    {
        case _C_ID:
        case _C_CLASS:
        case _C_SEL:
            break;
        case _C_CHR: {
            char val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%c", val];
            break;
        }
        case _C_UCHR: {
            unsigned char val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%cu",(unsigned char)val];
            break;
        }
        case _C_SHT: {
            short val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%hd",(short)val];
            break;
        }
        case _C_USHT: {
            unsigned short val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%hu",(unsigned short)val];
            break;
        }
        case _C_INT: {
            int val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%i",(int)val];
            break;
        }
        case _C_UINT: {
            unsigned int val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%iu",(unsigned int)val];
            break;
        }
        case _C_LNG: {
            long val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%ld",(long)val];
            break;
        }
        case _C_ULNG: {
            unsigned long val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%lu",(unsigned long)val];
            break;
        }
        case _C_LNG_LNG: {
            long long val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%lld",(long long)val];
            break;
        }
        case _C_ULNG_LNG: {
            unsigned long long val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%llu",(unsigned long long)val];
            break;
        }
        case _C_FLT: {
            float val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%f",(float)val];
            break;
        }
        case _C_DBL: {
            double val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%F",(double)val];
            break;
        }
        case _C_BFLD: {
            _Bool val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%cu",(_Bool)val];
            break;
        }
        case _C_VOID: {
            //valStr = [NSString stringWithFormat:@"%c",(void*)val];
            break;
        }
        case _C_UNDEF:
            break;
        case _C_PTR:
            //valStr = [NSString stringWithFormat:@"%c",(char)val];
            break;
        case _C_CHARPTR: {
            char *val;
            [self.theValue getValue:&val];
            valStr = [NSString stringWithFormat:@"%s",(char*)val];
            break;
        }
        case _C_ARY_B:
        case _C_ARY_E:
        case _C_UNION_B:
        case _C_UNION_E:
        case _C_STRUCT_B:
        case _C_STRUCT_E:
            

            break;
    }
    
    return valStr;
}

@end
