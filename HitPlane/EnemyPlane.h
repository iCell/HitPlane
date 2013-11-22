//
//  EnemyPlane.h
//  HitPlane
//
//  Created by LiXiaoyu on 10/30/13.
//  Copyright (c) 2013 LiXiaoyu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface EnemyPlane : SKSpriteNode

@property (nonatomic, assign) NSInteger planeType;
@property (nonatomic, assign) NSInteger planeHp;
@property (nonatomic, assign) NSInteger planeSpeed;

@end
