//
//  AudioWrapper.m
//  DyslexicAdvantageScreener
//
//  Created by Joe on 11/28/13.
//  Copyright (c) 2013 Vidya Gamer, LLC. All rights reserved.
//

#import "AudioWrapper.h"
#import "SoundBank.h"
#import "SCElement.h"

@interface RecordedAudioObject : NSObject
@property (nonatomic, strong) NSString *audioName;
@end
@implementation RecordedAudioObject
@end

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} ;//encodingTypes;
//#define recordEncoding ENC_PCM
#define recordEncoding ENC_AAC

@implementation AudioElement
@synthesize doesExist, actualPathAndFile, actualPath, actualFileName;

-(BOOL)doesExist{
    NSString *pathAndFile = self.actualPathAndFile;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathAndFile];
    
    return fileExists;
}
-(NSString*)actualPath{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* thePath = [documentsPath stringByAppendingPathComponent:self.path];
    return thePath;
}
-(NSString*)actualFileName{
    NSString* fullFileName = self.fileName;
    
    NSString *recordExtention = nil;
    switch (recordEncoding) {
        case (ENC_AAC):
            recordExtention = @".aac";
            break;
        case (ENC_ALAC):
            recordExtention = @".alac";
            break;
        case (ENC_IMA4):
            recordExtention = @".ima4";
            break;
        case (ENC_ILBC):
            recordExtention = @".ilbc";
            break;
        case (ENC_ULAW):
            recordExtention = @".ulaw";
            break;
        default:
            recordExtention = @".PCM";
    }
    
    
    fullFileName = [NSString stringWithFormat:@"%@%@", fullFileName, recordExtention];
    return fullFileName;
    
}
-(NSString*)actualPathAndFile{
    NSString* pathAndFile = [self actualPath];
    pathAndFile = [pathAndFile stringByAppendingPathComponent:self.actualFileName];
    return pathAndFile;
}
-(NSDate*)fileDate{
    NSDate *result = nil;
    
    NSError *error = nil;;
    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:self.actualPathAndFile error:&error];
    result = fileAttr[NSFileModificationDate];
    
    return result;
}
//-(AudioElement*)initWithPath:(NSString*)thisPath andFileName:(NSString*)thisFileName{
-(AudioElement*)initWithPath:(NSString*)thisPath
                    fileName:(NSString*)thisFileName
                textToSpeach:(NSString*)thisTextToSpeach{
    self = [super init];
    if (self) {
        // Initialize self.
        self.path = [NSString stringWithFormat:@"soundbanks/%@", thisPath];
        self.fileName = thisFileName;
        self.textToSpeach = thisTextToSpeach;
    }
    return self;
}
@end



@interface AudioWrapper ()
@property (nonatomic, strong) NSTimer *meteringTimer;
@property (nonatomic, strong) AVAudioRecorder *meteringRecorder;
@property (nonatomic, strong) void (^ meteringBlock)(float aveagePower, float peakPower) ;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) void (^ recordCompleteBlock)(AudioElement* recordedAudio, BOOL success) ;
@property (nonatomic, strong) AudioElement *recordedAudio;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayerFX;
@property (nonatomic, strong) void (^ playbackCompleteBlock)(BOOL success);
@end

@implementation AudioWrapper


+(AudioWrapper *)sharedAudio{
    static AudioWrapper *shared = nil;
    
    if (shared==nil) {
        shared = [[super allocWithZone:NULL] init];
        
        // set up any first time inits
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    return shared;
}

-(void)stopMetering{
    if (self.meteringRecorder) {
        [self.meteringRecorder stop];
        self.meteringRecorder = nil;
    }
    if (self.meteringTimer) {
        [self.meteringTimer invalidate];
        self.meteringTimer = nil;
    }
    self.meteringBlock = nil;
    
}

-(void)startMetering:(void (^)(float aveagePower, float peakPower))meteringBlock{
    
    // stop existing metering
    [self stopMetering];

    
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
  	self.meteringRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];

    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); NSString *basePath = paths[0];
    //NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", basePath]];
  	//self.meteringRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];

  	if (self.meteringRecorder) {
        if ([self.meteringRecorder prepareToRecord]) {
        
            self.meteringBlock = meteringBlock;
            self.meteringTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];

            self.meteringRecorder.meteringEnabled = YES;
            [self.meteringRecorder record];
        }
        

        
        
  	} else {
  		NSLog(@"%@",[error description]);
    }
}
-(void)timerCallback:(NSTimer *)timer {

    if (self.meteringRecorder) {
        [self.meteringRecorder updateMeters];
    }

    if (self.meteringBlock) self.meteringBlock([self.meteringRecorder averagePowerForChannel:0],[self.meteringRecorder peakPowerForChannel:0]);
    
    NSString *outputStr = nil;
        outputStr = [NSString stringWithFormat:@"record levels = %f, %f", [self.meteringRecorder averagePowerForChannel:0], [self.meteringRecorder peakPowerForChannel:0]];
        //NSLog(@"%@",outputStr);
}


