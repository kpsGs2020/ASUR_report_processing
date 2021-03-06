
Функция СформироватьСтруктурыДанных(СтруктураПараметров)  Экспорт
	Источник = СтруктураПараметров.Источник;
	ДанныеСтруктур = Новый Структура("СтрокаВКодДляРазработчика, ПутьКГруппеПапок, ПутьРазмещенияФайлов");
	ДанныеСтруктур.СтрокаВКодДляРазработчика = ПолучитьСтрокуВКодДляРазработчика(Источник, Источник.КатегорияЗадачи);
	ДанныеСтруктур.ПутьКГруппеПапок      	 = "ERP\Разработка\2020";
	ДанныеСтруктур.ПутьРазмещенияФайлов      = "D:\1С Труд\ERP\Разработка\2020";
	
	Возврат  ДанныеСтруктур;
КонецФункции

Функция ПолучитТекстЗапросаКатегорииСтруктурыФормированияКода()
	Возврат 
		"ВЫБРАТЬ
		|	asur_КатегорииЗадачСтруктураФормированияКодаРазработчику.ИмяРеквизитаОбъекта КАК ИмяРеквизитаОбъекта,
		|	asur_КатегорииЗадачСтруктураФормированияКодаРазработчику.СинонимРеквизитаОбъекта КАК СинонимРеквизитаОбъекта,
		|	asur_КатегорииЗадачСтруктураФормированияКодаРазработчику.ЕстьПрефикс КАК ЕстьПрефикс,
		|	asur_КатегорииЗадачСтруктураФормированияКодаРазработчику.ЗначениеИзПрефикса КАК ЗначениеИзПрефикса,
		|	asur_КатегорииЗадачСтруктураФормированияКодаРазработчику.СимволРазделения КАК СимволРазделения
		|ПОМЕСТИТЬ ВТ_ТаблицаКатегории
		|ИЗ
		|	Справочник.asur_КатегорииЗадач.СтруктураФормированияКодаРазработчику КАК asur_КатегорииЗадачСтруктураФормированияКодаРазработчику
		|ГДЕ
		|	asur_КатегорииЗадачСтруктураФормированияКодаРазработчику.Ссылка = &Категория
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ТаблицаКатегории.ИмяРеквизитаОбъекта КАК ИмяРеквизитаОбъекта,
		|	ВТ_ТаблицаКатегории.СинонимРеквизитаОбъекта КАК СинонимРеквизитаОбъекта,
		|	ВТ_ТаблицаКатегории.ЕстьПрефикс КАК ЕстьПрефикс,
		|	ВТ_ТаблицаКатегории.ЗначениеИзПрефикса КАК ЗначениеИзПрефикса,
		|	ВТ_ТаблицаКатегории.СимволРазделения КАК СимволРазделения
		|ИЗ
		|	ВТ_ТаблицаКатегории КАК ВТ_ТаблицаКатегории";
	
КонецФункции 

