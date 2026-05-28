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
ApplicationMethodPretenuringStrategy >> trimAllocationPath: allocationPath forBag: aBag [

	| index |
	allocationPath isEmpty ifTrue: [ ^ {  } ].

	index := allocationPath findFirst: [ :each | self isApplicationMethod: each method ].	
	index = 0 ifTrue: [ ^ {  } ].

	^ (allocationPath first: index) asOrderedCollection
]