-(void) record:(AudioElement*)audio{
    [self record:audio completeBlock:nil];
}
-(void) record:(AudioElement*)audio completeBlock:(void (^)(AudioElement* recordedAudio, BOOL success))completeBlock{
    self.audioRecorder = nil;
    
    // Init audio with record capability
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    

    
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //[recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    
    NSURL *url = nil;
    NSString *pathOnly = nil;
    if ([audio isKindOfClass:[AudioElement class]]) {
        AudioElement* audioElement = audio;
        url = [NSURL fileURLWithPath:audioElement.actualPathAndFile];
        pathOnly =audioElement.actualPath;
    }
    
    NSError *error = nil;
    // if folder does not exist, then create it
    BOOL isDir;
    if (! [[NSFileManager defaultManager]fileExistsAtPath:pathOnly isDirectory:&isDir]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:pathOnly withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // create audio recorder
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    
    if ([self.audioRecorder prepareToRecord] == YES){
        //self.audioRecorder.meteringEnabled = YES;
        
        self.recordCompleteBlock = completeBlock;
        self.recordedAudio = audio;
        [self.audioRecorder record];
        
    }else {
        //int errorCode = CFSwapInt32HostToBig ([error code]);
        //NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        //int errorCode = [error code];
        NSLog(@"Error: %@ [%4.4ld])" , [error localizedDescription], (long)[error code]);
        
    }
    
    
}

-(void) recordStop
{
    [self.audioRecorder stop];
    [self setRecordStateStopped:YES];
}

-(void) playback:(AudioElement*)audio{
    [self playback:audio completeBlock:nil];
    
}
-(void) playback:(AudioElement*)audio completeBlock:(void (^)(BOOL success))completeBlock{
    // Init audio with playback capability

    NSURL *url = nil;
    
    if ([audio isKindOfClass:[AudioElement class]]) {
        AudioElement* audioElement = audio;
        url = [NSURL fileURLWithPath:audioElement.actualPathAndFile];
    }
    
    if (url) {
        // make sure current playing is stopped
        [self playbackStop];
        
        NSError *error;
        self.playbackCompleteBlock = completeBlock;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = 0;
        self.audioPlayer.delegate = self;
        self.audioPlayer.meteringEnabled = YES;
        [self.audioPlayer play];
    }
}



-(void) playbackStop
{
    [self.audioPlayer stop];
    [self setPlayStateStopped:NO];
}


-(void)setPlayStateStopped:(BOOL)success {
    void (^ completionBlock)(BOOL success) = self.playbackCompleteBlock;
    self.playbackCompleteBlock = nil;
    self.audioPlayer = nil;
    if (completionBlock) completionBlock(success);
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (player== self.audioPlayer) {
        [self setPlayStateStopped:flag];
    }
}
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    if (player == self.audioPlayer) {
        [self setPlayStateStopped:NO];
    }
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    if (player == self.audioPlayer) {
        [self setPlayStateStopped:NO];
    }
}

-(void)setRecordStateStopped:(BOOL)success {
    void (^ completionBlock)(AudioElement* recordedAudio, BOOL success) = self.recordCompleteBlock;
    
    self.recordCompleteBlock = nil;
    self.audioRecorder = nil;

    if (completionBlock) completionBlock(self.recordedAudio, success);
}

-(void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    if (recorder == self.audioRecorder) {
        [self setRecordStateStopped:NO];
    }
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (recorder == self.audioRecorder) {
        [self setRecordStateStopped:flag];
    }
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    if (recorder == self.audioRecorder) {
        [self setRecordStateStopped:NO];
    }
}
-(void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    if (recorder == self.audioRecorder) {
        [self setRecordStateStopped:NO];
    }
}


