//
//  MyScene.m
//  HitPlane
//
//  Created by LiXiaoyu on 10/28/13.
//  Copyright (c) 2013 LiXiaoyu. All rights reserved.
//

#import "MyScene.h"
#import "EnemyPlane.h"

static const uint32_t enemyPlaneCategory = 0x1 << 0;
static const uint32_t heroPlaneCategory = 0x1 << 1 ;
static const uint32_t bulletCategory = 0x1 << 2;

@implementation MyScene
{
    CGFloat _screenHeight;
    SKTextureAtlas *_planeAtlas;
    NSMutableArray *_enemyPlaneArray;
    
    NSInteger _smallPlaneTime;
    NSInteger _middlePlaneTime;
    NSInteger _bigPlaneTime;
    
    NSInteger _bulletSpeed;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        [self.physicsWorld setGravity:CGVectorMake(0, 0)];
        [self.physicsWorld setContactDelegate:(id)self];
        
        [self dataInitialize];
        [self loadBackground];
        [self loadPlayer];
        [self makeBullet];
    }
    return self;
}

- (void)dataInitialize
{
    _screenHeight = self.frame.size.height;
    _planeAtlas = [SKTextureAtlas atlasNamed:@"planes"];
    _enemyPlaneArray = [NSMutableArray array];

    _smallPlaneTime = 0;
    _middlePlaneTime = 0;
    _bigPlaneTime = 0;
    
    _bulletSpeed = 25;
}

- (void)loadBackground
{
    _backgroundNode = [SKSpriteNode spriteNodeWithTexture:[_planeAtlas textureNamed:@"background"]];
    [_backgroundNode setPosition:CGPointMake(CGRectGetMidX(self.frame), 0)];
    [_backgroundNode setAnchorPoint:CGPointMake(0.5, 0)];
    [self addChild:_backgroundNode];
    
    _tempBackgroundNode = [SKSpriteNode spriteNodeWithTexture:[_planeAtlas textureNamed:@"background"]];
    [_tempBackgroundNode setPosition:CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 1)];
    [_tempBackgroundNode setAnchorPoint:CGPointMake(0.5, 0)];
    [self addChild:_tempBackgroundNode];
}

- (void)scrollBackground
{
    _screenHeight --;
    if (_screenHeight <= 0) {
        _screenHeight = self.frame.size.height;
    }
    [self.backgroundNode setPosition:CGPointMake(CGRectGetMidX(self.frame), _screenHeight - self.frame.size.height)];
    [self.tempBackgroundNode setPosition:CGPointMake(CGRectGetMidX(self.frame), _screenHeight - 1)];
}

- (void)loadPlayer
{
    NSMutableArray *flyFrame = [NSMutableArray array];
    for (NSInteger i = 1; i <= 2; i++) {
        NSString *texString = [NSString stringWithFormat:@"hero_fly_%d", i];
        [flyFrame addObject:[_planeAtlas textureNamed:texString]];
    }
    
    _mainPlane = [SKSpriteNode spriteNodeWithTexture:[flyFrame firstObject]];
    [_mainPlane setName:@"hero"];
    [_mainPlane setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:_mainPlane.size]];
    [[_mainPlane physicsBody] setDynamic:YES];
    [[_mainPlane physicsBody] setCategoryBitMask:heroPlaneCategory];
    [[_mainPlane physicsBody] setContactTestBitMask:enemyPlaneCategory];
    [[_mainPlane physicsBody] setCollisionBitMask:0];
    
    [_mainPlane setAnchorPoint:CGPointMake(0.5, 0.5)];
    [_mainPlane setPosition:CGPointMake(160, 50)];
    [self addChild:_mainPlane];
    
    const NSTimeInterval kHeroPlaneFlySpeed = 1 / 10.0;
    SKAction *repeatAction = [SKAction repeatActionForever:[SKAction animateWithTextures:flyFrame timePerFrame:kHeroPlaneFlySpeed resize:YES restore:YES]];
    [_mainPlane runAction:repeatAction];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInNode:self];
    CGPoint previousLocation = [touch previousLocationInNode:self];
    
    CGPoint subPoint = CGPointMake(currentLocation.x - previousLocation.x, currentLocation.y - previousLocation.y);
    [self.mainPlane setPosition:[self addBoundsToHeroPlaneWithPoint:subPoint]];
}

- (CGPoint)addBoundsToHeroPlaneWithPoint:(CGPoint)subPoint
{
    CGPoint temp = CGPointZero;
    temp.x = self.mainPlane.position.x + subPoint.x;
    temp.y = self.mainPlane.position.y + subPoint.y;
    
    if (temp.x >= 286) {
        temp.x = 286;
    }else if (temp.x <= 33) {
        temp.x = 33;
    }
    
    if (temp.y >= self.frame.size.height - 50) {
        temp.y = self.frame.size.height - 50;
    }else if (temp.y <= 43) {
        temp.y = 43;
    }
    
    return temp;
}

- (void)loadEnemyPlanes
{
    _smallPlaneTime ++;
    _middlePlaneTime ++;
    _bigPlaneTime ++;
    
    if (_smallPlaneTime > 25) {
        EnemyPlane *smallPlane = [self makeSmallEnemyPlane];
        [self addChild:smallPlane];
        [_enemyPlaneArray addObject:smallPlane];
        
        _smallPlaneTime = 0;
    }
    if (_middlePlaneTime > 400) {
        EnemyPlane *middlePlane = [self makeMiddleEnemyPlane];
        [self addChild:middlePlane];
        [_enemyPlaneArray addObject:middlePlane];
        _middlePlaneTime = 0;
    }
    if (_bigPlaneTime > 700) {
        EnemyPlane *bigPlane = [self makeBigEnemyPlane];
        [self addChild:bigPlane];
        [_enemyPlaneArray addObject:bigPlane];
        _bigPlaneTime = 0;
    }
}

