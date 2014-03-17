//
//  KTClassRnD.m
//  Kibble
//
//  Created by Joe on 3/15/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "KTClassRnD.h"
#define kPathName       @"KTFoundations"
#define kFileExtension  @"plist"
#define kVersion        0.1

@implementation KTClassRnD
+(void)test{
    
    BOOL testSave = NO;
    BOOL testLoad = YES;
  
    if (testSave) {
        KTType *tNSStringPtr = [KTType objCObjectPointer:@"NSString"];
        
        KTMethodParam *p0 = [KTMethodParam newParam:@"aString"
                                          paramType:tNSStringPtr
                                        commandName:@"stringWithString:"
                                            comment:@"The string from which to copy characters. This value must not be nil."];
        
        NSArray *p = [NSArray arrayWithObjects:p0, nil];
        KTMethod *m1 = [KTMethod classMethodWithReturns:tNSStringPtr
                                             methodName:@"stringWithString:"
                                                 params:p
                                                comment:@"Returns a string created by copying the characters from another given string."];
        
        KTClass *cNSString = [KTClass classWithName:@"NSString"];
        [cNSString addClassMethod:m1];
        
        [cNSString enumerateClassIniters:^(KTMethod *aMethod) {
            NSLog(@"%@", aMethod);
            
            NSString *str1 = [KTClass sendMessageToClass:cNSString message:@"stringWithString:" params:@"hello world",nil];
            NSLog(@"%@", str1);
        }];
        
        KTFoundation *f = [KTFoundation foundationWithName:@"TestFoundation"];
        [f addClass:cNSString];
        [f saveToiOSDisk];
    }
    
    if (testLoad) {
        KTFoundation *f = [KTFoundation foundationFromDisk:@"TestFoundation"];
        [f enumerateClasses:^(KTClass *aClass) {
            NSLog(@"%@", aClass.name);
            [aClass enumerateClassIniters:^(KTMethod *aMethod) {
                NSLog(@"..%@", aMethod.name);
                
                NSString *str1 = nil;
                //str1 = [KTClass sendMessageToClass:aClass message:aMethod.name params:@"hello world",nil];
                if (str1) {
                    NSLog(@"%@", str1);
                }
            }];
        }];
    }
    
}
@end

@interface KTFoundation ()
@end
@implementation KTFoundation
//---
static NSMutableDictionary *foundations;
+(KTFoundation*)foundationWithName:(NSString *)name{
    if (!foundations) {
        foundations = [NSMutableDictionary new];
    }
    KTFoundation *o = [foundations objectForKey:name];
    if (!o) {
        o = [KTFoundation new];
        o.name = name;
        o.classes = [NSMutableDictionary new];
        [foundations setObject:o forKey:name];
    }
    return o;
}
//---
#pragma mark NSCoding

#define kName           @"name"
#define kClasses        @"classes"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.classes forKey:kClasses];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [KTFoundation foundationWithName:[decoder decodeObjectForKey:kName]];
    self.classes = [decoder decodeObjectForKey:kClasses];
    return self;
}
//---
+(void)enumerateFoundations:(void(^)(KTFoundation* aFoundation))block{
    [foundations enumerateKeysAndObjectsUsingBlock:^(id key, KTFoundation* aFoundation, BOOL *stop) {
        if (block) {
            block(aFoundation);
        }
    }];
}
//---
-(void)saveToiOSDisk{
    
    NSString *path = [KTFoundation getiOSPath];
    NSString *filePath = [[NSString alloc] initWithString: [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.name, kFileExtension]]];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"data"];
    [archiver encodeObject:[NSNumber numberWithFloat:kVersion] forKey:@"version"];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}
//---
-(void)saveToOSXDisk{
    
    NSString *path = [KTFoundation getOSXPath];
    NSString *filePath = [[NSString alloc] initWithString: [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.name, kFileExtension]]];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"data"];
    [archiver encodeObject:[NSNumber numberWithFloat:kVersion] forKey:@"version"];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}
+(KTFoundation*)foundationFromDisk:(NSString *)name{
    NSString *path = [KTFoundation getMostCurrentPathFor:name];
    NSString *filePath = [[NSString alloc] initWithString: [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, kFileExtension]]];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (codedData == nil) return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    NSNumber *archivedVersion = [unarchiver decodeObjectForKey:@"version"];
    NSLog(@"version %@", archivedVersion);
    KTFoundation* o = [unarchiver decodeObjectForKey:@"data"];
    [unarchiver finishDecoding];
    return o;
}

+(NSString*)getOSXPath{
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSString *path = [dirPaths objectAtIndex:0];
    path = [[NSString alloc] initWithString: [path stringByAppendingPathComponent:@"../development/Kibble"]];
    
    path = [[NSString alloc] initWithString: [path stringByAppendingPathComponent:[NSString stringWithFormat:kPathName]]];
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return path;
}

+(NSString*)getiOSPath{
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [dirPaths objectAtIndex:0];
    
    path = [[NSString alloc] initWithString: [path stringByAppendingPathComponent:[NSString stringWithFormat:kPathName]]];

    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return path;
}

