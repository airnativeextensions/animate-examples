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

import com.distriqt.extension.cloudstorage.CloudStorage;
import com.distriqt.extension.cloudstorage.documents.Document;
import com.distriqt.extension.cloudstorage.events.DocumentEvent;
import com.distriqt.extension.cloudstorage.events.DocumentStoreEvent;
import com.distriqt.extension.cloudstorage.events.DocumentStoreStateEvent;
import com.distriqt.extension.cloudstorage.events.KeyValueStoreEvent;


try {
	CloudStorage.init("YOUR KEY HERE");
	if (CloudStorage.isSupported) {
		trace("CloudStorage Version:   " + CloudStorage.service.version);

		CloudStorage.service.keyValueStore.addEventListener(KeyValueStoreEvent.CHANGED, keyStore_changedHandler);
		CloudStorage.service.keyValueStore.synchronise();
	}
} catch (e: Error) {
	trace(e);
}


var TEST_KEY:String = "testKey";
var _state: int = 0;


function startCloudEvents():void{
	switch (_state) {
		case 0:
			{
				synchronise();
				actionBTN.btnUI.btnTxt.txt.text = "Get Value";
				break;
			}

		case 1:
			{
				getValue();
				actionBTN.btnUI.btnTxt.txt.text = "Set Value";
				break;
			}

		case 2:
			{
				setValue();
				actionBTN.btnUI.btnTxt.txt.text = "Setup Document Store";
				break;
			}
		
		case 3:
			{
				ds_setup();
				actionBTN.btnUI.btnTxt.txt.text = "List Documents";
				break;
			}
		
		case 4:
			{
				ds_listDocuments();
				actionBTN.btnUI.btnTxt.txt.text = "Update Document Store";
				break;
			}
			
		case 5:
			{
				ds_update();
				actionBTN.btnUI.btnTxt.txt.text = "Create Document";
				break;
			}
			
		case 6:
			{
				ds_createDocument();
				actionBTN.btnUI.btnTxt.txt.text = "Create Doc In Folder";
				break;
			}
			
		case 7:
			{
				ds_createDocumentInFolder();
				actionBTN.btnUI.btnTxt.txt.text = "Load Document";
				break;
			}
			
		case 8:
			{
				ds_loadDocument();
				actionBTN.btnUI.btnTxt.txt.text = "Save Document";
				break;
			}
			
		case 9:
			{
				ds_saveDocument();
				actionBTN.btnUI.btnTxt.txt.text = "Delete Document";
				break;
			}

		default:
			{
				_state = 0;
				ds_deleteDocument();
				actionBTN.btnUI.btnTxt.txt.text = "Synchronize";
			}
	}
	_state++;
}


