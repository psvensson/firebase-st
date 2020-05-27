"
From https://firebase.google.com/docs/firestore/reference/rest/v1beta1/Value
-----------------------------------------------------------------------------
{

  // Union field value_type can be only one of the following:
  ""nullValue"": null,
  ""booleanValue"": boolean,
  ""integerValue"": string,
  ""doubleValue"": number,
  ""timestampValue"": string,
  ""stringValue"": string,
  ""bytesValue"": string,
  ""referenceValue"": string,
  ""geoPointValue"": {
    object(LatLng)
  },
  ""arrayValue"": {
    object(ArrayValue)
  },
  ""mapValue"": {
    object(MapValue)
  }
  // End of list of possible types for union field value_type.
}
"
Class {
	#name : #FirestoreJsonWriter,
	#superclass : #NeoJSONWriter,
	#category : #'Firebase-Core'
}

{ #category : #writing }
FirestoreJsonWriter >> encodeKey: key value: value [
	writeStream nextPutAll: '"',key,'"'.
	writeStream nextPutAll: ': '.
	self nextPut: value
]

{ #category : #writing }
FirestoreJsonWriter >> initialize [ 
	super initialize.
]

{ #category : #writing }
FirestoreJsonWriter >> writeBoolean: boolean [
	writeStream nextPutAll: '{"booleanValue": '.
	boolean printOn: writeStream.
	writeStream nextPut: $}
]

{ #category : #writing }
FirestoreJsonWriter >> writeFloat: float [
	writeStream nextPutAll: '{"doubleValue": '.
	float printOn: writeStream.
	writeStream nextPut: $}
]

{ #category : #writing }
FirestoreJsonWriter >> writeInteger: int [
	writeStream nextPutAll: '{"integerValue": '.
	int printOn: writeStream.
	writeStream nextPut: $}
]

{ #category : #writing }
FirestoreJsonWriter >> writeList: collection [
	writeStream nextPutAll: '{"arrayValue": {"values": '.
	self writeListStreamingDo: [ :jsonListWriter |
		collection do: [ :each |
			jsonListWriter writeElement: each ] ].
	writeStream nextPutAll: '}}'
]

{ #category : #writing }
FirestoreJsonWriter >> writeMap: keyValueCollection [
	writeStream nextPutAll: '{"mapValue": {"fields": '.
	self writeMapStreamingDo: [ :jsonMapWriter |
		keyValueCollection keysAndValuesDo: [ :key :value |
			jsonMapWriter writeKey: key value: value ] ].
	writeStream nextPutAll: '}}'
]

{ #category : #writing }
FirestoreJsonWriter >> writeNull [
	writeStream nextPutAll: '{"nullValue": null}'
	
]

{ #category : #writing }
FirestoreJsonWriter >> writeString: string [
	writeStream nextPutAll: '{"stringValue": "'.
	1 to: string size do: [ :index |
		self encodeChar: (string at: index) ].
	writeStream nextPutAll: '"}'
	
]
