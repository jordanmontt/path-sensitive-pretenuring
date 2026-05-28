"
I classify PSPStackBag instances as short-lived, long-lived, or immortal using the Pretenuring Advice algorithm of Blackburn et al. I am the bag-of-stacks counterpart of MerlinPretenuringAdviceAlgorithm in the legacy graph pipeline.

The algorithm is unchanged:

1. **Setup.** I receive a collection of PSPStackBags from PSPStackBagBuilder, plus the program-wide startTime and endTime (the profiling interval from FiLiP).
2. **Binning.** For each bag, I sort its samples into three sub-collections (immortal, short-lived, long-lived) using the same lifetime thresholds as the legacy classifier.
3. **Pruning.** Bags whose total sample count is below pruningThreshold x totalProgramAllocations are dropped from classification (they keep their default unclassified state and are therefore not pretenured).
4. **Classification.** For each surviving bag, I compute the relative HIF / HLF fractions and tag the bag #immortal, #long, or #short.

The only change relative to MerlinPretenuringAdviceAlgorithm is the key: bags instead of edges. The HIF, HLF, taThreshold, and pruningThreshold constants are identical so results are directly comparable.
"
Class {
	#name : 'PSPStackBagClassifier',
	#superclass : 'Object',
	#instVars : [
		'bags',
		'startTime',
		'endTime',
		'maxLiveSize',
		'taThreshold',
		'hif',
		'hlf'
	],
	#category : 'PathSensitivePretenuring-BagOfStacks-Classification',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Classification'
}

{ #category : 'api - configuration' }
PSPStackBagClassifier >> ambiguityThreshold: aNumber [
	"Kept polymorphic with MerlinPretenuringAdviceAlgorithm for the legacy entry points
	that pass an ambiguity threshold. The Pretenuring Advice algorithm does not use one
	directly, but PSPPretenuringAdviceAlgorithm did."

	"no-op"
]

{ #category : 'accessing' }
PSPStackBagClassifier >> bags [

	^ bags
]

{ #category : 'private - binning' }
PSPStackBagClassifier >> binObjects [

	bags do: [ :bag |
		bag samples do: [ :illEphe |
			| isObjectClassified |
			isObjectClassified := false.
			(self isObjectImmortal: illEphe) ifTrue: [
				bag addImmortalObject: illEphe.
				isObjectClassified := true ].
			(isObjectClassified not and: [
				 self isObjectShortLived: illEphe ]) ifTrue: [
				bag addShortLivedObject: illEphe.
				isObjectClassified := true ].
			isObjectClassified ifFalse: [
				bag addLongLivedObject: illEphe ] ] ]
]

{ #category : 'private - calculating' }
PSPStackBagClassifier >> calculateMaxLiveSize [
	"Maximum live size over the program: simulates allocation+death ordering to compute
	the peak resident set size. Same logic as MerlinPretenuringAdviceAlgorithm but reading
	samples from the bags instead of from an allocation graph."

	| currentTime aliveObjectsSize allocatedSamples deathObjects |
	maxLiveSize := 0.
	allocatedSamples := self allSamples sorted: [ :v1 :v2 |
		                    v1 initializationTime < v2 initializationTime ].
	deathObjects := (self allSamples sorted: [ :v1 :v2 |
		                 v1 finalizationTime < v2 finalizationTime ])
		                readStream.

	aliveObjectsSize := 0.
	allocatedSamples do: [ :illiEphemeron |
		currentTime := illiEphemeron initializationTime.

		[
		deathObjects atEnd not and: [
			deathObjects peek finalizationTime <= currentTime ] ] whileTrue: [
			| theDeadObject |
			theDeadObject := deathObjects next.
			aliveObjectsSize := aliveObjectsSize - theDeadObject sizeInBytes ].

		aliveObjectsSize := aliveObjectsSize + illiEphemeron sizeInBytes.
		maxLiveSize := maxLiveSize max: aliveObjectsSize ].

	^ maxLiveSize
]

{ #category : 'api' }
PSPStackBagClassifier >> classifyByLifetime [

	self binObjects.
	self pruneBags.
	self classifyBags
]

{ #category : 'private - classification' }
PSPStackBagClassifier >> classifyBags [

	bags do: [ :bag |
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

{ #category : 'accessing' }
PSPStackBagClassifier >> endTime [

	^ endTime
]

{ #category : 'accessing' }
PSPStackBagClassifier >> endTime: anInteger [

	endTime := anInteger
]

{ #category : 'initialization' }
PSPStackBagClassifier >> initialize [

	super initialize.

	"Same constants as MerlinPretenuringAdviceAlgorithm. Changing these here would
	make bag-of-stacks results incomparable to the thesis numbers."
	taThreshold := 0.45.
	hif := 0.
	hlf := 0.6
]

{ #category : 'private - calculating' }
PSPStackBagClassifier >> isObjectImmortal: illEphe [

	| timeOfDeath halfwayBirthtimeToEnd birthTime |
	timeOfDeath := illEphe finalizationTime min: endTime.
	birthTime := illEphe initializationTime.
	halfwayBirthtimeToEnd := birthTime + (endTime - illEphe initializationTime / 2).
	^ timeOfDeath > halfwayBirthtimeToEnd
]

{ #category : 'private - calculating' }
PSPStackBagClassifier >> isObjectShortLived: illEphe [

	| age maxSize |
	maxSize := self maxLiveSize.
	age := (illEphe lifetime / maxSize) asFloat.
	^ age < (taThreshold * maxSize)
]

{ #category : 'api' }
PSPStackBagClassifier >> longLivedBags [

	^ bags select: #isLongOrImmortal
]

{ #category : 'accessing' }
PSPStackBagClassifier >> maxLiveSize [

	^ maxLiveSize ifNil: [ self calculateMaxLiveSize ]
]

{ #category : 'private - calculating' }
PSPStackBagClassifier >> allSamples [

	^ bags flatCollect: [ :bag | bag samples ]
]

{ #category : 'private - pruning' }
PSPStackBagClassifier >> pruneBags [
	"Drop bags whose own sample count is below pruningThreshold x totalProgramAllocations.
	Same threshold and policy as the legacy classifier; the difference is that we prune
	bags instead of edges."

	| totalProgramAllocations |
	totalProgramAllocations := self allSamples size.
	bags := bags reject: [ :bag |
		        bag samples size
		        < (self pruningThreshold * totalProgramAllocations) ]
]

{ #category : 'private - pruning' }
PSPStackBagClassifier >> pruningThreshold [

	^ 0.000002
]

{ #category : 'api' }
PSPStackBagClassifier >> setUpForBags: aCollectionOfBags [

	bags := aCollectionOfBags asOrderedCollection
]

{ #category : 'accessing' }
PSPStackBagClassifier >> startTime [

	^ startTime
]

{ #category : 'accessing' }
PSPStackBagClassifier >> startTime: anInteger [

	startTime := anInteger
]

{ #category : 'accessing' }
PSPStackBagClassifier >> totalTime [

	^ endTime - startTime
]
