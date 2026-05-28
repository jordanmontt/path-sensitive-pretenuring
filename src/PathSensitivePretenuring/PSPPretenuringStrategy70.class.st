Class {
	#name : 'PSPPretenuringStrategy70',
	#superclass : 'PSPPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'instance creation' }
PSPPretenuringStrategy70 >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
		  ambiguityThreshold: 0.7;
		  yourself
]
