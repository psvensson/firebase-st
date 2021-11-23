Class {
	#name : #BaselineOfFirebase,
	#superclass : #BaselineOf,
	#category : #BaselineOfFirebase
}

{ #category : #baselines }
BaselineOfFirebase >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				baseline: 'NeoJSON'
				with: [ spec repository: 'github://svenvc/NeoJSON:master/repository' ].
			spec
				package: 'Firebase-Core'
				with: [ spec requires: #('NeoJSON') ].
			spec
				baseline: 'TaskIt'
				with: [ spec repository: 'github://sbragagnolo/taskit' ].
			spec
				for: #'pharo8.x'
					do: [
						Transcript show:'* Installing 8.x baseline firebase-st';cr. 
						spec
					baseline: 'JSONWebToken'
					with: [ spec repository: 'github://noha/JSONWebToken:master/source' ].
				].
			spec
				for:  #(#'pharo9.x' #'pharo10.x')
					do: [
						Transcript show:'* Installing 9/10.x baseline firebase-st';cr.  
						spec
					baseline: 'JSONWebToken'
					with: [ spec repository: 'github://noha/JSONWebToken:pharo9-openssl1.1/source' ].
				]
			 ]
]
