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

	| allocationGraph sendersChains expectedSendersChains |
	allocationGraph := psp allocationGraph.
	allocationGraph edges do: #beLongLived.

	expectedSendersChains := {
		{ (allocationGraph edgeFrom: Behavior >> #new to: Behavior >> #basicNew) .
	 	  (allocationGraph edgeFrom: MockedAllocatedClass class >> #fifi to: Behavior >> #new) } }.
	
	psp traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: allocationGraph; yourself).
	sendersChains := psp longLivedPaths.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains flattened hasSameElements: sendersChains flattened
]
