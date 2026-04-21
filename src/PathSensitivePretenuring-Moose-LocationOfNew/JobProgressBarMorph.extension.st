Extension { #name : 'JobProgressBarMorph' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
JobProgressBarMorph >> initialize [

	super initialize.
	progressBar := ProgressBarMorph newTenured.
	progressBar hResizing: #spaceFill.
	self extent: 200 @ 20.
	self
		color: Color transparent;
		layoutPolicy: TableLayout new;
		listDirection: #leftToRight;
		cellPositioning: #leftCenter;
		cellInset: 3;
		listCentering: #center;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap.

	self
		addMorphBack: progressBar;
		addInterruptionButton
]
