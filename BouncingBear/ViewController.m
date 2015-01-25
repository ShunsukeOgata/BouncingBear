
#import "ViewController.h"
#import "GameView.h"
#import <SpriteKit/SpriteKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView{
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	SKView *skView = [[SKView alloc] initWithFrame:applicationFrame];
	self.view = skView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	SKView *skView = (SKView *)self.view;
	skView.showsDrawCount = YES;
	skView.showsNodeCount = YES;
	skView.showsFPS = YES;
	
	SKScene *scene = [GameView sceneWithSize:self.view.bounds.size];
	scene.backgroundColor = [UIColor grayColor];
	[skView presentScene:scene];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end