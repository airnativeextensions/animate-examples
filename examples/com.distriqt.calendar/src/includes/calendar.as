/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * http://distriqt.com
 *
 * @author 		"Michael Archbold"
 * @copyright	http://distriqt.com/copyright/license.txt
 */

import com.distriqt.extension.calendar.AuthorisationStatus;
import com.distriqt.extension.calendar.Calendar;
import com.distriqt.extension.calendar.Recurrence;
import com.distriqt.extension.calendar.events.AuthorisationEvent;
import com.distriqt.extension.calendar.events.CalendarStatusEvent;
import com.distriqt.extension.calendar.objects.CalendarObject;
import com.distriqt.extension.calendar.objects.EventAlarmObject;
import com.distriqt.extension.calendar.objects.EventObject;


try {
	Calendar.init("YOUR KEY HERE");
	if (Calendar.isSupported) {
		trace("Calendar Version: " + Calendar.service.version);

		Calendar.service.addEventListener(AuthorisationEvent.CHANGED, calendar_authorisationChangedHandler);

		Calendar.service.addEventListener(CalendarStatusEvent.UI_SAVE, calendar_uiHandler, false, 0, true);
		Calendar.service.addEventListener(CalendarStatusEvent.UI_CANCEL, calendar_uiHandler, false, 0, true);
		Calendar.service.addEventListener(CalendarStatusEvent.UI_DELETE, calendar_uiHandler, false, 0, true);
	}
} catch (e: Error) {
	trace(e);
}



function listEvents(): void {
	trace("==============================");
	trace("LIST EVENTS");

	// now
	var startDate: Date = new Date();
	// one week from now
	var endDate: Date = new Date(startDate.time + 1000 * 60 * 60 * 24 * 7);


	var events: Array = Calendar.service.getEvents(startDate, endDate);
	if (events.length > 0) {
		for each(var event: EventObject in events) {
			trace("event: " + event.title);
		}
	} else {
		trace("no events found");
	}

}


function addEvent(): void {
	trace("==============================");
	trace("CREATING AN EVENT");
	//
	//	CREATE AN EVENT
	var e: EventObject = new EventObject();
	e.title = "Test title now";
	e.startDate = new Date();
	e.endDate = new Date();
	e.startDate.minutes = e.startDate.minutes + 6;
	e.endDate.hours = e.endDate.hours + 1;
	//					e.allDay = true;
	//					e.calendarId = calendarId;

	var a: EventAlarmObject = new EventAlarmObject();
	a.offset = -1;
	e.alarms.push(a);

	var r: Recurrence = new Recurrence();
	r.endCount = 5;
	r.interval = 1;
	r.frequency = Recurrence.FREQUENCY_DAILY;

	e.recurrenceRules.push(r);

	//
	//	ADD EVENT
	trace("ADDING: " + e.startDateString + " :: " + e.title);
	Calendar.service.addEventWithUI(e);
}


function removeEvent(): void {
	trace("==============================");
	trace("REMOVE AN EVENT");

	//
	// 	GET EVENTS
	var startDate: Date = new Date();
	startDate.date -= 1;
	var endDate: Date = new Date();
	endDate.date += 2;

	var events: Array = Calendar.service.getEvents(startDate, endDate);

	for each(var evt: EventObject in events) {
		trace("[" + evt.id + "] in " + evt.calendarId + " @ " + evt.startDateString + " :: " + evt.title);
		for each(var alarm: EventAlarmObject in evt.alarms) {
			//							trace( "\tALARM: "+alarm.offset );
		}
		for each(var rule: Recurrence in evt.recurrenceRules) {
			//							trace( "\tRRULE: "+rule.notes );
		}

		if (evt.title == "Test title now") {
			trace("REMOVING");
			Calendar.service.removeEvent(evt);
			break;
		}
	}
}



//
//	FUNCTIONALITY 
//
var calendars: Array;


function getCalendars(): void {
	//
	//	GET LIST OF CALENDARS

	var calendarId: String = "";
	calendars = Calendar.service.getCalendars();

	for each(var cal: CalendarObject in calendars) {
		trace("CALENDAR: [" + cal.id + "] " + cal.displayName + "(" + cal.name + ")");
		if (cal.displayName.toLowerCase() == "test") {
			calendarId = cal.id;
			trace("USING : " + calendarId);
		}
	}

}





//
//	EVENT HANDLERS
//

var _state: int = 0;

function startCalendarEvents(): void {
	switch (_state) {
		case 0:
			{
				trace("==============================");
				trace("AUTHORISATION STATUS: " + Calendar.service.authorisationStatus());
				switch (Calendar.service.authorisationStatus()) {
					case AuthorisationStatus.AUTHORISED:
						getCalendars();
						actionBTN.btnUI.btnTxt.txt.text = "LIST EVENTS";
						_state++;
						break;

					case AuthorisationStatus.SHOULD_EXPLAIN:
					case AuthorisationStatus.NOT_DETERMINED:
						trace("REQUEST ACCESS");
						Calendar.service.requestAccess();
						return;

					case AuthorisationStatus.RESTRICTED:
					case AuthorisationStatus.DENIED:
					default:
						trace("ACCESS DENIED");
						return;
				}
			}

		case 1:
			{
				listEvents();
				actionBTN.btnUI.btnTxt.txt.text = "ADD EVENT";
				break;
			}

		case 2:
			{
				addEvent();
				actionBTN.btnUI.btnTxt.txt.text = "REMOVE EVENT";
				break;
			}

		case 3:
			{
				removeEvent();
				actionBTN.btnUI.btnTxt.txt.text = "GET CALENDARS";
				break;
			}

		default:
			{
				_state = 0;
				getCalendars();
				actionBTN.btnUI.btnTxt.txt.text = "LIST EVENTS";
			}
	}
	_state++;
}





//
//	EXTENSION EVENT HANDLERS
//

function calendar_authorisationChangedHandler(event: AuthorisationEvent): void {
	trace(event.type + "::" + event.status);
	switch (event.status) {
		case AuthorisationStatus.SHOULD_EXPLAIN:
			// Should display a reason you need this feature
			break;

		case AuthorisationStatus.AUTHORISED:
			// AUTHORISED: Camera will be available
			getCalendars();
			actionBTN.btnUI.btnTxt.txt.text = "LIST EVENTS";
			_state++;
			break;

		case AuthorisationStatus.RESTRICTED:
		case AuthorisationStatus.DENIED:
			// ACCESS DENIED: You should inform your user appropriately
			break;
	}
}


function calendar_uiHandler(event: CalendarStatusEvent): void {
	switch (event.type) {
		//				case CalendarStatusEvent.UI_SAVE:
		//				case CalendarStatusEvent.UI_CANCEL:
		//				case CalendarStatusEvent.UI_DELETE:
		//					break;

		default: trace(event.type);
	}
}