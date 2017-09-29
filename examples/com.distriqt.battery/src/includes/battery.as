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
import com.distriqt.extension.battery.Battery;
import com.distriqt.extension.battery.BatteryState;
import com.distriqt.extension.battery.events.BatteryEvent;


try {
	//App Key
	Battery.init("YOUR KEY HERE");
	if (Battery.isSupported) {
		// Functionality here
		Battery.service.addEventListener(BatteryEvent.BATTERY_INFO, battery_infoHandler);
	}
} catch (e: Error) {
	trace(e);
}


trace("Battery Supported: " + Battery.isSupported);
trace("Battery Version:   " + Battery.service.version);


function battery_infoHandler(event: BatteryEvent): void {
	//SHOW RESULTS ON UI 
	batteryMC.chargeBar.height = event.batteryLevel * 143;
	batteryMC.batteryPercent_txt.text = event.batteryLevel * 100 +"%";
	
	switch (int(event.batteryState)) {
		case BatteryState.CHARGING:
			trace("Battery state: CHARGING");
			batteryMC.batteryStatus_txt.text = "CHARGING";
			batteryMC.chargeIcon.visible = true;
			break;
		case BatteryState.FULL:
			trace("Battery state: FULL");
			batteryMC.batteryStatus_txt.text = "FULL";
		    batteryMC.chargeIcon.visible = false;
			break;
		case BatteryState.NOT_CHARGING:
			trace("Battery state: NOT CHARGING");
			batteryMC.batteryStatus_txt.text = "NOT CHARGING";
		    batteryMC.chargeIcon.visible = false;
			break;
		case BatteryState.NOT_SUPPORTED:
			trace("Battery state: NOT SUPPORTED");
			batteryMC.batteryStatus_txt.text = "NOT SUPPORTED";
		    batteryMC.chargeIcon.visible = false;
			break;
		case BatteryState.UNKNOWN:
		default:
			trace("Battery state: UNKNOWN");
			break;
	}

	trace("Battery level: " + event.batteryLevel);
}


function getBatteryStatus(): void {
	Battery.service.getBatteryInfo();
}