function synchronise(e:Event=null):void
		{
			CloudStorage.service.keyValueStore.synchronise();
		}
		
		
		function getValue(e:Event=null):void
		{
			trace( TEST_KEY +"="+ CloudStorage.service.keyValueStore.getString( TEST_KEY ) );
		}
		
		
		function setValue(e:Event=null):void
		{
			var newValue:String = String(Math.floor(Math.random()*100000));
			trace( "storeValue( " + TEST_KEY +", "+ newValue +" )" );
			CloudStorage.service.keyValueStore.setString( TEST_KEY, newValue );
		}
		
		
		//
		//	KEY-VALUE STORE EVENTS
		//
		
		function keyStore_changedHandler( event:KeyValueStoreEvent ):void
		{
			trace( "KeyStore CHANGED" );
		}
		
		
		
		
		//
		//
		//	DOCUMENT STORE
		//
		//
		
		var _documents 	: Vector.<Document>;
		
		function ds_setup(e:Event=null):void
		{
			trace( "setup()" );
			CloudStorage.service.documentStore.addEventListener( DocumentStoreStateEvent.INITIALISED, ds_initialisedHandler );
			CloudStorage.service.documentStore.addEventListener( DocumentStoreStateEvent.CHANGE, ds_stateChangeHandler );

			CloudStorage.service.documentStore.addEventListener( DocumentStoreEvent.FILES_DID_CHANGE, ds_filesDidChangeHandler );
			CloudStorage.service.documentStore.addEventListener( DocumentStoreEvent.CONFLICT, ds_conflictHandler );

			CloudStorage.service.documentStore.setup();
		}
		
		
		function ds_initialisedHandler( event:DocumentStoreStateEvent ):void
		{
			trace( "ds_initialisedHandler: " + event.available + ":"+event.containerUrl );
			trace( event.token );
		}
		
		function ds_stateChangeHandler( event:DocumentStoreStateEvent ):void
		{
//			trace( "ds_stateChangeHandler: " + event.available + ":"+event.containerUrl );
			
			// Should check for user change here storing the current value of the token
//			trace( event.token );
		}
		
		
		function ds_filesDidChangeHandler( event:DocumentStoreEvent ):void
		{
			trace( "ds_filesDidChangeHandler" );
			for each (var document:Document in event.documents)
			{
				trace( "changed: "+document.filename );
			}
		}
		
		
		function ds_conflictHandler( event:DocumentStoreEvent ):void
		{
			trace( "ds_conflictHandler" );
			for each (var document:Document in event.documents)
			{
				trace( "conflict: "+document.filename );
				var versions:Array = CloudStorage.service.documentStore.getConflictingVersionsForDocument( document );
				CloudStorage.service.documentStore.resolveConflictWithVersion( document, versions[0] );
			}
		}
		
		
		////////////////////////////////////////////////////////
		// 	LIST DOCUMENTS
		//		
		
		function ds_listDocuments(e:Event=null):void
		{
			trace( "listDocuments()" );
			if (CloudStorage.service.documentStore.isAvailable)
			{
				var documents:Vector.<Document> = CloudStorage.service.documentStore.listDocuments();
				
				for each (var document:Document in documents)
				{
					trace( "document: "+document.filename +" ["+document.url+"]" );
				}
				
				// Store for other actions
				_documents = documents;
			}
		}
		
		
		
		
		////////////////////////////////////////////////////////
		// 	UPDATE
		//		
		
		function ds_update(e:Event=null):void
		{
			trace( "update()" );
			if (CloudStorage.service.documentStore.isAvailable)
			{
				var success:Boolean = CloudStorage.service.documentStore.update();
				trace( "update() = "+success );
			}
		}
		
		
		
		
		////////////////////////////////////////////////////////
		// 	CREATE DOCUMENT
		//
		
		function ds_createDocument(e:Event=null):void
		{
			trace( "Creating a document" );
			if (CloudStorage.service.documentStore.isAvailable)
			{
				var document:Document = new Document();
				document.filename = "test.txt";
				document.data = new ByteArray();
				document.data.writeUTFBytes( "TEST SOME STRING WRITING" );
				
				CloudStorage.service.documentStore.addEventListener( DocumentEvent.SAVE_COMPLETE, document_createCompleteHandler );
				CloudStorage.service.documentStore.addEventListener( DocumentEvent.SAVE_ERROR, document_createErrorHandler );
				
				CloudStorage.service.documentStore.saveDocument( document );
			}
		}
		
		function ds_createDocumentInFolder(e:Event=null):void
		{
			trace( "Creating a document in folder" );
			if (CloudStorage.service.documentStore.isAvailable)
			{
				var document:Document = new Document();
				document.filename = "folder/test.txt";
				document.data = new ByteArray();
				document.data.writeUTFBytes( "TEST SOME STRING WRITING" );
				
				CloudStorage.service.documentStore.addEventListener( DocumentEvent.SAVE_COMPLETE, document_createCompleteHandler );
				CloudStorage.service.documentStore.addEventListener( DocumentEvent.SAVE_ERROR, document_createErrorHandler );
				
				CloudStorage.service.documentStore.saveDocument( document );
			}
		}
		
		function document_createCompleteHandler( event:DocumentEvent ):void
		{
			trace( "document_createCompleteHandler" );
			
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_COMPLETE, document_loadCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_ERROR, document_loadErrorHandler );
		}
		
		function document_createErrorHandler( event:DocumentEvent ):void
		{
			trace( "document_createErrorHandler" );
			
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_COMPLETE, document_loadCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_ERROR, document_loadErrorHandler );
		}
		
		
		
		
		////////////////////////////////////////////////////////
		// 	LOAD DOCUMENT
		//
		
		function ds_loadDocument(e:Event=null):void
		{
			if (CloudStorage.service.documentStore.isAvailable)
			{
				if (_documents != null && _documents.length > 0)
				{
					CloudStorage.service.documentStore.addEventListener( DocumentEvent.LOAD_COMPLETE, document_loadCompleteHandler );
					CloudStorage.service.documentStore.addEventListener( DocumentEvent.LOAD_ERROR, document_loadErrorHandler );
					
					var success:Boolean = CloudStorage.service.documentStore.loadDocument( _documents[0].filename );
					trace( "loadDocument( "+_documents[0].filename +" ) = " + success );
				}
				else 
				{
					trace( "call listDocuments first" );
				}
			}
		}
		
		function document_loadCompleteHandler( event:DocumentEvent ):void
		{
			trace( "document_loadCompleteHandler" );

			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.LOAD_COMPLETE, document_loadCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.LOAD_ERROR, document_loadErrorHandler );
			
			if (event.document && event.document.data)
			{
				trace( "document.data["+event.document.data.length+"] : "+event.document.modifiedDate.toLocaleString() );
				try {
					trace( event.document.data.readUTFBytes( event.document.data.length ));
				} catch (e:Error) {}
			}
		}
		
		function document_loadErrorHandler( event:DocumentEvent ):void
		{
			trace( "document_loadErrorHandler: " + event.error );
		
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.LOAD_COMPLETE, document_loadCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.LOAD_ERROR, document_loadErrorHandler );
		}
		

		
		
		////////////////////////////////////////////////////////
		// 	SAVE DOCUMENT
		//
		
		function ds_saveDocument(e:Event=null):void
		{
			if (CloudStorage.service.documentStore.isAvailable)
			{
				if (_documents != null && _documents.length > 0)
				{
					var content:String =  "TEST SOME STRING WRITING "+String(Math.floor(Math.random()*100000));e
					trace( "saving: "+content );
					
					_documents[0].data = new ByteArray();
					_documents[0].data.writeUTFBytes( content );
				
					CloudStorage.service.documentStore.addEventListener( DocumentEvent.SAVE_COMPLETE, document_saveCompleteHandler );
					CloudStorage.service.documentStore.addEventListener( DocumentEvent.SAVE_ERROR, document_saveErrorHandler );
					
					CloudStorage.service.documentStore.saveDocument( _documents[0] );
				}
			}
		}
		
		function document_saveCompleteHandler( event:DocumentEvent ):void
		{
			trace( "document_saveCompleteHandler" );
			
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_COMPLETE, document_saveCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_ERROR, document_saveErrorHandler );
		}
		
		function document_saveErrorHandler( event:DocumentEvent ):void
		{
			trace( "document_saveErrorHandler" );
			
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_COMPLETE, document_saveCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.SAVE_ERROR, document_saveErrorHandler );
		}
		
		
		////////////////////////////////////////////////////////
		// 	DELETE DOCUMENT
		//
		
		function ds_deleteDocument(e:Event=null):void
		{
			if (CloudStorage.service.documentStore.isAvailable)
			{
				if (_documents != null && _documents.length > 0)
				{
					trace( "deleting: "+_documents[0].filename );
					
					CloudStorage.service.documentStore.addEventListener( DocumentEvent.DELETE_COMPLETE, document_deleteCompleteHandler );
					CloudStorage.service.documentStore.addEventListener( DocumentEvent.DELETE_ERROR, document_deleteErrorHandler );
					
					CloudStorage.service.documentStore.deleteDocument( _documents[0].filename );
				}
			}
		}
		
		function document_deleteCompleteHandler( event:DocumentEvent ):void
		{
			trace( "document_deleteCompleteHandler" );
			
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.DELETE_COMPLETE, document_deleteCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.DELETE_ERROR, document_deleteErrorHandler );
		}
		
		function document_deleteErrorHandler( event:DocumentEvent ):void
		{
			trace( "document_deleteErrorHandler" );
			
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.DELETE_COMPLETE, document_deleteCompleteHandler );
			CloudStorage.service.documentStore.removeEventListener( DocumentEvent.DELETE_ERROR, document_deleteErrorHandler );
		}