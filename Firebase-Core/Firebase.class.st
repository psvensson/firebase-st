Class {
	#name : #Firebase,
	#superclass : #Object,
	#instVars : [
		'certificate',
		'connection',
		'client'
	],
	#category : #'Firebase-Core'
}

{ #category : #generating }
Firebase class >> certificateFromJSONString: aString [
	| reader |
	reader := [ :string | (NeoJSONReader on: string readStream) next ].
	^ reader value: aString .
]

{ #category : #generating }
Firebase class >> createJWTFromCertificate: cert [
	| jws iat exp scopes |
	"NOTE: scapes are space-delimited"
	scopes := 'https://www.googleapis.com/auth/firebase.database https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/datastore'.	
	iat := DateAndTime now asUnixTime.
	exp := iat + (59 * 60).
	jws := JsonWebSignature new
		algorithmName: 'RS256';
		payload:
			(JWTClaimsSet new
				at: 'iss' put: (cert at: 'client_email');
				at: 'scope' put: scopes;
				at: 'aud' put: 'https://oauth2.googleapis.com/token';
				at: 'exp' put: exp;
				at: 'iat' put: iat).
	jws key: (self getNakedPrivateKey: (cert at: 'private_key')).
	^ jws compactSerialized
]

{ #category : #generating }
Firebase class >> getNakedPrivateKey: keystring [
	| key |
	key := keystring copyReplaceAll: '-----BEGIN PRIVATE KEY-----\n' with: ''.
	^  key copyReplaceAll: '\n-----END PRIVATE KEY-----\n' with: ''.
]

{ #category : #generating }
Firebase class >> new: certificateString [
	| instance |
	instance := self new.
	instance certificate: (self certificateFromJSONString: certificateString) .	
	
	^  instance 
]

{ #category : #generating }
Firebase class >> requestAccessTokenForJWT: aJWT [
	| client result |	
	(client := ZnClient new)
			url: 'https://oauth2.googleapis.com';
			addPath: 'token';
			formAt: 'grant_type' put: 'urn:ietf:params:oauth:grant-type:jwt-bearer';
			formAdd: 'assertion' -> aJWT ;
			post.
	result := NeoJSONObject fromString: client contents.		
	"Transcript show:'requestAccessTokenForJWT Full result: ',result asString;cr"
	^ result at: 'access_token'
]

{ #category : #accessing }
Firebase >> certificate [
	^ certificate
]

{ #category : #accessing }
Firebase >> certificate: anObject [
	certificate := anObject
]

{ #category : #accessing }
Firebase >> connect [
	| jwt |
	jwt := self class createJWTFromCertificate: certificate.
	^ self class requestAccessTokenForJWT: jwt
]

{ #category : #accessing }
Firebase >> connection [
	^ connection
]

{ #category : #accessing }
Firebase >> connection: anObject [
	connection := anObject
]

{ #category : #initialization }
Firebase >> initialize [
	client := ZnClient new.
]

{ #category : #accessing }
Firebase >> projectId [
	^ certificate at: #project_id
]

{ #category : #accessing }
Firebase >> secureDirectFirestoreJSONCallTo: url JSONContent: json id: id token: token [
	| jsonString mapValue newValue finalurl |
	Transcript
		show: 'secureFirestoreJSONCallTo';
		cr.
	
	mapValue := FirestoreJsonWriter toString: json.
	newValue := mapValue copyFrom: 15 to: mapValue size - 1.
	jsonString := '{' , newValue.
	finalurl := id isNil
		ifFalse: [ url , '?documentId=' , id ]
		ifTrue: [ url ].
	Transcript
		show: 'finalUrl=' , finalurl;
		cr.
	Transcript
		show: 'data=' , jsonString;
		cr.
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: finalurl;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail:
				[ :ex | UIManager default inform: 'post Network Error: ' , ex asString ];
		post.
	^ client contents
]

{ #category : #accessing }
Firebase >> secureDirectJSONCallTo: url JSONContent: json token: token [
	| jsonString |
	jsonString := STONJSON toString: json.
		Transcript show:'secureJSONCall json; ',jsonString;cr.
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | 
			| rv |
			rv := NeoJSONReader fromString: entity contents.
			rv ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			ex inspect.
			UIManager default inform: 'post Network Error: ' , ex asString ];
		post.
	^client contents 
]

{ #category : #accessing }
Firebase >> secureFirestoreCallTo: url token: token [
	| fut |
	fut := [ client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | 
			"Transcript show: 'json string in: ' , entity contents."
			FirestoreJsonReader fromString: entity contents ].
	client
		url: url;
		ifFail:
				[ :ex | UIManager default inform: 'post Network Error: ' , ex greaseString ];
		get.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureFirestoreJSONCallTo: url JSONContent: json id: id token: token [
	| fut jsonString mapValue newValue finalurl |
	Transcript show:'secureFirestoreJSONCallTo';cr.
	fut := [ 
		Transcript show:'original json=',json;cr.
		mapValue := FirestoreJsonWriter toString: json.
	newValue := mapValue copyFrom: 15 to: mapValue size - 1.
	jsonString := '{' , newValue.
	finalurl := id isNil
		ifFalse: [ url , '?documentId=' , id ]
		ifTrue: [ url ].
	Transcript
		show: 'finalUrl=' , finalurl;
		cr.
	Transcript
		show: 'data=' , jsonString;
		cr.
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: finalurl;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail:
				[ :ex | UIManager default inform: 'post Network Error: ' , ex asString ];
		post.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureFirestoreJSONCallTo: url JSONContent: json token: token [
	| fut jsonString |
	fut := [ jsonString := FirestoreJsonWriter toString: json.
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	Transcript show:'secureFirestoreCall calling .. ',jsonString;cr.
	client
		contentReader: [ :entity | 
			Transcript show:'json string in: ',entity contents.
			FirestoreJsonReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			UIManager default
				inform: 'post Network Error: ' , ex asString ];
		post.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureFirestorePatchJSONCallTo: url JSONContent: json token: token [
	| fut jsonString mapValue newValue |
	fut := [ mapValue := FirestoreJsonWriter toString: json.
	newValue := mapValue copyFrom: 15 to: mapValue size - 1.
	jsonString := '{' , newValue.	
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"	
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail:
				[ :ex | UIManager default inform: 'post Network Error: ' , ex asString ];
		patch.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONCallTo: url JSONContent: json token: token [
	| fut jsonString |
	fut := [ jsonString := STONJSON toString: json.
		Transcript show:'secureJSONCall json; ',jsonString;cr.
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | 
			| rv |
			rv := NeoJSONReader fromString: entity contents.
			rv ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			ex inspect.
			UIManager default inform: 'post Network Error: ' , ex asString ];
		post.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONCallTo: url token: token [
	| fut finalurl |
	fut := [ 
		client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	finalurl :=	url,'?access_token=',token.
	"finalurl := url."
	
	client
		url: finalurl;
		ifFail: [ :ex | 
			UIManager default
				inform: 'get Network Error: ' , ex asString ];
		get.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONCallTo: url token: token extraParams: params [
	| fut finalurl |
	fut := [ client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	finalurl := url , params , 'access_token=' , token.
	client
		url: finalurl;
		ifFail: [ :ex | 
			UIManager default
				inform: 'get Network Error: ' , ex asString ];
		get.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONDeleteCallTo: url token: token [
	| fut finalurl |
	fut := [ 
		client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	finalurl :=	url,'?access_token=',token.
	"finalurl := url."
	
	client
		url: finalurl;
		ifFail: [ :ex | 
			UIManager default
				inform: 'delete Network Error: ' , ex asString ];
		delete.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONPatchCallTo: url JSONContent: json token: token [
	| fut jsonString |
	fut := [ client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	jsonString := STONJSON toString: json.
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			Transcript show: ex asString;cr.
			UIManager default
				inform: 'Network Error: ' , ex asString ];
		patch.
	client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONPutCallTo: url JSONContent: json token: token [
	| fut jsonString |
	fut := [ client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	jsonString := STONJSON toString: json.
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			Transcript show: ex asString;cr.
			UIManager default
				inform: 'Network Error: ' , ex asString ];
		put.
	client contents ] future.
	^ fut
]
