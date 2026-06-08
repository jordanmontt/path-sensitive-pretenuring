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
		            profileOn: [ AllocationGraphFixtureCaller tata ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
		           { AllocationGraphFixtureCaller. AllocationGraphFixture } includes: ephemeron allocatedObjectClass ].
	allocationGraph := AllocationGraph new
		                   setUpForSamples: samples;
		                   yourself
]

{ #category : 'tests' }
LocationOfNewStrategyTest >> testTextualLocationStrategy [

	| sendersChains expectedSendersChains |
	allocationGraph edges do: #beLongLived.
	allocationGraph := allocationGraph subgraphReachableFromNode: (allocationGraph nodeAtMethod: (AllocationGraphFixtureCaller class >> #tata)).

	expectedSendersChains := {
		{ (allocationGraph edgeFrom: Behavior >> #new to: Behavior >> #basicNew) .
	 	  (allocationGraph edgeFrom: AllocationGraphFixture class >> #fifi to: Behavior >> #new) } }.
	
	allocationGraph traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: allocationGraph; yourself).
	sendersChains := sendersChains := (allocationGraph nodes select: #isAllocationSite) flatCollect: #allocationCallStacks.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains flattened hasSameElements: sendersChains flattened
]
