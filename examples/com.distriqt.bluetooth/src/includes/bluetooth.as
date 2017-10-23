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

import com.distriqt.extension.bluetooth.Bluetooth;
import com.distriqt.extension.bluetooth.BluetoothDevice;
import com.distriqt.extension.bluetooth.events.BluetoothConnectionEvent;
import com.distriqt.extension.bluetooth.events.BluetoothDeviceEvent;
import com.distriqt.extension.bluetooth.events.BluetoothEvent;



var APP_KEY = "715ae6a4c7029edb2adda85c881c6299979aa9deBkVyDgLlo6ZTqntMdmnJ/v6FltwC/TVXws9HyBcIalC8/9yWmL+LQTBlENX3E+L8K/7CVk39FEUoSP2pBxtUEZsEJTyNMg82PYT08nZtHWygdoE2QrGrwvGOfUS0xkZQAyqnqZ45AkvG7ez4ZW2A3HKwwCbhr/HjhdxJh3lkVt0csk+08AHbwJb5yMttERmQXuNzDEHjWP3XrCVLVcS1puiOAhRo8Iq6gEPN/xndlAxGtEfukgGoUc4pemABzWsCZlE1UX6+dMdioHbPBjeaypsIXj1IJI6lt/5XNYSnsPhF+/AWO9EEAKzzgrm4iGSK4rtbG+oIsOpAJxkjPF1Nhg==";

Bluetooth.init(APP_KEY);

	if (Bluetooth.isSupported) {
		trace("Bluetooth Supported: " + Bluetooth.isSupported);
		trace("Bluetooth Version:   " + Bluetooth.service.version);

		//
		//	Add test inits here
		//

		Bluetooth.service.addEventListener(BluetoothEvent.STATE_CHANGED, bluetooth_stateChangedHandler, false, 0, true);
		Bluetooth.service.addEventListener(BluetoothEvent.SCAN_MODE_CHANGED, bluetooth_scanModeChangedHandler, false, 0, true);
		Bluetooth.service.addEventListener(BluetoothEvent.SCAN_STARTED, bluetooth_scanStartedHandler, false, 0, true);
		Bluetooth.service.addEventListener(BluetoothEvent.SCAN_FINISHED, bluetooth_scanFinishedHandler, false, 0, true);


		Bluetooth.service.addEventListener(BluetoothDeviceEvent.DEVICE_FOUND, bluetooth_deviceFoundHandler, false, 0, true);
		Bluetooth.service.addEventListener(BluetoothConnectionEvent.CONNECTION_RECEIVED_BYTES, bluetooth_receivedBytesHandler, false, 0, true);
		Bluetooth.service.addEventListener(BluetoothConnectionEvent.CONNECTION_REMOTE, bluetooth_remoteConnectionHandler, false, 0, true);
	}



	var _device: BluetoothDevice;

	var uuid: String = "fa87c0d0-afac-11de-8a39-0800200c9a66";
	
	var steps:  int = 0;

	//	NOTIFICATION HANDLERS
	//

	function activateHandler(event: Event): void {

	}


	function deactivateHandler(event: Event): void {
		//			trace( "deactivateHandler() ");
	}


	function bluetooth_stateChangedHandler(event: BluetoothEvent): void {
		trace("state changed:: " + event.data);
	}


	function bluetooth_scanModeChangedHandler(event: BluetoothEvent): void {
		trace("scan mode changed:: " + event.data);
	}


	function bluetooth_scanStartedHandler(event: BluetoothEvent): void {
		trace("scan started");
	}


	function bluetooth_scanFinishedHandler(event: BluetoothEvent): void {
		trace("scan finished");
	}


	function bluetooth_deviceFoundHandler(event: BluetoothDeviceEvent): void {
		trace("device found:: '" + event.device.deviceName + "' :: " + event.device.address);
		if (event.device.bluetoothClass != null)
			trace("  Class: " + event.device.bluetoothClass.deviceClass + "::" + event.device.bluetoothClass.majorDeviceClass);

		_device = event.device;
	}


	function bluetooth_remoteConnectionHandler(event: BluetoothConnectionEvent): void {
		var data: ByteArray = new ByteArray();
		data.writeUTF("thanks for connecting to me");
		var success: Boolean = Bluetooth.service.writeBytes(event.uuid, data);
		trace("send to client: success=" + success);
	}


	function bluetooth_receivedBytesHandler(event: BluetoothConnectionEvent): void {
		trace("received bytes");
		var read: ByteArray = Bluetooth.service.readBytes(uuid);
		if (read == null) {
			trace("error reading data?");
		} else {
			read.position = 0;
			trace("READ: " + read.readUTF());
		}
	}



	function checkBTActions():void
		{
		switch (steps) {
			case 0:
				statusWin.txt.text = "Enable bluetooth";
				btMC.btnTxt.text = "Get Paired Devices";
				if (!Bluetooth.service.isEnabled())
					Bluetooth.service.enable();
				else
					statusWin.txt.text = "Bluetooth already enabled";
				break;


			case 1:
				btMC.btnTxt.text = "Create Listener";
				statusWin.txt.text = "getPairedDevices()";
				var pairedDevices: Vector.<BluetoothDevice> = Bluetooth.service.getPairedDevices();
				if (pairedDevices.length == 0) {
					statusWin.txt.text = "No paired devices";
				} else {
					for each(var device: BluetoothDevice in pairedDevices) {
						_device = device;
						statusWin.txt.text = "Device: " + device.deviceName + "::" + device.address;
						if (device.bluetoothClass != null)
							statusWin.txt.text = "  Class: " + device.bluetoothClass.deviceClass + "::" + device.bluetoothClass.majorDeviceClass;
					}
				}
				break;


			case 2:
				//					statusWin.txt.text = "setting device discoverable";
				//					Bluetooth.service.setDeviceDiscoverable();
				break;


			case 3:
				//					statusWin.txt.text = "scan for devices";
				//					Bluetooth.service.startScan();
				break;


			case 4:
				//					statusWin.txt.text = "show settings";
				//					Bluetooth.service.showSettings();
				break;


			case 5:
				btMC.btnTxt.text = "Create a Connection";
				statusWin.txt.text = "create a listen connection :: " + uuid;
				var listenResult: Boolean = Bluetooth.service.listen(uuid);
				statusWin.txt.text = "success=" + listenResult;
				break;

			case 6:
				//					_root._device = new  BluetoothDevice();
				//					_root._device.address = "F0:08:F1:A9:BF:E1";
				btMC.btnTxt.text = "Write Some Data";
				if (_device) {
					statusWin.txt.text = "create a connection :: " + _device.deviceName;
					var connectionResult: Boolean = Bluetooth.service.connect(_device, uuid);
					statusWin.txt.text = "success=" + connectionResult;
				}
				break;

			case 7:
				btMC.btnTxt.text = "Disable Bluetooth";
				statusWin.txt.text = "write some data";
				var data: ByteArray = new ByteArray();
				data.writeUTF("some test data string");
				var success: Boolean = Bluetooth.service.writeBytes(uuid, data);

				statusWin.txt.text = "success=" + success;
				break;


			default:
				btMC.btnTxt.text = "Enable Bluetooth";
				statusWin.txt.text = "disable bluetooth";
				Bluetooth.service.closeAll();
				Bluetooth.service.disable();
			    steps = -1;
		}
		steps++
	}