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

import com.distriqt.extension.compass.Compass;
import com.distriqt.extension.compass.SensorRate;
import com.distriqt.extension.compass.events.CompassEvent;
import com.distriqt.extension.compass.events.MagneticFieldEvent;


try {
	Compass.init("YOUR KEY HERE");
	if (Compass.isSupported) {
		Compass.service.addEventListener(CompassEvent.HEADING_UPDATED, compass_headingUpdatedHandler, false, 0, true);
		Compass.service.addEventListener(CompassEvent.HEADING_RAW_UPDATED, compass_headingRawUpdatedHandler, false, 0, true);

		Compass.service.magneticFieldSensor.addEventListener(MagneticFieldEvent.MAGNETIC_FIELD_UPDATED, compass_magneticFieldUpdatedHandler, false, 0, true);
		Compass.service.magneticFieldSensor.addEventListener(MagneticFieldEvent.MAGNETIC_FIELD_UNCALIBRATED_UPDATED, compass_magneticFieldUncalibratedUpdatedHandler, false, 0, true);
	}
} catch (e: Error) {
	trace(e);
}


var test: int = 0;


function startCompassEvents(): void {
	if (Compass.isSupported) {
		switch (test) {
			case 0:
				trace("registering compass");
				Compass.service.register(SensorRate.SENSOR_DELAY_NORMAL, 0.4);
				actionBTN.btnUI.btnTxt.txt.text = "Unregister Compass";
				break;

			case 1:
				trace("unregistering compass");
				Compass.service.unregister();
				actionBTN.btnUI.btnTxt.txt.text = "Register Magnetic";
				break;

			case 2:
				trace("registering magneticFieldSensor uncalibrated");
				Compass.service.magneticFieldSensor.register(SensorRate.SENSOR_DELAY_NORMAL, false);
				actionBTN.btnUI.btnTxt.txt.text = "Unregister Magnetic";
				break;

			case 3:
				trace("unregistering magneticFieldSensor");
				Compass.service.magneticFieldSensor.unregister();
				actionBTN.btnUI.btnTxt.txt.text = "Register Calibrated";
				break;

			case 4:
				trace("registering magneticFieldSensor calibrated");
				Compass.service.magneticFieldSensor.register(SensorRate.SENSOR_DELAY_NORMAL, true);
				actionBTN.btnUI.btnTxt.txt.text = "Unregister Calibrated";
				break;

			case 5:
				trace("unregistering magneticFieldSensor");
				Compass.service.magneticFieldSensor.unregister();
				actionBTN.btnUI.btnTxt.txt.text = "Register Custom";
				break;

			case 6:
				actionBTN.btnUI.btnTxt.txt.text = "Unregister Custom";
				Compass.service.magneticFieldSensor.register(SensorRate.SENSOR_DELAY_NORMAL, true);
				Compass.service.magneticFieldSensor.register(SensorRate.SENSOR_DELAY_NORMAL, false);
				Compass.service.register(Compass.SENSOR_DELAY_NORMAL, 0.4);
				break;

			case 7:
				Compass.service.magneticFieldSensor.unregister();
				Compass.service.unregister();
				actionBTN.btnUI.btnTxt.txt.text = "Register Compass";
				test = -1;
				break;
		}
		test++;
	}

}


function activateHandler(event: Event): void {}


function deactivateHandler(event: Event): void {
	Compass.service.unregister();
	Compass.service.magneticFieldSensor.unregister();
}


//
//	EXTENSION HANDLERS
//

function compass_headingUpdatedHandler(event: CompassEvent): void {
	trace(String(event.magneticHeading) + "   [" + event.headingAccuracy + "]");
}


function compass_headingRawUpdatedHandler(event: CompassEvent): void {
	trace(String(event.magneticHeading) + "   [" + event.headingAccuracy + "]");
}


function compass_magneticFieldUpdatedHandler(event: MagneticFieldEvent): void {
	trace("calibrated\nx:" + event.fieldX + "\ny:" + event.fieldY + "\nz:" + event.fieldZ + "\na:" + event.accuracy);
}


function compass_magneticFieldUncalibratedUpdatedHandler(event: MagneticFieldEvent): void {
	trace("uncalibrated\nx:" + event.fieldX + "\ny:" + event.fieldY + "\nz:" + event.fieldZ + "\na:" + event.accuracy);
}