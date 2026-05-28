Class {
	#name : 'ApplicationMethodPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#instVars : [
		'applicationPackages'
	],
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'initialization' }
ApplicationMethodPretenuringStrategy class >> setUpForApplicationPackages: aListOfPackages [

    ^ self new
          setUpForApplicationPackages: aListOfPackages;
          yourself
]

{ #category : 'private' }
ApplicationMethodPretenuringStrategy >> isApplicationMethod: aCompiledMethod [

    ^ applicationPackages includes: aCompiledMethod package
]

{ #category : 'private' }
ApplicationMethodPretenuringStrategy >> setUpForApplicationPackages: aListOfPackages [

    applicationPackages := aListOfPackages asSet
]

{ #category : 'api' }
ApplicationMethodPretenuringStrategy >> trimChain: aFullChain forBag: aBag [
	"Walk the chain from the deepest sender upward; keep the prefix up to and including
	the first frame whose method's package is in #applicationPackages. If no frame is in
	an application package, return empty so the bag is skipped (matches the legacy DFS
	behaviour, which would never have recorded such a chain)."

	| index |
	aFullChain isEmpty ifTrue: [ ^ OrderedCollection new ].
	(applicationPackages isNil or: [ applicationPackages isEmpty ]) ifTrue: [
		^ OrderedCollection new ].
	index := aFullChain findFirst: [ :each |
		         self isApplicationMethod: each method ].
	index = 0 ifTrue: [ ^ OrderedCollection new ].
	^ (aFullChain first: index) asOrderedCollection
]
