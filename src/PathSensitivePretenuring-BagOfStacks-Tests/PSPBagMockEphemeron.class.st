"
A test-only stand-in for FiLiPEphemeron. Carries exactly the fields the bag-of-stacks pipeline reads (allocatedObjectClass, sizeInBytes, initializationTime, finalizationTime, textualAllocatorMethod, offset, sendersCallStack), and nothing else.

Built with #stack:type:initializationTime:finalizationTime:sizeInBytes:textualAllocatorMethod:offset: so test cases stay self-contained.
"
Class {
	#name : 'PSPBagMockEphemeron',
	#superclass : 'Object',
	#instVars : [
		'allocatedObjectClass',
		'sizeInBytes',
		'initializationTime',
		'finalizationTime',
		'sendersCallStack',
		'textualAllocatorMethod',
		'offset'
	],
	#category : 'PathSensitivePretenuring-BagOfStacks-Tests',
	#package : 'PathSensitivePretenuring-BagOfStacks-Tests'
}

{ #category : 'accessing' }
PSPBagMockEphemeron >> allocatedObjectClass [

	^ allocatedObjectClass
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> allocatedObjectClass: aClass [

	allocatedObjectClass := aClass
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> finalizationTime [

	^ finalizationTime
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> finalizationTime: anInteger [

	finalizationTime := anInteger
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> initializationTime [

	^ initializationTime
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> initializationTime: anInteger [

	initializationTime := anInteger
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> lifetime [

	^ finalizationTime - initializationTime
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> offset [

	^ offset
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> offset: anInteger [

	offset := anInteger
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> sendersCallStack [

	^ sendersCallStack
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> sendersCallStack: anIllSendersCallStack [

	sendersCallStack := anIllSendersCallStack
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> sizeInBytes [

	^ sizeInBytes
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> sizeInBytes: anInteger [

	sizeInBytes := anInteger
]

{ #category : 'instance creation' }
PSPBagMockEphemeron >> stack: aFlatArray type: aClass initializationTime: aBirthTime finalizationTime: aDeathTime sizeInBytes: aSize textualAllocatorMethod: anAllocatorMethod offset: anOffset [

	sendersCallStack := IllSendersCallStack senders: aFlatArray.
	allocatedObjectClass := aClass.
	initializationTime := aBirthTime.
	finalizationTime := aDeathTime.
	sizeInBytes := aSize.
	textualAllocatorMethod := anAllocatorMethod.
	offset := anOffset
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> textualAllocatorMethod [

	^ textualAllocatorMethod
]

{ #category : 'accessing' }
PSPBagMockEphemeron >> textualAllocatorMethod: aMethod [

	textualAllocatorMethod := aMethod
]
