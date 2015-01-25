//
//  SKScene+GameView.m
//  BouncingBear
//
//  Created by Mighty on 2014/11/04.
//  Copyright (c) 2014年 Shunsuke Ogata. All rights reserved.
//

#import "GameView.h"

static inline CGFloat skRandf() {
	return (float)arc4random() / INT_MAX;
}
static inline CGFloat skRand(CGFloat low, CGFloat high) {
	return skRandf() * (high - low) + low;
}


@interface GameView () <SKPhysicsContactDelegate>
@end

@implementation GameView{
	BOOL _contentCreated;
	double timeInterval;
	NSTimer *timeObj, *barAddTimer;
	UILabel *timeLabel;
	double currentTime;
	NSInteger barCounter;
}

SKSpriteNode *bear;
static const uint32_t bearCategory = 0x1 << 0;
static const uint32_t barCategory = 0x1 << 1;
static const uint32_t spikeCategory = 0x1 << 2;
static const uint32_t worldCategory = 0x1 << 3;




- (void)didMoveToView:(SKView *)view {
	if (!_contentCreated) {
		[self createSceneContents];
		_contentCreated = YES;
	}
}

- (void)createSceneContents {
	
	timeInterval = 1.0/60;
	currentTime = 0.0;
	barCounter = 0;
	
	CGRect timeLabelRect = CGRectMake(0, 0, self.view.center.x, 20);
	timeLabel = [[UILabel alloc] initWithFrame:timeLabelRect];
	timeLabel.text = [NSString stringWithFormat:@"%.2fs", timeInterval];
	timeLabel.center = CGPointMake(3*self.frame.size.width/4, 70);
	timeLabel.textAlignment =	NSTextAlignmentRight;
	[self.view addSubview:timeLabel];
	
	self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
	self.physicsBody.density = 1000;
	self.physicsWorld.contactDelegate = self;
	self.physicsBody.categoryBitMask = worldCategory;
	self.physicsBody.collisionBitMask = bearCategory;
	
	SKSpriteNode *spike = [SKSpriteNode spriteNodeWithImageNamed:@"spike"];
	spike.position = CGPointMake(self.view.center.x, self.frame.size.height - 40);
	spike.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(600, 40)];
	spike.physicsBody.pinned = YES;
	spike.physicsBody.categoryBitMask = spikeCategory;
	spike.physicsBody.dynamic = NO;
	[self addChild:spike];
	
	
	bear = [SKSpriteNode spriteNodeWithImageNamed:@"kuma"];
	bear.position = self.view.center;
	bear.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
	bear.physicsBody.categoryBitMask = bearCategory;
	bear.physicsBody.contactTestBitMask = spikeCategory;
	bear.physicsBody.usesPreciseCollisionDetection = YES;
	bear.physicsBody.restitution = 0.9f;

	[self addChild:bear];

	
	timeObj = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timeGoing) userInfo:nil repeats:YES];
	barAddTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addBar) userInfo:nil repeats:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint location = [touch locationInNode:self];
		
		bear.physicsBody.velocity = CGVectorMake( (bear.physicsBody.velocity.dx + (location.x - bear.position.x)*3) , (bear.physicsBody.velocity.dy + (location.y - bear.position.y)*2));
	}
}

- (void)timeGoing{
	currentTime += timeInterval;
	timeLabel.text = [NSString stringWithFormat:@"%.2fs", currentTime];
	if(bear.position.x<0 || bear.position.x >self.frame.size.width || bear.position.y > self.frame.size.height){
		[timeObj invalidate];
	}
}

- (void)addBar{
	
	float r, g, b;
	CGRect rect =  CGRectMake(0, 0, 225,10);
	SKShapeNode *bar = [SKShapeNode node];
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, Nil,rect);
	bar.path = path;
	bar.fillColor = [SKColor colorWithRed:r = skRand(0, 1.0f) green:g = skRand(0, 1.0f) blue:b = skRand(0, 1.0f) alpha:1];
	bar.strokeColor = [SKColor blackColor];
	bar.position = CGPointMake(skRand(0, 100), 0);
	bar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
	bar.physicsBody.categoryBitMask = barCategory;
	bar.physicsBody.affectedByGravity = NO;
	bar.physicsBody.angularVelocity = M_PI/(skRand(24, 48)) - 1.5*M_PI/48;
	bar.physicsBody.restitution = skRand(0, 1.5);
	bar.physicsBody.friction = (r+g+b)/3.0 ;
	bar.physicsBody.linearDamping = 0;
	bar.physicsBody.velocity = CGVectorMake(0, self.size.height / 8);
	bar.physicsBody.density = 10000;
	
	[self addChild:bar];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
	SKPhysicsBody *firstBody, *secondBody;
	
	if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
		firstBody = contact.bodyA;
		secondBody = contact.bodyB;
	} else {
		firstBody = contact.bodyB;
		secondBody = contact.bodyA;
	}
	
	if ((firstBody.categoryBitMask & bearCategory) != 0) {
		
		if ((secondBody.categoryBitMask & spikeCategory) != 0) {
			NSString *sparkPath = [[NSBundle mainBundle] pathForResource:@"spark" ofType:@"sks"];
			SKEmitterNode *spark = [NSKeyedUnarchiver unarchiveObjectWithFile:sparkPath];
			spark.position = CGPointMake(firstBody.node.position.x, firstBody.node.position.y + 20);
			[self addChild:spark];
			
			SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3f];
			SKAction *remove = [SKAction removeFromParent];
			SKAction *sequence = [SKAction sequence:@[fadeOut, remove]];
			[spark runAction:sequence];
			
			[firstBody.node removeFromParent];
			[timeObj invalidate];
		}
		
	}
}


@end
