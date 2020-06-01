Class {
	#name : #FirestoreJsonReader,
	#superclass : #NeoJSONReader,
	#category : #'Firebase-Core'
}

{ #category : #convenience }
FirestoreJsonReader class >> fromDocument: rv [
	rv
		at: #fields
		ifPresent: [ rv at: #fields put: (self reverseMap: (rv at: #fields)) ].
	rv
		at: #documents
		ifPresent: [ rv
				at: #documents
				put: ((rv at: #documents) collect: [ :each | 
					Transcript show:'collecting document ',each asString;cr.
					self fromDocument: each ]) ].
	^ rv
]

{ #category : #convenience }
FirestoreJsonReader class >> fromString: string [
	| rv |
	rv := (self on: string readStream) next.
	"TODO: Ensure that the 'fields' property is handled and type cruft removed from values"
	^ self fromDocument: rv
]

{ #category : #convenience }
FirestoreJsonReader class >> getCorrectValueFor: dict [
	| firstKey firstVal |
	firstKey := dict keys first.
	firstVal := dict at: firstKey.
	firstKey = #mapValue ifTrue: [ ^ self reverseMap: (firstVal at: #fields) ].
	firstKey = #arrayValue ifTrue: [ ^ self reverseArray: (firstVal at: #values) ].
	^ firstVal 
]

{ #category : #convenience }
FirestoreJsonReader class >> reverseArray: value [ 
	^ value  collect: [ :each | | key val |
		key := each keys first.
		val := each at: key.
		"Transcript show:'reverseMap mapping ',key,' -> ',value asString;cr."
		val ]
	
]

{ #category : #convenience }
FirestoreJsonReader class >> reverseMap: aDict [
	| rv |
	rv := Dictionary new.
	aDict
		keysAndValuesDo:
			[ :key :value | | val |
			"Transcript show:'reverseMap mapping ............................ ',key;cr."
			val := self getCorrectValueFor: value.
			"Transcript show:'reverseMap mapping ',key,' -> ',value asString;cr."
			rv at: key put: val ].
	^ rv
]

{ #category : #parsing }
FirestoreJsonReader >> parseFirestoreValue [
	| char |
	readStream atEnd ifFalse: [ 
		char := readStream peek.
		char = ${
			ifTrue: [ ^ self parseMap ].
		char = $[
			ifTrue: [ ^ self parseList ].
		char = $"
			ifTrue: [ ^ self parseString ].
		(char = $- or: [ char isDigit ])
			ifTrue: [ ^ self parseNumber ].
		self parseConstantDo: [ :value | ^ value ] ].
	self error: 'invalid input: ', char asString
]
