//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OWSTableItem;
@class OWSTableSection;

@interface OWSTableContents : NSObject

@property (nonatomic) NSString *title;

- (void)addSection:(OWSTableSection *)section;

@end

#pragma mark -

@interface OWSTableSection : NSObject

@property (nonatomic, nullable) NSString *title;

+ (OWSTableSection *)sectionWithTitle:(NSString *)title items:(NSArray<OWSTableItem *> *)items;

- (void)addItem:(OWSTableItem *)item;

@end

#pragma mark -

typedef NS_ENUM(NSInteger, OWSTableItemType) {
    OWSTableItemTypeAction,
};

typedef void (^OWSTableActionBlock)();

@interface OWSTableItem : NSObject

+ (OWSTableItem *)actionWithTitle:(NSString *)title
                      actionBlock:(OWSTableActionBlock)actionBlock;

@end

#pragma mark -

@interface OWSTableViewController : UITableViewController

@property (nonatomic) OWSTableContents *contents;

#pragma mark - Presentation

- (void)presentFromViewController:(UIViewController *)fromViewController;

@end

NS_ASSUME_NONNULL_END
