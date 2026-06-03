"
The algorithm works as follow:

1. Data cleaning. Clean noise if any.
2. Allocation graph. Create an allocation graph using the samples as an input. The samples are objects obtained during profiling that contain information about the stack, the object lifetime, etc.
3. Identify the allocation sites using different strategies. Mark the nodes in the graph.
4. Classify the allocation sites as long or short using Blackburn's algorithm.
5. Rewrite the code from the allocation site to the primitive allocator creating an unique path. 
 
"
Class {
	#name : 'PathSensitvePretenuring',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'allocationSiteClassificator',
		'rawAllocationsSamples',
		'allocationGraph',
		'sendersToPretenure',
		'pretenuringStrategy',
		'profiler',
		'ambiguityThreshold'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'initialization' }
PathSensitvePretenuring >> ambiguityThreshold: aNumber [

	ambiguityThreshold := aNumber
]

{ #category : 'api' }
PathSensitvePretenuring >> analyzeAllocations [

   self constructAllocationGraph.

   	self classifyEdgesByLifetime.

	pretenuringStrategy setUpForGraph: allocationGraph.
	allocationGraph traverseLongLivedSenderChainsUsing: pretenuringStrategy.
   sendersToPretenure := self extractLongLivedSendersChains
]

{ #category : 'calculating' }
PathSensitvePretenuring >> classifyEdgesByLifetime [

	allocationSiteClassificator := pretenuringStrategy newClassificationAlgorithm.

	"Set up"
	allocationSiteClassificator
		startTime: rawAllocationsSamples first initializationTime;
		endTime: profiler endTime;
		setUpForAllocationGraph: allocationGraph.
	ambiguityThreshold ifNotNil: [ allocationSiteClassificator ambiguityThreshold: ambiguityThreshold ].

	"API call"
	allocationSiteClassificator classifyEdgesByLifetime
]

{ #category : 'api' }
PathSensitvePretenuring >> compilePretenuredMethods [

    pretenurator compilePretenuredPathsFrom: sendersToPretenure.
    ^ pretenurator
]

{ #category : 'calculating' }
PathSensitvePretenuring >> constructAllocationGraph [

    self removeKernelAllocations.
    allocationGraph := AllocationGraph onSamples: rawAllocationsSamples
]

{ #category : 'api' }
PathSensitvePretenuring >> deserializeAndInstallCompiledMethodsFrom: aFileReference [

	| compiledMethods pretenuredMethods alreadyInstalledMethods |
	compiledMethods := CompiledMethodToSourceCodeSerializer new deserialize: aFileReference contents.

	pretenuredMethods := compiledMethods select: [ :method | method selector includesSubstring: 'pretenured' ].
	alreadyInstalledMethods := compiledMethods reject: [ :method | 
	    method selector includesSubstring: 'pretenured' ].

	pretenuredMethods do: [ :aCompiledMethod | 
		CallSiteTransformer new installPretenuredMethod: aCompiledMethod ].
	alreadyInstalledMethods do: [ :aCompiledMethod |
		CallSiteTransformer new installMethod: aCompiledMethod ]
]

{ #category : 'api' }
PathSensitvePretenuring >> exportPretenuredMethods: aWriteStream [

    pretenurator exportPretenuredMethods: aWriteStream
]

{ #category : 'calculating' }
PathSensitvePretenuring >> extractLongLivedSendersChains [

    sendersToPretenure := pretenuringStrategy extractLongLivedSendersChains: allocationGraph.
    ^ sendersToPretenure
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

	pretenuringStrategy := aStrategy
]

{ #category : 'calculating' }
PathSensitvePretenuring >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{ Context. Deprecation. Process. WeakArray. MouseMoveEvent }
			includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> setUpForProfiler: aProfiler [

	profiler := aProfiler.
	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by birth time."
]
