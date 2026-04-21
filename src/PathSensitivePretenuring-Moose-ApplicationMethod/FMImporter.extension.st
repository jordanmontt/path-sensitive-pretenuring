Extension { #name : 'FMImporter' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FMImporter >> dangling: reference to: serial [

	(reminderDict
		 _pretenured_382711116_at: serial
		 ifAbsentPut: [ OrderedCollection new ]) _pretenured_86169303_add:
		reference.
	numberOfDanglingReferences := numberOfDanglingReferences + 1.
	^ reference
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FMImporter >> entityAt: aSerial ifAbsent: aBlock [

	^ serialDict _pretenured_333867595_at: aSerial ifAbsent: aBlock
]
