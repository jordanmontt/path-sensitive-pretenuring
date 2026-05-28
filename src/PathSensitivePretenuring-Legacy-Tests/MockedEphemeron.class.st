Class {
	#name : 'MockedEphemeron',
	#superclass : 'Object',
	#instVars : [
		'initializationTime',
		'finalizationTime',
		'sizeInBytes',
		'key'
	],
	#category : 'PathSensitivePretenuring-Legacy-Tests',
	#package : 'PathSensitivePretenuring-Legacy-Tests'
}

{ #category : 'accessing' }
MockedEphemeron >> finalizationTime [

    ^ finalizationTime
]

{ #category : 'accessing' }
MockedEphemeron >> finalizationTime: anInteger [

    finalizationTime := anInteger
]

{ #category : 'accessing' }
MockedEphemeron >> initializationTime [

    ^ initializationTime
]

{ #category : 'accessing' }
MockedEphemeron >> initializationTime: anInteger [

    initializationTime := anInteger
]

{ #category : 'accessing' }
MockedEphemeron >> key: aKey [

    key := aKey
]

{ #category : 'accessing' }
MockedEphemeron >> sizeInBytes [

    ^ sizeInBytes
]

{ #category : 'accessing' }
MockedEphemeron >> sizeInBytes: anInteger [

    sizeInBytes := anInteger
]