Функция СформироватьЗапросДляПолученияСтрокиКода(Категория, МВТ)
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МВТ;
	Запрос.Текст = ПолучитТекстЗапросаКатегорииСтруктурыФормированияКода();
	Запрос.УстановитьПараметр("Категория", Категория);
	ВДЗ = Запрос.Выполнить().Выбрать();
	
	ТекстЗапросаПрефикса = "";
	ТекстЗапросаСоединенияПрефикса = "";
	ТекстЗапроса =
		"ВЫБРАТЬ 
		| ТекОбъект.КатегорияЗадачи КАК КатегорияЗадачи, " + Символы.ПС;
	//КолСтрок = СписокРеквизитов.Количество(); 
	
	Пока ВДЗ.Следующий() Цикл
		
		
		ТекстЗапроса = ТекстЗапроса +
		" ТекОбъект." + ВДЗ.ИмяРеквизитаОбъекта + " КАК " + ВДЗ.ИмяРеквизитаОбъекта + "," + Символы.ПС;
		
		Если ВДЗ.ЗначениеИзПрефикса Тогда
			//_Префикс
			ИмяПоляТаблицы = ВДЗ.ИмяРеквизитаОбъекта + "_Префикс";
			ТекстЗапросаПрефикса = ТекстЗапросаПрефикса + 
		"	ЕСТЬNULL(" + ИмяПоляТаблицы  + ".Префикс, """") КАК " + ИмяПоляТаблицы + "," + Символы.ПС;
			
			ТекстЗапросаСоединенияПрефикса = ТекстЗапросаСоединенияПрефикса + Символы.ПС +
		"		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.asur_ПрефиксыОбъектов КАК "+ ИмяПоляТаблицы + " 
			|  	ПО ТекОбъект." + ВДЗ.ИмяРеквизитаОбъекта + " = " + ИмяПоляТаблицы + ".Объект" + Символы.ПС;

		КонецЕсли; 
				
	КонецЦикла; 
	
	ТекстЗапроса =  ТекстЗапроса + ТекстЗапросаПрефикса;
	
	//Убираю последнюю запятую	
	ТекстЗапроса =  Сред(ТекстЗапроса,1,СтрДлина(ТекстЗапроса)-2) + Символы.ПС;
	
	//Помещаю во Временную Талицу ВТ_СписокЗадач
	ТекстЗапроса = ТекстЗапроса +  " ПОМЕСТИТЬ  ВТ_СписокЗадач" + Символы.ПС; 
	
	ТекстЗапроса = ТекстЗапроса + 
		"ИЗ
		|	Справочник.asur_СписокЗадач КАК ТекОбъект " + Символы.ПС 
		+  ТекстЗапросаСоединенияПрефикса + Символы.ПС +  
		"ГДЕ
		|	ТекОбъект.Ссылка = &Ссылка";
	Возврат ТекстЗапроса;
	
КонецФункции

Функция ПолучитьСтрокуВКодДляРазработчика(Источник, Категория)
	СтрокаВКодДляРазработчика = "";

	МВТ = Новый МенеджерВременныхТаблиц;
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МВТ;
	Запрос.Текст = СформироватьЗапросДляПолученияСтрокиКода(Категория, МВТ);
	
	Запрос.УстановитьПараметр("Ссылка", Источник);
	Запрос.Выполнить();
	
	ВДЗ = МВТ.Таблицы.Найти("ВТ_ТаблицаКатегории").ПолучитьДанные().Выбрать();

	
	ВДЗ_Префикс = МВТ.Таблицы.Найти("ВТ_СписокЗадач").ПолучитьДанные().Выбрать();
	ВДЗ_Префикс.Следующий();
	
	Пока ВДЗ.Следующий() Цикл
		Попытка
			
			Значение = ВДЗ_Префикс[ВДЗ.ИмяРеквизитаОбъекта];
			//Заполнение значения из реквизитов		
			Если ВДЗ.ИмяРеквизитаОбъекта = "Код" Тогда
				Значение = Прав(Значение,3);
			ИначеЕсли ВДЗ.ИмяРеквизитаОбъекта = "ДатаСозданияЗадачи" Тогда
				Значение = Формат(Значение, "ДФ=dd.MM.yyyy");
			ИначеЕсли ВДЗ.ЗначениеИзПрефикса Тогда
				Значение = ВДЗ_Префикс[ВДЗ.ИмяРеквизитаОбъекта + "_Префикс"];
			КонецЕсли; 
			
			СтрокаВКодДляРазработчика = СтрокаВКодДляРазработчика + Значение +  ВДЗ.СимволРазделения;
			
		Исключение
			
		    Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "В объекте" + Источник + "Изменен реквизит:" + ВДЗ.ИмяРеквизитаОбъекта + Символы.ПС +
							  " Необходимо перезаполнить Шаблон категории: " + Источник.КатегорияЗадачи;
			Сообщение.Сообщить();
			
		КонецПопытки;
		
	КонецЦикла; 
	
	МВТ.Закрыть();
	
	Возврат СтрокаВКодДляРазработчика
КонецФункции

