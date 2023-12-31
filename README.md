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

<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/74956b35-78f0-41ea-aff2-32c42bd9027c" width="700" height="300" />

## Точно не стоит использовать паттерн MVC (Model-View-Controller)

Так как Flutter предлагает свою собственную архитектуру под названием Flutter’s Widget Tree, которая представляет собой комбинацию паттернов MVC и композиционного паттерна. Использование MVC может создать дополнительную сложность и неудобство для разработчика.

# Установка приложения

## Сгенерировать .apk файл
  1. Установить flutter. [Ссылка](https://docs.flutter.dev/get-started/install)
  2. Скопировать этот репозиторий
  ```
  git clone https://github.com/SanyaWarvar/Toadstools-Money
  ```
  3.
  ```
  flutter pub get
  flutter build apk --release
  ```
   4. Сгенерированный файл будет здесь: Project\build\app\outputs\apk\release\app-release.apk
## Установить сгенерированный файл на телефон (Android)

1. Скачать установочный файл на компьютер:

2. Если .apk файл был сгенерирова самостоятельно, то он будет здесь: **Project\build\app\outputs\apk\release\app-release.apk**

Можно скачать только этот файл из репозитория, он здесь: **build\app\outputs\flutter-apk\app-release.apk**
 
Либо скачать этот же файл с яндекс диска: **https://disk.yandex.ru/d/Jft_-G-gCEj3HQ**

3. Переслать этот файл на мобильное устройство (либо скачивать сразу не него).

4. Установить скачанный файл (следовать указаниям системы).

# Пользовательское руководство

В этом руководство будет подробная инструкция к каждому экрану приложения.

## Общая информация
В левом верхнем углу вы всегда можете увидеть текущий баланс. Он подсчитывается на основе всех ваших транзакций (как доходов, так и расходов).

## Начальный экран

На главном экране вы можете увидеть все добавленные вами транзакции. 

Отображается сумма транзакции, категория и дата. Рядом с информацией о транзакции находится красная кнопка с иконкой урны. По нажатии на эту кнопку будет удалена соответствующая запись.

В нижней части экрана вы можете увидеть 4 кнопки. Подробнее о них можно прочитать снизу. Нумерация идет слева направо. 

1. Перенаправляет на "Экран отображения статистики"
2. Перенаправляет на "Экран отображения повторяющихся платежей"
3. Перенаправляет на "Экран добавления новых платежей"
4. Перенаправляет на "Экран отображения поставленных целей"
5. 
<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/7c313cf7-e7cc-46d7-9601-f3da6da09766" width="250" height="500" />

## Экран отображения статистики

Сверху есть две даты. По нажатии на них появится всплывающее окно для выборы даты. По умолчанию первая дата - 1 число текующего месяца. Вторая дата - сегодня. (Период вводится невключительно).

Ниже есть выбор из двух категорий - расходы и доходы.

В зависимости от выбора приложение отобразить разные диаграммы.

Если за выбранный период не было ни одной транзакции выбранного типа, то никакой диаграммы не будет.

Под диаграммой есть легенда и процентное соотношение.

Вернуться на главный экран можно либо по нажатии кнопки "назад" на вашем устройстве, либо по нажатии сверху слева "стрелочки назад"

<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/27bd7814-debb-421a-87db-c4c0dcc80459" width="250" height="500" />
<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/ff8740c6-3b98-41d8-836c-b9558f24804a" width="250" height="500" />


## Экран отображения повторяющихся платежей

Этот экран очень похож на начальный. Он отображает список всех повторяющихся платежей и дату последнего платежа

Удалить повторяющийся платеж можно по нажатии справа от него красной кнопки с иконкой урны.
Вернуться на главный экран можно либо по нажатии кнопки "назад" на вашем устройстве, либо по нажатии сверху слева "стрелочки назад"

<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/ba43a49b-2a34-4315-ad94-183b796b2976" width="250" height="500" />


## Экран добавления новых платежей

С самого начала у нас есть выбор добавить платеж типа расход или платеж типа доход. Доход будет увеличивать баланс, расход уменьшать.

Если вы выбираете разовый платеж, то платеж добавиться один раз.
Если вы выбираете повторяемый платеж, то каждый раз по прошествии некоторого времени (появится выпадающий список для выбора) точно такой же платеж будет добавляться автоматически.
Чтобы платеж перестал добавляться зайдите в экран отображения повторяющихся платежей и удалите его.

Вы можете выбрать категорию платежа. Учтите, что у доходов и расходов разные категории.

Ниже вы можете ввести сумму платежа, причем вы можете ввести арифметическое выражение. Например, 200 + 500 - 100. Программа сама посчитает значение. Если вы ошиблись при вводе то вы можете нажать на стрелочку, повернутую влево. Она находится правее циферблата и левее выбора даты платежа.

Справа от циферблата находится дата. По умолчанию там стоит сегодняшнее число. Но вы можете выбрать любое другое в диапозоне от 1.1.1990 до 1.1.2077, нажав на дату и выбрав в появившемся окне нужное число.

Чтобы сохранить введенные данные нажмите на зеленую галочку справа внизу экрана. Учтите, что, если введенная вами сумма равна 0, то платеж не будет добавлен.

Чтобы отменить на крестик слева снизу экрана. 

По нажатии на любую из этих кнопок вы вернетесь на начальный экран.

<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/4fddb0d5-28f9-4492-9362-761c9a78871f" width="250" height="500" />
<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/20fb366f-928f-4375-bd3a-083ebfed5893" width="250" height="500" />



## Экран отображения поставленных целей

На этом экране вы можете увидеть все поставленные вами цели. Изначально их не будет, создать свою первую цель вы можете, нажав на иконку плюсика внизу экрана, попав на экран создания цели.

Рядом с каждой целью есть красная иконка урны. По нажатии на эту урну удалится соответствующая ей цель.

У каждой цели указан период, значение и тип цели (если цель ограничивающая, то указана и категория расхода).

По завершении периода будет указано провалена ли ваша цель или выполнена. 

Вы можете завершить цель раньше в нескольких случаях:

1. Ограничивающие цели.
Если вы на данный момент (период еще не прошел) потратили уже больше, чем планировали, то цель провалена.
2. Накопительные цели
Если вы на данный момент (период еще не прошел) заработали больше, чем планировали, то цель выполнена.

<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/bb28b2d8-e1d1-497f-8b5c-a473ba832a8d" width="250" height="500" />
<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/6ed6b68b-b329-4a9a-aad5-41809366ddd1" width="250" height="500" />


## Экран создания цели

Вы можете ввести две даты - начало и конец (невключительно). По умолчанию эти даты равны и являются сегодняшним днем.

Вы можете поставить тип цели - накопительная или ограничивающая.

Накопительная цель подразумевает, что вы за выбранный период (или раньше) заработаете введенную сумму или более. 

Ограничивающая цель подразумевает, что вы за выбранный период (или раньше) потратите не более введенной суммы на выбранную категорию. 

После выбора типа цели вы можете ввести сумму цели.

Если цель ограничивающая, то вы можете выбрать одну из категорий расходов.

Чтоб создать цель или отменить создание вы можете воспользоваться кнопками галочки и крестика снизу. По аналогии с экраном создания платежа.



<img src="https://github.com/SanyaWarvar/Toadstools-Money/assets/120565896/a86fe7c0-c433-4fd1-95fd-a6a8ab95eb51" width="250" height="500" />



## Конец!

Спасибо, что прочитали пользовательскую инструкцию, надеюсь, вам будет приятно пользоваться этим приложением!




