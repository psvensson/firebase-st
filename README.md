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

getPath: path, deletePath: path, get: path query: query, putPaht: path obj: obj, pushPath: path obj: obj, patchPath: path obj: obj.

putPath adds new object to a path, pushPath pushes a new member of an array or an object of an existing path, pachPath replaces an existing path's proeprties with those proivded in the obj.
