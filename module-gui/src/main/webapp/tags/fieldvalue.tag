<fieldvalue class="w-100">
	<!-- VOCABULAR ERROR -->
    <span class="text-danger error" if={state.vocabError}>{state.vocabError}</template>

    <!-- Mount the following template when there is no VOCABULAR ERROR -->
    <template if={!state.vocabError && fieldPrepared()}>
    	<!-- INPUT -->
    	<input type="text" class="form-control" onkeyup={changeValue} if={props.field.type == 'INPUT'} value={props.field.values[0].value}></input>

    	<!-- TEXTAREA -->
    	<textarea id="{convertToSlug(props.field.name) + '_textarea'}" class="form-control" onkeyup={changeValue} if={props.field.type == 'TEXTAREA'} rows="1" >{props.field.values[0].value}</textarea>

    	<!-- BOOLEAN -->
    	<input type="checkbox" class="form-check-input" onchange={changeValue} checked={checkBoxChecked(props.field.values)} if={props.field.type == 'BOOLEAN'}></input>

    	<!-- DROPDOWN -->
    	<div class="select" if={props.field.type == 'DROPDOWN'} onclick={toggleExpandMulti}>
    		<span class="form-control">
                <span class="multiselect-label" >
                    {props.field.values.length > 0 ? props.field.values[0].value : props.field.name + ' - auswählen'}
                </span>
    		</span>
            <div class="multiselect-options" if={state.multiExpanded}>
                <ul>
                    <li onclick={ (e) => selectEntry(e, null)}>
                        {props.field.name + ' - auswählen'}
                    </li>
                    <li
                        each={record in state.vocab.records} onclick={ (e) => selectEntry(e, record) }
                        selected={props.field.values.length != 0 && record.fields[state.vocabFieldIdx].value == props.field.values[0].value}>
                        {record.fields[state.vocabFieldIdx].value}
                    </li>
                </ul>
            </div>
    	</div>
    	<!-- // DROPDOWN -->

    	<!-- MULTISELECT -->
    	<div class="multiselect" if={props.field.type == 'MULTISELECT'} onclick={toggleExpandMulti}>
    		<span class="form-control">
    			<span class="multiselect-label">
    				{props.field.name} - auswählen
    			</span>
    			<span class="multiselect-icon">
    				<span class="fa fa-caret-down" if={!state.multiExpanded} aria-hidden="true" />
    				<span class="fa fa-caret-up" if={state.multiExpanded} aria-hidden="true" />
    			</span>
    		</span>
    		<div class="multiselect-options" if={state.multiExpanded}>
    			<ul>
    				<li each={record in state.vocab.records} onclick={ (e) => toggleEntry(e, record) }>
    					<input type="checkbox" checked={props.field.values.filter(val => val.value == record.fields[state.vocabFieldIdx].value).length > 0}>
    					{record.fields[state.vocabFieldIdx].value}
    				</li>
    			</ul>
    		</div>
    		<div class="multiselect-values">
    			<span class="badge" each={value in props.field.values}>{value.value}</span>
    		</div>
    	</div>
    	<!-- // MULTISELECT -->
	</template>

	<style>
		.multiselect {
			cursor: pointer;
			position: relative;
		}
		.multiselect .form-control {
			display: flex;
		}
		.multiselect .form-control .multiselect-label {
			flex-grow: 1;
            overflow: hidden;
		}
		.multiselect-options {
			position: absolute;
			top: 25px;
			left: 0px;
			right: 0px;
			border: 1px solid #ccc;
            border-top: none;
			background-color: #fff;
			z-index: 1;
            max-height: 30vh;
            overflow-y: auto;
		}
		.multiselect-options ul {
			padding-left: 0px;
			list-style-type: none;
			margin-bottom: 0px;
		}
		.multiselect-options ul li {
			padding-left: 12px;
		}
		.multiselect-options ul li input[type="checkbox"] {
			margin-right: 5px;
		}
		.multiselect-options ul li:hover {
			padding-left: 12px;
			background-color: #3584e4;
			color: white;
		}
		.multiselect .multiselect-values {
			margin-top: 10px;
		}

		.multiselect .multiselect-values .badge {
			margin-right: 5px;
		}

		.select {
			position: relative;
			display: block;
		}
		.select:after {
			font-family: FontAwesome;
			content:"\f0d7";
			padding: 0px 12px;
		    position: absolute; right: 0; top: 0;
		    color: #000;
	     z-index: 1;
		}
        .select .multiselect-options ul li {
            cursor: default;
        }
        .multiselect-options ul li[selected] {
            padding-left: 12px;
            background-color: #3584e4;
            color: white;
        }
        .error {
            padding: 2px;
        }
        textarea.form-control {
            resize: vertical;
            height: 25px;
        }
	</style>
	<script>
		export default {
			/* triggered before mounting */
		    onBeforeMount() {
		        this.state = {
		            vocab: {},
		            vocabFieldIdx: -1,
		            multiExpanded: false
		        };
		        //this.fillField();
		    },

		    /* triggered after mounted */
		    onMounted() {
		    	this.init(true);
		    },

		    /* triggered before update */
		    onBeforeUpdate() {
		    	this.init(false);
		    },

		    /* triggered whenever a new mounting or an update takes place */
		    init(update) {
		    	var field = this.props.field;
		        if(field.sourceVocabularies && field.sourceVocabularies.length > 0 && this.state) {
		            this.state.vocab = this.props.vocabularies[field.sourceVocabularies] || {stub: true, struct: [], records: [{fields:[]}]};
					console.log(field.sourceVocabularies);
					console.log(this.props.vocabularies[field.sourceVocabularies]);
					if(this.state.vocab.stub) {
		            	this.state.vocabError = `Vocabulary "${field.sourceVocabularies}" was not found`;
		            	if(update) {
		            		this.update();
		            	}
		            	return;
		            } else {
		            	this.state.vocabError = null;
		            }
		            this.state.vocabFieldIdx = this.state.vocab.struct.findIndex(f => f.mainEntry);
		            if(update) {
		            	this.update();
		            }
		        }
		        switch(field.type) {
		            case "BOOLEAN":
		            	console.log(field.values[0]);
		            	if(field.values.length == 0) {
		                	field.values[0] = {value: false};
		            	}
		                break;
		            case "INPUT":
		            case "TEXTAREA":
		            	if(field.values.length == 0) {
		                	field.values[0] = {value: ""};
		            	}
		            	var textarea = this.$('#' + this.convertToSlug(this.props.field.name) + '_textarea');
		            	if(textarea) {
		            		this.setTextAreaHeight(textarea);
		            	}
		                break;
		            case "DROPDOWN":
		                break;
		            case "MULTISELECT":
		                break;
		        }
		        this.closeHandler = document.addEventListener('click', (e) => this.closeMulti(e));
		    },

		    /* used to check if the field is prepared to load the component */
		    fieldPrepared() {
		    	var field = this.props.field;
		    	return field.values.length > 0 || field.type == "MULTISELECT" || field.type == "DROPDOWN";
		    },

		    /* used as callback for closeHandler */
		    closeMulti(e) {
		        if(this.state.multiExpanded) {
		            e.stopPropagation();
				    this.state.multiExpanded = false;
				    this.update();
		        }
		    },

		    /* triggered when a multiselector or a drop down list is clicked */
		    toggleExpandMulti(e) {
		      e.stopPropagation();
		      this.state.multiExpanded = !this.state.multiExpanded;
		      this.update();
		      if(this.state.multiExpanded && this.props.field.type == "DROPDOWN") {
		    	  var selected = this.$('li[selected]');
		    	  if(selected) {
		    		// scroll active element into view
		    		var parent = selected.parentElement.parentElement;
		    		var offset = selected.offsetTop;
		    		parent.scrollTop = offset - parent.offsetHeight/2;
					this.update();
		    	  }
		      }
		    },

		    /* triggered when an item form the multiselector is selected */
		    toggleEntry(e, record) {
		        e.stopPropagation();
		      	var field = this.props.field;
		      	var recordValue = record.fields[this.state.vocabFieldIdx].value;
		      	var idx = field.values.findIndex(val => val.value == recordValue);
		      	if(idx < 0) {
		      	    field.values.push({value: recordValue});
		      	} else {
		      	    field.values.splice(idx, 1);
		      	    this.props.field.values = field.values;
		      	}
		      	this.update();
		    },

		    /* triggered when an item from the drop down list is selected */
		    selectEntry(e, record) {
		    	e.stopPropagation();
		    	var field = this.props.field;
		    	if(!record) {
		    		field.values = [];

		    	} else {
			      	var recordValue = record.fields[this.state.vocabFieldIdx].value;
		      		field.values = [{value: recordValue}];
		    	}
		      	this.state.multiExpanded = false;
		      	this.update();
		    },

		    /* triggered when the value of an input is changed */
		    changeValue(e) {
		        var field = this.props.field;
		        switch(field.type) {
		            case "BOOLEAN":
		                field.values[0].value = e.target.checked;
		                break;
		            case "INPUT":
		                field.values[0].value = e.target.value;
		                break;
		            case "TEXTAREA":
		                field.values[0].value = e.target.value;
		                this.setTextAreaHeight(e.target, e);
		                break;
		            case "DROPDOWN":
		                break;
		            case "MULTISELECT":
		                break;
		        }
		        //console.log(field);
		    },

		    /* used to set the height of a textarea */
		    setTextAreaHeight(area, e) {
		        if(area.offsetHeight < area.scrollHeight) {
                    area.style.height = (area.scrollHeight + 5) + "px";
                }
                if(e !== undefined && (e.key == "Delete" || e.key == "Backspace" || (e.key == "x" && e.ctrlKey))) {
                    area.style.height = 5 + "px";
                    if(area.offsetHeight < area.scrollHeight) {
	                    area.style.height = (area.scrollHeight + 5) + "px";
	                }
                }
		    },

		    /* used to generate ids for textareas */
		    convertToSlug(text){
		        return text.toLowerCase()
		            .replace(/ /g,'-')
		            .replace(/[^\w-]+/g,'');
		    },

		    /* triggered when any check box is clicked */
		    checkBoxChecked(values) {
		    	return values.length != 0
		    		&& typeof values[0].value == "string"
		    		&& values[0].value.toLowerCase() == "true";
		    }
		}
	</script>
</fieldvalue>