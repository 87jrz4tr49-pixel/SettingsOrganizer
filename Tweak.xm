#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <rootless.h> // Подключаем для работы с путями в rootless среде

// 1. Пустой контроллер для "скрытых приложений"
@interface EmptyListController : PSListController
@end

@implementation EmptyListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        // Возвращаем пустой массив — список будет абсолютно пустым
        _specifiers = [NSArray array];
    }
    return _specifiers;
}
@end

// Хук для корневого контроллера настроек
%hook PSEditableListController

- (NSArray *)specifiers {
    NSArray *orig = %orig;
    
    // Проверяем, что массив не пустой и содержит элементы
    if (orig.count > 1) {
        // Создаём массив для пунктов, которые будут внутри "папки"
        NSMutableArray *collected = [NSMutableArray new];
        
        // Собираем пункты начиная со второго элемента
        // (Первый элемент обычно это группа "Apple ID/iCloud" или подобное, 
        // мы оставим его на виду)
        for (int i = 1; i < orig.count; i++) {
            [collected addObject:orig[i]];
        }
        
        // Создаём динамический класс для нашей "папки"
        // Это и будет тот самый контроллер, который откроется при нажатии
        Class folderController = objc_allocateClassPair([PSListController class], "FolderController", 0);
        
        // Добавляем метод -specifiers, который вернёт собранные нами пункты
        class_addMethod(folderController, @selector(specifiers), imp_implementationWithBlock(^(id self) {
            return collected;
        }), "@@:");
        
        objc_registerClassPair(folderController);
        
        // Создаём пункт, который будет вести в эту "папку"
        PSSpecifier *folder = [PSSpecifier preferenceSpecifierNamed:@"Сгруппированные настройки"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:folderController
                                                               cell:PSLinkCell
                                                               edit:nil];
        
        // Создаём пункт "Скрытые приложения"
        PSSpecifier *hidden = [PSSpecifier preferenceSpecifierNamed:@"Скрытые приложения"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:[EmptyListController class]
                                                               cell:PSLinkCell
                                                               edit:nil];
        
        // Формируем финальный массив specifier'ов для главного экрана настроек
        NSMutableArray *final = [NSMutableArray array];
        // Оставляем первый пункт (Apple ID) на виду
        [final addObject:orig[0]];
        // Добавляем нашу новую "папку"
        [final addObject:folder];
        // Добавляем пункт "Скрытые приложения" в самый конец
        [final addObject:hidden];
        
        return final;
    }
    
    // Если что-то пошло не так или массив пустой, возвращаем оригинал
    return orig;
}
%end