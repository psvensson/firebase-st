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
	Transcript show:'Firestore#create id=',id asString;cr.
	token := firebase connect.
	url := ('https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path asString)  .
	Transcript show:'Firestore#create url=',url;cr.
	Transcript show:'document=',document asString;cr.
	^ firebase
		secureFirestoreJSONCallTo: url
		JSONContent: document
		id: id
		token: token
]

{ #category : #accessing }
Firestore >> createDirect: path id:id document: document [
	"https://firestore.googleapis.com/v1beta1/{parent=projects/*/databases/*/documents/**}/{collectionId}"
	| url token |
	Transcript show:'Firestore#create id=',id asString;cr.
	token := firebase connect.
	url := ('https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path asString) asLowercase .
	Transcript show:'Firestore#create url=',url;cr.
	Transcript show:'document=',document asString;cr.
	^ firebase
		secureDirectFirestoreJSONCallTo: url
		JSONContent: document
		id: id asString
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

{ #category : #'as yet unclassified' }
Firestore >> getFilter: filterString [
	| filter parts prop op val fieldPath fieldFilter |
	parts := filterString findTokens: '.'.
	prop := parts at: 1.
	op := parts at: 2.
	val := parts at: 3.
	fieldPath := Dictionary new.
	fieldPath at: 'fieldPath' put: prop.
	filter := Dictionary new.
	fieldFilter := Dictionary new.
	filter at: 'fieldFilter' put: fieldFilter.
	fieldFilter at: #field put: fieldPath.
	fieldFilter at: 'op' put: op.
	fieldFilter at: 'value' put: (self getFilterValue: val).
	Transcript
		show: 'getFilter for ' , filterString , ' returns ' , filter asString;
		cr.
	^ filter
]

{ #category : #accessing }
Firestore >> getFilterValue: val [
	| filterValue |
	filterValue := Dictionary new.
	val isString
		ifTrue: [ filterValue at: #stringValue put: val ].
	val isInteger
		ifTrue: [ filterValue at: #integerValue put: val ].
	val isFloat
		ifTrue: [ filterValue at: #doubleValue put: val ].
	val ifNil: [ filterValue at: #nullValue put: val ].
	(val = false or: val = true)
		ifTrue: [ filterValue at: #booleanValue put: val ].
	Transcript show:'getFilterValue for ',val asString,' returns ',filterValue asString;cr.
	^ filterValue
]

{ #category : #'as yet unclassified' }
Firestore >> getOrderBy: query [
	| rv orderBy fieldpath |
	fieldpath := Dictionary new.
	fieldpath at: #fieldPath put: (query at: #orderBy).	
	orderBy := Dictionary new.
	orderBy at: #field put: fieldpath.
	orderBy
		at: #direction
		put:
			(query
				at: #direction
				ifPresent: [ query at: #direction ]
				ifAbsent: [ 'DESCENDING' ]).
	rv := orderBy.
	Transcript show:'getOrderBy returns ',rv asString;cr.
	^ rv
]

{ #category : #'as yet unclassified' }
Firestore >> getSelect: query [
	| select fields |
	fields := (query at: #select)
		collect: [ :each | 
			| fieldPath |
			fieldPath := Dictionary new.
			fieldPath at: #fieldPath put: each.
			fieldPath ].
	select := Dictionary new.
	select at: #fields put: fields.
	Transcript
		show: 'getSelect returns ' , select asString;
		cr.
	^ select
]

{ #category : #'as yet unclassified' }
Firestore >> getWhere: query [
	| where compositeFilter filters rv |
	where := Dictionary new.
	compositeFilter := Dictionary new.
	where at: #compositeFilter put: compositeFilter .
	compositeFilter at: #op put: (query at: #op ifPresent: [ query at: #op ] ifAbsent: ['AND']).
	filters := ((query at: #where ) collect: [:each | self getFilter: each]).
	compositeFilter at: #filters put: filters.	
	Transcript show:'getWhere returns ',where asString;cr.
	^ where
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

{ #category : #accessing }
Firestore >> patch: path document: document [
	"https://firestore.googleapis.com/v1beta1/{parent=projects/*/databases/*/documents/**}/{collectionId}"

	| url token updateMask |
	updateMask := ''.
	document keysDo: [ :key | updateMask := updateMask , '&updateMask.fieldPaths=',key asString ].
	updateMask at: 1 put: $?.
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents/' , path.
	
	^ firebase 
		secureFirestorePatchJSONCallTo: url
		JSONContent: document
		token: token
]

{ #category : #accessing }
Firestore >> runQuery: query [
	"https://www.jeansnyman.com/posts/google-firestore-rest-api-examples/"

	| url token sq obj collection |
	obj := Dictionary new.
	collection := Dictionary new.
	collection at: #collectionId put: (query at: #from).
	obj
		at: #from
		put:
			(Array
				new;
				with: collection).
	query
		at: #orderBy
		ifPresent: [ obj at: #orderBy put: (self getOrderBy: query) ].
	query
		at: #select
		ifPresent: [ obj at: #select put: (self getSelect: query) ].
	query
		at: #where
		ifPresent: [ obj at: #where put: (self getWhere: query) ].
	query
		at: #limit
		ifPresent: [ obj at: #limit put: (query at: #limit) ].
	query
		at: #offset
		ifPresent: [ obj at: #offset put: (query at: #offset) ].	
	sq := Dictionary new.
	sq at: #structuredQuery put: obj.
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents:runQuery'.
	^ firebase secureJSONCallTo: url JSONContent: sq token: token
]

{ #category : #accessing }
Firestore >> runQueryDirect: query [
	"https://www.jeansnyman.com/posts/google-firestore-rest-api-examples/"

	| url token sq obj collection |
	obj := Dictionary new.
	collection := Dictionary new.
	collection at: #collectionId put: (query at: #from) asLowercase .
	obj
		at: #from
		put:
			(Array
				new;
				with: collection).
	query
		at: #orderBy
		ifPresent: [ obj at: #orderBy put: (self getOrderBy: query) ].
	query
		at: #select
		ifPresent: [ obj at: #select put: (self getSelect: query) ].
	query
		at: #where
		ifPresent: [ obj at: #where put: (self getWhere: query) ].
	query
		at: #limit
		ifPresent: [ obj at: #limit put: (query at: #limit) ].
	sq := Dictionary new.
	sq at: #structuredQuery put: obj.
	token := firebase connect.
	url := 'https://firestore.googleapis.com/v1beta1/projects/'
		, firebase projectId , '/databases/(default)/documents:runQuery'.
	^ firebase secureDirectJSONCallTo: url JSONContent: sq token: token
]
