Class {
	#name : 'MockedEphemeron',
	#superclass : 'Object',
	#instVars : [
		'initializationTime',
		'finalizationTime',
		'sizeInBytes',
		'key',
		'allocatedObjectClass',
		'sendersCallStack',
		'textualAllocatorMethod'
	],
	#category : 'PathSensitivePretenuring-Tests',
	#package : 'PathSensitivePretenuring-Tests'
}

{ #category : 'accessing' }
MockedEphemeron >> allocatedObjectClass [
	"Defaults to Object so unconfigured mocks land in a single AllocationSiteBin under
	the new bag-of-stacks classifier. Tests that need to vary the type pass one in."

	^ allocatedObjectClass ifNil: [ Object ]
]

{ #category : 'accessing' }
MockedEphemeron >> allocatedObjectClass: aClass [

	allocatedObjectClass := aClass
]

{ #category : 'accessing' }
MockedEphemeron >> finalizationTime [

    ^ finalizationTime
]

{ #category : 'accessing' }
MockedEphemeron >> lifetime [

	^ finalizationTime - initializationTime
]

{ #category : 'accessing' }
MockedEphemeron >> sendersCallStack [
	"Defaults to a one-frame synthetic stack so unconfigured mocks have a valid stack
	under the new bag-of-stacks classifier. Tests that need distinct contexts pass one in."

	^ sendersCallStack ifNil: [
		  IllSendersCallStack senders: { Object >> #yourself. 0 } ]
]

{ #category : 'accessing' }
MockedEphemeron >> sendersCallStack: anIllSendersCallStack [

	sendersCallStack := anIllSendersCallStack
]

{ #category : 'accessing' }
MockedEphemeron >> textualAllocatorMethod [
	"Polymorphic with FiLiPEphemeron. Defaults to the method used in the default mock stack."

	^ textualAllocatorMethod ifNil: [ Object >> #yourself ]
]

{ #category : 'accessing' }
MockedEphemeron >> textualAllocatorMethod: aCompiledMethod [

	textualAllocatorMethod := aCompiledMethod
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
