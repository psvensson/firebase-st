# firebase-st
A simple Smalltalk layer on top of the Google Firebase REST API, since no working gRPC/Protobuf libraries exists yet for Smalltalk.

# Installation

```Smalltalk
Metacello new
    repository: 'github://psvensson/firebase-st:master';
    baseline: 'Firebase';
    load
```

# Usage

You need to generate a service account credential file in JSON format, which can be done either from the Firebase project settings page or from the Google Cloud console; https://cloud.google.com/iam/docs/creating-managing-service-account-keys

```Smalltalk
certificateString := 'opencobalt-firebase-adminsdk.json' asFileReference readStream contents.

"push put and patch uses dictionaries as objects"
obj := Dictionary new.
obj at: #abc put: 'foobar'

"queries are also objects, and which keys can be any of; startAt endAt limitToFirst limitToLast equalTo orderBy)"
query := Dictionary new.
query at: #orderBy put: '"$key"'.

firebase := Firebase new: certificateString .
rtdb := FirebaseRtdb new: firebase.
(rtdb putPath: '/foo/bar' obj: obj ) onSuccessDo: [ :res | Transcript show:'put result=',res asString;cr ].
(rtdb get: '/foo' query: query ) onSuccessDo: [ :res | Transcript show:'put result=',res asString;cr ].
```

# Methods for rtdb

Rtdb is the original firestore real-time database. All data for a project resides in one large JSON structure, so be careful what you get or query, as you might get back quite a lot of data. Queries can only be made at one property at a time, which limits the use a bit.

* getPath: path "get data under path"
* deletePath: path "delete data from path"
* get: path "get data at path but not under"
* query: query "see example above"
* putPath: path obj: obj "add data under path"
* pushPath: path obj: obj "add data to array on object path"
* patchPath: path obj: obj "update data on path"

putPath adds new object to a path, pushPath pushes a new member of an array or an object of an existing path, pachPath replaces an existing path's proeprties with those proivded in the obj.

# Firestore Usage

Firestore is the new firebase datastore with a more traditional noSQL way of organizing data. You create collections (tables) where you store documents (which can contain sub-collections). You can query on multiple properties and if an index needs to be created for the query, you will get a handy url back in an error message telling where to go to add one.

```Smalltalk
|certificateString firebase firestore data data2 data3 query res|
data := Dictionary new.
data at: 'hej' put: 'svejs2'.
data at: 'foo' put: #(a b c).
data2 := Dictionary new.
data2 at: #x put: #y.
data3 := Dictionary new.
data3 at: #deep put: #stuff.
data at: #z put: data3.
certificateString := 'service_account.json' asFileReference readStream contents.

firebase := Firebase new: certificateString .
firestore := Firestore new: firebase.

res := firestore create: 'bar' id: 'whoop2' document: data.
res onSuccessDo: [ :s | Transcript show:'Success: ',s asString;cr ].
res onFailureDo: [ :e | Transcript show:'Failure: ',e asString;cr ].
res
```

The above code in a playground will create a new collection named 'bar' (if it doesn't exist already) and adds a nontrivial JSON document with id 'whoop2'.

```Smalltalk
|certificateString firebase firestore data query res|
certificateString := 'service_account.json' asFileReference readStream contents.

firebase := Firebase new: certificateString .
firestore := Firestore new: firebase.

query := Dictionary new.
query 
	at: #from put: #bar
	;at: #select put: #(hej)	
	;at: #where put: #('hej.EQUAL.svejs')
	;at: #direction put: 'ASCENDING'.

res := firestore runQuery: query.
res onSuccessDo: [ :s | Transcript show:'Success: ',s asString;cr. ].
res onFailureDo: [ :e | Transcript show:'Failure: ',e asString;cr ].
res
```

This is a complex query with one 'where' clause which also filte rout just the proeprties you want to seee using 'select'.
A list of possible where operators can be found here; https://firebase.google.com/docs/firestore/reference/rest/v1beta1/StructuredQuery#FieldFilter

```Smalltalk
query := Dictionary new.
query 
	at: #from put: #bar
	;at: #offset put: 3	
	;at: #direction put: 'ASCENDING'.

res := firestore runQuery: query.
res onSuccessDo: [ :s | Transcript show:'Success: ',s asString;cr. s inspect].
res onFailureDo: [ :e | Transcript show:'Failure: ',e asString;cr ].
res
```

And the above is a simple query which uses offset, to enable a simple form of pagination.

# Methods for Firestore

* list: path pageSize: pageSize pageToken: pageToken orderBy: orderBy  "All can be nil except for 'path'"
* create: path id:id document: document "path is the colelction name and id (if not nil) is the desired id. If nil, an id will be generated"
* get: path "Get the document on the path, like 'bar/whoop2'"
* patch: path document: document "Update an existing document"
* runQuery: query "Query properties can be any of from, select, where, direction, limit, offset and orderBy






