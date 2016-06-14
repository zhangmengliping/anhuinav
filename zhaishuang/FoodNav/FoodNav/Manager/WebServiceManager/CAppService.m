//
//  CAppService.m
//
//  Created by LiuCarl on 15/1/8.
//  Copyright (c) 2015年 Carl Liu. All rights reserved.
//
#import "CAppService.h"
#import "CAPIClient.h"
static CAppService *appService = nil;
@implementation CAppServiceError

- (instancetype)initWithType:(ykAppServiceError)type andMessage:(NSString *)message {
    if (self = [super init]) {
        self.errorType = type;
        self.errorMessage = message;
        return self;
    }
    return nil;
}

+ (instancetype)type:(ykAppServiceError)type message:(NSString *)message {
    return [[self alloc] initWithType:type andMessage:message];
}

+ (instancetype)error:(NSError *)error {
            return [[self alloc] initWithType:-1 andMessage:NSLocalizedString(@"网络错误",@"")];
}

@end

@interface CAppService ()
@property (nonatomic, strong) CAPIClient *client;

@end

@implementation CAppService

- (instancetype)init {
    if (self = [super init]) {
        self.client = [[CAPIClient alloc] init];
    }
    
    return self;
}
DEFINE_SINGLETON_FOR_CLASS(CAppService);
#pragma mark - API WebService
- (AFHTTPRequestOperation *)getSearch_request:(void (^)(NSDictionary *model))success

                                      failure:(AppServiceErrorRespondBlock)failure
                                     animated:(BOOL)animated {
    NSString *url = @"/?app=warehouse&act=index&pn=5&p=2&warehouse_name=柴桥";
    return [self.client postHttpRequestWithURL:url
                                   parameters:nil
                                      success:^(id responseObject) {
                                          success(responseObject);
                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          failure([CAppServiceError error:error]);
                                      }];
}
@end
