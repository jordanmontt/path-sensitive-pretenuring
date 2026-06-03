Class {
	#name : 'PSPPretenuringStrategy85',
	#superclass : 'PSPPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'instance creation' }
PSPPretenuringStrategy85 >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
		  ambiguityThreshold: 0.85;
		  yourself
]
