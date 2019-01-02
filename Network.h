//
//  NetworkingManage.h
//  Shopping
//
//  Created by 党玉华 on 2018/7/13.
//  Copyright © 2018年 党玉华. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock) (id data);
typedef void(^failBlock) (NSError *error);
typedef void(^progressBlock) (NSProgress *progress);

@interface Network : NSObject
//网络检测
+(void)startMonitoringNetwork;
//
+(AFHTTPSessionManager *)shareManager;
//获取新闻列表
+(NSURLSessionDataTask *)getNewsListWithContent:(NSString *)content page:(NSString *)page success:(successBlock)success failure:(failBlock)failure;
//新闻搜索
+(NSURLSessionDataTask *)postNewsWithSearchContent:(NSString *)content success:(successBlock)success failure:(failBlock)failure;
//获取新闻标题
+(NSURLSessionDataTask *)getNewsListTitlesSuccess:(successBlock)success failure:(failBlock)failure;
//菜谱分类
+(NSURLSessionDataTask *)getRecipeClassSuccess:(successBlock)success failure:(failBlock)failure;
//按分类检索
+(NSURLSessionDataTask *)getRecipeNameClassid:(NSString *)classid page:(NSString *)page success:(successBlock)success failure:(failBlock)failure;
//搜索
+(NSURLSessionDataTask *)searchRecipe:(NSString *)recipe success:(successBlock)success failure:(failBlock)failure;
//上传头像
+(NSURLSessionDataTask *)uploadPicWithUserName:(NSString *)userName images:(NSMutableArray *)images progress:(progressBlock)progress success:(successBlock)success failure:(failBlock)failure;

@end
