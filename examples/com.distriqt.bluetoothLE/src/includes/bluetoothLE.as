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
 * @brief
 * @author 		"Michael Archbold (ma&#64;distriqt.com)"
 * @created		26/03/2015
 * @copyright	http://distriqt.com/copyright/license.txt
 */

import com.distriqt.extension.bluetoothle.AuthorisationStatus;
import com.distriqt.extension.bluetoothle.BluetoothLE;
import com.distriqt.extension.bluetoothle.BluetoothLEState;
import com.distriqt.extension.bluetoothle.events.AuthorisationEvent;
import com.distriqt.extension.bluetoothle.events.BluetoothLEEvent;
import com.distriqt.extension.bluetoothle.events.CentralEvent;
import com.distriqt.extension.bluetoothle.events.CentralManagerEvent;
import com.distriqt.extension.bluetoothle.events.CharacteristicEvent;
import com.distriqt.extension.bluetoothle.events.PeripheralEvent;
import com.distriqt.extension.bluetoothle.events.PeripheralManagerEvent;
import com.distriqt.extension.bluetoothle.events.RequestEvent;
import com.distriqt.extension.bluetoothle.objects.Characteristic;
import com.distriqt.extension.bluetoothle.objects.Peripheral;
import com.distriqt.extension.bluetoothle.objects.Request;
import com.distriqt.extension.bluetoothle.objects.Service;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;




// max length to limit characteristic values
var MAX_VALUE_LENGTH: int = 1000;

var APP_KEY = "YOUR KEY HERE";
var initStatus = "off";

