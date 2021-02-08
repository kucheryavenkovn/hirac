# HTTP interface for RAC (HiRAC)

[![GitHub release](https://img.shields.io/github/release/ArKuznetsov/hirac.svg?style=flat-square)](https://github.com/ArKuznetsov/hirac/releases)
[![GitHub license](https://img.shields.io/github/license/ArKuznetsov/hirac.svg?style=flat-square)](https://github.com/ArKuznetsov/hirac/blob/develop/LICENSE)
[![Build Status](https://img.shields.io/github/workflow/status/ArKuznetsov/hirac/%D0%9A%D0%BE%D0%BD%D1%82%D1%80%D0%BE%D0%BB%D1%8C%20%D0%BA%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%B0)](https://github.com/arkuznetsov/hirac/actions/)
[![Quality Gate](https://open.checkbsl.org/api/badges/gate?key=hirac)](https://open.checkbsl.org/dashboard/index/hirac)
[![Coverage](https://open.checkbsl.org/api/badges/measure?key=hirac&metric=coverage)](https://open.checkbsl.org/dashboard/index/hirac)
[![Tech debt](https://open.checkbsl.org/api/badges/measure?key=hirac&metric=sqale_debt_ratio)](https://open.checkbsl.org/dashboard/index/hirac)## Кластеры

REST API для получения информации о кластере сервера 1С и управления объектами кластера.

## Требования

Требуются следующие библиотеки и инструменты:
- [OneScript.Web](https://github.com/EvilBeaver/OneScript.Web) - MVC фреймворк для разработки веб-сайтов с использованием [OneScript](https://github.com/EvilBeaver/OneScript)
- [irac](https://github.com/oscript-library/irac) - если установлен [OneScript](https://github.com/EvilBeaver/OneScript) устанавливается командой `opm install -l`
- [1C RAC](https://releases.1c.ru/project/Platform83) - утилита RAC из состава платформы 1С:Предприятие 8.3

## Запуск

Перейти в подкаталог src и запустить OneScript.Web:

```bat
cd <путь к hirac>\src
<путь к OneScript.Web>\OneScript.WebHost.exe
```

Запуск будет выполнен на 5005 порту. Изменить порт можно в файле настроек [appsettings.json](./src/appsettings.json)

## Регистрация в качестве службы

В командный файл [reg_os_web_as_service.cmd](./reg_os_web_as_service.cmd) регистрации HiRAC в качестве сервиса Windows. Запуск:

```bat
reg_os_web_as_service.cmd <путь к OneScript.Web>\OneScript.WebHost.exe <адрес>:<порт> <путь к hirac>\src

```

## Варианты запросов

  - **<имя объекта>/list** - список объектов
  - **<имя объекта>/<путь к объекту>** - содержимое объекта по указанному пути
  - **<имя объекта>/<путь к объекту>/<свойство>** - значение свойства <свойство> объекта по указанному пути
  - **counter/list** - описания доступных счетчиков
  - **counter/<имя объекта>/list** - описания доступных счетчиков для <имя объекта>
  - **counter/<имя объекта>/<счетчик>** - значения счетчика <счетчик> для <имя объекта>

## Доступные поля запросов

### Доступные поля запроса списка (`<имя объекта>/list`)

  - **field** - имя поля запрашиваемого объекта, которое попадет в результат (`field=_all` - попадут все поля)
  - **filter_<операция сравнения>_<поле объекта>** - условие (фильтр) по значению поля
  - **top_<поле объекта>** - отбор указанного количества первых результатов с максимальным значением поля <поле объекта>
  - **format** - формат вывода результата

### Доступные поля запроса счетчиков (`counter/<имя объекта>`)

  - **filter_<операция сравнения>_<поле объекта>** - условие (фильтр) по значению поля
  - **dim** - имя измерения счетчика по которым выполняется свертка значения счетчика (`dim=_all` - попадут все измерения счетчика)
  - **top** - отбор указанного количества первых значений счетчика с максимальным значением
  - **agregate** - агрегатная функция свертки значений счетчика
- **format** - формат вывода результата

### Доступные операции сравнения фильтров

  - **eq** - равно (может не указываться), для строк выполняется без учета регистра
  - **neq** - не равно, для строк выполняется без учета регистра
  - **gt** - больше
  - **gte** - больше или равно
  - **lt** - меньше
  - **lte** - меньше или равно

### Доступные агрегатные функции свертки значений счетчиков

  - **count** - количество значений счетчика
  - **distinct** - количество **различных** значений счетчика
  - **sum** - сумма значений счетчика
  - **min** - минимальное значение счетчика
  - **max** - максимальное значение счетчика
  - **avg** - среднее значение счетчика

### Доступные форматы

  - **json** - (по умолчанию) JSON-текст собственной структуры
  - **prometheus** - формат Prometheus
  - **plain** - плоский текстовый формат без указания значений измерений

## Примеры запросов:

### Получение списка кластеров

```

http://localhost:5005/cluster/list

```

## Серверы

### Получение списка серверов

```

http://localhost:5005/server/list

```

## Информационные базы

### Получение списка ИБ

```

http://localhost:5005/infobase/list

```

## Сеансы

### Получение списка сеансов

```

http://localhost:5005/session/list

```
## Счетчики

### Получение списка счетчиков


```

http://localhost:5005/counter/list

```

### Получение всех счетчиков сеансов

#### Развернуто по всем измерениям

```

http://localhost:5005/counter/session

или

http://localhost:5005/counter/session?dim=_all

```

В формате Prometheus

```

http://localhost:5005/counter/session?format=prometheus

```

#### Свернуто по всем измерениям

Агрегатная функция по умолчанию (`count`)

```

http://localhost:5005/counter/session?dim=_no

```

Агрегатная функция СУММА (`sum`)

```

http://localhost:5005/counter/session?dim=_no&agregate=sum

```

### Получение конкретного счетчика сеансов

#### Развернуто по всем измерениям

```

http://localhost:5005/counter/session/count?dim=_all

```

#### С отбором по типу клиента

```

http://localhost:5005/counter/session/count?filter_app_id=Designer

```

#### Свернуто по хосту и ИБ

Агрегатная функция СУММА (`sum`)

```

http://localhost:5005/counter/session/count?dim=host&dim=infobase&agregate=sum

```
