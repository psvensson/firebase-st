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
	instance firebase: firebase
]

{ #category : #accessing }
FirebaseRtdb >> firebase [
	^ firebase
]

{ #category : #accessing }
FirebaseRtdb >> firebase: anObject [
	firebase := anObject
]
