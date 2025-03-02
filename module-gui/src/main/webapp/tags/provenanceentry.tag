<provenanceentry>
    <div class="provenance-entry">
        Provenienz: {props.groupValue.type}
        <div class="action">
        	<!-- BUTTON to delete the provenance entry -->
            <a onclick={deleteProvenance}>
              <span class="fa fa-minus-circle" aria-hidden="true" />
            </a>
        </div>
    </div>

    <div class="form-row" each={key in Object.keys(props.groupValue.values)} if={key != 'type'}>
    	<!-- FIELD LABEL -->
        <div class="form-label">
			{msg('ruleset_' + key)}
        </div>
        <!-- // FIELD LABEL -->

        <!-- FIELD VALUE -->
        <div class="form-input">

            <span onmouseover={() => showPopover(key)} onmouseout={() => hidePopover(key)}>

                <input class="form-control" disabled value={recordTitle(props.groupValue.values[key], key)}></input>

            </span>

            <div
                class="popover fade top in {key}"
                style="{state.showPopover[key] ? 'display: block;' : ''} top: {state.popoverTop}px;">
                <table class="table">
                    <tbody>
                        <tr each={recordField in recordFromId(props.groupValue.values[key], key).fields}>
                            <td>{recordField.label}</td>
                            <td>{recordField.value}</td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </div>
        <!-- // FIELD VALUE -->
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
        .popover {
            border-color: #E8860C !important;
        }
        .table tbody tr:first-child td {
            border-top: none;
        }
    </style>

    <script>
    	import {vocabularyForMetadataType, recordMainValue, recordFromMainEntry, recordTitle} from '../vocabulary_util.js';
    	export default {
    		/* triggered before mounting */
    		onBeforeMount() {
    			this.state = {
    					showPopover: {}
        			};
    		},

    		onMount() {
    		},

    		/* triggered when the button fa-minus-circle is clicked */
    		deleteProvenance() {
    			console.log("deleting me");
    			// deleteValue is defined in box.tag as getDeleteValueFromFieldFunction
    			this.props.deleteValue();
    		},

    		/* used to retrieve values from msg */
    		msg(key) {
				return this.props.msg(key);
			},

			/*  */
			mainEntryForGroupValue(groupValueType, groupValue) {
				let mappings = this.props.field.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, groupValueType, this.props.vocabularies);
				if(vocabulary) {
					return recordMainValue(groupValue, vocabulary);
				}
				return groupValue;
			},

			/* used to get records from id */
			recordFromId(id, metadatatype) {
				console.log("recordFromId is called with id = " + id);
				let mappings = this.props.field.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, metadatatype, this.props.vocabularies);
				if(!vocabulary) {
					return {fields: []};
				}

				if (isNaN(id)){
					id = this.retrieveId(id);
				}

				let record = vocabulary.records.filter(r => r.id == id)[0];

				console.log("record = ");
				console.log(record);

				if(!record) {
					return {fields: []};
				}
				return record;
			},

			/* used to get record title from id */
			recordTitle(id, metadatatype) {
				let mappings = this.props.field.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, metadatatype, this.props.vocabularies);
				if(!vocabulary) {
					return id;
				}

				if (isNaN(id)){
					id = this.retrieveId(id);
				}

				let record = vocabulary.records.filter(r => r.id == id)[0];
				// the imported function is meant here
				return recordTitle(record, vocabulary);
			},

			/* used to retrieve id at reloading time from the string in the format /vocabularies/{vocabularyId}/{recordId} */
			retrieveId(idString){
				let parts = idString.split("/");
				return parts[parts.length - 1];
			},

			/*  */
			showPopover(key) {
				if(this.recordFromId(this.props.groupValue.values[key], key).fields.length==0) {
					return;
				}
				this.state.showPopover[key] = true;
				this.update();
				this.state.popoverTop = -this.$('.popover.' + key).clientHeight + 15;
				this.update();
			},

			/*  */
			hidePopover(key) {
				this.state.showPopover[key] = false;
				this.update();
			}
    	}
    </script>

</provenanceentry>