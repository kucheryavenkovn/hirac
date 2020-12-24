﻿#Использовать irac

Перем ПодключениеКАгентам;
Перем ИнформационныеБазы;

#Область ПрограммныйИнтерфейс

// Процедура инициализирует подключение к агентам управления кластерами
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура Инициализировать(Знач НастройкиПодключения = Неопределено) Экспорт

	ПодключениеКАгентам = Новый ПодключениеКАгентам(НастройкиПодключения);

КонецПроцедуры // Инициализировать()

// Функция - возвращает объект-подключение к агентам кластера 1С
//
// Возвращаемое значение:
//   ПодключениеКАгентам     - объект-подключение к агентам кластера 1С
//
Функция ПодключениеКАгентам() Экспорт
	
	Возврат ПодключениеКАгентам;

КонецФункции // ПодключениеКАгентам()

Процедура ОбновитьИБ(Знач Поля = "_summary", Знач Фильтр = Неопределено) Экспорт

	Если ТипЗнч(Поля) = Тип("Строка") Тогда
		Поля = СтрРазделить(Поля, ",", Ложь);
		Для й = 0 По Поля.ВГраница() Цикл
			Поля[й] = ВРег(СокрЛП(Поля[й]));
		КонецЦикла;
	ИначеЕсли НЕ ТипЗнч(Поля) = Тип("Массив") Тогда
		Поля = Новый Массив();
		Поля.Добавить("_SUMMARY");
	КонецЕсли;

	ДобавленныеИБ = Новый Соответствие();
	
	ИнформационныеБазы = Новый Массив();

	Для Каждого ТекАгент Из ПодключениеКАгентам.Агенты() Цикл

		ИБАгента = ИБАгента(ТекАгент.Значение, Поля);

		Для Каждого ТекИБ Из ИБАгента Цикл
			Если ДобавленныеИБ[ТекИБ["infobase"]] = Неопределено Тогда
				ДобавленныеИБ.Вставить(ТекИБ["infobase"], Истина);
			Иначе
				Продолжить;
			КонецЕсли;

			Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ТекИБ, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			ИнформационныеБазы.Добавить(ТекИБ);
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ОбновитьИБ()

Функция ИнформационныеБазы(Знач Поля = "_summary", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьИБ(Поля, Фильтр);
	КонецЕсли;

	Возврат ИнформационныеБазы;

КонецФункции // ИнформационныеБазы()

Функция ИнформационнаяБаза(ИБ, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьИБ(Поля);
	КонецЕсли;

	Для Каждого ТекИБ Из ИнформационныеБазы Цикл
		Если ТекИБ["infobase-label"] = ИБ Тогда
			Возврат ТекИБ;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // ИнформационнаяБаза()

Функция Список() Экспорт

	Возврат ОбщегоНазначения.ДанныеВJSON(ИнформационныеБазы(Истина));
	
КонецФункции // Список()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхИБ

Функция ИБАгента(Знач Агент, Знач Поля)

	ИБАгента = Новый Массив();

	ДобавленныеКластеры = Новый Соответствие();

	Кластеры = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		Если ДобавленныеКластеры[ТекКластер.Ид()] = Неопределено Тогда
			ДобавленныеКластеры.Вставить(ТекКластер.Ид(), Истина);
		Иначе
			Продолжить;
		КонецЕсли;

		ИБКластера = ИБКластера(ТекКластер, Поля);

		Для Каждого ТекИБ Из ИБКластера Цикл
			
			Если ДобавитьПоле(Поля, "AGENT") Тогда
				ТекИБ.Вставить("agent", СтрШаблон("%1:%2",
				                                  Агент.АдресСервераАдминистрирования(),
				                                  Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если ДобавитьПоле(Поля, "AGENT") Тогда
				ТекИБ.Вставить("cluster" , ТекКластер.Ид());
				ТекИБ.Вставить("cluster-label",
				               СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если ДобавитьПоле(Поля, "AGENT") Тогда
				ТекИБ.Вставить("count", 1);
			КонецЕсли;
	
			ИБАгента.Добавить(ТекИБ);

		КонецЦикла;

	КонецЦикла;

	Возврат ИБАгента;

КонецФункции // ИБАгента()

Функция ИБКластера(Знач Кластер, Знач Поля)

	ИБКластера = Новый Массив();
	
	СписокИБ = Кластер.ИнформационныеБазы().Список();

	ПоляИБ = Кластер.ИнформационныеБазы().ПараметрыОбъекта().ОписаниеСвойств("ИмяРАК");

	ПолноеОписание = Ложь;
	Для Каждого ТекПоле Из Поля Цикл
		Если НЕ ПолеОсновнойИнформации(ТекПоле) Тогда
			ПолноеОписание = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Для Каждого ТекИБ Из СписокИБ Цикл

		Если ПолноеОписание И НЕ ТекИБ.ПолноеОписание() Тогда
			ТекИБ.ОбновитьДанные(Истина);
		КонецЕсли;

		ОписаниеИБ = Новый Соответствие();

		Для Каждого ТекЭлемент Из ПоляИБ Цикл
			Если НЕ ДобавитьПоле(Поля, ТекЭлемент.Ключ) Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекИБ.Получить(ТекЭлемент.Значение.Имя);
			Если ТекЭлемент.Ключ = "descr" И Лев(ЗначениеЭлемента, 1) = """"  И Прав(ЗначениеЭлемента, 1) = """" Тогда
				ЗначениеЭлемента = Сред(ЗначениеЭлемента, 2, СтрДлина(ЗначениеЭлемента) - 2);
			КонецЕсли;
			ОписаниеИБ.Вставить(ТекЭлемент.Ключ, ЗначениеЭлемента);
		КонецЦикла;

		ИБКластера.Добавить(ОписаниеИБ);

	КонецЦикла;

	Возврат ИБКластера;
	
КонецФункции // ИБКластера()

Функция ПолеОсновнойИнформации(ИмяПоля)

	КраткиеСведения = "INFOBASE, NAME, CLUSTER, AGENT, DESCR, COUNT, _NO, _SUMMARY";

	Возврат НЕ Найти(КраткиеСведения, ВРег(ИмяПоля)) = 0;

КонецФункции // ПолеОсновнойИнформации()

Функция ДобавитьПоле(ДобавляемыеПоля, ИмяПоля)

	Если НЕ ДобавляемыеПоля.Найти("_ALL") = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Если НЕ ДобавляемыеПоля.Найти("_SUMMARY") = Неопределено И ПолеОсновнойИнформации(ИмяПоля) Тогда
		Возврат Истина;
	КонецЕсли;

	Если НЕ ДобавляемыеПоля.Найти(ВРег(ИмяПоля)) = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;

КонецФункции // ПолеОсновнойИнформации()

#КонецОбласти // ПолучениеДанныхИБ

Инициализировать();
