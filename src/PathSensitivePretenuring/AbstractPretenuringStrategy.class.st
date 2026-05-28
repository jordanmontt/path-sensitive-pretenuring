"
I am the abstract base for chain-trimming strategies in the bag-of-stacks pipeline.

After the classifier tags every AllocationSiteBin as #short / #long / #immortal, I drive the chain extraction step: for every long-or-immortal bag, my subclasses decide how much of the bag's full call chain to feed to the rewriter. The bag's #chain method produces the full IllMethodWithOffset sequence (deepest sender first); subclasses implement #trimChain:forBag: to slice it down to the prefix they want pretenured. An empty trim means 'skip this bag'.

Two graph-era guarantees are now automatic in the bag world and therefore not re-checked here:
 * 'only long-lived edges' - I am only invoked on bags whose classification is long-or-immortal;
 * 'same allocated type along the path' - a bag is keyed on (stack, type) so all its samples share one type.
"
Class {
	#name : 'AbstractPretenuringStrategy',
	#superclass : 'Object',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'api' }
AbstractPretenuringStrategy >> extractLongLivedSendersChains: aCollectionOfBags [

	| sendersToPretenure |
	sendersToPretenure := OrderedCollection new.
	aCollectionOfBags do: [ :bag |
		bag isLongOrImmortal ifTrue: [
			| trimmed |
			trimmed := self trimAllocationPath: bag path forBag: bag.
			trimmed isEmpty ifFalse: [ sendersToPretenure add: trimmed ] ] ].
	^ sendersToPretenure
]

{ #category : 'instance creation' }
AbstractPretenuringStrategy >> newClassificationAlgorithm [

	^ MerlinPretenuringAdviceAlgorithm new
]

{ #category : 'api' }
AbstractPretenuringStrategy >> setUpForBags: aCollectionOfBags [

	
]

{ #category : 'api' }
AbstractPretenuringStrategy >> trimAllocationPath: allocationPath forBag: aBag [
	"Return an OrderedCollection<IllMethodWithOffset> or empty collection"

	^ self subclassResponsibility
]
