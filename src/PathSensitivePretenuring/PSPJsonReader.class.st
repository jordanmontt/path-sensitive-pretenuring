Class {
	#name : 'PSPJsonReader',
	#superclass : 'Object',
	#instVars : [
		'jsonFileName'
	],
	#category : 'PathSensitivePretenuring',
	#package : 'PathSensitivePretenuring'
}

{ #category : 'as yet unclassified' }
PSPJsonReader >> jsonFileName: aString [

	jsonFileName := aString
]

{ #category : 'as yet unclassified' }
PSPJsonReader >> jsonsFolder [

	^ (FileLocator localDirectory / 'iceberg' / 'jordanmontt'
	   / 'path-sensitive-pretenuring' / 'pretenuredMethods')
		  asFileReference
]

{ #category : 'as yet unclassified' }
PSPJsonReader >> readJsons [

	| jsonFile jsonsAsDictionary |
	jsonFile := self jsonsFolder / jsonFileName.
	jsonsAsDictionary :=  NeoJSONReader fromString: jsonFile readStream contents.
	1halt.
	jsonsAsDictionary do: [ :aDictionary | 
		aDictionary at: #class ]
]
