"
The algorithm works as follow:

1. Data cleaning. Clean noise if any.
2. Allocation graph. Create an allocation graph using the samples as an input. The samples are objects obtained during profiling that contain information about the stack, the object lifetime, etc.
3. Identify the allocation sites using different strategies. Mark the nodes in the graph.
4. Classify the allocation sites as long or short using Blackburn's algorithm.
5. Rewrite the code from the allocation site to the primitive allocator creating an unique path. 
 
"
Class {
	#name : 'PathSensitvePretenuringExperiment',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'allocationSiteStrategy',
		'allocationSiteClassificator',
		'rawAllocationsSamples',
		'allocationGraph',
		'sendersToPretenure'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'instance creation' }
PathSensitvePretenuringExperiment class >> onProfiler: aProfiler traversalStrategy: aStrategy [

    ^ self new
          setUpForProfiler: aProfiler;
          allocationSiteStrategy: aStrategy;
          yourself
]

{ #category : 'api - accessing' }
PathSensitvePretenuringExperiment >> allocationSiteStrategy: aStrategy [

	allocationSiteStrategy := aStrategy
]

{ #category : 'api' }
PathSensitvePretenuringExperiment >> analyzeAllocations [

   self constructAllocationGraph.

   	self classifyEdgesByLifetime.

	allocationSiteStrategy setUpForGraph: allocationGraph.
	allocationGraph traverseLongLivedSenderChainsUsing: allocationSiteStrategy.
   sendersToPretenure := self extractLongLivedSendersChains
]

{ #category : 'calculating' }
PathSensitvePretenuringExperiment >> classifyEdgesByLifetime [

    allocationSiteClassificator
        setUpForAllocationGraph: allocationGraph;
        classifyEdgesByLifetime
]

{ #category : 'api' }
PathSensitvePretenuringExperiment >> compilePretenuredMethods [

    pretenurator compilePretenuredPathsFrom: sendersToPretenure.
    ^ pretenurator
]

{ #category : 'calculating' }
PathSensitvePretenuringExperiment >> constructAllocationGraph [

    self removeKernelAllocations.
    allocationGraph := AllocationGraph onSamples: rawAllocationsSamples
]

{ #category : 'api' }
PathSensitvePretenuringExperiment >> deserializeAndInstallCompiledMethodsIn: aFileReference [

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
PathSensitvePretenuringExperiment >> exportPretenuredMethods: aWriteStream [

    pretenurator exportPretenuredMethods: aWriteStream
]

{ #category : 'calculating' }
PathSensitvePretenuringExperiment >> extractLongLivedSendersChains [

    sendersToPretenure := allocationSiteStrategy extractLongLivedSendersChains: allocationGraph.
    ^ sendersToPretenure
]

{ #category : 'initialization' }
PathSensitvePretenuringExperiment >> initialize [

    super initialize.

    allocationSiteClassificator := PretenuringAdviceAlgorithm new.
    pretenurator := AllocationSitesPretenurer new.
    sendersToPretenure := OrderedCollection new
]

{ #category : 'inspector' }
PathSensitvePretenuringExperiment >> inspector: aBuilder [

    <inspectorPresentationOrder: 1 title: 'To Pretenure Sites'>
    ^ sendersToPretenure inspectionItems: aBuilder
]

{ #category : 'api' }
PathSensitvePretenuringExperiment >> installPretenuredMethods [

    pretenurator installPretenuredMethods
]

{ #category : 'api - accessing' }
PathSensitvePretenuringExperiment >> methodProtocol: aProtocol [

	pretenurator methodProtocol: aProtocol
]

{ #category : 'calculating' }
PathSensitvePretenuringExperiment >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{ Context. Deprecation. Process. WeakArray. MouseMoveEvent }
			includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'api - accessing' }
PathSensitvePretenuringExperiment >> setUpForProfiler: aProfiler [

	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by time."
	allocationSiteClassificator
		startTime: aProfiler objectAllocations first initializationTime;
		endTime: aProfiler endTime

]
