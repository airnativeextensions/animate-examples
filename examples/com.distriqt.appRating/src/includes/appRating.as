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
 * Core features of AppRating ANE
 *
 */

//Define Classes
import com.distriqt.extension.applicationrater.ApplicationRater;
import com.distriqt.extension.applicationrater.events.ApplicationRaterEvent;


// You will need to add iOS 10.3 sdk in order to publish for IOS. Downlaod it from here:
// http://resources.airnativeextensions.com/ios/


// Point to the lcoation in publish settings.



try {
	//App Key
	ApplicationRater.init("YOUR APP KEY HERE");
	if (ApplicationRater.isSupported) {
		// Functionality here
	}
} catch (e: Error) {
	trace(e);
}



trace("ApplicationRater Supported: " + String(ApplicationRater.isSupported));
trace("ApplicationRater Version: " + ApplicationRater.service.version);
trace("ApplicationRater State: " + ApplicationRater.service.state);

ApplicationRater.service.reset();

//
//	Setup the app rater service, listeners and register the app launch
//
ApplicationRater.service.setLaunchesUntilPrompt(2);

ApplicationRater.service.setSignificantEventsUntilPrompt(5);
ApplicationRater.service.userDidSignificantEvent();

ApplicationRater.service.setDaysUntilPrompt( -1 );

ApplicationRater.service.setTimeBeforeReminding( 7 );

ApplicationRater.service.addEventListener(ApplicationRaterEvent.DIALOG_DISPLAYED, applicationRater_dialogDisplayedHandler, false, 0, true);
ApplicationRater.service.addEventListener(ApplicationRaterEvent.DIALOG_CANCELLED, applicationRater_dialogCancelledHandler, false, 0, true);
ApplicationRater.service.addEventListener(ApplicationRaterEvent.SELECTED_RATE, applicationRater_selectedRateHandler, false, 0, true);
ApplicationRater.service.addEventListener(ApplicationRaterEvent.SELECTED_LATER, applicationRater_selectedLaterHandler, false, 0, true);
ApplicationRater.service.addEventListener(ApplicationRaterEvent.SELECTED_DECLINE, applicationRater_selectedDeclineHandler, false, 0, true);


if (appType == "android"){
// ANDROID - Make sure to add air. before your application name
ApplicationRater.service.setApplicationId("air.com.distriqt.test", ApplicationRater.IMPLEMENTATION_ANDROID);
}

if (appType == "iOS"){
// IOS - iTunes App Store link URL which will be of the form https://itunes.apple.com/us/app/[APP_NAME]/id[APP_ID]
ApplicationRater.service.setApplicationId("662053009", ApplicationRater.IMPLEMENTATION_IOS);
}


//SET UP FOR TESTING
ApplicationRater.service.debugMode = true;


ApplicationRater.service.applicationLaunched();

function openRatingWin(): void {
	if (ApplicationRater.service.review.isSupported) {
		trace("Requesting Review");
		ApplicationRater.service.review.requestReview();
	} else {
		trace("Review not supported");
	}
}

var state:String = ApplicationRater.service.state;
trace(state);



//
//	APPLICATION RATER NOTIFICATION HANDLERS
//

function applicationRater_dialogDisplayedHandler(event: ApplicationRaterEvent): void {
	trace(event.type);
}

function applicationRater_dialogCancelledHandler(event: ApplicationRaterEvent): void {
	trace(event.type);
}

function applicationRater_selectedRateHandler(event: ApplicationRaterEvent): void {
	trace(event.type);
}

function applicationRater_selectedLaterHandler(event: ApplicationRaterEvent): void {
	trace(event.type);
}

function applicationRater_selectedDeclineHandler(event: ApplicationRaterEvent): void {
	trace(event.type);
}