var recordMainValue = function(record, vocabulary) {
	if(!record) {
		return "";
	}
	let mainEntryLabel = vocabulary.struct.find(s => s.mainEntry).label;
	return record.fields.find(f => f.label == mainEntryLabel).value;
}

var vocabularyForMetadataType = function(mappings, metadataType, vocabularies) {
	let mapping = mappings.find(m => m.metadataType == metadataType);
	if(!mapping) {
		return null;
	}
	return vocabularies[mapping.sourceVocabulary];
}

export {recordMainValue, vocabularyForMetadataType}