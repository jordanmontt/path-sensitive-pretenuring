Class {
	#name : 'PSPPretenuringStrategy100',
	#superclass : 'PSPPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'instance creation' }
PSPPretenuringStrategy100 >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
		  ambiguityThreshold: 1;
		  yourself
]
