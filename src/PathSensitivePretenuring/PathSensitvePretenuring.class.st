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

   self constructAllocationGraph.

   	self classifyEdgesByLifetime.

	pretenuringStrategy setUpForGraph: allocationGraph.
	allocationGraph traverseLongLivedSenderChainsUsing: pretenuringStrategy.
   sendersToPretenure := self extractLongLivedSendersChains
]

{ #category : 'calculating' }
PathSensitvePretenuring >> classifyEdgesByLifetime [

    allocationSiteClassificator
        setUpForAllocationGraph: allocationGraph;
        classifyEdgesByLifetime
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