//---------------------------------------------------
// helper code
void ScaleAudioFileAmplitude(NSURL *theURL, float ampScale) {
    OSStatus err = noErr;
    
    ExtAudioFileRef audiofile;
    ExtAudioFileOpenURL((__bridge CFURLRef)theURL, &audiofile);
    assert(audiofile);
    
    // get some info about the file's format.
    AudioStreamBasicDescription fileFormat;
    UInt32 size = sizeof(fileFormat);
    err = ExtAudioFileGetProperty(audiofile, kExtAudioFileProperty_FileDataFormat, &size, &fileFormat);
    
    // we'll need to know what type of file it is later when we write
    AudioFileID aFile;
    size = sizeof(aFile);
    err = ExtAudioFileGetProperty(audiofile, kExtAudioFileProperty_AudioFile, &size, &aFile);
    AudioFileTypeID fileType;
    size = sizeof(fileType);
    err = AudioFileGetProperty(aFile, kAudioFilePropertyFileFormat, &size, &fileType);
    
    
    // tell the ExtAudioFile API what format we want samples back in
    AudioStreamBasicDescription clientFormat;
    bzero(&clientFormat, sizeof(clientFormat));
    clientFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
    clientFormat.mBytesPerFrame = 4;
    clientFormat.mBytesPerPacket = clientFormat.mBytesPerFrame;
    clientFormat.mFramesPerPacket = 1;
    clientFormat.mBitsPerChannel = 32;
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mSampleRate = fileFormat.mSampleRate;
    clientFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved;
    err = ExtAudioFileSetProperty(audiofile, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
    
    // find out how many frames we need to read
    SInt64 numFrames = 0;
    size = sizeof(numFrames);
    err = ExtAudioFileGetProperty(audiofile, kExtAudioFileProperty_FileLengthFrames, &size, &numFrames);
    
    // create the buffers for reading in data
    AudioBufferList *bufferList = malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (clientFormat.mChannelsPerFrame - 1));
    bufferList->mNumberBuffers = clientFormat.mChannelsPerFrame;
    for (int ii=0; ii < bufferList->mNumberBuffers; ++ii) {
        bufferList->mBuffers[ii].mDataByteSize = sizeof(float) * (float)numFrames;
        bufferList->mBuffers[ii].mNumberChannels = 1;
        bufferList->mBuffers[ii].mData = malloc(bufferList->mBuffers[ii].mDataByteSize);
    }
    
    // read in the data
    UInt32 rFrames = (UInt32)numFrames;
    err = ExtAudioFileRead(audiofile, &rFrames, bufferList);
    
    // close the file
    err = ExtAudioFileDispose(audiofile);
    
    // process the audio
    for (int ii=0; ii < bufferList->mNumberBuffers; ++ii) {
        float *fBuf = (float *)bufferList->mBuffers[ii].mData;
        for (int jj=0; jj < rFrames; ++jj) {
            *fBuf = *fBuf * ampScale;
            fBuf++;
        }
    }
    
    // open the file for writing
    err = ExtAudioFileCreateWithURL((__bridge CFURLRef)theURL, fileType, &fileFormat, NULL, kAudioFileFlags_EraseFile, &audiofile);
    
    // tell the ExtAudioFile API what format we'll be sending samples in
    err = ExtAudioFileSetProperty(audiofile, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
    
    // write the data
    err = ExtAudioFileWrite(audiofile, rFrames, bufferList);
    
    // close the file
    ExtAudioFileDispose(audiofile);
    
    // destroy the buffers
    for (int ii=0; ii < bufferList->mNumberBuffers; ++ii) {
        free(bufferList->mBuffers[ii].mData);
    }
    free(bufferList);
    bufferList = NULL;
    
}


//-----------------------------------------------------
// FX players
-(void)playKeyClickDown{
    [self playFX:@"click" ofType:@"wav" atVolume:0.125/8];
}
-(void)playKeyClickUp{
    [self playFX:@"click" ofType:@"wav" atVolume:0.125/16];
}
-(void)playFX:(NSString*)fileName ofType:(NSString*)type atVolume:(float)volume{
    //NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Tock.caf"];
    NSString *path =[[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *error;
    //AVAudioPlayer *thisAudioPlayerFX;
    //thisAudioPlayerFX = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //thisAudioPlayerFX.volume = volume;
    //[thisAudioPlayerFX play];
    self.audioPlayerFX = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayerFX.volume = volume;
    [self.audioPlayerFX play];
}


@end
