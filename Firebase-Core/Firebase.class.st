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
	| jws iat exp |
	iat := (DateAndTime now) asUnixTime.
	exp := iat + (59 * 60).
	jws := JsonWebSignature new
		algorithmName: 'RS256';
		payload:
			(JWTClaimsSet new
				at: 'iss' put: (cert at: 'client_email');
				at: 'scope'
					put: 'https://www.googleapis.com/auth/cloud-platform';
				at: 'aud' put: 'https://oauth2.googleapis.com/token';
				at: 'exp' put: exp;
				at: 'iat' put: iat).
	jws key: ( CCConnection getNakedPrivateKey: (cert at: 'private_key')).
	^ jws compactSerialized
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
Firebase >> secureJSONCallTo: url JSONContent: json toekn: token [
	| fut |
	fut := [ 
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: json type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			UIManager default
				inform: 'Network Error: ' , ex asString;
				cr ];
		post.
	
	fut deploySuccess: client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONCallTo: url toekn: token [
	| fut |
	fut := [ 
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		ifFail: [ :ex | 
			UIManager default
				inform: 'Network Error: ' , ex asString;
				cr ];
		get.
	
	fut deploySuccess: client contents ] future.
	^ fut
]

{ #category : #accessing }
Firebase >> secureJSONPutCallTo: url JSONContent: json toekn: token [
	| fut |
	fut := [ 
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: json type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			UIManager default
				inform: 'Network Error: ' , ex asString;
				cr ];
		put.
	
	fut deploySuccess: client contents ] future.
	^ fut
]
