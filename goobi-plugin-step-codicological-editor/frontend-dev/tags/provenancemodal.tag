<provenancemodal>
<div class="my-modal-bg" onclick={props.hide}>
	<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
		<div class="box-title">
			<span>{props.field.name}</span>
			<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
		</div>
        <div class="box-content">
            <template each={group in props.field.groupMappings}>
                <template each={mapping in group.mappings}>
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
                                <td><button class="btn btn-primary" onclick={() => addValue(mapping, value)}><i class="fa fa-check"></i></button></td>
                            </tr>
                        </tbody>
                    </table>
                    <Vocabentryform 
                        vocabname={mapping.sourceVocabulary} 
                        vocabularies={props.vocabularies}
                        entryCreated={entryCreated} 
                        msg={props.msg}>
                    </Vocabentryform>
                </template>
                <table class="table">
                    <thead>
                        <tr>
                            <th each={mapping in group.mappings}>
                                {mapping.metadataType}
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td each={mapping in group.mappings}>
                                {recordMainValue(state.result[mapping.metadataType], mapping.sourceVocabulary)}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </template>
        </div>
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
		min-width: 50vw;
        max-width: 50vw;
	}
	.my-modal-bg .box .box-title {
		color: white;
        font-size: 16px;
	}
    .my-modal-bg .box .box-content {
        max-height: 90vh;
        overflow-y: auto;
    }
</style>

<script>
import Vocabentryform from './vocabentryform.tag'
export default {
	components: {
    	Vocabentryform
	},
	onBeforeMount(state, props) {
		this.listenerFunction = this.keyListener.bind(this);
		document.addEventListener("keyup", this.listenerFunction);
		this.state = {
			filteredVocabs: {},
			result: {},
			searchTerms: {},
		}
	},
	onMounted() {
		let vocabs = this.props.vocabularies;
		let field = this.props.field;
		this.state = {
			vocabs: {...vocabs},
			filteredVocabs: {},
			result: {},
			searchTerms: {},
		}
		console.log(this.state)
	},
	onBeforeUnmount() {
    	document.removeEventListener("keyup", this.listenerFunction);
    },
    keyListener(e) {
    	if(e.key == "Escape") {
    		this.props.hide();
    	}
    },
	msg(key) {
		return this.props.msg(key);
	},
	filterVocabulary(vocabularyName, e) {
		let term = e.target.value.toLowerCase();
		if(term.length < 3 || !this.state.vocabs[vocabularyName]) {
			this.state.filteredVocabs[vocabularyName] = null;
			this.update();
			return;
		}
		this.state.searchTerms[vocabularyName] = term;
		this.state.filteredVocabs[vocabularyName] = this.state.vocabs[vocabularyName].records.filter(val => {
			return val.fields.map(f => f.value.toLowerCase()).join(" ").indexOf(term) >= 0;
		})
		this.update();
	},
	addValue(mapping, value) {
		this.state.result[mapping.metadataType] = value;
		this.state.filteredVocabs[mapping.sourceVocabulary] = null;
		this.state.searchTerms[mapping.sourceVocabulary] = "";
		this.update();
	},
	entryCreated(entry) {
		console.log("modal:", entry)
	},
	valueOrEmpty(fields, label) {
		let field = fields.find(v => v.label == label);
		if(field) {
			return field.value
		}
		return "";
	},
	recordMainValue(record, vocabName) {
		if(!record) {
			return "";
		}
		let mainEntryLabel = this.props.vocabularies[vocabName].struct.find(s => s.mainEntry).label
		return record.fields.find(f => f.label == mainEntryLabel).value
	}
}

</script>
</provenancemodal>