+(NSString*)getMostCurrentPathFor:(NSString*)thisFile{
    // check the bundle
    //NSString* bundlePath = [[NSBundle mainBundle] pathForResource:thisFile ofType:kFileExtension];
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:kPathName ofType:nil];
    
    // check the documents
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [dirPaths objectAtIndex:0];
    documentsPath = [[NSString alloc] initWithString: [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:kPathName]]];

    return bundlePath;
}

//
//---
-(void)addClass:(KTClass*)aClass{
    [self.classes setObject:aClass forKey:aClass.name];
}
-(KTClass*)classWithName:(NSString*)aName{
    KTClass* aClass = [self.classes objectForKey:aName];
    return (aClass);
}
//---
-(void)enumerateClasses:(void(^)(KTClass* aClass))block{
    if (block) {
        [self.classes enumerateKeysAndObjectsUsingBlock:^(id key, KTClass* aClass, BOOL *stop) {
            block(aClass);
        }];
    }
}


@end

@implementation KTClass
//---
+(KTClass*)classWithName:(NSString *)name{
    KTClass *o = [KTClass new];
    o.name = name;
    o.classMethods = [NSMutableArray new];
    o.instanceMethods = [NSMutableArray new];
    o.classVars = [NSMutableArray new];
    o.instanceVars = [NSMutableArray new];
    return o;
}
//---
+(id)sendMessageToClass:(KTClass*)aClass message:(NSString*)aMessage params:(id)params, ...{

    NSMutableArray *arguments=[[NSMutableArray alloc]initWithArray:nil];
    id eachObject;
    va_list argumentList;
    if (params)
    {
        [arguments addObject: params];
        va_start(argumentList, params);
        while ((eachObject = va_arg(argumentList, id)))
        {
            [arguments addObject: eachObject];
        }
        va_end(argumentList);
    }
    NSLog(@"%@",arguments);
    
    id returns;
    SEL theSelector = NSSelectorFromString(aMessage);
    Class theClass = NSClassFromString(aClass.name);
    if([theClass respondsToSelector:theSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[theClass methodSignatureForSelector:theSelector]];
        [inv setSelector:theSelector];
        [inv setTarget:theClass];
        
        [arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSUInteger trueIndex = 2 + idx; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
            [inv setArgument:&(obj) atIndex:trueIndex];
        }];

        [inv invoke];
        
        [inv getReturnValue:&returns];
    } else {
        returns = nil;
    }
    return returns;
    
}
//---
-(void)addClassMethod:(KTMethod*)aMethod{
    [self.classMethods addObject:aMethod];
}
-(void)addInstanceMethod:(KTMethod*)aMethod{
    [self.instanceMethods addObject:aMethod];
}
//---
-(void)enumerateClassIniters:(void(^)(KTMethod* aMethod))block{
    KTType *type =[KTType objCObjectPointer:NSStringFromClass([self class])];
    [self enumerateClassMethodsThatReturn:type withBlock:block];
}
-(void)enumerateClassMethodsThatReturn:(KTType*)returns withBlock:(void(^)(KTMethod* aMethod))block{
    if (block) {
        [self.classMethods enumerateObjectsUsingBlock:^(KTMethod* method, NSUInteger idx, BOOL *stop) {
            block(method);
        }];
    }
}

//---
#pragma mark NSCoding

#define kName  @"name"
#define kClassMethods      @"classMethods"
//#define kClassVars      @"classVars"
#define kInstanceMethods      @"instanceMethods"
#define kInstanceVars      @"instanceVars"


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.classMethods forKey:kClassMethods];
//    [encoder encodeObject:self.classVars forKey:kClassVars];
    [encoder encodeObject:self.instanceMethods forKey:kInstanceMethods];
    [encoder encodeObject:self.instanceVars forKey:kInstanceVars];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [KTClass classWithName:[decoder decodeObjectForKey:kName]];
    self.classMethods = [decoder decodeObjectForKey:kClassMethods];
    //self.classVars = [decoder decodeObjectForKey:];
    self.instanceMethods = [decoder decodeObjectForKey:kInstanceMethods];
    self.instanceVars = [decoder decodeObjectForKey:kInstanceVars];
    return self;
}
@end


@implementation KTMethod
+(KTMethod*)classMethodWithReturns:(KTType*)returns methodName:(NSString*)methodName params:(NSArray*)params comment:(NSString*)comment{
    KTMethod *o = [KTMethod methodWithReturns:returns methodName:methodName params:params isClass:YES comment:comment];
    return o;
}
+(KTMethod*)instanceMethodWithReturns:(KTType*)returns methodName:(NSString*)methodName params:(NSArray*)params comment:(NSString*)comment{
    KTMethod *o = [KTMethod methodWithReturns:returns methodName:methodName params:params isClass:NO comment:comment];
    return o;
}
+(KTMethod*)methodWithReturns:(KTType*)returns methodName:(NSString*)methodName params:(NSArray*)params isClass:(BOOL)isClass comment:(NSString*)comment{
    KTMethod *o = [KTMethod new];
    o.returns = returns;
    o.name = methodName;
    o.params = params;
    o.isClass = isClass;
    o.isInstance = !isClass;
    o.comment = comment;
    return o;
}
//---
#pragma mark NSCoding

