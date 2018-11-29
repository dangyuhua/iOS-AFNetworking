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
+(void)getNewsListWithContent:(NSString *)content page:(NSString *)page success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"channel":content,@"start":page,@"num":@"20",@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    [self getWithURLString:@"/jisuapi/get" parameter:parameters success:success failure:failure];
}

//获取新闻标题
+(void)getNewsListTitlesSuccess:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    [self getWithURLString:@"/jisuapi/channel" parameter:parameters success:success failure:failure];
}

//新闻搜索
+(void)postNewsWithSearchContent:(NSString *)content success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"keyword":content,@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    [self postURLString:@"/jisuapi/newSearch" parameters:parameters success:success fail:failure];
}
//菜谱分类
+(void)getRecipeClassSuccess:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    [self postURLString:@"/jisuapi/recipe_class" parameters:parameters success:success fail:failure];
}
//按分类检索
+(void)getRecipeNameClassid:(NSString *)classid page:(NSString *)page success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"classid":classid,@"start":page,@"num":@"20",@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    [self postURLString:@"/jisuapi/byclass" parameters:parameters success:success fail:failure];
}
//搜索
+(void)searchRecipe:(NSString *)recipe success:(successBlock)success failure:(failBlock)failure{
    NSDictionary *parameters = @{@"keyword":recipe,@"num":@"20",@"appkey":@"b6fdf294e2eb7e223f59efa5a239365e"};
    [self getWithURLString:@"/jisuapi/search" parameter:parameters success:success failure:failure];
}
//上传头像
+(void)uploadPicWithUserName:(NSString *)userName images:(NSMutableArray *)images progress:(progressBlock)progress success:(successBlock)success failure:(failBlock)failure{
    AFHTTPSessionManager *manager = [self shareManager];
    [manager POST:@"" parameters:@{@"user_name":userName} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
}

//GET
+(void)getWithURLString:(NSString *)url parameter:(NSDictionary *)parameter success:(successBlock)success failure:(failBlock)failure{
    
    AFHTTPSessionManager *manager = [self shareManager];
    url = [NSString stringWithFormat:@"%@%@",BasicURL,url];
    DLog(@"%@",parameter);
    DLog(@"%@",url);
    [manager GET:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
}
//POST
+(void)postURLString:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock )success fail:(failBlock )failure{
    AFHTTPSessionManager *manager = [self shareManager];
    url = [NSString stringWithFormat:@"%@%@",BasicURL,url];
    DLog(@"%@",parameters);
    DLog(@"%@",url);
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
}
//取消网络请求
+(void)cancelRequest{
    AFHTTPSessionManager *manager = [self shareManager];
    [manager.operationQueue cancelAllOperations];
}

@end
