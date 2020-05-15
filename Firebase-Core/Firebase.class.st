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
	scopes := 'https://www.googleapis.com/auth/firebase.database https://www.googleapis.com/auth/userinfo.email'.
	"Transcript
		show: 'scopes; ' , scopes asString;
		cr."
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
	jws key: (CCConnection getNakedPrivateKey: (cert at: 'private_key')).
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
Firebase >> secureJSONCallTo: url JSONContent: json token: token [
	| fut jsonString |
	fut := [ jsonString := STONJSON toString: json.
	client headerAt: 'Authorization' put: 'Bearer ' , token.
	client headerAt: 'Accept' put: '*/*'.
	"headerAt: 'Content-Type' put: 'application/json';"
	client
		contentReader: [ :entity | NeoJSONReader fromString: entity contents ].
	"request setBearerAuthentication: token;"
	client
		url: url;
		entity: (ZnEntity with: jsonString type: ZnMimeType applicationJson);
		ifFail: [ :ex | 
			UIManager default
				inform: 'post Network Error: ' , ex asString;
				cr ];
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
				inform: 'get Network Error: ' , ex asString;
				cr ];
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
				inform: 'delete Network Error: ' , ex asString;
				cr ];
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
				inform: 'Network Error: ' , ex asString;
				cr ];
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
				inform: 'Network Error: ' , ex asString;
				cr ];
		put.
	client contents ] future.
	^ fut
]
