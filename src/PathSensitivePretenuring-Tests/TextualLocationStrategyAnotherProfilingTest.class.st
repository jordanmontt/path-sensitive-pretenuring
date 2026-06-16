Class {
	#name : 'TextualLocationStrategyAnotherProfilingTest',
	#superclass : 'TestCase',
	#instVars : [
		'psp'
	],
	#category : 'PathSensitivePretenuring-Tests',
	#package : 'PathSensitivePretenuring-Tests'
}

{ #category : 'running' }
TextualLocationStrategyAnotherProfilingTest >> setUp [

	| profiler samples |
	super setUp.
	profiler := FiLiP new
		            samplingRate: 1;
		            profileOn: [ MockedAllocatorClass tata ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
		           { MockedAllocatedClass } includes: ephemeron allocatedObjectClass ].
	psp := PathSensitvePretenuring new
		rawAllocationsSamples: samples;
		constructAllocationGraph;
		yourself
]

{ #category : 'tests' }
TextualLocationStrategyAnotherProfilingTest >> testTextualLocationStrategy [

	| allocationGraph sendersChains expectedLongLivedPaths |
	allocationGraph := psp allocationGraph.
	allocationGraph edges do: #beLongLived.

	expectedLongLivedPaths := {
		{ (allocationGraph edgeFrom: Behavior >> #new to: Behavior >> #basicNew) .
	 	  (allocationGraph edgeFrom: MockedAllocatedClass class >> #fifi to: Behavior >> #new) } }.
	
	psp traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: allocationGraph; yourself).
	sendersChains := psp longLivedPaths.

	self assert: expectedLongLivedPaths size equals: sendersChains size.
	self assertCollection: expectedLongLivedPaths flattened hasSameElements: sendersChains flattened
]
