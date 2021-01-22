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
				baseline: 'JSONWebToken'
				with: [ spec repository: 'github://noha/JSONWebToken/source' ].
			spec
				baseline: 'TaskIt'
				with: [ spec repository: 'github://sbragagnolo/taskit' ].
			 ]
]
