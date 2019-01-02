//
//  NetworkingManage.m
//  Shopping
//
//  Created by 党玉华 on 2018/7/13.
//  Copyright © 2018年 党玉华. All rights reserved.
//

#import "Network.h"

BOOL haveNetwork;

@interface Network()

@end

@implementation Network

//网络检测
+(void)startMonitoringNetwork{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            haveNetwork = NO;
            [MBPManage showMessage:WIN message:@"没有网络"];
        }else{
            haveNetwork = YES;
            [MBPManage showMessage:WIN message:@"网络已连接"];
        }
    }];
    
    //开始监控
    [manager startMonitoring];
}

+(AFHTTPSessionManager *)shareManager{
    static AFHTTPSessionManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(& onceToken, ^{
        if (manager == nil) {
            manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
            //超时
            manager.requestSerializer.timeoutInterval = 20.0;
        }
    });
    return manager;
}
//获取新闻列表
+(NSURLSessionDataTask *)getNewsListWithContent:(NSString *)content page:(NSString *)page success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"channel":content,@"start":page,@"num":@"20",@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    NSURLSessionDataTask *task = [self getWithURLString:@"/jisuapi/get" parameter:parameters success:success failure:failure];
    return task;
}

//获取新闻标题
+(NSURLSessionDataTask *)getNewsListTitlesSuccess:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    NSURLSessionDataTask *task = [self getWithURLString:@"/jisuapi/channel" parameter:parameters success:success failure:failure];
    return task;
}

//新闻搜索
+(NSURLSessionDataTask *)postNewsWithSearchContent:(NSString *)content success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"keyword":content,@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    NSURLSessionDataTask *task = [self postURLString:@"/jisuapi/newSearch" parameters:parameters success:success fail:failure];
    return task;
}
//菜谱分类
+(NSURLSessionDataTask *)getRecipeClassSuccess:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    NSURLSessionDataTask *task = [self postURLString:@"/jisuapi/recipe_class" parameters:parameters success:success fail:failure];
    return task;
}
//按分类检索
+(NSURLSessionDataTask *)getRecipeNameClassid:(NSString *)classid page:(NSString *)page success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"classid":classid,@"start":page,@"num":@"20",@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    NSURLSessionDataTask *task = [self postURLString:@"/jisuapi/byclass" parameters:parameters success:success fail:failure];
    return task;
}
//搜索
+(NSURLSessionDataTask *)searchRecipe:(NSString *)recipe success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"keyword":recipe,@"num":@"20",@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    NSURLSessionDataTask *task = [self getWithURLString:@"/jisuapi/search" parameter:parameters success:success failure:failure];
    return task;
}
//上传头像
+(NSURLSessionDataTask *)uploadPicWithUserName:(NSString *)userName images:(NSMutableArray *)images progress:(progressBlock)progress success:(successBlock)success failure:(failBlock)failure{
    AFHTTPSessionManager *manager = [self shareManager];
    NSURLSessionDataTask *task = [manager POST:@"" parameters:@{@"user_name":userName} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i=0; i<images.count; i++) {
            UIImage *image = images[i];
            NSData *data = UIImagePNGRepresentation(image);
            // 获取沙盒目录
            NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
            // 将图片写入文件
            [data writeToFile:fullPath atomically:YES];
            [formData appendPartWithFileData:data name:@"parents_head" fileName:fullPath mimeType:@"image/png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
        DLog(@"%lld",uploadProgress.completedUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        success(dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    return task;
}

//GET
+(NSURLSessionDataTask *)getWithURLString:(NSString *)url parameter:(NSDictionary *)parameter success:(successBlock)success failure:(failBlock)failure{
    
    AFHTTPSessionManager *manager = [self shareManager];
    url = [NSString stringWithFormat:@"%@%@",BasicURL,url];
    DLog(@"%@",parameter);
    DLog(@"%@",url);
    NSURLSessionDataTask *task = [manager GET:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        success(dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!haveNetwork) {
            NSError *e = [NSError errorWithDomain:@"com.network" code:0 userInfo:[NSDictionary dictionaryWithObject:@"请检查网络设置" forKey:NSLocalizedDescriptionKey]];
            failure(e);
        }else{
            failure(error);
        }
    }];
    return task;
}
//POST
+(NSURLSessionDataTask *)postURLString:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock )success fail:(failBlock )failure{
    AFHTTPSessionManager *manager = [self shareManager];
    url = [NSString stringWithFormat:@"%@%@",BasicURL,url];
    DLog(@"%@",parameters);
    DLog(@"%@",url);
    NSURLSessionDataTask *task = [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        success(dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!haveNetwork) {
            NSError *e = [NSError errorWithDomain:@"com.network" code:0 userInfo:[NSDictionary dictionaryWithObject:@"请检查网络设置" forKey:NSLocalizedDescriptionKey]];
            failure(e);
        }else{
            failure(error);
        }
    }];
    return task;
}

@end
