"
I implement the Application-Specific-Method policy from the path-sensitive pretenuring thesis, restated as a chain-trimmer over a PSPStackBag.

In the legacy graph pipeline this was ApplicationMethodPretenuringStrategy: walking up from the leaf, stop at the first method whose package is one of the application's packages.

In the bag world, the bag's chain starts at the deepest sender. I scan it from index 1 upward and trim the chain to the prefix up to and including the first frame whose method's package is in my application-packages set.

If the chain never enters an application package (only framework / kernel methods, all the way up), I return an empty chain so the bag is skipped. This matches the legacy behavior: the DFS would never have hit a stopping node, so no allocation site would have been recorded.

Configuration: pass the application packages to me via #setUpForApplicationPackages: before the pipeline runs the trim phase. PSPBagPipeline does this.
"
Class {
	#name : 'PSPBagApplicationMethodStrategy',
	#superclass : 'PSPBagTraversalStrategy',
	#instVars : [
		'applicationPackages'
	],
	#category : 'PathSensitivePretenuring-BagOfStacks-Strategies',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Strategies'
}

{ #category : 'instance creation' }
PSPBagApplicationMethodStrategy class >> setUpForApplicationPackages: aListOfPackages [

	^ self new
		  setUpForApplicationPackages: aListOfPackages;
		  yourself
]

{ #category : 'private' }
PSPBagApplicationMethodStrategy >> isApplicationMethod: aCompiledMethod [

	^ applicationPackages includes: aCompiledMethod package
]

{ #category : 'api' }
PSPBagApplicationMethodStrategy >> setUpForApplicationPackages: aListOfPackages [

	applicationPackages := aListOfPackages asSet
]

{ #category : 'api' }
PSPBagApplicationMethodStrategy >> trimChain: aFullChain forBag: aPSPStackBag [

	| index |
	aFullChain isEmpty ifTrue: [ ^ OrderedCollection new ].
	applicationPackages
		ifNil: [ ^ OrderedCollection new ]
		ifNotNil: [ applicationPackages isEmpty ifTrue: [ ^ OrderedCollection new ] ].

	index := aFullChain findFirst: [ :each |
		         self isApplicationMethod: each method ].
	index = 0 ifTrue: [ ^ OrderedCollection new ].

	^ (aFullChain first: index) asOrderedCollection
]
