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


import com.distriqt.extension.contacts.AuthorisationStatus;
import com.distriqt.extension.contacts.Contacts;
import com.distriqt.extension.contacts.events.AuthorisationEvent;
import com.distriqt.extension.contacts.events.ContactsEvent;
import com.distriqt.extension.contacts.events.ContactsJSONEvent;
import com.distriqt.extension.contacts.model.Address;
import com.distriqt.extension.contacts.model.Contact;
import com.distriqt.extension.contacts.model.ContactDate;
import com.distriqt.extension.contacts.model.ContactProperty;
import com.distriqt.extension.contacts.model.InstantMessageService;
import com.distriqt.extension.contacts.model.SocialService;
import flash.filesystem.File;


var _contactId: int = -1;
var _time: int = 0;
var contact: Contact;



try {
	Contacts.init("");
	if (Contacts.isSupported) {
		trace("Contacts Version:   " + Contacts.service.version);
		Contacts.service.addEventListener(AuthorisationEvent.CHANGED, contacts_authorisationChangedHandler);

		Contacts.service.addEventListener(ContactsEvent.CONTACT_SELECTED, contact_selectedHandler);
		Contacts.service.addEventListener(ContactsEvent.CONTACTPICKER_CANCEL, contacts_contactPickerEventHandler);
		Contacts.service.addEventListener(ContactsEvent.CONTACTPICKER_CLOSED, contacts_contactPickerEventHandler);
		Contacts.service.addEventListener(ContactsEvent.CONTACTPICKER_ERROR, contacts_contactPickerEventHandler);

		Contacts.service.addEventListener(ContactsEvent.GET_CONTACTS, contacts_getContactsHandler, false, 0, true);
		Contacts.service.addEventListener(ContactsEvent.GET_CONTACTS_EXTENDED, contacts_getContactsExtendedHandler, false, 0, true);

		Contacts.service.addEventListener(ContactsJSONEvent.GET_CONTACTS_JSON, contacts_getContactsJSONHandler);

		Contacts.service.addEventListener(ContactsEvent.GET_CONTACTS_ERROR, contacts_getContactsErrorHandler, false, 0, true);

	}
} catch (e: Error) {
	trace(e);
}



var _state: int = 0;

function startContactEvents(): void {
	switch (_state) {
		case 0:
			{
				trace("==============================");
				trace("AUTHORISATION STATUS: " + Contacts.service.authorisationStatus());
				switch (Contacts.service.authorisationStatus()) {
					case AuthorisationStatus.AUTHORISED:
						showContactPicker();
						actionBTN.btnUI.btnTxt.txt.text = "Add Contact";
						_state++;
						if (_contactId != -1) {
							//						var c:Contact = Contacts.service.getContactDetails( _contactId );
							//						printContact( c );

							//						if (c.hasImage)
							//						{
							//							addChild( new Bitmap(c.image));
							//						}

							Contacts.service.saveContactImage(_contactId, File.applicationStorageDirectory.resolvePath("contacts/images"));

							_contactId = -1;
						}
						break;

					case AuthorisationStatus.SHOULD_EXPLAIN:
					case AuthorisationStatus.NOT_DETERMINED:
						trace("REQUEST ACCESS");
						Contacts.service.requestAccess();
						return;

					case AuthorisationStatus.RESTRICTED:
					case AuthorisationStatus.DENIED:
					default:
						trace("ACCESS DENIED");
						return;
				}
			}

		case 1:
			{
				addContact();
				actionBTN.btnUI.btnTxt.txt.text = "Get Basic List";
				break;
			}

		case 2:
			{
				listBasicContacts();
				actionBTN.btnUI.btnTxt.txt.text = "Get Extended List";
				break;
			}


		case 3:
			{
				listExtendedContacts();
				actionBTN.btnUI.btnTxt.txt.text = "Get JSON from List";
				break;
			}

		case 4:
			{
				getContactListAsJSON();
				actionBTN.btnUI.btnTxt.txt.text = "Get Contact Pic";
				break;
			}

		case 5:
			{
				getContactImage();
				actionBTN.btnUI.btnTxt.txt.text = "Access Contacts";
				break;
			}

		default:
			{
				_state = 0;
				showContactPicker();
				actionBTN.btnUI.btnTxt.txt.text = "Add Contact";
			}
	}
	_state++;
}





function contacts_authorisationChangedHandler(event: AuthorisationEvent): void {
	trace(event.type + "::" + event.status);
	switch (event.status) {
		case AuthorisationStatus.SHOULD_EXPLAIN:
			// Should display a reason you need this feature
			break;

		case AuthorisationStatus.AUTHORISED:
			// AUTHORISED: Camera will be available
			showContactPicker();
			actionBTN.btnUI.btnTxt.txt.text = "ADD CONTACT";
			_state++;
			break;

		case AuthorisationStatus.RESTRICTED:
		case AuthorisationStatus.DENIED:
			// ACCESS DENIED: You should inform your user appropriately
			break;
	}
}

