Class {
	#name : 'TextualLocationOfNewPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> trimAllocationPath: allocationPath forBag: aBag [

	| textualAllocatorMethod index |
	allocationPath isEmpty ifTrue: [ ^ OrderedCollection new ].

	textualAllocatorMethod := aBag textualAllocatorMethod.
	index := allocationPath findFirst: [ :each | each method = textualAllocatorMethod ].

	index = 0 ifTrue: [ ^ OrderedCollection new ].
	^ (allocationPath first: index) asOrderedCollection
]
