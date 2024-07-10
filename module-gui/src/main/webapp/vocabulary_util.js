var recordMainValue = function(record, vocabulary) {
	if(!record) {
		return "";
	}
	let mainEntryLabel = vocabulary.struct.find(s => s.mainEntry).label;
	return record.fields.find(f => f.label == mainEntryLabel).value;
}

var recordTitle = function(record, vocabulary) {
	if(!record) {
		return "";
	}
	let titleLabels = vocabulary.struct.filter(s => s.titleField).map(s => s.label);
	let title = "";
	for(let label of titleLabels) {
		let value = record.fields.find(f => f.label == label).value;
		title += value + " ";
	}
	return title;
}

var vocabularyForMetadataType = function(mappings, metadataType, vocabularies) {
	let mapping = mappings.find(m => m.metadataType == metadataType);
	if(!mapping) {
		return null;
	}
	return vocabularies[mapping.sourceVocabulary];
}

var recordFromMainEntry = function(mainEntry, metadatatype, groupMappings, vocabulary) {
	let mappings = groupMappings[0].mappings;
	if(!vocabulary) {
		return {fields: []};
	}
	let mainEntryLabel = vocabulary.struct.find(str => str.mainEntry).label;
	let record = vocabulary.records.find(record => record.fields.filter(field => field.label == mainEntryLabel && field.value == mainEntry).length>0);
	return record;
}

export {recordMainValue, recordTitle, vocabularyForMetadataType, recordFromMainEntry}