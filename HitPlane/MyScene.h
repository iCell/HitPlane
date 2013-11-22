//
//  MyScene.h
//  HitPlane
//

//  Copyright (c) 2013 LiXiaoyu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *mainPlane;
@property (nonatomic, strong) SKSpriteNode *backgroundNode;
@property (nonatomic, strong) SKSpriteNode *tempBackgroundNode;
@property (nonatomic, strong) SKSpriteNode *bulletNode;

@end
