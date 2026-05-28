"
I am one bag of allocation samples in the bag-of-stacks pipeline.

My identity is the pair (sendersCallStack, allocatedType): every FiLiPEphemeron whose full call stack and allocated type match mine accumulates in my #samples collection. Two bags with different prefixes never merge - this is the central property that distinguishes the bag-of-stacks pipeline from the previous graph-based one.

I am also the unit of classification: the Pretenuring Advice algorithm bins my samples into #immortalObjects / #shortLivedObjects / #longLivedObjects and then tags me #immortal / #short / #long via #beImmortal / #beShortLived / #beLongLived. After classification, the strategy reads my #chain to obtain the IllMethodWithOffset sequence that the rewriter consumes.
"
Class {
	#name : 'AllocationSiteBin',
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
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'instance creation' }
AllocationSiteBin class >> forStack: anIllSendersCallStack type: aClass [

	^ self new
		  sendersCallStack: anIllSendersCallStack;
		  allocatedType: aClass;
		  yourself
]

{ #category : 'comparing' }
AllocationSiteBin >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ sendersCallStack = anObject sendersCallStack
		and: [ allocatedType = anObject allocatedType ]
]

{ #category : 'api' }
AllocationSiteBin >> addImmortalObject: object [

	immortalObjects add: object
]

{ #category : 'api' }
AllocationSiteBin >> addSample: aFiLiPEphemeron [

	samples add: aFiLiPEphemeron
]

{ #category : 'api' }
AllocationSiteBin >> addLongLivedObject: object [

	longLivedObjects add: object
]

{ #category : 'api' }
AllocationSiteBin >> addShortLivedObject: object [

	shortLivedObjects add: object
]

{ #category : 'accessing' }
AllocationSiteBin >> allObjects [

	^ self longAndImmortalLivedObjects , self shortLivedObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> allocatedSamples [
	"Polymorphic with AllocationGraphEdge >> allocatedSamples so the classifier
	can read samples uniformly."

	^ samples
]

{ #category : 'accessing' }
AllocationSiteBin >> allocatedType [

	^ allocatedType
]

{ #category : 'accessing' }
AllocationSiteBin >> allocatedType: aClass [

	allocatedType := aClass
]

{ #category : 'api - classification' }
AllocationSiteBin >> beImmortal [
	"Pharo VM has two generations; immortals are pretenured like long-lived.
	The tag is still stored so reports can distinguish them."

	classification := #immortal
]

{ #category : 'api - classification' }
AllocationSiteBin >> beLongLived [

	classification := #long
]

{ #category : 'api - classification' }
AllocationSiteBin >> beShortLived [

	classification := #short
]

{ #category : 'api' }
AllocationSiteBin >> chain [
	"The chain of (method, bytecode-offset) pairs that the senders-chain rewriter
	consumes. The deepest frame's offset is dropped: under the same convention used
	by the legacy graph extraction, an edge offset is the offset within the caller of
	the call to the next-deeper frame. So given a stack [m1, off1, m2, off2, ..., mN, offN]
	with m1 the deepest, the chain is [(m2, off2), ..., (mN, offN)], deepest sender first."

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
AllocationSiteBin >> classification [

	^ classification
]

{ #category : 'accessing' }
AllocationSiteBin >> classification: obj [

	classification := obj
]

{ #category : 'testing' }
AllocationSiteBin >> containsClass: anObjClass [

	| block |
	block := [ :e | e allocatedObjectClass = anObjClass ].
	^ (longLivedObjects contains: block) or: [
		  (immortalObjects contains: block) or: [
			  shortLivedObjects contains: block ] ]
]

{ #category : 'comparing' }
AllocationSiteBin >> hash [

	^ sendersCallStack hash bitXor: allocatedType hash
]

{ #category : 'accessing' }
AllocationSiteBin >> immortalObjects [

	^ immortalObjects
]

{ #category : 'initialization' }
AllocationSiteBin >> initialize [

	super initialize.
	samples := OrderedCollection new.
	immortalObjects := OrderedCollection new.
	longLivedObjects := OrderedCollection new.
	shortLivedObjects := OrderedCollection new
]

{ #category : 'testing' }
AllocationSiteBin >> isAmbiguous [

	^ shortLivedObjects notEmpty and: [ longLivedObjects notEmpty or: [ immortalObjects notEmpty ] ]
]

{ #category : 'testing' }
AllocationSiteBin >> isImmortal [

	^ classification = #immortal
]

{ #category : 'testing' }
AllocationSiteBin >> isLong [

	^ classification = #long
]

{ #category : 'testing' }
AllocationSiteBin >> isLongOrImmortal [

	^ self isLong or: [ self isImmortal ]
]

{ #category : 'testing' }
AllocationSiteBin >> isShort [

	^ classification = #short
]

{ #category : 'accessing' }
AllocationSiteBin >> longAndImmortalLivedObjects [

	^ self longLivedObjects , self immortalObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> longLivedObjects [

	^ longLivedObjects
]

{ #category : 'printing' }
AllocationSiteBin >> printOn: aStream [

	| text |
	text := classification ifNil: [ '-' ].
	aStream << text << ' bin '
]

{ #category : 'accessing' }
AllocationSiteBin >> samples [

	^ samples
]

{ #category : 'accessing' }
AllocationSiteBin >> sendersCallStack [

	^ sendersCallStack
]

{ #category : 'accessing' }
AllocationSiteBin >> sendersCallStack: anIllSendersCallStack [

	sendersCallStack := anIllSendersCallStack
]

{ #category : 'accessing' }
AllocationSiteBin >> shortLivedObjects [

	^ shortLivedObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> textualAllocatorMethod [
	"All samples in a bag share their call stack, so they share their textual
	allocator (the first instance-side method that called new / basicNew, as
	captured by FiLiP). Reading it from any sample is therefore safe."

	samples isEmpty ifTrue: [ ^ nil ].
	^ samples first textualAllocatorMethod
]

{ #category : 'accessing' }
AllocationSiteBin >> totalAllocations [

	^ immortalObjects size + longLivedObjects size + shortLivedObjects size
]
