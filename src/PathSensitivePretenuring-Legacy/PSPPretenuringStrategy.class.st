Class {
	#name : 'PSPPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Legacy-Graph-Traversal',
	#package : 'PathSensitivePretenuring-Legacy',
	#tag : 'Graph-Traversal'
}

{ #category : 'api' }
PSPPretenuringStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: pathUntilNow [

	pathUntilNow ifEmpty: [ ^ false ].
	^ pathUntilNow last isLongLived
]

{ #category : 'instance creation' }
PSPPretenuringStrategy >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
]
