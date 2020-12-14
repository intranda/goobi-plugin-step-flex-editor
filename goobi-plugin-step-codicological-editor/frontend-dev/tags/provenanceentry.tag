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
                {key}
            </div>
        </div>
        <div class="value">
            <input class="form-control" disabled value={mainEntryForGroupValue(key, props.groupValue.values[key])}></input>
        </div>
    </div>
    
    <style>
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
    			console.log(this.props)
    		},
    		deleteProvenance() {
    			this.props.deleteValue();
    		},
    		msg(key) {
				return this.props.msg(key);
			},
			mainEntryForGroupValue(groupValueType, groupValue) {
				console.log(this.props.field)
				let mappings = this.props.field.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, groupValueType, this.props.vocabularies);
				return recordMainValue(groupValue, vocabulary);
			}
    	}
    </script>

</provenanceentry>