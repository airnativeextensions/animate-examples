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
 * Core features of Local Auth ANE
 *
 */

//Define Classes
import com.distriqt.extension.localauth.LocalAuth;
import com.distriqt.extension.localauth.events.LocalAuthEvent;
var touchEnabled: String;
var touchStatus: String;



try {
	//App Key
	LocalAuth.init("KEY GOES HERE");
	trace("LocalAuth Version:   " + LocalAuth.service.version);

	if (LocalAuth.service.canAuthenticateWithFingerprint()) {
		// Fingerprint authentication is available on device
		touchEnabled = "on";
	}

	//
	//	Add test inits here
	//
} catch (e: Error) {
	trace("ERROR::" + e.message);
}


function verifyFingerprint(): void {
	//
	//	Do something when user clicks screen?
	//	

	if (LocalAuth.service.canAuthenticateWithFingerprint()) {
		LocalAuth.service.addEventListener(LocalAuthEvent.AUTH_SUCCESS, localAuth_authSuccessHandler);
		LocalAuth.service.addEventListener(LocalAuthEvent.AUTH_FAILED, localAuth_authFailedHandler);
		LocalAuth.service.authenticateWithFingerprint("Scan fingerprint to continue");
	}
}


//	EXTENSION HANDLERS
function localAuth_authSuccessHandler(event: LocalAuthEvent): void {
	trace("localAuth_authSuccessHandler");
	loginMC.passwordText.visible = false;
	loginMC.passwordText.text = touchPassword.text;
	checkUserLogin();
}


function localAuth_authFailedHandler(event: LocalAuthEvent): void {
	trace("localAuth_authFailedHandler: " + event.errorCode + "::" + event.message);
	loginMC.passwordText.text = "";
	loginMC.passMC.visible = true;
}


//allow entry into app
function checkUserLogin() {
savePassData();
alertTitleTXT = "LOGIN SUCCESSFUL!";
alertTXT = "You have logged in. Exit the application and try again.";
transitionMC.gotoAndPlay("alert");
loginMC.passwordText.visible = false;
}


//STORE TOUCH DATA (no encryption)
import flash.filesystem.FileStream;
import flash.filesystem.File;
import flash.filesystem.FileMode;

var file: File = File.applicationStorageDirectory.resolvePath("localAuth.txt");
var filestream: FileStream = new FileStream();
var appDataTemp: String;
var touchData: String;

function saveTouchData() {
	try {
		filestream.open(file, FileMode.WRITE);
		touchData = touchStatus;
		filestream.writeUTF(touchData);
		filestream.close();

	} catch (error: Error) {
		trace("update failed");
	}
}

function getTouchData() {
	try {
		file = file.resolvePath("localAuth.txt");
		filestream.open(file, FileMode.UPDATE);
		appDataTemp = filestream.readUTF();
		var pulledData = appDataTemp.split("&&&");
		touchData = String(pulledData[0]);
		touchStatus = touchData;
		trace("TouchID=" + touchData);
	} catch (error: Error) {
		//Testing on PC
		trace("ERROR: no localAuth.txt");
		touchData = "";
	}
	filestream.close();
}

getTouchData();