#define kName  @"name"
#define kComment      @"comment"
#define kReturns      @"returns"
#define kIsClass      @"isClass"
#define kIsInstance      @"isInstance"
#define kParams      @"params"
//#define k      @""


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.comment forKey:kComment];
    [encoder encodeObject:self.returns forKey:kReturns];
    [encoder encodeObject:[NSNumber numberWithBool:self.isClass] forKey:kIsClass];
    [encoder encodeObject:[NSNumber numberWithBool:self.isInstance] forKey:kIsInstance];
    [encoder encodeObject:self.params forKey:kParams];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    self.returns = [decoder decodeObjectForKey:kReturns];
    self.name = [decoder decodeObjectForKey:kName];
    self.params = [decoder decodeObjectForKey:kParams];
    self.isClass = [[decoder decodeObjectForKey:kIsClass] boolValue];
    self.isInstance = [[decoder decodeObjectForKey:kIsInstance] boolValue];
    self.comment = [decoder decodeObjectForKey:kComment];
    return self;
}
@end

@interface KTMethodParam ()
@end
@implementation KTMethodParam
+(KTMethodParam*) newParam:(NSString*)paramName paramType:(KTType*)type{
    KTMethodParam *o = [KTMethodParam newParam:paramName paramType:type commandName:nil comment:nil];
    return o;
}
+(KTMethodParam*) newParam:(NSString*)paramName paramType:(KTType*)type commandName:(NSString*)commandName{
    KTMethodParam *o = [KTMethodParam newParam:paramName paramType:type commandName:commandName comment:nil];
    return o;
}
+(KTMethodParam*) newParam:(NSString*)paramName paramType:(KTType*)type commandName:(NSString*)commandName comment:(NSString*)comment{
    KTMethodParam *o = [KTMethodParam new];
    o.name = commandName;
    o.comment = comment;
    o.paramName = paramName;
    o.paramType = type;
    return o;
}
//---
#pragma mark NSCoding

#define kName  @"name"
#define kComment      @"comment"
#define kParamName      @"paramName"
#define kParamType      @"paramType"
//#define k      @""

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.comment forKey:kComment];
    [encoder encodeObject:self.paramName forKey:kParamName];
    [encoder encodeObject:self.paramType forKey:kParamType];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    self.name = [decoder decodeObjectForKey:kName];
    self.paramName = [decoder decodeObjectForKey:kParamName];
    self.paramType = [decoder decodeObjectForKey:kParamType];
    self.comment = [decoder decodeObjectForKey:kComment];
    return self;
}
@end


@interface KTType ()
//@property (nonatomic, strong) NSMutableDictionary *objCInterfaces;
//@property (nonatomic, strong) NSMutableDictionary *objCObjectPointers;
@end
@implementation KTType
//@synthesize objCInterfaces, objCObjectPointers;
static NSMutableDictionary *objCInterfaces, *objCObjectPointers;
-(NSMutableDictionary*)objCInterfaces{
    if (!objCInterfaces) {
        objCInterfaces = [NSMutableDictionary new];
    }
    return objCInterfaces;
}
-(NSMutableDictionary*)objCObjectPointers{
    if (!objCObjectPointers) {
        objCObjectPointers = [NSMutableDictionary new];
    }
    return objCObjectPointers;
}
+(KTType*)objCInterface:(NSString*)thisName{
    KTType *o = [objCInterfaces objectForKey:thisName];
    
    if (o == nil) {
        o = [KTType new];
        o.name = thisName;
        o.kind = KTCXType_ObjCInterface;
        o.canonical = o;
        [objCInterfaces setObject:o forKey:thisName];
    }
    
    return o;
}
     

+(KTType*)objCObjectPointer:(NSString*)thisName{
    KTType *o = [objCObjectPointers objectForKey:thisName];
    
    if (o == nil) {
        o = [KTType new];
        o.name = [NSString stringWithFormat:@"%@ *", thisName];
        o.kind = KTCXType_ObjCObjectPointer;
        o.canonical = o;
        o.pointee = [KTType objCInterface:thisName];
        [objCObjectPointers setObject:o forKey:thisName];
    }
        
     return o;
 }

//---
#pragma mark NSCoding

#define kName           @"name"
#define kKind           @"kind"
#define kCanonical      @"canonical"
#define kPointee        @"pointee"
//#define k      @""
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.kind] forKey:kKind];
    [encoder encodeObject:self.canonical forKey:kCanonical];
    [encoder encodeObject:self.pointee forKey:kPointee];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    self.name = [decoder decodeObjectForKey:kName];
    self.kind = [[decoder decodeObjectForKey:kKind] unsignedIntegerValue];
    self.canonical = [decoder decodeObjectForKey:kCanonical];
    self.pointee = [decoder decodeObjectForKey:kPointee];
    return self;
}
@end

@implementation KTVariable

//---
#pragma mark NSCoding

#define kName           @"name"
//#define k      @""
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kName];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    self.name = [decoder decodeObjectForKey:kName];
    return self;
}
@end
