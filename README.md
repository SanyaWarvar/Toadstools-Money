# Гладин Даниил КИ22-17/1Б

Изначальные требования:
Приложение для контроля финансов. Требования:
1. Для мобильных устройств (Android, IOS).
2. Возможность выбора разной валюты.
3. Добавление доходов и расходов в определенные дни(даты).
4. Разделение доходов и расходов по категориям.
5. Хранение текущих средств на счетах разных типов (банковская карта, наличные и тд)
6. Подсчет остатка на счете.
7. Подсчет трат за определенный период времени (выбранный пользователем).
8. Напоминание о систематических платежах (например, ежемесячная оплата мобильной
связи)
9. Возможность ставить себе цель (например, ограничить количество трат на определенную
категорию в месяц. При приближении к ограничению оповещать пользователя. Цели не
только ограничивающие, но и для накопления)

Приложение не тестировалось на IOS устройствах по причине отсутствия таких устройств у разработчика. 
В ходе разработки было принято решение отказаться от возможности иметь несколько счетов (избавление от пунктов 2 и 5) и оставить пользователю один счет. Также было принято решение отказаться от всех уведомлений.

Эти решения были приняты из-за трудностями со сроками выполнения.

# Паттерны:

## Использовался паттерн синглтон (Singletone) для работы с базой данных по двум причинам:

1.Глобальный доступ к данным: Синглтон позволяет обеспечить глобальный доступ к данным базы данных из любой части приложения. Это упрощает работу с данными и позволяет эффективно управлять финансовыми данными в приложении.

2.Экономия ресурсов: Создание и уничтожение объекта базы данных может быть затратным в плане ресурсов. Используя паттерн синглтон, можно избежать создания множества экземпляров базы данных и сэкономить ресурсы мобильного устройства.

## Точно не стоит использовать паттерн MVC (Model-View-Controller)

Так как Flutter предлагает свою собственную архитектуру под названием Flutter’s Widget Tree, которая представляет собой комбинацию паттернов MVC и композиционного паттерна. Использование MVC может создать дополнительную сложность и неудобство для разработчика.

# Установка приложения

Скачать на android устройство установочный файл:
 **build\app\outputs\flutter-apk\app-release.apk**
 
Либо скачать этот же файл с яндекс диска:
**https://disk.yandex.ru/d/Jft_-G-gCEj3HQ**
