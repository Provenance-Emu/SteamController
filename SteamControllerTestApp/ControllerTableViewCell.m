//
//  ControllerTableViewCell.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 19/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "ControllerTableViewCell.h"
#import "XYView.h"
#import "SteamController.h"

// declare these selectors, so we can use them, and ARC wont complain
@interface NSObject()
-(GCControllerButtonInput*)buttonHome;
-(GCControllerButtonInput*)buttonMenu;
-(GCControllerButtonInput*)buttonOptions;
@end

@implementation ControllerTableViewCell {
    GCControllerButtonInput* _buttonHome;
    GCControllerButtonInput* _buttonMenu;
    GCControllerButtonInput* _buttonOptions;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.controller = nil;
}

- (void)setController:(GCController *)controller {
    _controller.extendedGamepad.valueChangedHandler = nil;
    _controller.controllerPausedHandler = nil;
    if ([_controller isKindOfClass:[SteamController class]]) {
        SteamController *steamController = (SteamController*)_controller;
        steamController.steamButtonCombinationHandler = nil;
    }
    _controller = controller;
    controller.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad * _Nonnull gamepad, GCControllerElement * _Nonnull element) {
        [self didUpdateElement:element inGamepad:gamepad];
    };

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wpartial-availability"
    _buttonHome = [_controller.extendedGamepad respondsToSelector:@selector(buttonHome)] ? [_controller.extendedGamepad buttonHome] : nil;
    _buttonMenu = [_controller.extendedGamepad respondsToSelector:@selector(buttonMenu)] ? [_controller.extendedGamepad buttonMenu] : nil;
    _buttonOptions = [_controller.extendedGamepad respondsToSelector:@selector(buttonOptions)] ? [_controller.extendedGamepad buttonOptions] : nil;
    #pragma clang diagnostic pop
    
    if (_buttonHome != nil) {
        self.homeButton = self.pauseButton;
        [self.homeButton setTitle:@"HOME" forState:UIControlStateNormal];
    }
    else if (_buttonMenu != nil) {
        self.menuButton = self.pauseButton;
        [self.menuButton setTitle:@"MENU" forState:UIControlStateNormal];
    }
    else {
        controller.controllerPausedHandler = ^(GCController * _Nonnull controller) {
            self.pauseButton.selected = YES;
            [self.pauseButton performSelector:@selector(setSelected:) withObject:nil afterDelay:0.2];
        };
    }
    // if steamButtonCombinationHandler == nil the STEAM/HOME button will act like a normal button, else it will have combo-only behaviour
    if (_buttonHome == nil && [controller isKindOfClass:[SteamController class]]) {
        SteamController *steamController = (SteamController*)controller;
        steamController.steamButtonCombinationHandler = ^(SteamController *controller, SteamControllerButton button, BOOL isDown) {
            NSLog(@"Steam combo with button %@ %s", NSStringFromSteamControllerButton(button), isDown?"DOWN":"UP");
            // Mode toggles
            if (isDown && button == SteamControllerButtonLeftTrackpadClick) {
                // toggle left trackpad click to input
                controller.steamLeftTrackpadRequiresClick = !controller.steamLeftTrackpadRequiresClick;
            } else if (isDown && button == SteamControllerButtonRightTrackpadClick) {
                // toggle right trackpad click to input
                controller.steamRightTrackpadRequiresClick = !controller.steamRightTrackpadRequiresClick;
            } else if (isDown && button == SteamControllerButtonStick) {
                // toggle stick mapping between d-pad and left stick
                if (controller.steamThumbstickMapping == SteamControllerMappingLeftThumbstick) {
                    controller.steamThumbstickMapping = SteamControllerMappingDPad;
                } else {
                    controller.steamThumbstickMapping = SteamControllerMappingLeftThumbstick;
                }
            }
        };
    }
}

- (void)didUpdateElement:(GCControllerElement*)element inGamepad:(GCExtendedGamepad*)gamepad {
    if (element == gamepad.buttonA) {
        self.buttonA.selected = gamepad.buttonA.pressed;
    } else if (element == gamepad.buttonB) {
        self.buttonB.selected = gamepad.buttonB.pressed;
    } else if (element == gamepad.buttonX) {
        self.buttonX.selected = gamepad.buttonX.pressed;
    } else if (element == gamepad.buttonY) {
        self.buttonY.selected = gamepad.buttonY.pressed;
    } else if (element == gamepad.leftShoulder) {
        self.leftShoulder.selected = gamepad.leftShoulder.pressed;
    } else if (element == gamepad.rightShoulder) {
        self.rightShoulder.selected = gamepad.rightShoulder.pressed;
    } else if (element == gamepad.leftTrigger) {
        int percent = gamepad.leftTrigger.value * 100;
        NSString *title = percent ? [NSString stringWithFormat:@"%d%%", percent] : @"LT";
        [self.leftTrigger setTitle:title forState:UIControlStateNormal];
        self.leftTrigger.selected = gamepad.leftTrigger.pressed;
    } else if (element == gamepad.rightTrigger) {
        int percent = gamepad.rightTrigger.value * 100;
        NSString *title = percent ? [NSString stringWithFormat:@"%d%%", percent] : @"RT";
        [self.rightTrigger setTitle:title forState:UIControlStateNormal];
        self.rightTrigger.selected = gamepad.rightTrigger.pressed;
    } else if (element == gamepad.dpad) {
        [self.dpadView setX:gamepad.dpad.xAxis.value Y:gamepad.dpad.yAxis.value];
    } else if (element == gamepad.leftThumbstick) {
        [self.leftTrackpadView setX:gamepad.leftThumbstick.xAxis.value Y:gamepad.leftThumbstick.yAxis.value];
    } else if (element == gamepad.rightThumbstick) {
        [self.rightTrackpadView setX:gamepad.rightThumbstick.xAxis.value Y:gamepad.rightThumbstick.yAxis.value];
    }
    
    if (element == _buttonHome)
        self.homeButton.selected = _buttonHome.pressed;
    if (element == _buttonOptions)
        self.backButton.selected = _buttonOptions.pressed;
    if (element == _buttonMenu)
        self.forwardButton.selected = _buttonMenu.pressed;

    if (@available(iOS 12.1, *)) {
        if (element == gamepad.leftThumbstickButton) {
            self.leftTrackpadView.backgroundColor = gamepad.leftThumbstickButton.pressed ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
        } else if (element == gamepad.rightThumbstickButton) {
            self.rightTrackpadView.backgroundColor = gamepad.rightThumbstickButton.pressed ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
        }
    }
}

@end