- (EnemyPlane *)makeSmallEnemyPlane
{
    EnemyPlane *smallEnemy = [EnemyPlane spriteNodeWithTexture:[_planeAtlas textureNamed:@"enemy1_fly_1"]];
    [smallEnemy setPosition:CGPointMake((arc4random() % 290) + 17, self.frame.size.height)];
    [smallEnemy setPlaneHp:1];
    [smallEnemy setPlaneSpeed:(arc4random()%4 + 2)];
    [smallEnemy setPlaneType:1];
    
    return smallEnemy;
}

- (EnemyPlane *)makeMiddleEnemyPlane
{
    EnemyPlane *middleEnemy = [EnemyPlane spriteNodeWithTexture:[_planeAtlas textureNamed:@"enemy3_fly_1"]];
    [middleEnemy setPosition:CGPointMake((arc4random() % 280 + 23), self.frame.size.height)];
    [middleEnemy setPlaneType:3];
    [middleEnemy setPlaneHp:15];
    [middleEnemy setPlaneSpeed:(arc4random()%3 + 2)];
    
    return middleEnemy;
}

- (EnemyPlane *)makeBigEnemyPlane
{
    EnemyPlane *bigEnemy = [EnemyPlane spriteNodeWithTexture:[_planeAtlas textureNamed:@"enemy2_fly_1"]];
    [bigEnemy setPosition:CGPointMake((arc4random()%210 + 55), 700)];
    [bigEnemy setPlaneSpeed:arc4random() % 2 + 2];
    [bigEnemy setPlaneType:2];
    [bigEnemy setPlaneHp:25];
    
    return bigEnemy;
}

- (void)moveEnemyPlane
{
    NSArray *tempArray = [NSArray arrayWithArray:_enemyPlaneArray];
    for (EnemyPlane *enemyPlane in tempArray) {
        [enemyPlane setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:enemyPlane.size]];
        [enemyPlane setName:@"enemy"];
        [[enemyPlane physicsBody] setDynamic:YES];
        [[enemyPlane physicsBody] setCategoryBitMask:enemyPlaneCategory];
        [[enemyPlane physicsBody] setContactTestBitMask:heroPlaneCategory | bulletCategory];
        [[enemyPlane physicsBody] setCollisionBitMask:0];
        
        [enemyPlane setPosition:CGPointMake(enemyPlane.position.x, enemyPlane.position.y - enemyPlane.planeSpeed)];
        if (enemyPlane.position.y < (-75)) {
            [_enemyPlaneArray removeObject:enemyPlane];
            [enemyPlane removeFromParent];
        }
    }
}

- (void)makeBullet
{
    _bulletNode = [SKSpriteNode spriteNodeWithTexture:[_planeAtlas textureNamed:@"bullet1"]];
    _bulletNode.name = @"bullet";
    [_bulletNode setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:_bulletNode.size]];
    [[_bulletNode physicsBody] setDynamic:YES];
    [[_bulletNode physicsBody] setCategoryBitMask:bulletCategory];
    [[_bulletNode physicsBody] setContactTestBitMask:enemyPlaneCategory];
    [[_bulletNode physicsBody] setCollisionBitMask:0];
    [[_bulletNode physicsBody] setUsesPreciseCollisionDetection:YES];
    
    [_bulletNode setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self addChild:_bulletNode];
}

- (void)resetBullet
{
    _bulletSpeed = (self.frame.size.height - (_mainPlane.position.y + 50)) / 15;
    if (_bulletSpeed < 5) {
        _bulletSpeed = 5;
    }
    
    [_bulletNode setPosition:CGPointMake(_mainPlane.position.x ,_mainPlane.position.y+50)];
    
}

- (void)firing
{
    [self.bulletNode setPosition:CGPointMake(self.bulletNode.position.x, self.bulletNode.position.y + _bulletSpeed)];
    if (self.bulletNode.position.y > self.frame.size.height - 20) {
        [self resetBullet];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    [self scrollBackground];
    
    [self loadEnemyPlanes];
    [self moveEnemyPlane];
    
    [self firing];
}

#pragma mark SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (((firstBody.categoryBitMask & enemyPlaneCategory) != 0) && (secondBody.categoryBitMask & bulletCategory) != 0) {
        //NSLog(@"first:%@, second:%@",firstBody.node.name, secondBody.node.name);
        
        NSMutableArray *testArr = [NSMutableArray array];
        for (NSInteger i = 1; i <= 4; i++) {
            NSString *texStr = [NSString stringWithFormat:@"enemy1_blowup_%d",i];
            [testArr addObject:[_planeAtlas textureNamed:texStr]];
        }
        SKSpriteNode *test = [SKSpriteNode spriteNodeWithTexture:[testArr firstObject]];
        [test setPosition:firstBody.node.position];
        [self addChild:test];

        
        [firstBody.node removeFromParent];
        SKAction *testAction = [SKAction animateWithTextures:testArr timePerFrame:5/10];
        [test runAction:testAction completion:^(void){
            [test removeFromParent];
        }];
    }else if (((secondBody.categoryBitMask & heroPlaneCategory) != 0) && ((firstBody.categoryBitMask & enemyPlaneCategory) != 0)) {
        
    }
}

@end
