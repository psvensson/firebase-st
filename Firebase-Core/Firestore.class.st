"
Test like this;
----------------

|certificateString firebase firestore data query res|
data := Dictionary new.
data at: 'hej' put: 'svejs'.
certificateString := 'service_account.json' asFileReference readStream contents.

firebase := Firebase new: certificateString .
firestore := Firestore new: firebase.

res := firestore create: 'bar' name: 'baz' document: data.
res onSuccessDo: [ :s | Transcript show:'Success: ',s asString;cr ].
res onFailureDo: [ :e | Transcript show:'Failure: ',e asString;cr ].
res

"
Class {
	#name : #Firestore,
	#superclass : #Object,
	#instVars : [
		'firebase'
	],
	#category : #'Firebase-Core'
}

{ #category : #'instance creation' }
Firestore class >> new: firebase [
	| instance |
	instance := self new.
	instance firebase: firebase.
	^  instance
]

{ #category : #accessing }
Firestore >> create: path id:id document: document [
	"https://firestore.googleapis.com/v1beta1/{parent=projects/*/databases/*/documents/**}/{collectionId}"

	| url token |
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path.
	
	^ firebase
		secureFirestoreJSONCallTo: url
		JSONContent: document
		id: id
		token: token
]

{ #category : #accessing }
Firestore >> firebase [
	^ firebase
]

{ #category : #accessing }
Firestore >> firebase: anObject [
	firebase := anObject
]

{ #category : #accessing }
Firestore >> get: path [
	"GET https://firestore.googleapis.com/v1beta1/{name=projects/*/databases/*/documents/*/**}"

	| url token |
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path.
	
	^ firebase
		secureFirestoreCallTo: url
		token: token
]

{ #category : #accessing }
Firestore >> list: path pageSize: pageSize pageToken: pageToken orderBy: orderBy [
	"GET https://firestore.googleapis.com/v1beta1/{name=projects/*/databases/*/documents/*/**}"

	| url token |
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path
		, '?showMissing=true'.
	pageSize ifNotNil: [ url := url , '&pageSize=' , pageSize ].
	pageToken ifNotNil: [ url := url , '&pageToken=' , pageToken ].
	orderBy ifNotNil: [ url := url , '&orderBy=' , orderBy ].
	^ firebase secureFirestoreCallTo: url token: token
]
