<provenanceentry>
    <div class="provenance-entry">
        Provenienz: {props.groupValue.type}
        <div class="action">
            <a onclick={deleteProvenance}>
              <i class="fa fa-minus-circle"></i>
            </a>
        </div>
        
    </div>
    <div class="field-detail" each={key in Object.keys(props.groupValue.values)} if={key != 'type'}>
        <div class="field-label">
            <div class="label-text">
                {msg('ruleset_' + key)}
            </div>
        </div>
        <div class="value" style="position: relative;">
            <input class="form-control" disabled value={props.groupValue.values[key]} 
                onmouseover={() => showPopover(key)} 
                onmouseout={() => hidePopover(key)}></input>
            <div
                class="popover fade top in {key}" 
                style="{state.showPopover[key] ? 'display: block;' : ''} top: {state.popoverTop}px;">
                <table>
                    <tbody>
                        <tr each={recordField in recordFromMainEntry(props.groupValue.values[key], key).fields}>
                            <td>{recordField.label}</td>
                            <td>{recordField.value}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <style>
        .popover td {
            padding: 5px;
        }
        .form-control[disabled] {
            background-color: #fafafa
        }
        .provenance-entry {
            display: flex;
            width: 100%;
            padding: 10px;
            background-color: #f4f4f4;
            color: #555;
            text-decoration: underline;
            border-bottom: 1px solid #ddd;
        }
        .action {
            position: relative;
        }
        .action a {
            font-size: 16px;
            color: #777;
            cursor: pointer;
            position: absolute;
            top: -2px;
            left: 8px; 
        }
        .action a:hover {
            color: #9E9E9E;
        }
    </style>
    
    <script>
    	import {vocabularyForMetadataType, recordMainValue} from '../vocabulary_util.js'
    	export default {
    		onBeforeMount() {
    			this.state = {
    					showPopover: {}
        			}
    		},
    		onMount() {
    		},
    		deleteProvenance() {
    			console.log("deleting me");
    			this.props.deleteValue();
    		},
    		msg(key) {
				return this.props.msg(key);
			},
			mainEntryForGroupValue(groupValueType, groupValue) {
				let mappings = this.props.field.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, groupValueType, this.props.vocabularies);
				if(vocabulary) {
					return recordMainValue(groupValue, vocabulary);
				}
				return groupValue;
			},
			recordFromMainEntry(mainEntry, metadatatype) {
				let mappings = this.props.field.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, metadatatype, this.props.vocabularies);
				if(!vocabulary) {
					return {fields: []};
				}
				let mainEntryLabel = vocabulary.struct.find(str => str.mainEntry).label;
				let record = vocabulary.records.find(record => record.fields.filter(field => field.label == mainEntryLabel && field.value == mainEntry).length>0);
				return record;
			},
			showPopover(key) {
				this.state.showPopover[key] = true;
				this.update();
				this.state.popoverTop = -this.$('.popover.' + key).clientHeight + 15;
				this.update();
			},
			hidePopover(key) {
				this.state.showPopover[key] = false;
				this.update();
			}
    	}
    </script>

</provenanceentry>