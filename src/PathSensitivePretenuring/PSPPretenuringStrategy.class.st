Class {
	#name : 'PSPPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'instance creation' }
PSPPretenuringStrategy >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
]

{ #category : 'api' }
PSPPretenuringStrategy >> trimAllocationPath: allocationPath forBag: aBag [

	"pathUntilNow ifEmpty: [ ^ false ].
	^ pathUntilNow last isLongLived"

	^ allocationPath
]
