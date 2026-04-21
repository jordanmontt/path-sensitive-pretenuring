Extension { #name : 'NeoCSVReader' }

{ #category : '*PathSensitivePretenuring-DataFrame-CallerOfNew' }
NeoCSVReader >> _pretenured_349331367_recordClassNew: size [

	^ recordClass newTenured: size
]

{ #category : '*PathSensitivePretenuring-DataFrame-CallerOfNew' }
NeoCSVReader >> readNextRecord [

	| record |
	record := self _pretenured_349331367_recordClassNew: fieldCount.
	fieldAccessors
		ifNil: [ self readNextRecordWithoutFieldAccessors: record ]
		ifNotNil: [ self readNextRecordWithFieldAccessors: record ].
	self handleEndOfRecord.
	^ record
]
