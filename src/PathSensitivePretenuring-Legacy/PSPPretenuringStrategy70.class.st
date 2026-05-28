Class {
	#name : 'PSPPretenuringStrategy70',
	#superclass : 'PSPPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Legacy-Graph-Traversal',
	#package : 'PathSensitivePretenuring-Legacy',
	#tag : 'Graph-Traversal'
}

{ #category : 'instance creation' }
PSPPretenuringStrategy70 >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
		  ambiguityThreshold: 0.7;
		  yourself
]
