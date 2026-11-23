TARGET := iphone:clang:16.5:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = LifeEvolution

LifeEvolution_FILES = main.m AppDelegate.m GameViewController.m
LifeEvolution_FRAMEWORKS = UIKit Foundation QuartzCore CoreHaptics AVFoundation
LifeEvolution_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS)/makefiles/application.mk