"
Allocation sites classification algorithm. Paper: https://www.steveblackburn.org/pubs/papers/pbp-toplas-2007.pdf

The algorithm works as follows:

1. Setup. It receives an allocation graph as an input. It takes the nodes of the graph and creates ""allocation bin"" objects, an internal helper data structure, and does some data cleaning.
2. Pruning. It prunes the allocation sites that have total allocation less than 0.000002 times the total allocation.
3. Allocation Site Identification. It traverses the graph and it identifies all the possible allocation sites. It can use different strategies to ask to each node if it is an allocation site.
4. (Optional) Return the allocations that are long or lived
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
		'hlf',
		'allocationGraph',
		'pruningThreshold'
	],
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> allocationGraph: anAllocationGraph [

	allocationGraph := anAllocationGraph
]

{ #category : 'initialization' }
MerlinPretenuringAdviceAlgorithm >> ambiguityThreshold: aNumber [

	
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> binObjects [

	groupedAllocationSites keysDo: [ :allocationGraphComponent |
		allocationGraphComponent allocatedSamples do: [ :illEphe |
			| isObjectClassified |
			isObjectClassified := false.
			(self isObjectImmortal: illEphe) ifTrue: [
					(groupedAllocationSites at: allocationGraphComponent) addImmortalObject: illEphe.
					isObjectClassified := true ].
			(isObjectClassified not and: [ self isObjectShortLived: illEphe ]) ifTrue: [
					(groupedAllocationSites at: allocationGraphComponent) addShortLivedObject: illEphe.
					isObjectClassified := true ].
			isObjectClassified ifFalse: [
					(groupedAllocationSites at: allocationGraphComponent) addLongLivedObject: illEphe ] ] ]
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> calculateMaxLiveSize [

    | currentTime aliveObjectsSize allocatedSamples deathObjects |
    maxLiveSize := 0.
    allocatedSamples := allocationGraph allocatedSamples sorted: [ :v1 :v2 |
				v1 initializationTime < v2 initializationTime ].
    deathObjects := (allocationGraph allocatedSamples sorted: [ :v1 :v2 |
				v1 finalizationTime < v2 finalizationTime ]) readStream.

    aliveObjectsSize := 0.
    allocatedSamples do: [ :illiEphemeron |
		currentTime := illiEphemeron initializationTime.
		
		[ deathObjects peek finalizationTime <= currentTime ] whileTrue: [
				| theDeadObject |
				theDeadObject := deathObjects next.
				aliveObjectsSize := aliveObjectsSize - theDeadObject sizeInBytes ].

		aliveObjectsSize := aliveObjectsSize + illiEphemeron sizeInBytes.
		maxLiveSize := maxLiveSize max: aliveObjectsSize ].

    ^ maxLiveSize
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> classifyAllocationSites [

	groupedAllocationSites keysAndValuesDo: [ :allocationGraphComponent :allocationSiteBin |
		| is ss ls wasClassified relativeHlf relativeHif |
		wasClassified := false.
		is := allocationSiteBin immortalObjects sum: #sizeInBytes.
		ss := allocationSiteBin shortLivedObjects sum: #sizeInBytes.
		ls := allocationSiteBin longLivedObjects sum: #sizeInBytes.
		relativeHif := (is + ss + ls) * hif.
		relativeHlf := (is + ss + ls) * hlf.

		is > (ss + ls + relativeHif) ifTrue: [
			allocationSiteBin classification: #immortal.
			allocationGraphComponent beImmortal.
			wasClassified := true ].
		(wasClassified not and: [ is + ls > (ss + relativeHlf) ]) ifTrue: [
			allocationSiteBin classification: #long.
			allocationGraphComponent beLongLived.
			wasClassified := true ].
		wasClassified ifFalse: [
			allocationSiteBin classification: #short.
			allocationGraphComponent beShortLived ] ]
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
	hlf := 0.6.
	pruningThreshold := 0.000002
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> isObjectImmortal: illEphe [

	| timeOfDeath halfwayBirthtimeToEnd birthTime |
	timeOfDeath := illEphe finalizationTime min: endTime.
	birthTime := illEphe initializationTime.
	halfwayBirthtimeToEnd := birthTime + (endTime - birthTime / 2).
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

    ^ groupedAllocationSites select: #isLongOrImmortal
]

{ #category : 'accessing' }
MerlinPretenuringAdviceAlgorithm >> maxLiveSize [

	^ maxLiveSize ifNil: [ self calculateMaxLiveSize ]
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> pruneAllocationSites [

	| totalProgramAllocations sitesWithSignificantSize |
	totalProgramAllocations := allocationGraph allocatedSamples size.
	sitesWithSignificantSize := groupedAllocationSites associations reject: [ :assoc |
			assoc key allocatedSamples size < (pruningThreshold * totalProgramAllocations) ].
	groupedAllocationSites := Dictionary newFrom: sitesWithSignificantSize
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> pruningThreshold [

	^ pruningThreshold
]

{ #category : 'calculating' }
MerlinPretenuringAdviceAlgorithm >> pruningThreshold: aNumber [

	pruningThreshold := aNumber
]

{ #category : 'api' }
MerlinPretenuringAdviceAlgorithm >> setUpForAllocationGraph: anAllocationGraph [

    allocationGraph := anAllocationGraph.

    groupedAllocationSites := Dictionary new.
    allocationGraph edges do: [ :edge |
        groupedAllocationSites
            at: edge
            ifAbsentPut: (AllocationSiteBin new allocationSite: edge; yourself) ]
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
