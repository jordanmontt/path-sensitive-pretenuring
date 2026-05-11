Class {
	#name : 'PSPPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
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
