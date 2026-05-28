"
I am one bag in the bag-of-stacks pretenuring pipeline.

I represent the multiset of object allocations that share the same calling context AND the same allocated type. My identity is the pair (sendersCallStack, allocatedType), where the call stack is the full IllSendersCallStack captured by FiLiP at the allocation point.

I am the unit of:
 * accumulation - I hold every FiLiPEphemeron whose stack and type match mine,
 * classification - the bag classifier bins my samples into short/long/immortal and sets my classification,
 * chain extraction - I expose my call stack as an OrderedCollection of IllMethodWithOffset, in the order the senders-chain rewriter expects (deepest sender first, entry point last).

I never merge with bags that share only a suffix of my stack. That is the central distinction between the bag-of-stacks pipeline and the graph-based pipeline kept in the -Legacy package.
"
Class {
	#name : 'PSPStackBag',
	#superclass : 'Object',
	#instVars : [
		'sendersCallStack',
		'allocatedType',
		'samples',
		'immortalObjects',
		'longLivedObjects',
		'shortLivedObjects',
		'classification'
	],
	#category : 'PathSensitivePretenuring-BagOfStacks-Bag',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Bag'
}

{ #category : 'instance creation' }
PSPStackBag class >> forStack: anIllSendersCallStack type: aClass [

	^ self new
		  sendersCallStack: anIllSendersCallStack;
		  allocatedType: aClass;
		  yourself
]

{ #category : 'comparing' }
PSPStackBag >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ sendersCallStack = anObject sendersCallStack
		and: [ allocatedType = anObject allocatedType ]
]

{ #category : 'api' }
PSPStackBag >> addSample: aFiLiPEphemeron [

	samples add: aFiLiPEphemeron
]

{ #category : 'accessing' }
PSPStackBag >> allocatedSamples [
	"Polymorphic with AllocationGraphEdge >> allocatedSamples so the classifier can
	read samples uniformly. Kept for parity with the legacy classifier shape."

	^ samples
]

{ #category : 'accessing' }
PSPStackBag >> allocatedType [

	^ allocatedType
]

{ #category : 'accessing' }
PSPStackBag >> allocatedType: aClass [

	allocatedType := aClass
]

{ #category : 'api - classification' }
PSPStackBag >> beImmortal [
	"Pharo VM has two generations, so immortals are pretenured like long-lived.
	The tag is still stored so reports can distinguish them."

	classification := #immortal
]

{ #category : 'api - classification' }
PSPStackBag >> beLongLived [

	classification := #long
]

{ #category : 'api - classification' }
PSPStackBag >> beShortLived [

	classification := #short
]

{ #category : 'api - binning' }
PSPStackBag >> addImmortalObject: aFiLiPEphemeron [

	immortalObjects add: aFiLiPEphemeron
]

{ #category : 'api - binning' }
PSPStackBag >> addLongLivedObject: aFiLiPEphemeron [

	longLivedObjects add: aFiLiPEphemeron
]

{ #category : 'api - binning' }
PSPStackBag >> addShortLivedObject: aFiLiPEphemeron [

	shortLivedObjects add: aFiLiPEphemeron
]

{ #category : 'api' }
PSPStackBag >> chain [
	"The chain of (method, bytecode-offset) pairs that the senders-chain rewriter consumes.

	A FiLiPEphemeron's senders call stack is stored as a flat array
	[m1, off1, m2, off2, ..., mN, offN], with m1 the deepest frame (the textual
	allocator). Following the same convention as AllocationGraph >> accumulateSample:
	and AbstractPretenuringStrategy >> extractLongLivedSendersChains:, each edge in
	the chain is (caller-method, bytecode-offset-of-call-to-callee). The offset paired
	with the deepest frame (off1) is unused for edges. Therefore the chain is:

		[(m2, off2), (m3, off3), ..., (mN, offN)]

	with the deepest frame first and the entry point last, exactly the order
	AllocationSitesPretenurer expects."

	| chain isFirst |
	chain := OrderedCollection new.
	isFirst := true.
	sendersCallStack methodWithOffsetDo: [ :method :offset |
		isFirst
			ifTrue: [ isFirst := false ]
			ifFalse: [
				chain add: (IllMethodWithOffset method: method offset: offset) ] ].
	^ chain
]

{ #category : 'accessing' }
PSPStackBag >> classification [

	^ classification
]

{ #category : 'comparing' }
PSPStackBag >> hash [

	^ sendersCallStack hash bitXor: allocatedType hash
]

{ #category : 'accessing' }
PSPStackBag >> immortalObjects [

	^ immortalObjects
]

{ #category : 'initialization' }
PSPStackBag >> initialize [

	super initialize.
	samples := OrderedCollection new.
	immortalObjects := OrderedCollection new.
	longLivedObjects := OrderedCollection new.
	shortLivedObjects := OrderedCollection new
]

{ #category : 'testing' }
PSPStackBag >> isLongOrImmortal [

	^ classification = #long or: [ classification = #immortal ]
]

{ #category : 'testing' }
PSPStackBag >> isShortLived [

	^ classification = #short
]

{ #category : 'accessing' }
PSPStackBag >> longLivedObjects [

	^ longLivedObjects
]

{ #category : 'printing' }
PSPStackBag >> printOn: aStream [

	aStream
		nextPutAll: 'PSPStackBag(';
		print: allocatedType;
		nextPutAll: ', ';
		print: samples size;
		nextPutAll: ' samples';
		nextPutAll: (classification ifNil: [ '' ] ifNotNil: [ ', ' , classification ]);
		nextPutAll: ')'
]

{ #category : 'accessing' }
PSPStackBag >> samples [

	^ samples
]

{ #category : 'accessing' }
PSPStackBag >> sendersCallStack [

	^ sendersCallStack
]

{ #category : 'accessing' }
PSPStackBag >> sendersCallStack: anIllSendersCallStack [

	sendersCallStack := anIllSendersCallStack
]

{ #category : 'accessing' }
PSPStackBag >> shortLivedObjects [

	^ shortLivedObjects
]

{ #category : 'accessing' }
PSPStackBag >> textualAllocatorMethod [
	"All samples in a bag share the same call stack, so they share the same textual
	allocator method (the first instance-side method that called new / basicNew, as
	captured by FiLiP). Reading it from any sample is therefore safe."

	samples isEmpty ifTrue: [ ^ nil ].
	^ samples first textualAllocatorMethod
]
