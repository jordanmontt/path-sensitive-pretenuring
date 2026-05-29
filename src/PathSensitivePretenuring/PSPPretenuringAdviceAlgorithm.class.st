Class {
	#name : 'PSPPretenuringAdviceAlgorithm',
	#superclass : 'MerlinPretenuringAdviceAlgorithm',
	#instVars : [
		'ambiguityThreshold'
	],
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'initialization' }
PSPPretenuringAdviceAlgorithm >> ambiguityThreshold: aNumber [

	ambiguityThreshold := aNumber
]

{ #category : 'calculating' }
PSPPretenuringAdviceAlgorithm >> classifyAllocationSites [

	groupedAllocationSites keysAndValuesDo: [ :allocationGraphEdge :allocationSiteBin |
		| is ss ls wasClassified |
		wasClassified := false.
		is := allocationSiteBin immortalObjects sum: #sizeInBytes.
		ss := allocationSiteBin shortLivedObjects sum: #sizeInBytes.
		ls := allocationSiteBin longLivedObjects sum: #sizeInBytes.

		(is + ls) >= ((is + ls + ss) * ambiguityThreshold) ifTrue: [
			allocationSiteBin classification: #long.
			allocationGraphEdge beLongLived.
			wasClassified := true ].
		wasClassified ifFalse: [
			allocationSiteBin classification: #ambiguous.
			allocationGraphEdge beAmbiguous ] ]
]

{ #category : 'initialization' }
PSPPretenuringAdviceAlgorithm >> initialize [

	super initialize.
	ambiguityThreshold := 0.9
]
