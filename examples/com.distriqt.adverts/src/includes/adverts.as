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

import com.distriqt.extension.adverts.AdvertPlatform;
import com.distriqt.extension.adverts.AdvertPosition;
import com.distriqt.extension.adverts.Adverts;
import com.distriqt.extension.adverts.events.AdvertEvent;
import com.distriqt.extension.adverts.events.InterstitialEvent;


try {
	Adverts.init("YOUR KEY HERE");
	if (Adverts.isSupported) {
		//IS SUPPORTED
	}
} catch (e: Error) {
	trace(e);
}


//YOUR ADMOB ACCOUNT INFO
var ADMOB_AD_UNIT_ID_ANDROID: String = "ca-app-pub-4920614350579341/4907715712";
var ADMOB_AD_UNIT_ID_INTERSTITIAL_ANDROID: String = "ca-app-pub-4920614350579341/9513358916";

var ADMOB_AD_UNIT_ID_IOS: String = "ca-app-pub-4920614350579341/7276417316";
var ADMOB_AD_UNIT_ID_INTERSTITIAL_IOS: String = "ca-app-pub-4920614350579341/7447554111";

var IAD_ACCOUNT_ID: String = "";


var _adUnitId = ADMOB_AD_UNIT_ID_IOS;
var _adUnitIdInterstitial = ADMOB_AD_UNIT_ID_INTERSTITIAL_IOS;



trace("Adverts Supported:       " + Adverts.isSupported);
trace("Adverts Version:         " + Adverts.service.version);
//trace("IAD Supported:           " + Adverts.service.isPlatformSupported(AdvertPlatform.PLATFORM_IAD));
trace("ADMOB Supported:         " + Adverts.service.isPlatformSupported(AdvertPlatform.PLATFORM_ADMOB));
//trace("DOUBLECLICK Supported:   " + Adverts.service.isPlatformSupported(AdvertPlatform.PLATFORM_DOUBLECLICK));

if (Adverts.isSupported) {
	Adverts.service.addEventListener(AdvertEvent.RECEIVED_AD, adverts_receivedAdHandler, false, 0, true);
	Adverts.service.addEventListener(AdvertEvent.ERROR, adverts_errorHandler, false, 0, true);
	Adverts.service.addEventListener(AdvertEvent.USER_EVENT_DISMISSED, adverts_userDismissedHandler, false, 0, true);
	Adverts.service.addEventListener(AdvertEvent.USER_EVENT_LEAVE, adverts_userLeaveHandler, false, 0, true);
	Adverts.service.addEventListener(AdvertEvent.USER_EVENT_SHOW_AD, adverts_userShowAdHandler, false, 0, true);

	Adverts.service.interstitials.addEventListener(InterstitialEvent.LOADED, interstitial_loadedHandler, false, 0, true);
	Adverts.service.interstitials.addEventListener(InterstitialEvent.ERROR, interstitial_errorHandler, false, 0, true);
	Adverts.service.interstitials.addEventListener(InterstitialEvent.DISMISSED, interstitial_dismissedHandler, false, 0, true);

	//					if (Adverts.service.isPlatformSupported( AdvertPlatform.PLATFORM_DOUBLECLICK ))
	//					{
	//						trace( "Initialising DOUBLECLICK" );
	//						Adverts.service.initialisePlatform( AdvertPlatform.PLATFORM_DOUBLECLICK, "/6499/example/banner" );
	//					}
	if (Adverts.service.isPlatformSupported(AdvertPlatform.PLATFORM_ADMOB)) {
		trace("Initialising ADMOB");
		Adverts.service.initialisePlatform(AdvertPlatform.PLATFORM_ADMOB);
		//TESTING ADMOB
		Adverts.service.setTestDetails(["a924a6ab51e8b35d7433ad0315c9889b"]);
	}
	//					else 
	//					if (Adverts.service.isPlatformSupported( AdvertPlatform.PLATFORM_IAD ))
	//					{
	//						trace( "Initialising iAD" );
	//						Adverts.service.initialisePlatform( AdvertPlatform.PLATFORM_IAD, IAD_ACCOUNT_ID );
	//					}
}


function refresh(): void {
	trace("refresh");
	if (Adverts.isSupported) {
		Adverts.service.refreshAdvert();
	}
}

//OPEN AD
function openAdvert(): void {
var size: AdvertPosition = new AdvertPosition();
size.verticalAlign = AdvertPosition.ALIGN_BOTTOM;
size.horizontalAlign = AdvertPosition.ALIGN_CENTER;

trace("Adverts.showAdvert(" + size.toString() + ")");
Adverts.service.showAdvert(size, _adUnitId);
}

// CLOSE AD
function closeAdvert(): void {
Adverts.service.hideAdvert();
}




function adverts_receivedAdHandler(event: AdvertEvent): void {
	trace("adverts_receivedAdHandler");
}

function adverts_errorHandler(event: AdvertEvent): void {
	trace("adverts_errorHandler:: " + event.details.trace);
	//
	//	If you wish you can force a reload attempt here by setting a delayed call to refreshAdvert
	//  setTimeout( refresh, 10000 );	
}

function adverts_userDismissedHandler(event: AdvertEvent): void {
	trace("adverts_userDismissedHandler");
}

function adverts_userLeaveHandler(event: AdvertEvent): void {
	trace("adverts_userLeaveHandler");
}

function adverts_userShowAdHandler(event: AdvertEvent): void {
	trace("adverts_userShowAdHandler");
}





function interstitial_loadedHandler(event: InterstitialEvent): void {
	trace("interstitial_loadedHandler");
}

function interstitial_errorHandler(event: InterstitialEvent): void {
	trace("interstitial_errorHandler");
}

function interstitial_dismissedHandler(event: InterstitialEvent): void {
	trace("interstitial_dismissedHandler");
}