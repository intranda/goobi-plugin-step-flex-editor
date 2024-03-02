<provenancemodal>
<!-- hide is defined in box.tag as hideProvenanceModal -->
<div class="my-modal-bg" onclick={props.hide}>
	<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
		<!-- BOX TITLE -->
		<div class="box-title">
			<span>{props.field.name}</span>
			<!-- hide is defined in box.tag as hideProvenanceModal -->
			<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
		</div>
        <!-- // BOX TITLE -->
        
        <!-- BOX CONTENT -->
        <div class="box-content">
        	<!-- TEMPLATE for group mappings -->
            <template each={group in props.field.groupMappings}>
            	<!-- TEMPLATE for mappings -->
                <template each={mapping in group.mappings}>
                    <!-- Mounted when mapping does NOT have a valid sourceVocabulary attribute -->
                    <template if={!mapping.sourceVocabulary}>
                        <div class="form-group">
                          <label for="input{mapping.metadataType}">{msg('ruleset_' + mapping.metadataType)}</label>
                          <input 
                            type="input" 
                            class="form-control" 
                            id="input{mapping.metadataType}" 
                            placeholder="{msg('ruleset_' + mapping.metadataType)}" 
                            value={state.result[mapping.metadataType]}
                            onkeyup={(e) => updateResult(mapping.metadataType, e)}>
                        </div>
                    </template>
                    
                    <!-- Mounted when mapping has a valid sourceVocabulary attribute -->
                    <template if={mapping.sourceVocabulary}>
                    	<!-- Text input to search for existing entry -->
                        <div class="form-group">
                          <label for="search{mapping.sourceVocabulary}">{mapping.sourceVocabulary} durchsuchen</label>
                          <input 
                            type="input" 
                            class="form-control" 
                            id="search{mapping.sourceVocabulary}" 
                            placeholder="{mapping.sourceVocabulary} durchsuchen" 
                            value={state.searchTerms[mapping.sourceVocabulary]}
                            onkeyup={(e) => filterVocabulary(mapping.sourceVocabulary, e)}>
                        </div>
                        
                        <!-- Table of matched results -->
                        <table class="table" if={state.filteredVocabs[mapping.sourceVocabulary] && state.filteredVocabs[mapping.sourceVocabulary].length != 0}>
                            <thead>
                                <tr>
                                    <th each={field in props.vocabularies[mapping.sourceVocabulary].struct}>{field.label}</th>
                                    <th>Aktion</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr each={value in state.filteredVocabs[mapping.sourceVocabulary]}>
                                    <td each={field in props.vocabularies[mapping.sourceVocabulary].struct}>
                                        {valueOrEmpty(value.fields, field.label)}
                                    </td>
                                    <!-- BUTTON to add this entry -->
                                    <td><button class="btn btn-primary" onclick={() => addValue(mapping, value)}><i class="fa fa-check"></i></button></td>
                                </tr>
                            </tbody>
                        </table>
                        
                        <!-- COMPONENT of `Neu anlegen` -->
                        <Vocabentryform 
                            vocabname={mapping.sourceVocabulary} 
                            vocabularies={props.vocabularies}
                            entryCreated={entryCreated} 
                            msg={props.msg}>
                        </Vocabentryform>
                    </template>
                    
                </template>
                <!-- // TEMPLATE for mappings -->
                
                <!-- RESULT TABLE -->
                <table class="table result-table" if={anyResults()}>
                    <thead>
                        <tr>
                            <th each={mapping in group.mappings}>
                                {msg('ruleset_' + mapping.metadataType)}
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td each={mapping in group.mappings}>
                                {getPrettyVocabValue(mapping, state.result[mapping.metadataType])}
                            </td>
                        </tr>
                    </tbody>
                </table>
                <!-- // RESULT TABLE -->
            </template>
            <!-- TEMPLATE for group mappings -->
            
            <!-- BUTTON to add new Provenienz -->
            <button class="btn btn-primary pull-right confirm-button" onclick={addEntry}>Provenienz hinzufügen</button>
        </div>
        <!-- // BOX CONTENT -->
    </div>
</div>

<style>
   .my-modal-bg {
		display: flex;
		justify-content: center;
		align-items: center;
		position: fixed;
		top: 0px;
		right: 0px;
		bottom: 0px;
		left: 0px;
		background-color: rgba(255, 255, 255, 0.5);
        z-index: 9999;
	}
	.icon-only-button {
		background: none;
		border: none;
		padding-right: 10px;
	}
	.my-modal-bg .box {
		min-width: 85vw;
        max-width: 85vw;
	}
	.my-modal-bg .box .box-title {
		color: white;
        font-size: 16px;
	}
    .my-modal-bg .box .box-content {
        max-height: 90vh;
        overflow-y: auto;
    }
    .table {
        border: 1px solid #ddd;
    }
    .box.box-bordered .table {
        margin-bottom: 15px;
    }
    .confirm-button {
        margin-bottom: 10px;
    }