try {
	BluetoothLE.init(APP_KEY);
	
	if (BluetoothLE.isSupported) {
		BluetoothLE.service.addEventListener(AuthorisationEvent.CHANGED, authorisationChangedHandler);
	}
} catch (e: Error) {
	trace(e);


	////////////////////////////////////////////////////////
	//	VARIABLES
	//


	var _service: Service;
	var _characteristic: Characteristic;
	var _peripheral: Peripheral;



	////////////////////////////////////////////////////////
	//	AUTHORISATION
	//


	function checkAndRequestAuthorisation(): void {
		if (BluetoothLE.isSupported) {
			statusWin.txt.text = "Authorisation Status = " + BluetoothLE.service.authorisationStatus();
			switch (BluetoothLE.service.authorisationStatus()) {
				case AuthorisationStatus.AUTHORISED:
					break;

				case AuthorisationStatus.NOT_DETERMINED:
				case AuthorisationStatus.SHOULD_EXPLAIN:
					BluetoothLE.service.requestAuthorisation();
					break;

				case AuthorisationStatus.DENIED:
				case AuthorisationStatus.RESTRICTED:
				case AuthorisationStatus.UNKNOWN:
					break;
			}
		}
	}

	function authorisationChangedHandler(event: AuthorisationEvent): void {
		statusWin.txt.text = "authorisationChangedHandler( " + event.status + " )";
		if (event.status == "authorised") {
			trace("Bluetooth LE authorized");
		}
	}






	//CHECK STATE OF BLUETOOTH	

	BluetoothLE.service.addEventListener(BluetoothLEEvent.STATE_CHANGED, stateChangedHandler);

	switch (BluetoothLE.service.state) {
		case BluetoothLEState.STATE_ON:
			// We can use the Bluetooth LE functions
			break;

		case BluetoothLEState.STATE_OFF:
		case BluetoothLEState.STATE_RESETTING:
		case BluetoothLEState.STATE_UNAUTHORISED:
		case BluetoothLEState.STATE_UNSUPPORTED:
		case BluetoothLEState.STATE_UNKNOWN:
			// All of these indicate the Bluetooth LE is not available
	}




	function stateChangedHandler(event: BluetoothLEEvent): void {
		if (BluetoothLE.service.state == "on") {
			statusWin.txt.text = "BluetoothLE.service.version = " + BluetoothLE.service.version;
			statusWin.txt.text = "BluetoothLE.service.state   = " + BluetoothLE.service.state;
		}
	}

	function dispose(e: Event = null): void {
		if (isSetup) {
			statusWin.txt.text = "Choose a device type below.";
			initStatus = "off"

			BluetoothLE.service.dispose();
			isSetup = false;
		}
	}


	//TURN ON / OFF BLUETOOTH LE SHARING
	function enableWithUI(): void {
		if (isSetup) {
			statusWin.txt.text = "enableWithUI";
			BluetoothLE.service.enableWithUI();
		}
	}

	function disable(): void {
		if (isSetup) {
			statusWin.txt.text = "Service Disabled";
			BluetoothLE.service.disable();
		}
	}




	////////////////////////////////////////////////////////
	//	SETUP AS PERIPHERAL - If testing on iOS, you must restart the device in order to reset the connection to central devices
	///////////////////////////////////////////////////////

	var _isSetup: Boolean = false;
	function get isSetup(): Boolean {
		return _isSetup;
	}
	function set isSetup(value: Boolean): void {
		_isSetup = value;
	}

	function initializePeripheral(): void {
		if(initStatus == "off"){
			BluetoothLE.init(APP_KEY);
			initStatus = "on"
		}
		if (!isSetup) {
			try {
				statusWin.txt.text = "BluetoothLE.isSupported = " + BluetoothLE.isSupported;

				if (BluetoothLE.isSupported) {

					BluetoothLE.service.peripheralManager.addEventListener(PeripheralManagerEvent.STATE_CHANGED, peripheral_stateChangedHandler);
					BluetoothLE.service.peripheralManager.addEventListener(PeripheralManagerEvent.SERVICE_ADD, peripheral_serviceAddHandler);
					BluetoothLE.service.peripheralManager.addEventListener(PeripheralManagerEvent.SERVICE_ADD_ERROR, peripheral_serviceAddErrorHandler);
					BluetoothLE.service.peripheralManager.addEventListener(PeripheralManagerEvent.START_ADVERTISING, peripheral_startAdvertisingHandler);
				} else {
					statusWin.txt.text = "BluetoothLE not supported";
				}

				isSetup = true;
			} catch (e: Error) {
				statusWin.txt.text = e.message;
			}
		}
	}
	

	/////////////////////////////////////////////
	//	PERIPHERAL DEVICE FUNCTIONS
	////////////////////////////////////////////

	function startAdvertising(e: Event = null): void {
		if (!isSetup) return;
		
		//DEFINE CHARACTERISTIC
		_characteristic = new Characteristic("00002a37-0000-1000-8000-00805f9b34fb", [Characteristic.PROPERTY_NOTIFY, Characteristic.PROPERTY_READ, Characteristic.PROPERTY_WRITE], [Characteristic.PERMISSION_READABLE, Characteristic.PERMISSION_WRITEABLE]);

		//DEFINE SERVICE FOR CHARACTERISTIC
		_service = new Service();
		_service.uuid = "0000180d-0000-1000-8000-00805f9b34fb";
		_service.characteristics.push(_characteristic);


		//Add most recent datq for service
		BluetoothLE.service.peripheralManager.addService(_service);
		trace("startAdvertising");
		
		BluetoothLE.service.peripheralManager.startAdvertising("Distriqt Peripheral", new <Service>[_service]);
		
		BluetoothLE.service.peripheralManager.addEventListener(CentralEvent.SUBSCRIBE, peripheral_central_subscribeHandler);
		BluetoothLE.service.peripheralManager.addEventListener(CentralEvent.UNSUBSCRIBE, peripheral_central_unsubscribeHandler);

		BluetoothLE.service.peripheralManager.addEventListener(RequestEvent.READ, peripheral_readRequestHandler);
		BluetoothLE.service.peripheralManager.addEventListener(RequestEvent.WRITE, peripheral_writeRequestHandler);
	}



    //  Update Value to all Centrals
	function updateValue(e: Event = null): void {
		if (!isSetup) return;

		var content: String = "Value Updated from Peripheral";

		statusWin.txt.text = "Updated Value: " + content;

		var value: ByteArray = new ByteArray();
		value.writeUTFBytes(content);

		BluetoothLE.service.peripheralManager.updateValue(_characteristic, value);
	}
	
	
	//Stop Advertising and dispose of Bluetooth
	function stopAdvertising(e: Event = null): void {
		if (!isSetup) return;

		trace("stopAdvertising");

		BluetoothLE.service.peripheralManager.stopAdvertising();
		BluetoothLE.service.peripheralManager.removeAllServices();
		
		dispose();
	}




	//
	//	SETUP AS CENTRAL DEVICE TO START SCANNING
	//
	
function initializeCentral(): void {
	if(initStatus == "off"){
			BluetoothLE.init(APP_KEY);
			initStatus = "on"
		}
		if (!isSetup) {
			try {
				if (BluetoothLE.isSupported) {
					BluetoothLE.service.peripheralManager.addEventListener(PeripheralManagerEvent.STATE_CHANGED, peripheral_stateChangedHandler);
					BluetoothLE.service.centralManager.addEventListener( CentralManagerEvent.STATE_CHANGED, central_stateChangedHandler );
					BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.DISCOVERED, central_peripheralDiscoveredHandler);
					BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.CONNECT, central_peripheralConnectHandler);
					BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.CONNECT_FAIL, central_peripheralConnectFailHandler);
					BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.DISCONNECT, central_peripheralDisconnectHandler);
					
					BluetoothLE.service.peripheralManager.addEventListener(CentralEvent.SUBSCRIBE, peripheral_central_subscribeHandler);
					BluetoothLE.service.peripheralManager.addEventListener(CentralEvent.UNSUBSCRIBE, peripheral_central_unsubscribeHandler);
					
					trace("BluetoothLE.isSupported = " + BluetoothLE.isSupported);
				} else {
					statusWin.txt.text = "BluetoothLE not supported";
				}

				isSetup = true;
			} catch (e: Error) {
				statusWin.txt.text = e.message;
			}
		}
	}
	

	function scanForPeripherals(): void {
		statusWin.txt.text = "Scanning For Peripherals";
		BluetoothLE.service.centralManager.scanForPeripherals();
	}


	function stopScan(): void {
		statusWin.txt.text = "Stop Scanning";
		BluetoothLE.service.centralManager.stopScan();
	}



	function discoverCharacteristics(e: Event = null): void {
		if (!isSetup) return;
		if (_peripheral == null) return;

		trace("discoverCharacteristics");

		var success: Boolean = _peripheral.discoverCharacteristics(_service);
		trace("Discover Characteristics: success=" + success);
	}


	function readCharacteristic(e: Event = null): void {
		if (!isSetup) return;
		if (_peripheral == null) return;

        _peripheral.readValueForCharacteristic( _characteristic );
		
	}


	function writeCharacteristic(e: Event = null): void {

        _peripheral.addEventListener( CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler );
        _peripheral.addEventListener( CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler );
			
        // Some data to write
        var value:ByteArray = new ByteArray();
        value.writeUTFBytes( "Value written from Central" );

        var success:Boolean = _peripheral.writeValueForCharacteristic( _characteristic, value );
		trace("writeCharacteristic: success=" + success);
	    }



	function unsubscribeCharacteristic(e: Event = null): void {
		if (!isSetup) return;
		if (_peripheral == null) return;

		statusWin.txt.text = "Unsubscribed from Characteristic";

		var success: Boolean = _peripheral.unsubscribeToCharacteristic(_characteristic);
		trace("unsubscribeCharacteristic: success=" + success);
		
		dispose();
	}





	////////////////////////////////////////////////////////
	//	INTERNALS
	//

	function setActivePeripheral(peripheral: Peripheral): void {
		if (_peripheral != null) {
			_peripheral.removeEventListener(PeripheralEvent.DISCOVER_SERVICES, peripheral_discoverServicesHandler);
			_peripheral.removeEventListener(PeripheralEvent.DISCOVER_CHARACTERISTICS, peripheral_discoverCharacteristicsHandler);

			_peripheral.removeEventListener(CharacteristicEvent.UPDATE, peripheral_characteristic_updatedHandler);
			_peripheral.removeEventListener(CharacteristicEvent.UPDATE_ERROR, peripheral_characteristic_errorHandler);
			_peripheral.removeEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			_peripheral.removeEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			_peripheral.removeEventListener(CharacteristicEvent.SUBSCRIBE, peripheral_characteristic_subscribeHandler);
			_peripheral.removeEventListener(CharacteristicEvent.SUBSCRIBE_ERROR, peripheral_characteristic_subscribeErrorHandler);
			_peripheral.removeEventListener(CharacteristicEvent.UNSUBSCRIBE, peripheral_characteristic_unsubscribeHandler);

			_peripheral = null;
		}

		if (peripheral != null) {
			_peripheral = peripheral;

			_peripheral.addEventListener(PeripheralEvent.DISCOVER_SERVICES, peripheral_discoverServicesHandler);
			_peripheral.addEventListener(PeripheralEvent.DISCOVER_CHARACTERISTICS, peripheral_discoverCharacteristicsHandler);

			_peripheral.addEventListener(CharacteristicEvent.UPDATE, peripheral_characteristic_updatedHandler);
			_peripheral.addEventListener(CharacteristicEvent.UPDATE_ERROR, peripheral_characteristic_errorHandler);
			_peripheral.addEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			_peripheral.addEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			_peripheral.addEventListener(CharacteristicEvent.SUBSCRIBE, peripheral_characteristic_subscribeHandler);
			_peripheral.addEventListener(CharacteristicEvent.SUBSCRIBE_ERROR, peripheral_characteristic_subscribeErrorHandler);
			_peripheral.addEventListener(CharacteristicEvent.UNSUBSCRIBE, peripheral_characteristic_unsubscribeHandler);
		}
	}



	/////////////////////////////////////////
	//	CENTRAL DEVICE EVENTS
	////////////////////////////////////////

	function central_stateChangedHandler(event: CentralManagerEvent): void {
		statusWin.txt.text = "Central State = " + BluetoothLE.service.centralManager.state;
	}


	function central_peripheralDiscoveredHandler(event: PeripheralEvent): void {
		var foundPeripheral:Peripheral = event.peripheral;
		
		 statusWin.txt.text = "Peripheral discovered: Name - " + foundPeripheral.name + " UUID - " + foundPeripheral.uuid;

		if (foundPeripheral.name == "Distriqt Peripheral") {
			trace("connecting: " + foundPeripheral);
			BluetoothLE.service.centralManager.stopScan();
			BluetoothLE.service.centralManager.connect(foundPeripheral);
		}

	}

	function central_peripheralConnectHandler(event: PeripheralEvent): void {
		var connectedPeripheral:Peripheral = event.peripheral;
		setActivePeripheral(connectedPeripheral);
		statusWin.txt.text = "Peripheral Connected: " + connectedPeripheral.toString();

		 connectedPeripheral.addEventListener(PeripheralEvent.DISCOVER_SERVICES, peripheral_discoverServicesHandler);
		 connectedPeripheral.discoverServices();
	}

	function central_peripheralConnectFailHandler(event: PeripheralEvent): void {
		statusWin.txt.text = "Peripheral Connect Fail: " + event.peripheral.name;
		setActivePeripheral(null);
	}

	function central_peripheralDisconnectHandler(event: PeripheralEvent): void {
		statusWin.txt.text = "Peripheral Disconnect: " + event.peripheral.name;
		setActivePeripheral(null);
	}

	
	
	

	//	PERIPHERAL SERVICES DISCOVERY HANDLER
	function peripheral_discoverServicesHandler(event: PeripheralEvent): void {
		 var foundPeripheral:Peripheral = event.peripheral;
		 _peripheral = foundPeripheral;

            trace("Peripheral Discover Services: " + foundPeripheral.name);

            if (foundPeripheral != null) {
                for (var i:int = 0; i < foundPeripheral.services.length; i++) {
                    var service:Service = foundPeripheral.services[i];
                     if (service.uuid == "0000180d-0000-1000-8000-00805f9b34fb") {
						trace("service: " + service.uuid);
                        // discover characteristics
                        foundPeripheral.addEventListener(PeripheralEvent.DISCOVER_CHARACTERISTICS, peripheral_discoverCharacteristicsHandler);
                        foundPeripheral.discoverCharacteristics(service);
						_service = service;
                    }
                }
            }

	}


	//	PERIPHERAL CHARACTERISTICS DISCOVERY HANDLER
	function peripheral_discoverCharacteristicsHandler(event: PeripheralEvent): void {
	trace( "peripheral discover characteristics: " + event.peripheral.name );
	for each (var service:Service in event.peripheral.services)
	{
		trace( "service: "+ service.uuid );
		for each (var ch:Characteristic in service.characteristics)
		{
			trace( "characteristic: "+ch.uuid );
			if(ch.uuid == "00002a37-0000-1000-8000-00805f9b34fb"){
				trace("Characteristic found: " + ch.uuid);
				trace("Characteristic permissions: " + ch.permissions.toString());
				trace("Characteristic properties: " + ch.properties.toString());
				var success:Boolean = event.peripheral.subscribeToCharacteristic(ch);
				trace("subscribeCharacteristic: success=" + success);
				_characteristic = ch;
			}
		}
	}
	}


	function peripheral_characteristic_updatedHandler(event: CharacteristicEvent): void {
		 statusWin.txt.text = "Peripheral Characteristic Updated: " + event.characteristic.uuid + " value=" + event.characteristic.value.readUTFBytes(event.characteristic.value.length);


	}

	function peripheral_characteristic_errorHandler(event: CharacteristicEvent): void {
		statusWin.txt.text = "Peripheral Characteristic Error: [" + event.errorCode +"] "+event.error;

	}

	function peripheral_characteristic_writeHandler(event: CharacteristicEvent): void {
		statusWin.txt.text = "Peripheral Characteristic Write: " + event.peripheral.name;
	}

	function peripheral_characteristic_writeErrorHandler(event: CharacteristicEvent): void {
		statusWin.txt.text = "Peripheral Characteristic error: [" + event.errorCode + "] " + event.error;
	}

	function peripheral_characteristic_subscribeHandler(event: CharacteristicEvent): void {
		statusWin.txt.text = "Peripheral Characteristic Subscribe: " + event.peripheral.name;
	}

	function peripheral_characteristic_subscribeErrorHandler(event: CharacteristicEvent): void {
		statusWin.txt.text = "Peripheral Characteristic Error: [" + event.errorCode + "] " + event.error;
	}

	function peripheral_characteristic_unsubscribeHandler(event: CharacteristicEvent): void {
		statusWin.txt.text = "Peripheral Characteristic Unsubscribe: " + event.peripheral.name;
	}



	//
	//	PERIPHERAL MANAGER EVENTS
	//

	function peripheral_stateChangedHandler(event: PeripheralManagerEvent): void {
		statusWin.txt.text = "Peripheral state = " + BluetoothLE.service.peripheralManager.state;
	}

	function peripheral_serviceAddHandler(event: PeripheralManagerEvent): void {
		statusWin.txt.text = "Peripheral manager service added";
	}

	function peripheral_serviceAddErrorHandler(event: PeripheralManagerEvent): void {
		statusWin.txt.text = "Peripheral manager service add error";
	}

	function peripheral_startAdvertisingHandler(event: PeripheralManagerEvent): void {
		statusWin.txt.text = "Peripheral Advertising: Service - " + _service.uuid;
	}


	function peripheral_central_subscribeHandler(event: CentralEvent): void {
	statusWin.txt.text = "Peripheral manager: Central subscribed: " + event.central.uuid;
	
	// You should use this to track whether you should be periodically sending updates
	// For the moment we'll just show as an example sending an update immediately
	
	var value:ByteArray = new ByteArray();
	value.writeUTFBytes( "Central has subscribed" );
	
	BluetoothLE.service.peripheralManager.updateValue( _characteristic, value );

	}

	function peripheral_central_unsubscribeHandler(event: CentralEvent): void {
		statusWin.txt.text = "Peripheral manager: Central unsubscribed: " + event.central.uuid;
	}


	
	
	// PERIPHERAL READ DATA HANDLER
	function peripheral_readRequestHandler(event: RequestEvent): void {
	//
	//
	//	Read requests will only have one object in the requests event
	
	var request:Request = event.requests[0];
	
	statusWin.txt.text = "Peripheral manager: Read request: " + request.characteristic.uuid;

	//
	//	Handle the read request by first checking the UUID and then responding with the requested data.
	// 	You need to make sure you correctly handle the offset variable as illustrated below
	
	if (request.characteristic.uuid == _characteristic.uuid)
	{
		if (request.offset > _characteristic.value.length)
		{
			BluetoothLE.service.peripheralManager.respondToRequest( request, Request.INVALID_OFFSET );
		}
		else
		{
			_characteristic.value.position = 0;
			
			var data:ByteArray = new ByteArray();
			data.writeBytes( _characteristic.value, request.offset, (_characteristic.value.length - request.offset) );
			
			BluetoothLE.service.peripheralManager.respondToRequest( request, Request.SUCCESS, data );
		}
	}
	}


	
	// PERIPHERAL WRITE DATA HANDLER
	function peripheral_writeRequestHandler(event: RequestEvent): void {
		trace("peripheral manager: write request: " + event.requests.length);

		//
		//	Write requests may have several requests and you should process each one
		//	before calling respondToRequest. You only need to call respondToRequest once
		//	with the first request in the array
		for each(var request: Request in event.requests) {
			statusWin.txt.text = "Peripheral Manager: Write request: " + request.characteristic.uuid + " :: [" + request.offset + "] " + request.value.readUTFBytes(request.value.length);

			if (request.characteristic.uuid == _characteristic.uuid) {
				if (request.offset + request.value.length > MAX_VALUE_LENGTH) {
					BluetoothLE.service.peripheralManager.respondToRequest(request, Request.INVALID_OFFSET);
					return;
				} else {
					if (_characteristic.value == null) _characteristic.value = new ByteArray();
					_characteristic.value.position = 0;
					_characteristic.value.writeBytes(request.value, request.offset);
				}
			}
		}

		BluetoothLE.service.peripheralManager.respondToRequest(event.requests[0], Request.SUCCESS);

	}

}