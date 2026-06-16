Class {
	#name : 'GraphTraversalTest',
	#superclass : 'TestCase',
	#instVars : [
		'psp'
	],
	#category : 'PathSensitivePretenuring-Tests',
	#package : 'PathSensitivePretenuring-Tests'
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
	psp := PathSensitvePretenuring new
		rawAllocationsSamples: samples;
		constructAllocationGraph;
		yourself
]

{ #category : 'tests' }
GraphTraversalTest >> testAllPathsFromTo [

	| allocationGraph actualPaths expectedPaths |
	allocationGraph := psp allocationGraph.
	
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
GraphTraversalTest >> testTraverseLongLivedSenderChains [

	| allocationGraph sendersChains expectedLongLivedPaths |
	allocationGraph := psp allocationGraph.
	allocationGraph edges do: #beLongLived.

	expectedLongLivedPaths := {
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: (Array class lookupSelector: #new:)) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m3 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m4 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixture class >> #m5 to: Behavior >> #basicNew) }.
		{ (allocationGraph edgeFrom: AllocationGraphFixtureUtilities class >> #mm to: Behavior >> #basicNew) }}.

	psp traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: psp allocationGraph; yourself).
	sendersChains := psp longLivedPaths.

	self assert: expectedLongLivedPaths size equals: sendersChains size.
	self assertCollection: expectedLongLivedPaths flattened hasSameElements: sendersChains flattened
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseTextualStrategyOnlyGetsLongLivedEdges [

	| expectedLongLivedPaths edge |
	psp allocationGraph edges do: #beShortLived.
	edge := psp allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: Behavior >> #basicNew.
	edge beLongLived.
	expectedLongLivedPaths := { OrderedCollection with: edge }.
	
	psp traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: psp allocationGraph; yourself).

	self assert: psp longLivedPaths size equals: 1.
	self assertCollection: psp longLivedPaths hasSameElements: expectedLongLivedPaths
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseUsingTextualAllocationSiteStrategy [

	| expectedMethodsToPreture |
	
	psp allocationGraph edges do: #beLongLived.
	psp traverseLongLivedSenderChainsUsing: (TextualLocationOfNewPretenuringStrategy new setUpForGraph: psp allocationGraph).
	psp flatLongLivedAllocationPaths.
	expectedMethodsToPreture := { 
		{ IllMethodWithOffset method: AllocationGraphFixture class >> #m1 offset: 103 }.
		{ IllMethodWithOffset method: AllocationGraphFixture class >> #m1 offset: 82 }.
		{ IllMethodWithOffset method: AllocationGraphFixture class >> #m4 offset: 66 }.
		{ IllMethodWithOffset method: AllocationGraphFixture class >> #m3 offset: 66 }.
		{ IllMethodWithOffset method: AllocationGraphFixture class >> #m5 offset: 66 }.
		{ IllMethodWithOffset method: AllocationGraphFixtureUtilities class >> #mm offset: 66 } }.
	expectedMethodsToPreture := expectedMethodsToPreture collect: #asOrderedCollection.

	self assertCollection: psp methodsToPretenure hasSameElements: expectedMethodsToPreture  
]
