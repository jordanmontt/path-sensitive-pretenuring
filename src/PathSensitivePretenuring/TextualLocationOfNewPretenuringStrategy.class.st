Class {
	#name : 'TextualLocationOfNewPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> trimChain: aFullChain forBag: aBag [
	"Walk the chain from the deepest sender upward; keep the prefix up to and including
	the first frame whose method is the bag's textualAllocatorMethod (the first
	instance-side method that called new / basicNew, as captured by FiLiP). This is the
	shortest chain that still ends at the textual allocator. If the textual allocator is
	not found in the chain (truncated stack at FiLiP's depth cap), return empty."

	| target index |
	aFullChain isEmpty ifTrue: [ ^ OrderedCollection new ].
	target := aBag textualAllocatorMethod.
	target ifNil: [ ^ OrderedCollection new ].
	index := aFullChain findFirst: [ :each | each method = target ].
	index = 0 ifTrue: [ ^ OrderedCollection new ].
	^ (aFullChain first: index) asOrderedCollection
]
