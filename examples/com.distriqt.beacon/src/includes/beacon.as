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
 * Core features of Beacon ANE
 *
 */

//Define Classes
import com.distriqt.extension.beacon.AuthorisationStatus;
import com.distriqt.extension.beacon.Beacon;
import com.distriqt.extension.beacon.events.AuthorisationEvent;
import com.distriqt.extension.beacon.events.BeaconEvent;
import com.distriqt.extension.beacon.events.BroadcastEvent;
import com.distriqt.extension.beacon.objects.BeaconObject;
import com.distriqt.extension.beacon.objects.BroadcastConfig;

var regionStatus;
var beaconStatus = "off";
var beaconProximity;


//DEFINE BEACON UDID's
var UUID_1: String = "B9407F30-F5F8-466E-AFF9-25556B57FE5D";
var UUID_2: String = "B9407F30-F5F8-466E-AFF9-25556B57FE6D";



try {
	//App Key
	Beacon.init("YOUR KEY HERE");
	if (Beacon.isSupported) {
		// Functionality here
		trace("Beacon Supported: " + Beacon.isSupported);
		trace("Beacon Version:   " + Beacon.service.version);
		Beacon.service.addEventListener(AuthorisationEvent.CHANGED, beacon_authorisationChangedHandler, false, 0, true);

		if (!Beacon.service.hasAuthorisation()) {
			if (!Beacon.service.requestAuthorisation(AuthorisationStatus.ALWAYS)) {
				// User has already denied access you should get the user to manually change
				trace("User has denied access");
			}
		}

		Beacon.service.addEventListener(BeaconEvent.BLUETOOTH_STATE_ENABLED, beacon_bluetoothStateChangedHandler, false, 0, true);
		Beacon.service.addEventListener(BeaconEvent.BLUETOOTH_STATE_DISABLED, beacon_bluetoothStateChangedHandler, false, 0, true);


		Beacon.service.addEventListener(BroadcastEvent.BROADCAST_ERROR, broadcast_errorHandler, false, 0, true);
		Beacon.service.addEventListener(BroadcastEvent.BROADCAST_START, broadcast_startHandler, false, 0, true);
		Beacon.service.addEventListener(BeaconEvent.REGION_MONITORING_START, beacon_monitoringStartHandler, false, 0, true);
		Beacon.service.addEventListener(BeaconEvent.REGION_ENTER, beacon_regionEnterHandler, false, 0, true);
		Beacon.service.addEventListener(BeaconEvent.REGION_EXIT, beacon_regionExitHandler, false, 0, true);
		Beacon.service.addEventListener(BeaconEvent.BEACON_UPDATE, beacon_beaconUpdateHandler, false, 0, true);
	}
} catch (e: Error) {
	trace(e);
}



//CHECK BLUETOOTH STATUS
setTimeout(checkBluetoothState, 500);


function checkBluetoothState(): void {
	trace("Bluetooth enabled:" + Beacon.service.isBluetoothEnabled());
}


//START MONITORING REGIONS
function startMonitoring(): void {
	checkBluetoothState();
	if(regionStatus == "active"){
		beaconAlerts.gotoAndPlay("enter");
	}
	Beacon.service.startMonitoringRegionWithUUID(UUID_1, "region_1_identifier");
	Beacon.service.startMonitoringRegionWithUUID(UUID_2, "region_2_identifier");
}

//STOP MONITORING REGIONS
function stopMonitoring(): void {
	checkBluetoothState();
	beaconStatus = "off"
	Beacon.service.stopMonitoringRegionWithUUID(UUID_1, "region_1_identifier");
	Beacon.service.stopMonitoringRegionWithUUID(UUID_2, "region_2_identifier");
	beaconAlerts.gotoAndPlay("off");
}


//
//	EXTENSION HANDLERS
//

function beacon_authorisationChangedHandler(event: AuthorisationEvent): void {
	trace("beacon_authorisationChangedHandler():" + event.status);
}


function beacon_monitoringStartHandler(event: BeaconEvent): void {
	trace("beacon_monitoringStartHandler():" + event.region.identifier + "::" + event.region.uuid);
}



function beacon_regionEnterHandler(event: BeaconEvent): void {
	//Set up local notifications to let users know when they are entering a beacon zone when app is in background mode
	trace("Entered region:" + event.region.uuid);
	beaconAlerts.gotoAndPlay("enter");
	regionStatus = "active";
}


function beacon_regionExitHandler(event: BeaconEvent): void {
	//Set up local notifications to let users know when they are exiting a beacon zone when app is in background mode
	trace("Exit region:" + event.region.uuid);
	beaconAlerts.gotoAndPlay("exit");
	regionStatus = "inactive";
}



//UPDATE LOCATION OF EACH BEACON AND TRIGGER EVENTS BASED ON PROXIMITY (IMMEDIATE)
function beacon_beaconUpdateHandler(event: BeaconEvent): void {
	trace("Beacon update for region:" + event.region.uuid);
	for each(var beacon: BeaconObject in event.beacons) {
		event.region.uuid = event.region.uuid.toUpperCase();
		trace("Beacon:" + beacon.major + "." + beacon.minor + "::" + beacon.proximity + "[" + beacon.accuracy + "]");
		beaconProximity = beacon.proximity;
		//LOOK FOR BEACON UUID & PROXIMITY TO TRIGGER EVENTS
		if (event.region.uuid == UUID_1 && beacon.proximity == "immediate") {
			if (beaconStatus == "beacon1") {
				return;
			}
			beaconAlerts.gotoAndPlay("active");
			beaconAlerts.beaconID_txt.text = "1";
			beaconStatus = "beacon1";
		}

		if (event.region.uuid == UUID_2 && beacon.proximity == "immediate") {
			if (beaconStatus == "beacon2") {
				return;
			}
			beaconAlerts.gotoAndPlay("active");
			beaconAlerts.beaconID_txt.text = "2";
			beaconStatus = "beacon2";
		}
		if (regionStatus == "active" && beaconStatus == "off") {
			beaconAlerts.gotoAndPlay("enter");
		}
	}
}



function beacon_bluetoothStateChangedHandler(event: BeaconEvent): void {
	trace("beacon_bluetoothStateChangedHandler( " + event.type + " )");
	if (Beacon.service.isBluetoothEnabled()) {
		var started: Boolean = Beacon.service.startMonitoringRegionWithUUID(UUID_1, "region_1_identifier");
		var started2: Boolean = Beacon.service.startMonitoringRegionWithUUID(UUID_2, "region_2_identifier");
		trace("Bluetooth monitoring started:" + started);
	}
}


//
//	BROADCAST

function broadcast_startHandler(event: BroadcastEvent): void {
	trace(event.type);
}

function broadcast_errorHandler(event: BroadcastEvent): void {
	trace(event.type);
}

function broadcast_stopHandler(event: BroadcastEvent): void {
	trace(event.type);
}

//SET APP TO RUN IN BACKGROUND
stage.addEventListener(Event.DEACTIVATE, onDeactivate);

function onDeactivate(e: Event): void {
	trace("Running in background");
	NativeApplication.nativeApplication.executeInBackground = true;
}