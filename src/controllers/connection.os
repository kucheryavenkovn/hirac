
&HTTPMethod("GET")
Функция list() Экспорт

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамер(ЗапросHTTP.Путь, ЗапросHTTP.СтрокаЗапроса, "connection", "list");

	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Поля = "_summary";
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ПараметрыЗапроса);

	Первые = ОбщегоНазначения.ВыборкаПервыхИзПараметровЗапроса(ПараметрыЗапроса);

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	Результат = ОбщегоНазначения.ДанныеВJSON(ПодключенияКАгентам.Соединения(Поля, Фильтр, Первые, Истина));

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Возврат Содержимое(Результат);

КонецФункции // list()

&HTTPMethod("GET")
Функция get() Экспорт

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамер(ЗапросHTTP.Путь, ЗапросHTTP.СтрокаЗапроса, "connection", "get");

	ИБ           = Неопределено;
	Соединение   = Неопределено;
	ИмяПараметра = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		ИБ           = ЗначенияМаршрута.Получить("infobase");
		Соединение   = Число(ЗначенияМаршрута.Получить("connection"));
		ИмяПараметра = ЗначенияМаршрута.Получить("parameter");
	КонецЕсли;
	
	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = "json";
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ПараметрыЗапроса["format"];
	КонецЕсли;

	Поля = "_all";
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	Данные = ПодключенияКАгентам.Соединение(ИБ, Соединение, Поля, Истина);
	
	Если ЗначениеЗаполнено(ИмяПараметра) Тогда
		Если Данные = Неопределено Тогда
			ЗначениеПараметра = ПодключенияКАгентам.ПустойОбъектКластера("connection", Поля)[ИмяПараметра];
		Иначе
			ЗначениеПараметра = Данные[ИмяПараметра];
		КонецЕсли;
		Если ТипЗнч(ЗначениеПараметра) = Тип("Дата") Тогда
			ЗначениеПараметра = Формат(ЗначениеПараметра, "ДФ=yyyy-MM-ddThh:mm:ss");
		КонецЕсли;
		Результат = СтрШаблон("%1=%2", ИмяПараметра, ЗначениеПараметра);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(Данные);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Возврат Содержимое(Результат);

КонецФункции // get()
