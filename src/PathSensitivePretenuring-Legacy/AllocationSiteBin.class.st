"
I am a simple data structure used for classifiying the allocation sites. Check my users
"
Class {
	#name : 'AllocationSiteBin',
	#superclass : 'Object',
	#instVars : [
		'immortalObjects',
		'longLivedObjects',
		'shortLivedObjects',
		'classification',
		'allocationSite'
	],
	#category : 'PathSensitivePretenuring-Legacy-Graph-Traversal',
	#package : 'PathSensitivePretenuring-Legacy',
	#tag : 'Graph-Traversal'
}

{ #category : 'api' }
AllocationSiteBin >> addImmortalObject: object [

	immortalObjects add: object
]

{ #category : 'api' }
AllocationSiteBin >> addLongLivedObject: object [

	longLivedObjects add: object
]

{ #category : 'api' }
AllocationSiteBin >> addShortLivedObject: object [

	shortLivedObjects add: object
]

{ #category : 'accessing' }
AllocationSiteBin >> allObjects [

	^ self longAndImmortalLivedObjects , self shortLivedObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> allocationSite [

	^ allocationSite
]

{ #category : 'accessing' }
AllocationSiteBin >> allocationSite: anAllocationGraphEdge [

    allocationSite := anAllocationGraphEdge
]

{ #category : 'accessing' }
AllocationSiteBin >> classification [

	^ classification
]

{ #category : 'accessing' }
AllocationSiteBin >> classification: obj [

	classification := obj
]

{ #category : 'testing' }
AllocationSiteBin >> containsClass: anObjClass [

	| block |
	block := [ :e | e allocatedObjectClass = anObjClass ].
	^ (longLivedObjects contains: block) or: [
		  (immortalObjects contains: block) or: [
			  shortLivedObjects contains: block ] ]
]

{ #category : 'accessing' }
AllocationSiteBin >> immortalObjects [

	^ immortalObjects
]

{ #category : 'initialization' }
AllocationSiteBin >> initialize [

	super initialize.
	immortalObjects := OrderedCollection new.
	longLivedObjects := OrderedCollection new.
	shortLivedObjects := OrderedCollection new
]

{ #category : 'inspector' }
AllocationSiteBin >> inspectorAllocSite: aBuilder [

    <inspectorPresentationOrder: 901 title: 'Allocation site'>
    ^ (IllMethodWithOffset method: allocationSite sourceNode offset: allocationSite offset)
          inspectorPresenter: aBuilder
]

{ #category : 'testing' }
AllocationSiteBin >> isAmbiguous [

	^ shortLivedObjects notEmpty and: [ longLivedObjects notEmpty or: [ immortalObjects notEmpty ] ]
]

{ #category : 'testing' }
AllocationSiteBin >> isImmortal [

	^ classification = #immortal
]

{ #category : 'testing' }
AllocationSiteBin >> isLong [

	^ classification = #long
]

{ #category : 'testing' }
AllocationSiteBin >> isLongOrImmortal [

	^ self isLong or: [ self isImmortal ]
]

{ #category : 'testing' }
AllocationSiteBin >> isShort [

	^ classification = #short
]

{ #category : 'accessing' }
AllocationSiteBin >> longAndImmortalLivedObjects [

	^ self longLivedObjects , self immortalObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> longLivedObjects [

	^ longLivedObjects
]

{ #category : 'printing' }
AllocationSiteBin >> printOn: aStream [

	| text |
	text := classification ifNil: [ '-' ].
	aStream << text << ' bin '
]

{ #category : 'accessing' }
AllocationSiteBin >> shortLivedObjects [

	^ shortLivedObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> totalAllocations [

	^ immortalObjects size + longLivedObjects size + shortLivedObjects size
]
