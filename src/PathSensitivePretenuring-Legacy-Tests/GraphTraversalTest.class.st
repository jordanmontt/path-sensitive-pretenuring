Class {
	#name : 'GraphTraversalTest',
	#superclass : 'TestCase',
	#instVars : [
		'allocationGraph'
	],
	#category : 'PathSensitivePretenuring-Legacy-Tests',
	#package : 'PathSensitivePretenuring-Legacy-Tests'
}

{ #category : 'running' }
GraphTraversalTest >> setUp [

	| profiler samples |
	super setUp.
	profiler := FiLiP new
		            samplingRate: 1;
		            profileOn: [ AllocationGraphFixture entryPoint ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
		           { AllocationGraphFixtureObject . AllocationGraphFixtureArray } includes: ephemeron allocatedObjectClass ].
	allocationGraph := AllocationGraph new
		                   setUpForSamples: samples;
		                   yourself
]

{ #category : 'tests' }
GraphTraversalTest >> testAllPathsFromTo [

	| actualPaths expectedPaths |
	
	actualPaths := allocationGraph
			allPathsFrom: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7)
			to: (allocationGraph nodeAtMethod: Behavior >> #basicNew).
	expectedPaths := {
		                 {
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7).
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5).
			                 (allocationGraph nodeAtMethod: Behavior >> #basicNew) }.
		                 {
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7).
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4).
			                 (allocationGraph nodeAtMethod: Behavior >> #basicNew) } }.

	self assert: actualPaths size equals: 2.
	self assertCollection: actualPaths includesAll: expectedPaths.
]

{ #category : 'tests' }
GraphTraversalTest >> testDetectAllocationSiteDefault [

	allocationGraph edges do: #beLongLived.
	allocationGraph traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: allocationGraph).

	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
GraphTraversalTest >> testDetectAllocationSitesUsingMethodInPackage [

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.
	
	allocationGraph := allocationGraph subgraphReachableFromMethod: (AllocationGraphFixture class >> #entryPoint).
	allocationGraph edges do: #beLongLived.

	allocationGraph traverseLongLivedSenderChainsUsing:
		(ApplicationMethodPretenuringStrategy setUpForApplicationPackages: { AllocationGraphFixture package }).

	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseLongLivedSenderChains [

	| sendersChains expectedSendersChains |
	allocationGraph edges do: #beLongLived.
	allocationGraph := allocationGraph subgraphReachableFromNode: (allocationGraph nodeAtMethod: (AllocationGraphFixture class >> #entryPoint)).

	expectedSendersChains := {
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: (Array class lookupSelector: #new:)) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m3 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m4 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m5 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixtureUtilities class >> #mm to: Behavior >> #basicNew) }}.

	allocationGraph traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy setUpForGraph: allocationGraph).
	sendersChains := sendersChains := (allocationGraph nodes select: #isAllocationSite) flatCollect: #allocationCallStacks.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains hasSameElements: sendersChains
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseLongLivedSenderChainsSimpleStrategy [

	| sendersChains expectedSendersChains |
	allocationGraph edges do: #beLongLived.
	allocationGraph := allocationGraph subgraphReachableFromNode: (allocationGraph nodeAtMethod: (AllocationGraphFixture class >> #entryPoint)).
	(allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) beAllocationSite.

	expectedSendersChains := {
		{
			(allocationGraph edgeFrom: AllocationGraphFixture class >> #m4 to: Behavior >> #basicNew).
			(allocationGraph edgeFrom: AllocationGraphFixture class >> #m7 to: AllocationGraphFixture class >> #m4) }.
		{
			(allocationGraph edgeFrom: AllocationGraphFixture class >> #m5 to: Behavior >> #basicNew).
			(allocationGraph edgeFrom: AllocationGraphFixture class >> #m7 to: AllocationGraphFixture class >> #m5) } }.
	
	allocationGraph traverseLongLivedSenderChainsUsing: NodeBasedPretenuringStrategy new.
	sendersChains := sendersChains := (allocationGraph nodes select: #isAllocationSite) flatCollect: #allocationCallStacks.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains hasSameElements: sendersChains
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseTextualStrategyOnlyGetsLongLivedEdges [

	| sendersChains expectedSendersChains |
	allocationGraph := allocationGraph subgraphReachableFromNode: (allocationGraph nodeAtMethod: (AllocationGraphFixture class >> #entryPoint)).

	expectedSendersChains := {
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: Behavior >> #basicNew) } }.
	
	expectedSendersChains do: [ :array | array do: #beLongLived].

	allocationGraph traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy setUpForGraph: allocationGraph).
	sendersChains := (allocationGraph nodes select: #isAllocationSite) flatCollect: #allocationCallStacks.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains hasSameElements: sendersChains
]
