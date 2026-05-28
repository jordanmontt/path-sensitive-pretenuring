"
I am the abstract base class for chain-trimming strategies in the bag-of-stacks pretenuring pipeline.

A PSPStackBag's `chain` method produces the full IllMethodWithOffset chain from the captured call stack (deepest sender first, entry point last, leaf-frame offset dropped). My job is to trim that full chain down to the prefix that should be pretenured.

In the legacy graph pipeline, the equivalent decision was made implicitly by the DFS stopping rule in AbstractPretenuringStrategy>>isAllocationSite:fromAllocationPath:. Here it is explicit: subclasses implement #trimChain:forBag: and return a trimmed OrderedCollection (deepest first, same orientation as the input). An empty return value means 'do not pretenure this bag under this strategy'.

Two graph-era guarantees are now automatic in the bag world and therefore not re-checked here:
 * hasOnlyLongLivedEdges - trimmers are only ever called on bags whose classification isLongOrImmortal, by PSPBagPipeline.
 * edgesHaveSameAllocatedObjectTypes - a bag is keyed on (stack, type) so all its samples share one type.
"
Class {
	#name : 'PSPBagTraversalStrategy',
	#superclass : 'Object',
	#category : 'PathSensitivePretenuring-BagOfStacks-Strategies',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Strategies'
}

{ #category : 'api' }
PSPBagTraversalStrategy >> setUpForBags: aCollectionOfBags [
	"Hook for strategies that need to inspect all bags before trimming (e.g. to derive
	a list of application packages). Default: do nothing."


]

{ #category : 'api' }
PSPBagTraversalStrategy >> trimChain: aFullChain forBag: aPSPStackBag [
	"Subclasses return an OrderedCollection<IllMethodWithOffset> obtained by slicing
	aFullChain, keeping its deepest-first order. An empty result means 'skip this bag'."

	^ self subclassResponsibility
]
