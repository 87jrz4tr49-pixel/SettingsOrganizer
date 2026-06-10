#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface EmptyListController : PSListController
@end

@implementation EmptyListController
- (NSArray *)specifiers {
    return @[]; 
}
@end

%hook PSEditableListController

- (NSArray *)specifiers {
    NSArray *orig = %orig;
    if (orig.count > 1) {
        NSMutableArray *collected = [NSMutableArray new];
        for (int i = 1; i < orig.count; i++) {
            [collected addObject:orig[i]];
        }
        
        Class folderController = objc_allocateClassPair([PSListController class], "FolderController", 0);
        class_addMethod(folderController, @selector(specifiers), imp_implementationWithBlock(^(id self) {
            return collected;
        }), "@@:");
        objc_registerClassPair(folderController);
        
        PSSpecifier *folder = [PSSpecifier preferenceSpecifierNamed:@"Сгруппированные настройки"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:folderController
                                                               cell:PSLinkCell
                                                               edit:nil];
        PSSpecifier *hidden = [PSSpecifier preferenceSpecifierNamed:@"Скрытые приложения"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:[EmptyListController class]
                                                               cell:PSLinkCell
                                                               edit:nil];
        NSMutableArray *final = [NSMutableArray array];
        [final addObject:orig[0]];
        [final addObject:folder];
        [final addObject:hidden];
        return final;
    }
    return orig;
}
%end