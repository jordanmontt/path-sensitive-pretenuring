Class {
	#name : 'LocationOfNewStrategyTest',
	#superclass : 'TestCase',
	#instVars : [
		'allocationGraph'
	],
	#category : 'PathSensitivePretenuring-Tests',
	#package : 'PathSensitivePretenuring-Tests'
}

{ #category : 'running' }
LocationOfNewStrategyTest >> setUp [

	| profiler samples |
	super setUp.
	profiler := FiLiP new
		            samplingRate: 1;
		            profileOn: [ MockedAllocatorClass tata ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
		           { MockedAllocatorClass. MockedAllocatedClass } includes: ephemeron allocatedObjectClass ].
	allocationGraph := AllocationGraph new
		                   setUpForSamples: samples;
		                   yourself
]

{ #category : 'tests' }
LocationOfNewStrategyTest >> testTextualLocationStrategy [

	| sendersChains expectedSendersChains |
	allocationGraph edges do: #beLongLived.
	allocationGraph := allocationGraph subgraphReachableFromNode: (allocationGraph nodeAtMethod: (MockedAllocatorClass class >> #tata)).

	expectedSendersChains := {
		{ (allocationGraph edgeFrom: Behavior >> #new to: Behavior >> #basicNew) .
	 	  (allocationGraph edgeFrom: MockedAllocatedClass class >> #fifi to: Behavior >> #new) } }.
	
	allocationGraph traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: allocationGraph; yourself).
	sendersChains := sendersChains := (allocationGraph nodes select: #isAllocationSite) flatCollect: #allocationCallStacks.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains flattened hasSameElements: sendersChains flattened
]
