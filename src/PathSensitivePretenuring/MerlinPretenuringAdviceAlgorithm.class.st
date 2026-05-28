"
Allocation sites classification algorithm. Paper: https://www.steveblackburn.org/pubs/papers/pbp-toplas-2007.pdf

The algorithm works as follows:

1. Setup. It receives the collection of FiLiPEphemeron samples as input. It groups them into AllocationSiteBin instances keyed by (sendersCallStack, allocatedType): one bag per unique calling context + type. Two samples whose stacks differ never merge.
2. Pruning. Bags whose own sample count falls below 0.000002 x totalProgramAllocations are dropped.
3. Classification. Each remaining bag has its samples binned (immortal / short-lived / long-lived) and the bag is tagged accordingly via #beImmortal / #beLongLived / #beShortLived.
4. (Optional) Return the bags classified as long or immortal.
"
Class {
	#name : 'MerlinPretenuringAdviceAlgorithm',
	#superclass : 'Object',
	#instVars : [
		'maxLiveSize',
		'groupedAllocationSites',
		'startTime',
		'endTime',
		'taThreshold',
		'hif',
		'hlf'
	],
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'private' }
MerlinPretenuringAdviceAlgorithm >> allSamples [

	^ groupedAllocationSites keys flatCollect: #samples
]

{ #category : 'initialization' }
MerlinPretenuringAdviceAlgorithm >> ambiguityThreshold: aNumber [


]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> binObjects [

	groupedAllocationSites keysDo: [ :bag |
		bag allocatedSamples do: [ :illEphe |
			| isObjectClassified |
			isObjectClassified := false.
			(self isObjectImmortal: illEphe) ifTrue: [
					bag addImmortalObject: illEphe.
					isObjectClassified := true ].
			(isObjectClassified not and: [ self isObjectShortLived: illEphe ]) ifTrue: [
					bag addShortLivedObject: illEphe.
					isObjectClassified := true ].
			isObjectClassified ifFalse: [
					bag addLongLivedObject: illEphe ] ] ]
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> calculateMaxLiveSize [

    | currentTime aliveObjectsSize allocatedSamples deathObjects |
    maxLiveSize := 0.
    allocatedSamples := self allSamples sorted: [ :v1 :v2 |
				v1 initializationTime < v2 initializationTime ].
    deathObjects := (self allSamples sorted: [ :v1 :v2 |
				v1 finalizationTime < v2 finalizationTime ]) readStream.

    aliveObjectsSize := 0.
    allocatedSamples do: [ :illiEphemeron |
		currentTime := illiEphemeron initializationTime.

		[ deathObjects atEnd not and: [
			deathObjects peek finalizationTime <= currentTime ] ] whileTrue: [
				| theDeadObject |
				theDeadObject := deathObjects next.
				aliveObjectsSize := aliveObjectsSize - theDeadObject sizeInBytes ].

		aliveObjectsSize := aliveObjectsSize + illiEphemeron sizeInBytes.
		maxLiveSize := maxLiveSize max: aliveObjectsSize ].

    ^ maxLiveSize
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> classifyAllocationSites [

	groupedAllocationSites valuesDo: [ :bag |
		| is ss ls wasClassified relativeHlf relativeHif |
		wasClassified := false.
		is := bag immortalObjects sum: #sizeInBytes.
		ss := bag shortLivedObjects sum: #sizeInBytes.
		ls := bag longLivedObjects sum: #sizeInBytes.
		relativeHif := (is + ss + ls) * hif.
		relativeHlf := (is + ss + ls) * hlf.

		is > (ss + ls + relativeHif) ifTrue: [
			bag beImmortal.
			wasClassified := true ].
		(wasClassified not and: [ is + ls > (ss + relativeHlf) ]) ifTrue: [
			bag beLongLived.
			wasClassified := true ].
		wasClassified ifFalse: [ bag beShortLived ] ]
]

{ #category : 'api' }
MerlinPretenuringAdviceAlgorithm >> classifyEdgesByLifetime [

	self binObjects.
	self pruneAllocationSites.
	self classifyAllocationSites
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> endTime: anInteger [

	endTime := anInteger
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> groupedAllocationSites [
	^ groupedAllocationSites
]

{ #category : 'initialization' }
MerlinPretenuringAdviceAlgorithm >> initialize [

	super initialize.

	taThreshold := 0.45.
	hif := 0.
	hlf := 0.6
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> isObjectImmortal: illEphe [

	| timeOfDeath halfwayBirthtimeToEnd birthTime |
	timeOfDeath := illEphe finalizationTime min: endTime.
	birthTime := illEphe initializationTime.
	halfwayBirthtimeToEnd := birthTime + (endTime - illEphe initializationTime / 2).
	^ timeOfDeath > halfwayBirthtimeToEnd
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> isObjectShortLived: illEphe [

	| age maxSize |
	maxSize := self maxLiveSize.
	age := (illEphe lifetime / maxSize) asFloat.
	^ age < (taThreshold * maxSize)
]

{ #category : 'api' }
MerlinPretenuringAdviceAlgorithm >> longLivedAllocationSites [

	^ groupedAllocationSites values select: #isLongOrImmortal
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> maxLiveSize [

	^ maxLiveSize ifNil: [ self calculateMaxLiveSize ]
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> pruneAllocationSites [

	| totalProgramAllocations sitesWithSignificantSize |
	totalProgramAllocations := self allSamples size.
	sitesWithSignificantSize := groupedAllocationSites associations reject: [ :assoc |
			assoc key samples size < (self pruningThreshold * totalProgramAllocations) ].
	groupedAllocationSites := Dictionary newFrom: sitesWithSignificantSize
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> pruningThreshold [

	^ 0.000002
]

{ #category : 'api' }
MerlinPretenuringAdviceAlgorithm >> setUpForSamples: aCollectionOfFiLiPEphemerons [
	"Build one AllocationSiteBin per unique (sendersCallStack, allocatedType). The bag is
	used as both key and value because AllocationSiteBin implements # = and #hash on
	(stack, type). Samples whose stack is missing or empty are skipped: they cannot be
	assigned a calling context and are therefore not pretenurable."

	groupedAllocationSites := Dictionary new.
	aCollectionOfFiLiPEphemerons do: [ :sample |
		| stack bag |
		stack := sample sendersCallStack.
		(stack notNil and: [ stack senders isNotEmpty ]) ifTrue: [
			bag := AllocationSiteBin
				       forStack: stack
				       type: sample allocatedObjectClass.
			bag := groupedAllocationSites at: bag ifAbsentPut: [ bag ].
			bag addSample: sample ] ]
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> startTime [

	^ startTime
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> startTime: anInteger [

	startTime := anInteger
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> totalTime [

	^ endTime - startTime
]
