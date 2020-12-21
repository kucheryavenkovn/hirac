﻿#Использовать irac

Перем ПодключениеКАгентам;
Перем Сеансы;

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

Процедура ОбновитьСеансы(Знач Поля = "_all", Знач Фильтр = Неопределено) Экспорт

	Если ТипЗнч(Поля) = Тип("Строка") Тогда
		Поля = СтрРазделить(Поля, ",", Ложь);
		Для й = 0 По Поля.ВГраница() Цикл
			Поля[й] = ВРег(СокрЛП(Поля[й]));
		КонецЦикла;
	ИначеЕсли НЕ ТипЗнч(Поля) = Тип("Массив") Тогда
		Поля = Новый Массив();
		Поля.Добавить("_ALL");
	КонецЕсли;

	ДобавленныеСеансы = Новый Соответствие();
	
	Сеансы = Новый Массив();

	Для Каждого ТекАгент Из ПодключениеКАгентам.Агенты() Цикл

		СеансыАгента = СеансыАгента(ТекАгент.Значение, Поля);

		Для Каждого ТекСеанс Из СеансыАгента Цикл
			Если ДобавленныеСеансы[ТекСеанс["session"]] = Неопределено Тогда
				ДобавленныеСеансы.Вставить(ТекСеанс["session"], Истина);
			Иначе
				Продолжить;
			КонецЕсли;

			Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ТекСеанс, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			Сеансы.Добавить(ТекСеанс);
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ОбновитьСеансы()

Функция Сеансы(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьСеансы(Поля, Фильтр);
	КонецЕсли;

	Возврат Сеансы;

КонецФункции // Сеансы()

Функция Сеанс(ИБ, Сеанс, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьСеансы(Поля);
	КонецЕсли;

	Для Каждого ТекСеанс Из Сеансы Цикл
		Если ТекСеанс["infobase_label"] = ИБ И ТекСеанс["session-id"] = Сеанс Тогда
			Возврат ТекСеанс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сеанс()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхСеансов

Функция СеансыАгента(Знач Агент, Знач Поля)

	СеансыАгента = Новый Массив();

	ДобавленныеКластеры = Новый Соответствие();

	Кластеры = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		Если ДобавленныеКластеры[ТекКластер.Ид()] = Неопределено Тогда
			ДобавленныеКластеры.Вставить(ТекКластер.Ид(), Истина);
		Иначе
			Продолжить;
		КонецЕсли;

		СеансыКластера = СеансыКластера(ТекКластер, Поля);

		Для Каждого ТекСеанс Из СеансыКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("agent", СтрШаблон("%1:%2",
				                                     Агент.АдресСервераАдминистрирования(),
				                                     Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("cluster", ТекКластер.Ид());
				ТекСеанс.Вставить("cluster_label",
				                  СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("count", 1);
			КонецЕсли;

			СеансыАгента.Добавить(ТекСеанс);

		КонецЦикла;

	КонецЦикла;

	Возврат СеансыАгента;

КонецФункции // СеансыАгента()

Функция СеансыКластера(Знач Кластер, Знач Поля)

	МеткиИБ = Новый Соответствие();
	
	ИБ = Кластер.ИнформационныеБазы().Список();
	Для Каждого ТекИБ Из ИБ Цикл
		МеткиИБ.Вставить(ТекИБ.Ид(), ТекИб.Имя());
	КонецЦикла;

	МеткиПроцессов = Новый Соответствие();
	
	Процессы = Кластер.РабочиеПроцессы().Список();
	Для Каждого ТекПроцесс Из Процессы Цикл
		МеткиПроцессов.Вставить(ТекПроцесс.Ид(), СтрШаблон("%1:%2",
		                                                   ТекПроцесс.Получить("host"),
		                                                   ТекПроцесс.Получить("port")));
	КонецЦикла;

	СеансыКластера = Новый Массив();

	СписокСеансов = Кластер.Получить("Сеансы").Список(, , Истина);

	ПоляСеанса = Кластер.Сеансы().ПараметрыОбъекта().ОписаниеСвойств("ИмяРАК");

	Для Каждого ТекСеанс Из СписокСеансов Цикл
		
		ОписаниеСеанса = Новый Соответствие();

		Для Каждого ТекЭлемент Из ПоляСеанса Цикл

			Если Поля.Найти(ВРег(ТекЭлемент.Ключ)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекСеанс[ТекЭлемент.Значение.Имя];
			Если ТекЭлемент.Ключ = "infobase" Тогда
				ОписаниеСеанса.Вставить("infobase_label", МеткиИБ[ЗначениеЭлемента]);
			ИначеЕсли ТекЭлемент.Ключ = "process" Тогда
				ОписаниеСеанса.Вставить("process_label", МеткиПроцессов[ЗначениеЭлемента]);
			ИначеЕсли ТекЭлемент.Ключ = "started-at" Тогда
				ОписаниеСеанса.Вставить("duration", ТекущаяДата() - ЗначениеЭлемента);
			КонецЕсли;
			ОписаниеСеанса.Вставить(ТекЭлемент.Ключ, ЗначениеЭлемента);

		КонецЦикла;

		СеансыКластера.Добавить(ОписаниеСеанса);

	КонецЦикла;

	Возврат СеансыКластера;
	
КонецФункции // СеансыКластера()

#КонецОбласти // ПолучениеДанныхСеансов

Инициализировать();
