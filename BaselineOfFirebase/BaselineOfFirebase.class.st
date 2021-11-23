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
		do: [ spec
				package: 'Firebase-Core'.
			spec
				baseline: 'NeoJSON'
				with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			spec
				baseline: 'TaskIt'
				with: [ spec repository: 'github://sbragagnolo/taskit' ].
			spec
				for: #'pharo8.x'
					do: [ spec
					baseline: 'JSONWebToken'
					with: [ spec repository: 'github://noha/JSONWebToken:master/source' ].
				].
			spec
				for:  #(#'pharo9.x' #'pharo10.x')
					do: [ spec
					baseline: 'JSONWebToken'
					with: [ spec repository: 'github://noha/JSONWebToken:pharo9-openssl1.1/source' ].
				]
			 ]
]
