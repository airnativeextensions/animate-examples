//ENCRYPT PASSWORD DATA
import flash.data.EncryptedLocalStore;

var passID: String;
var passData;


function savePassData() {

	passID = loginMC.passwordText.text;
	passData = new ByteArray();
	passData.writeUTFBytes(passID);


	EncryptedLocalStore.setItem("passID", passData, false);

	trace("Password=" + passData);
}

function getPassData() {
	try {
		var passData = EncryptedLocalStore.getItem("passID");
		trace("Password=" + passData);
		touchPassword.text = passData;
	} catch (error: Error) {
		trace("ERROR: No Pass Data");
	}
}

function removePassData() {
	EncryptedLocalStore.removeItem("passID");
}

getPassData();