function showContactPicker(): void {
	if (!Contacts.service.showContactPicker()) {
		trace("Access to contacts list denied by user");
	}
}

function contact_selectedHandler(event: ContactsEvent): void {
	trace("Contact selected");
	if (event.data) {
		contact = event.data[0];

		trace("Got contact: " + contact.contactId);
		trace("Name: " + contact.fullName);
		trace("FName: " + contact.firstName);
		trace("Org: " + contact.organisation.name + " -- " + contact.organisation.title);
		for each(var p: Object in contact.phoneNumbers) {
			trace(p.label + " -- " + p.value);
		}
		for each(var e: Object in contact.emailAddresses) {
			trace(e.label + " -- " + e.value);
		}
	}
}

function contacts_contactPickerEventHandler(event: ContactsEvent): void {
	//trace(event.type + "::" + event.trace);
}




function addContact(): void {
	var contact: Contact = new Contact();
	contact.firstName = "Test";
	contact.lastName = "Someone";

	contact.phoneNumbers.push(new ContactProperty("home", "038-888-8888", false));
	contact.phoneNumbers.push(new ContactProperty("mobile", "044-444-4444", true));
	contact.emailAddresses.push(new ContactProperty("work", "test@distriqt.com", true));

	var address: Address = new Address();
	address.properties.push(new ContactProperty(Address.LABEL_STREET, "10 Credibility St"));
	address.properties.push(new ContactProperty(Address.LABEL_CITY, "Laudsville"));
	address.properties.push(new ContactProperty(Address.LABEL_POSTCODE, "90210"));
	address.properties.push(new ContactProperty(Address.LABEL_COUNTRY, "United States"));

	contact.addresses.push(address);

	//			var organisation:ContactOrganisation = new ContactOrganisation();
	//			organisation.name = "distriqt";
	//			organisation.title = "developer";
	//			
	//			contact.organisation = organisation;

	var success: Boolean = Contacts.service.addContact(contact);
	trace("Contacts.service.addContact( contact ) = " + success);
}






function getContactListAsJSON(): void {
	_time = getTimer();
	Contacts.service.getContactListAsJSON();
	trace("getContactListAsJSON(): (time=" + ((getTimer() - _time) / 1000) + "s)");
}

function contacts_getContactsJSONHandler(event: ContactsJSONEvent): void {
	trace(event.json);
}


function listBasicContacts(): void {
	//			var start:int = getTimer();
	//			var contacts:Vector.<Contact> = Contacts.service.getContactList();
	//			trace( "listBasicContacts(): Retrieved " + contacts.length + " contacts (time=" + ((getTimer()-start)/1000)+"s)");

	//			printContacts( contacts );


	_time = getTimer();
	Contacts.service.getContactListAsync(false);
	trace("getContactListAsync(): (time=" + ((getTimer() - _time) / 1000) + "s)");
}


function contacts_getContactsHandler(event: ContactsEvent): void {
	trace("getContactListAsync(): Retrieved " + event.data.length + " contacts (time=" + ((getTimer() - _time) / 1000) + "s)");

	//			printContacts( event.data );

	//			var destination:File = File.applicationStorageDirectory.resolvePath( "contacts/images" );
	//			for (var i:int = 0; i < 20 && i < event.data.length; i++)
	//			{
	//				Contacts.service.saveContactImage( event.data[i].contactId, destination );
	//			}
}



function listExtendedContacts(): void {
	var start: int = getTimer();
	//			var contacts:Vector.<Contact> = Contacts.service.getContactListExtended();
	//			trace( "listExtendedContacts(): Retrieved " + contacts.length + " contacts (time=" + ((getTimer()-start)/1000)+"s)");


	_time = getTimer();
	Contacts.service.getContactListExtendedAsync(false);
	trace("getContactListExtendedAsync(): (time=" + ((getTimer() - _time) / 1000) + "s)");

	//			printContacts( contacts );
}

function contacts_getContactsExtendedHandler(event: ContactsEvent): void {
	trace("getContactListExtendedAsync(): Retrieved " + event.data.length + " contacts (time=" + ((getTimer() - _time) / 1000) + "s)");
	//			printContacts( event.data );
}

function contacts_getContactsErrorHandler(event: ContactsEvent): void {
	//trace("ERROR::" + event.trace);
}


//Make sure the contact has an image associated with it.
function getContactImage(): void {
	trace(contact.contactId);
	//Contacts.service.getContactDetails(contact.contactId, true);
	var image:BitmapData = Contacts.service.getContactImage( contact.contactId );
	var myImage:Bitmap = new Bitmap(image);
	addChild(myImage);  
}

