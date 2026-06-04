Class {
	#name : 'PSPPretenuringStrategy90',
	#superclass : 'PSPPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'class initialization' }
PSPPretenuringStrategy90 class >> fileName [

   ^ 'psp90'
]

{ #category : 'instance creation' }
PSPPretenuringStrategy90 >> newClassificationAlgorithm [

	^ PSPPretenuringAdviceAlgorithm new
		  ambiguityThreshold: 0.9;
		  yourself
]
