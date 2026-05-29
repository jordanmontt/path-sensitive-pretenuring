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

{ #category : 'api' }
ApplicationMethodPretenuringStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ (self isApplicationMethod: anAllocationGraphNode)
      and: [ self edgesHaveSameAllocatedObjectTypes: aListOfEdges ]
]

{ #category : 'private' }
ApplicationMethodPretenuringStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package
]

{ #category : 'private' }
ApplicationMethodPretenuringStrategy >> setUpForApplicationPackages: aListOfPackages [

    applicationPackages := aListOfPackages asSet
]
