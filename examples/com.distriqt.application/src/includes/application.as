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
 * @author 		"Michael Archbold (ma&#64;distriqt.com)"
 * @copyright	http://distriqt.com/copyright/license.txt
 */

import com.distriqt.extension.application.Application;
import com.distriqt.extension.application.ApplicationDisplayModes;
import com.distriqt.extension.application.IDType;
import com.distriqt.extension.application.IOSStatusBarStyles;
import com.distriqt.extension.application.alarms.AlarmBuilder;
import com.distriqt.extension.application.events.AlarmEvent;
import com.distriqt.extension.application.events.ApplicationEvent;
import com.distriqt.extension.application.events.ApplicationStateEvent;

var barStatus:String = "default";
barStatus_txt.text = barStatus;


try {
	Application.init("YOUR KEY HERE");
	if (Application.isSupported) {
		// Functionality here
		var uniqueId: String = Application.service.device.uniqueId();
		uniqueID_txt.text = uniqueId;
	}
} catch (e: Error) {
	trace(e);
}

//DEVICE INFO
properties_txt.text = "DEVICE INFO ============================\r"
+ " name:         " + Application.service.device.name + "\r"
+ " brand:        " + Application.service.device.brand + "\r"
+ " manufacturer: " + Application.service.device.manufacturer + "\r"
+ " device:       " + Application.service.device.device + "\r"
+ " model:        " + Application.service.device.model + "\r"
+ " product:      " + Application.service.device.product + "\r"
+ "OPERATING SYSTEM =======================\r"
+ " name:         " + Application.service.device.os.name + "\r"
+ " type:         " + Application.service.device.os.type + "\r"
+ " version:      " + Application.service.device.os.version + "\r"
+ " API Level:    " + Application.service.device.os.api_level + "\r"
+ "DISPLAY METRICS ========================\r"
+ "densityDpi:   " + Application.service.device.displayMetrics.densityDpi + "\r"
+ "screenHeight: " + Application.service.device.displayMetrics.screenHeight + "\r"
+ "screenWidth:  " + Application.service.device.displayMetrics.screenWidth + "\r"
+ "xdpi:         " + Application.service.device.displayMetrics.xdpi + "\r"
+ "ydpi:         " + Application.service.device.displayMetrics.ydpi + "\r"
+ "CUSTOM URLS ========================\r"
+ "can open 'facebook://' : " + Application.service.checkUrlSchemeSupport("facebook://") + "\r"
+ "can open 'tel://'      : " + Application.service.checkUrlSchemeSupport("tel://");




//STATUS BAR OPTIONS
function changeStatusBar(): void {
	if (appType == "iOS") {
		//iOS (IOS_STATUS_BAR_DEFAULT, IOS_STATUS_BAR_LIGHT, IOS_STATUS_BLACK_OPAQUE, IOS_STATUS_BLACK_TRANSLUCENT)
		if (barStatus == "default") {
			Application.service.setStatusBarStyle(IOSStatusBarStyles.IOS_STATUS_BAR_LIGHT);
			barStatus = "light";
			barStatus_txt.text = barStatus;
			return;
		}
		if (barStatus == "light") {
			Application.service.setStatusBarStyle(IOSStatusBarStyles.IOS_STATUS_BLACK_OPAQUE);
			barStatus = "opaque";
			barStatus_txt.text = barStatus;
			return;
		}
		if (barStatus == "opaque") {
			Application.service.setStatusBarStyle(IOSStatusBarStyles.IOS_STATUS_BLACK_TRANSLUCENT);
			barStatus = "translucent";
			barStatus_txt.text = barStatus;
			return;
		}
		if (barStatus == "translucent") {
			Application.service.setStatusBarStyle(IOSStatusBarStyles.IOS_STATUS_BAR_DEFAULT);
			Application.service.setStatusBarHidden(true);
			barStatus = "off";
			barStatus_txt.text = barStatus;
			return;
		}
		if (barStatus == "off") {
			Application.service.setStatusBarStyle(IOSStatusBarStyles.IOS_STATUS_BAR_DEFAULT);
			Application.service.setStatusBarHidden(false);
			barStatus = "default";
			barStatus_txt.text = barStatus;
			return;
		}
	}
	if (appType == "android") {
		if (barStatus == "default") {
			Application.service.setStatusBarColour(0xFF0000);
			barStatus = "color 1";
			barStatus_txt.text = barStatus;
			return;
		}
		if (barStatus == "color 1") {
			Application.service.setStatusBarColour(0x000000);
			barStatus = "default";
			barStatus_txt.text = barStatus;
			return;
		}
	}
}