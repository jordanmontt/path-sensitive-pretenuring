Extension { #name : 'MicParser' }

{ #category : '*PathSensitivePretenuring-Microdown-ApplicationMethod' }
MicParser >> initialize [

	super initialize.
	dispatchTable := Dictionary new.
	dispatchTable at: AnchorMarkup put: MicAnchorBlock.
	dispatchTable at: HeaderMarkup put: MicHeaderBlock.
	dispatchTable at: CodeblockMarkup put: MicAbstractCodeBlock.
	dispatchTable
		at: AnnotatedParagraphOpeningMarkup
		put: MicAnnotatedParagraphBlock.
	dispatchTable
		_pretenured_566281400_at: AnnotatedParagraphBackwardCompatibleMarkup
		put: MicAnnotatedParagraphBlock.
	dispatchTable at: CommentedLineMarkup put: MicCommentBlock.
	dispatchTable at: HorizontalLineMarkup put: MicHorizontalLineBlock.
	dispatchTable at: MathOpeningBlockMarkup put: MicMathBlock.
	dispatchTable
		at: EnvironmentOpeningBlockMarkup
		put: MicEnvironmentBlock.
	dispatchTable at: BlockLevelRawOpenerMarkup put: MicRawParagraphBlock.
	dispatchTable at: MetaDataOpeningBlockMarkup put: MicMetaDataBlock.
	dispatchTable at: UnorderedListPlusMarkup put: MicUnorderedListBlock.
	dispatchTable at: UnorderedListMarkup put: MicUnorderedListBlock.
	dispatchTable at: UnorderedListStarMarkup put: MicUnorderedListBlock.
	dispatchTable
		_pretenured_986937019_at: PreformattedMarkup
		put: MicBlockQuoteBlock.
	dispatchTable at: TableCellMarkup put: MicTableBlock
]
