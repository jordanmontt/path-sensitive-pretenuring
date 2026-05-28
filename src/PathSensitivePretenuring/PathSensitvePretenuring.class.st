"
The algorithm works as follow:

1. Data cleaning. Clean noise if any.
2. Bag-of-stacks build. Group every FiLiPEphemeron by (sendersCallStack, allocatedType) using AllocationSiteBin as the bag. Two samples land in the same bag only if their full call stack and allocated type match exactly. Distinct prefixes never merge.
3. Classify the bags as short, long, or immortal using Blackburn's algorithm (immortal merged into long-lived for Pharo's two-generation VM).
4. Trim each long-lived bag's chain via the configured strategy (ApplicationMethod or TextualLocationOfNew).
5. Rewrite the code along the trimmed chains, creating unique paths for the pretenured allocations.

"
Class {
	#name : 'PathSensitvePretenuring',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'allocationSiteClassificator',
		'rawAllocationsSamples',
		'sendersToPretenure',
		'pretenuringStrategy'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'initialization' }
PathSensitvePretenuring >> ambiguityThreshold: aNumber [

	allocationSiteClassificator ambiguityThreshold: aNumber
]

{ #category : 'api' }
PathSensitvePretenuring >> analyzeAllocations [

	self removeKernelAllocations.

	self classifyEdgesByLifetime.

	pretenuringStrategy setUpForBags: self bags.
	sendersToPretenure := pretenuringStrategy extractLongLivedSendersChains: self bags
]

{ #category : 'accessing' }
PathSensitvePretenuring >> bags [

	^ allocationSiteClassificator groupedAllocationSites values
]

{ #category : 'calculating' }
PathSensitvePretenuring >> classifyEdgesByLifetime [

    allocationSiteClassificator
        setUpForSamples: rawAllocationsSamples;
        classifyEdgesByLifetime
]

{ #category : 'api' }
PathSensitvePretenuring >> compilePretenuredMethods [

    pretenurator compilePretenuredPathsFrom: sendersToPretenure.
    ^ pretenurator
]

{ #category : 'api' }
PathSensitvePretenuring >> deserializeAndInstallCompiledMethodsFrom: aFileReference [

	| compiledMethods uniqueMethods potentiallyAlreadyInstalledMethods |
	compiledMethods := CompiledMethodToSourceCodeSerializer new deserialize: aFileReference contents.

	uniqueMethods := compiledMethods select: [ :method | method selector includesSubstring: 'pretenured' ].
	potentiallyAlreadyInstalledMethods := compiledMethods reject: [ :method | 
	    method selector includesSubstring: 'pretenured' ].

	(uniqueMethods , potentiallyAlreadyInstalledMethods) do: [ :aCompiledMethod |
	    aCompiledMethod methodClass
           addSelector: aCompiledMethod selector
           withMethod: aCompiledMethod ]
]

{ #category : 'api' }
PathSensitvePretenuring >> exportPretenuredMethods: aWriteStream [

    pretenurator exportPretenuredMethods: aWriteStream
]

{ #category : 'initialization' }
PathSensitvePretenuring >> initialize [

    super initialize.

    pretenurator := AllocationSitesPretenurer new.
    sendersToPretenure := OrderedCollection new
]

{ #category : 'inspector' }
PathSensitvePretenuring >> inspector: aBuilder [

    <inspectorPresentationOrder: 1 title: 'To Pretenure Sites'>
    ^ sendersToPretenure inspectionItems: aBuilder
]

{ #category : 'api' }
PathSensitvePretenuring >> installPretenuredMethods [

    pretenurator installPretenuredMethods
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> methodProtocol: aProtocol [

	pretenurator methodProtocol: aProtocol
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> pretenuringStrategy: aStrategy [

	pretenuringStrategy := aStrategy.
	allocationSiteClassificator := pretenuringStrategy newClassificationAlgorithm
]

{ #category : 'calculating' }
PathSensitvePretenuring >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{ Context. Deprecation. Process. WeakArray. MouseMoveEvent }
			includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> setUpForProfiler: aProfiler [

	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by time."

	allocationSiteClassificator
		startTime: aProfiler objectAllocations first initializationTime;
		endTime: aProfiler endTime

]