</style>

<script>
import Vocabentryform from './vocabentryform.tag';
import {recordMainValue, recordTitle} from '../vocabulary_util.js';
export default {
	components: {
    	Vocabentryform
	},
	
	/* triggered before mounting */
	onBeforeMount(state, props) {
		this.listenerFunction = this.keyListener.bind(this);
		document.addEventListener("keyup", this.listenerFunction);
		this.state = {
			filteredVocabs: {},
			result: {},
			searchTerms: {},
		};
	},
	
	/* triggered after the component is mounted */
	onMounted() {
		let vocabs = this.props.vocabularies;
		let field = this.props.field;
		this.state = {
			vocabs: {...vocabs},
			filteredVocabs: {},
			result: {},
			searchTerms: {},
		};
		console.log(this.state);
	},
	
	/* triggered before unmounting */
	onBeforeUnmount() {
    	document.removeEventListener("keyup", this.listenerFunction);
    },
    
    /* listener function of the key */
    keyListener(e) {
    	if(e.key == "Escape") {
    		// hide is defined in box.tag as hideProvenanceModal
    		this.props.hide();
    	}
    },
    
    /* used to retrieve values from msg */
	msg(key) {
		return this.props.msg(key);
	},
	
	/* triggered when any text input for `... durchsuchen` gets an input, used to get a filtered vocabulary list according to the input */
	filterVocabulary(vocabularyName, e) {
		let term = e.target.value.toLowerCase();
		if(term == "*") {
			this.state.filteredVocabs[vocabularyName] = this.state.vocabs[vocabularyName].records;
			this.update();
			return;
		}
		if(term.length < 3 || !this.state.vocabs[vocabularyName]) {
			this.state.filteredVocabs[vocabularyName] = null;
			this.update();
			return;
		}
		this.state.searchTerms[vocabularyName] = term;
		this.state.filteredVocabs[vocabularyName] = this.state.vocabs[vocabularyName].records.filter(val => {
			return val.fields.map(f => f.value.toLowerCase()).join(" ").indexOf(term) >= 0;
		});
		this.update();
	},
	
	/* triggered when the button in the column `Aktion` for a record is clicked */
	addValue(mapping, value) {
		console.log(value);
		this.state.result[mapping.metadataType] = value.id;
		this.state.filteredVocabs[mapping.sourceVocabulary] = null;
		this.state.searchTerms[mapping.sourceVocabulary] = "";
		this.update();
	},
	
	/* triggered when the result table is generated, used to formulate pretty vocabular values */
	getPrettyVocabValue(mapping, value) {
		if(value == undefined) {
			return undefined;
		}
		if(mapping.sourceVocabulary) {
			let vocabulary = this.state.vocabs[mapping.sourceVocabulary];
			let record = vocabulary.records.filter(r => r.id == value)[0];
			return recordTitle(record, vocabulary); 
		}
		return value;
	},
	
	/* triggered when the text input of a mapping without a valid sourceVocabulary attribute gets an input */
	updateResult(metadataType, event) {
		this.state.result[metadataType] = event.target.value;
		this.update();
	},
	
	/* triggered when the button `Provenienz hinzufügen` is clicked */
	addEntry() {
		this.props.field.values.push({
			groupValue: {
				values: this.state.result,
				groupName: this.props.field.groupMappings[0].groupName	
			}
		});
		//console.log(this.props.valuesChanged, this.props.hide)
		// valuesChanged is defined in box.tag as valuesChanged
		this.props.valuesChanged();
		// hide is defined in box.tag as hideProvenanceModal
		this.props.hide();
	},
	
	/* used to check if the result table should be shown */
	anyResults() {
		return Object.values(this.state.result).filter(val => !!val).length > 0;
	},
	
	/* used to retrieve values of fields if they exist, otherwise empty string */
	valueOrEmpty(fields, label) {
		let field = fields.find(v => v.label == label);
		if(field) {
			return field.value;
		}
		return "";
	},
	
	/*  */
	recordMainValue(record, vocabName) {
		if(vocabName) {
    		let vocabulary = this.props.vocabularies[vocabName];
    		// The imported one is meant here.
    		return recordMainValue(record, vocabulary);
		}
		return record;
	},
	
	/* used in the vocabentryform.tag as entryCreated */
	entryCreated(entry) {
		console.log("entry created", entry);
		this.state.vocabs[entry.vocabName].records.push(entry.record);
	}
}

</script>
</provenancemodal>