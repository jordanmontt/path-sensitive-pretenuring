Extension { #name : 'FMFutureProperty' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FMFutureProperty >> referenceNumber: serial [

	self addToValues: (self importer entityAt: serial ifAbsent: [
				 self importer
					 dangling: (FMDanglingReference _pretenured_872263312_with: self)
					 to: serial ])
]
