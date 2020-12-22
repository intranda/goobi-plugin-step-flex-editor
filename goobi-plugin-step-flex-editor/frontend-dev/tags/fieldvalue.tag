<fieldvalue>
    <span class="text-danger error" if={state.vocabError}>{state.vocabError}</template>
    <template if={!state.vocabError && fieldPrepared()}>
    	<input type="text" class="form-control" onkeyup={changeValue} if={props.field.type == 'INPUT'} value={props.field.values[0].value}></input>
    	<textarea id="{convertToSlug(props.field.name) + '_textarea'}" class="form-control" onkeyup={changeValue} if={props.field.type == 'TEXTAREA'} >{props.field.values[0].value}</textarea>
    	<input type="checkbox" onchange={changeValue} checked={checkBoxChecked(props.field.values)} if={props.field.type == 'BOOLEAN'}></input>
    	<label class="select" if={props.field.type == 'DROPDOWN'}>
    		<select class="form-control" onchange={changeValue}>
    			<option 
                    each={record in state.vocab.records} 
                    value="{record.fields[state.vocabFieldIdx].value}" 
                    selected={record.fields[state.vocabFieldIdx].value == props.field.values[0].value}>
                    {record.fields[state.vocabFieldIdx].value}
                </option>
    		</select>
    	</label>
    	<div class="multiselect" if={props.field.type == 'MULTISELECT'} onclick={toggleExpandMulti}>
    		<span class="form-control">
    			<span class="multiselect-label">
    				{props.field.name} - auswählen
    			</span>
    			<span class="multiselect-icon">
    				<i class="fa fa-caret-down" if={!state.multiExpanded}></i>
    				<i class="fa fa-caret-up" if={state.multiExpanded}></i>
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
		}
		.multiselect .multiselect-options {
			position: absolute;
			top: 25px;
			left: 0px;
			right: 0px;
			border: 1px solid #ccc;
			background-color: #fff;
			z-index: 1; 
		}
		.multiselect .multiselect-options ul {
			padding-left: 0px;
			list-style-type: none;
			margin-bottom: 0px;
		}
		.multiselect .multiselect-options ul li {
			padding-left: 12px;
		}
		.multiselect .multiselect-options ul li input[type="checkbox"] {
			margin-right: 5px;
		}
		.multiselect .multiselect-options ul li:hover {
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
		select {
			-webkit-appearance: none;
			-moz-appearance: none;
			appearance: none;       /* Remove default arrow */
		}
		.select:after {
			font-family: FontAwesome;
			content:"\f0d7";
			padding: 0px 12px;
		    position: absolute; right: 0; top: 0;
		    color: #000;
	     z-index: 1;
		}
        .error {
            padding: 2px;
        }
        textarea {
            resize: vertical;
        }
	</style>
	<script>
		export default {
		    onBeforeMount() {
		        this.state = {
		            vocab: {},
		            vocabFieldIdx: -1,
		            multiExpanded: false
		        };
		        //this.fillField();
		    },
		    onMounted() {
		    	this.init(true)
		    },
		    onBeforeUpdate() {
		    	this.init(false)
		    },
		    init(update) {
		    	var field = this.props.field;
		        if(field.sourceVocabularies && field.sourceVocabularies.length > 0 && this.state) {
		            this.state.vocab = this.props.vocabularies[field.sourceVocabularies] || {stub: true, struct: [], records: [{fields:[]}]};
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
		            	console.log(field.values[0])
		            	if(field.values.length == 0) {
		                	field.values[0] = {value: false};
		            	}
		                break;
		            case "INPUT":
		            case "TEXTAREA":
		            	if(field.values.length == 0) {
		                	field.values[0] = {value: ""};
		            	}
		            	var textarea = this.$('#' + this.convertToSlug(this.props.field.name) + '_textarea')
		            	if(textarea) {
		            		this.setTextAreaHeight(textarea)
		            	}
		                break;
		            case "DROPDOWN":
		            	if(field.values.length == 0) {
		                	field.values[0] = {value: this.state.vocab.records[0].fields[this.state.vocabFieldIdx].value};
		            	}
		                break;
		            case "MULTISELECT":
		                break;
		        }
		        this.closeHandler = document.addEventListener('click', (e) => this.closeMulti(e))
		    },
		    fieldPrepared() {
		    	var field = this.props.field;
		    	return field.values.length > 0 || field.type == "MULTISELECT"; 
		    },
		    closeMulti(e) {
		        if(this.state.multiExpanded) {
		            e.stopPropagation();
				    this.state.multiExpanded = false;
				    this.update();
		        }
		    },
		    toggleExpandMulti(e) {
		      e.stopPropagation();
		      this.state.multiExpanded = !this.state.multiExpanded; 
		      this.update();
		    },
		    toggleEntry(e, record) {
		        e.stopPropagation();
		      	var field = this.props.field;
		      	var recordValue = record.fields[this.state.vocabFieldIdx].value;
		      	var idx = field.values.findIndex(val => val.value == recordValue);
		      	if(idx < 0) {
		      	    field.values.push({value: recordValue})
		      	} else {
		      	    field.values.splice(idx, 1);
		      	    this.props.field.values = field.values;
		      	}
		      	this.update();
		    },
		    changeValue(e) {
		        var field = this.props.field;
		        switch(field.type) {
		            case "BOOLEAN":
		                field.values[0].value = e.target.checked
		                break;
		            case "INPUT":
		                field.values[0].value = e.target.value;
		                break;
		            case "TEXTAREA":
		                field.values[0].value = e.target.value;
		                this.setTextAreaHeight(e.target, e);
		                break;
		            case "DROPDOWN":
		                for(var option of e.target.options) {
		                    if(option.selected) {
			                	field.values[0].value = option.value;
		                    }
		                }
		                break;
		            case "MULTISELECT":
		                break;
		        }
		        //console.log(field);
		    },
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
		    convertToSlug(text)		    {
		        return text.toLowerCase()
		            .replace(/ /g,'-')
		            .replace(/[^\w-]+/g,'');
		    },
		    checkBoxChecked(values) {
		    	return values.length != 0 
		    		&& typeof values[0].value == "string" 
		    		&& values[0].value.toLowerCase() == "true"
		    }
		}
	</script>
</fieldvalue>