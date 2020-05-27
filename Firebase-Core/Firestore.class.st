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
	Transcript
		show: 'firestore create: ' , url;
		cr.
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
