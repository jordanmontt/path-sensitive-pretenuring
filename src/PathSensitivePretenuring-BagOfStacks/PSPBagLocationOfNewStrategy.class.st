"
I implement the Location-of-`new` policy from the path-sensitive pretenuring thesis, restated as a chain-trimmer over a PSPStackBag.

In the legacy graph pipeline this was TextualLocationOfNewPretenuringStrategy: starting from the leaf, walk up the call graph until you hit the textual allocator method (the first instance-side method that called new / basicNew, as captured by FiLiP) and stop there.

In the bag world, the bag's chain already starts at the deepest sender (the metaclass-side helper just above the trapped primitive: typically a `basicNew` or `new` on the metaclass). I trim the chain to the prefix from there up to and including the first frame whose method equals the bag's textualAllocatorMethod. That prefix corresponds to:

	[ metaclass-side helpers..., textualAllocatorMethod ]

i.e., the shortest chain that ends at the textual allocator. The rewriter will then clone every frame in that prefix except the last and patch the call site at the last frame.

If the bag's stack was truncated before the textual allocator could be observed (rare; only happens at the depth cap), I return an empty chain so the bag is skipped.
"
Class {
	#name : 'PSPBagLocationOfNewStrategy',
	#superclass : 'PSPBagTraversalStrategy',
	#category : 'PathSensitivePretenuring-BagOfStacks-Strategies',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Strategies'
}

{ #category : 'api' }
PSPBagLocationOfNewStrategy >> trimChain: aFullChain forBag: aPSPStackBag [

	| target index |
	aFullChain isEmpty ifTrue: [ ^ OrderedCollection new ].
	target := aPSPStackBag textualAllocatorMethod.
	target ifNil: [ ^ OrderedCollection new ].

	index := aFullChain findFirst: [ :each | each method = target ].
	index = 0 ifTrue: [ ^ OrderedCollection new ].

	^ (aFullChain first: index) asOrderedCollection
]
