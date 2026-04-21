Extension { #name : 'FMFutureProperty' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FMFutureProperty >> referenceNumber: serial [

	self addToValues: (self importer entityAt: serial ifAbsent: [
				 self importer
					 dangling: (FMDanglingReference _pretenured_487301992_with: self)
					 to: serial ])
]
