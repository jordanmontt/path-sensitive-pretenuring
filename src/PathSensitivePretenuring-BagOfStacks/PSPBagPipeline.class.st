"
I am the bag-of-stacks pipeline. I encapsulate the three-step substitute for the legacy graph-based analysis:

	samples + strategy + (startTime, endTime)
		--> PSPStackBagBuilder     : build bags keyed by (stack, type)
		--> PSPStackBagClassifier  : classify each bag short / long / immortal
		--> PSPBagTraversalStrategy: trim each long-lived bag's chain
		--> OrderedCollection<OrderedCollection<IllMethodWithOffset>>

The collection I return is the exact shape that AllocationSitesPretenurer >> compilePretenuredPathsFrom: expects: each inner collection is a chain in deepest-sender-first order, suitable as-is for the senders-chain rewriter.

PathSensitvePretenuring delegates its analyzeAllocations to me. Tests instantiate me directly with crafted samples.
"
Class {
	#name : 'PSPBagPipeline',
	#superclass : 'Object',
	#instVars : [
		'samples',
		'strategy',
		'startTime',
		'endTime',
		'bags',
		'classifier'
	],
	#category : 'PathSensitivePretenuring-BagOfStacks-Pipeline',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Pipeline'
}

{ #category : 'api' }
PSPBagPipeline >> analyze [
	"Build bags and classify them. After this call:
	 * #bags returns all bags (including short-lived ones not pruned by the threshold);
	 * each bag has a classification of #short / #long / #immortal (or nil if pruned);
	 * #extractChains can be called to obtain the rewriter-ready chain collection."

	| builder |
	builder := PSPStackBagBuilder onSamples: samples.
	bags := builder bags.

	classifier := PSPStackBagClassifier new
		              startTime: startTime;
		              endTime: endTime;
		              setUpForBags: bags;
		              yourself.
	strategy setUpForBags: bags.
	classifier classifyByLifetime
]

{ #category : 'accessing' }
PSPBagPipeline >> bags [

	^ bags
]

{ #category : 'accessing' }
PSPBagPipeline >> classifier [

	^ classifier
]

{ #category : 'api' }
PSPBagPipeline >> extractChains [
	"Walk every long-or-immortal bag, ask the strategy to trim its full chain, drop empty
	trims. Return an OrderedCollection<OrderedCollection<IllMethodWithOffset>> ready for
	AllocationSitesPretenurer >> compilePretenuredPathsFrom:."

	| chains |
	chains := OrderedCollection new.
	bags do: [ :bag |
		bag isLongOrImmortal ifTrue: [
			| trimmed |
			trimmed := strategy trimChain: bag chain forBag: bag.
			trimmed isEmpty ifFalse: [ chains add: trimmed ] ] ].
	^ chains
]

{ #category : 'api' }
PSPBagPipeline >> samples: aCollectionOfSamples strategy: aPSPBagTraversalStrategy startTime: aStartTime endTime: anEndTime [

	samples := aCollectionOfSamples.
	strategy := aPSPBagTraversalStrategy.
	startTime := aStartTime.
	endTime := anEndTime
]

{ #category : 'accessing' }
PSPBagPipeline >> strategy [

	^ strategy
]
