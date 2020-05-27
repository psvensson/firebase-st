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
Firestore >> create: path name: name document: document [
	"https://firestore.googleapis.com/v1beta1/{parent=projects/*/databases/*/documents/**}/{collectionId}"

	| url token |
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path.
	
	^ firebase
		secureFirestoreJSONCallTo: url
		JSONContent: document
		name: name
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
