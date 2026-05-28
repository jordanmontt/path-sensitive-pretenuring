"
I am the public entry point of the path-sensitive pretenuring pipeline.

The algorithm works as follows:

1. Data cleaning. Remove allocations from a small fixed set of VM-internal classes (Context, Deprecation, Process, WeakArray, MouseMoveEvent) that would otherwise dominate the bag count without being meaningful pretenuring targets.
2. Bag-of-stacks build. Group every FiLiPEphemeron by (sendersCallStack, allocatedType). Two samples land in the same bag only if their full call stack and allocated type match exactly. This replaces the legacy AllocationGraph and is the key step that prevents the calling-context loss observed in the graph pipeline.
3. Lifetime classification. Run the Pretenuring Advice algorithm of Blackburn et al. (with immortal merged into long-lived for Pharo's two-generation VM) on each bag, tagging it short / long / immortal.
4. Chain extraction. For every long-or-immortal bag, ask the configured PSPBagTraversalStrategy to trim its full chain down to the prefix that should be pretenured. Drop bags whose trim is empty.
5. Code rewriting. Hand the resulting OrderedCollection<OrderedCollection<IllMethodWithOffset>> to AllocationSitesPretenurer, which monomorphizes each chain (duplicates every method except the last under a unique pretenured selector, then patches the last frame's call site).

The legacy graph pipeline (AllocationGraph, MerlinPretenuringAdviceAlgorithm, DFS-based stopping strategies) is preserved under the -Legacy package and is not loaded by default.
"
Class {
	#name : 'PathSensitvePretenuring',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'rawAllocationsSamples',
		'pipeline',
		'sendersToPretenure',
		'pretenuringStrategy',
		'startTime',
		'endTime'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'initialization' }
PathSensitvePretenuring >> ambiguityThreshold: aNumber [
	"Preserved for API compatibility with the legacy entry points. The bag-of-stacks
	classifier (PSPStackBagClassifier) implements Blackburn's algorithm without an
	ambiguity threshold, so this is a no-op in the new pipeline."

	"no-op"
]

{ #category : 'api' }
PathSensitvePretenuring >> analyzeAllocations [

	self removeKernelAllocations.

	pipeline := PSPBagPipeline new
		            samples: rawAllocationsSamples
		            strategy: pretenuringStrategy
		            startTime: startTime
		            endTime: endTime;
		            yourself.
	pipeline analyze.
	sendersToPretenure := pipeline extractChains
]

{ #category : 'accessing' }
PathSensitvePretenuring >> bags [
	"All bags produced by the pipeline, including short-lived ones not pruned by the threshold.
	Useful for inspection and tests."

	^ pipeline ifNil: [ #() ] ifNotNil: [ pipeline bags ]
]

{ #category : 'api' }
PathSensitvePretenuring >> compilePretenuredMethods [

	pretenurator compilePretenuredPathsFrom: sendersToPretenure.
	^ pretenurator
]

{ #category : 'api' }
PathSensitvePretenuring >> deserializeAndInstallCompiledMethodsFrom: aFileReference [

	| compiledMethods uniqueMethods potentiallyAlreadyInstalledMethods |
	compiledMethods := CompiledMethodToSourceCodeSerializer new deserialize:
		                   aFileReference contents.

	uniqueMethods := compiledMethods select: [ :method |
		                 method selector includesSubstring: 'pretenured' ].
	potentiallyAlreadyInstalledMethods := compiledMethods reject: [ :method |
		                                      method selector includesSubstring:
			                                      'pretenured' ].

	(uniqueMethods , potentiallyAlreadyInstalledMethods) do: [
		:aCompiledMethod |
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

{ #category : 'accessing' }
PathSensitvePretenuring >> pipeline [
	"The PSPBagPipeline used by the most recent #analyzeAllocations call."

	^ pipeline
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> pretenuringStrategy: aStrategy [

	pretenuringStrategy := aStrategy
]

{ #category : 'calculating' }
PathSensitvePretenuring >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{
			Context.
			Deprecation.
			Process.
			WeakArray.
			MouseMoveEvent } includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'accessing' }
PathSensitvePretenuring >> sendersToPretenure [

	^ sendersToPretenure
]

{ #category : 'api - accessing' }
PathSensitvePretenuring >> setUpForProfiler: aProfiler [

	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by time."

	startTime := aProfiler objectAllocations first initializationTime.
	endTime := aProfiler endTime
]
