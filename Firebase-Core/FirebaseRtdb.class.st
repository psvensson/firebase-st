Class {
	#name : #FirebaseRtdb,
	#superclass : #Object,
	#instVars : [
		'firebase'
	],
	#category : #'Firebase-Core'
}

{ #category : #'instance creation' }
FirebaseRtdb class >> new: firebase [
	| instance |
	instance := self new.
	instance firebase: firebase.
	^  instance
]

{ #category : #accessing }
FirebaseRtdb >> firebase [
	^ firebase
]

{ #category : #accessing }
FirebaseRtdb >> firebase: anObject [
	firebase := anObject
]

{ #category : #accessing }
FirebaseRtdb >> getPath: path [
	"'https://[PROJECT_ID].firebaseio.com/users/jack/name.json'"

	| url token |
	token := firebase connect.
	url := 'https://' , firebase projectId , '.firebaseio.com' , path
		, '.json'.
	^ firebase secureJSONCallTo: url token: token
]

{ #category : #accessing }
FirebaseRtdb >> putPath: path obj: obj [
	| url token |
	token := firebase connect.
	url := 'https://' , firebase projectId , '.firebaseio.com' , path
		, '.json'.
	^ firebase secureJSONPutCallTo: url JSONContent: obj token: token
]
