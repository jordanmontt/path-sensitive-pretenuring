Class {
	#name : 'PSPPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'api' }
PSPPretenuringStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: allocationStack [

	allocationStack ifEmpty: [ ^ false ].
	^ allocationStack last isLongLived
]

{ #category : 'instance creation' }
PSPPretenuringStrategy >> newClassificationAlgorithm [

   ^ PSPPretenuringAdviceAlgorithm new
]
