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
		'pretenuringStrategy',
		'profiler',
		'ambiguityThreshold',
		'longLivedPaths',
		'methodsToPretenure'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'accessing' }
PathSensitvePretenuring >> allocationGraph [

   ^ allocationGraph
]

{ #category : 'accessing' }
PathSensitvePretenuring >> allocationGraph: anAllocationGraph [

   allocationGraph := anAllocationGraph
]

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
   methodsToPretenure := self flatLongLivedAllocationPaths
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

    pretenurator compilePretenuredPathsFrom: methodsToPretenure.
    ^ pretenurator
]

{ #category : 'calculating' }
PathSensitvePretenuring >> constructAllocationGraph [

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
PathSensitvePretenuring >> flatLongLivedAllocationPaths [

   methodsToPretenure := longLivedPaths collect: [ :path |
		path collect: [ :edge |
				IllMethodWithOffset method: edge sourceNode method offset: edge offset ] ].

   methodsToPretenure := methodsToPretenure select: #isNotEmpty.
   ^ methodsToPretenure
]

{ #category : 'initialization' }
PathSensitvePretenuring >> initialize [

   super initialize.

   pretenurator := AllocationSitesPretenurer new.
   methodsToPretenure := OrderedCollection new.
   longLivedPaths := Set new
]

{ #category : 'inspector' }
PathSensitvePretenuring >> inspector: aBuilder [

    <inspectorPresentationOrder: 1 title: 'Methods to pretenure'>
    ^ methodsToPretenure inspectionItems: aBuilder
]

{ #category : 'inspector' }
PathSensitvePretenuring >> inspectorLongLivedPaths: aBuilder [

    <inspectorPresentationOrder: 0 title: 'Long-Lived Paths'>
    ^ longLivedPaths inspectionItems: aBuilder
]

{ #category : 'api' }
PathSensitvePretenuring >> installPretenuredMethods [

    pretenurator installPretenuredMethods
]

{ #category : 'accessing' }
PathSensitvePretenuring >> longLivedPaths [

   ^ longLivedPaths
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> methodProtocol: aProtocol [

	pretenurator methodProtocol: aProtocol
]

{ #category : 'accessing' }
PathSensitvePretenuring >> methodsToPretenure [

   ^ methodsToPretenure
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> pretenuringStrategy: aStrategy [

	pretenuringStrategy := aStrategy
]

{ #category : 'accessing' }
PathSensitvePretenuring >> rawAllocationsSamples: aCollection [

   rawAllocationsSamples := aCollection
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
   self removeKernelAllocations
]

{ #category : 'graph - traversal' }
PathSensitvePretenuring >> traverseLongLivedAllocationStack: rawAllocationStack using: aStrategy [

    | depth currentCallStack theCurrentNode |
    depth := 0.
    currentCallStack := OrderedCollection new.

    "The first one is the allocator method"
    (rawAllocationStack allButFirst: 2) pairsDo: [ :method :offset |
        | theEdge |
        depth > 20 ifTrue: [ ^ self ].

        theCurrentNode := allocationGraph nodeFor: method.
        [ theEdge := theCurrentNode edgeForOffset: offset ] on: NotFound do: [ :ex | ^ self ].
        currentCallStack add: theEdge.
        (aStrategy isAllocationSite: theCurrentNode fromAllocationPath: currentCallStack) ifTrue: [
            longLivedPaths add: currentCallStack.
            ^ self ].
        depth := depth + 1 ]
]

{ #category : 'graph - traversal' }
PathSensitvePretenuring >> traverseLongLivedSenderChainsUsing: aStrategy [

    longLivedPaths := Set new.	
    allocationGraph leaves do: [ :leaf |
        leaf allocatedObjectTypes do: [ :type |
            | callStacksPerType |
            callStacksPerType := leaf allocatedSamples collect: [ :sample | sample rawSendersCallStack ] as: Set.
            callStacksPerType do: [ :rawCallStackOfType | 
                self traverseLongLivedAllocationStack: rawCallStackOfType using: aStrategy ] ] ]
]
