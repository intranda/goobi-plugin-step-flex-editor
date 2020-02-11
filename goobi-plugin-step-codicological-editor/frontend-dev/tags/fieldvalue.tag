<fieldvalue>
	<input type="text" class="form-control" onkeyup={changeValue} if={props.field.type == 'INPUT'}></input>
	<textarea class="form-control" onkeyup={changeValue} if={props.field.type == 'TEXTAREA'}></textarea>
	<input type="checkbox" onchange={changeValue} if={props.field.type == 'BOOLEAN'}></input>
	<select class="form-control" onchange={changeValue} if={props.field.type == 'DROPDOWN'}>
		<option each={record in state.vocab.records} value="{record.fields[1].value}">{record.fields[0].value}</option>
	</select>
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
					<input type="checkbox" checked={props.field.values.indexOf(record.fields[1].value) >= 0}>
					{record.fields[0].value}
				</li>
			</ul>
		</div>
		<div class="multiselect-values">
			<span class="badge" each={value in props.field.values}>{value}</span>
		</div>
	</div>
	
	
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
	</style>
	<script>
		export default {
		    onBeforeMount() {
		        this.state = {
		            vocab: {},
		            multiExpanded: false
		        };
		    },
		    onMounted() {
		        var field = this.props.field;
		        if(field.sourceVocabulary) {
		            this.state.vocab = this.props.vocabularies[field.sourceVocabulary];
		            console.log(this.state.vocab.records);
		            this.update();
		        }
		        switch(field.type) {
		            case "BOOLEAN":
		                field.values[0] = false;
		                break;
		            case "INPUT":
		            case "TEXTAREA":
		                field.values[0] = "";
		                break;
		            case "DROPDOWN":
		                field.values[0] = this.state.vocab.records[0].fields[1].value;
		                break;
		            case "MULTISELECT":
		                break;
		        }
		        console.log(field)
		    },
		    toggleExpandMulti() {
		      this.state.multiExpanded = !this.state.multiExpanded; 
		      this.update();
		    },
		    toggleEntry(e, record) {
		        e.stopPropagation();
		      	var field = this.props.field;
		      	var recordValue = record.fields[1].value;
		      	var idx = field.values.indexOf(recordValue);
		      	if(idx < 0) {
		      	    field.values.push(recordValue)
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
		                field.values[0] = e.target.checked
		                break;
		            case "INPUT":
		                field.values[0] = e.target.value;
		                break;
		            case "TEXTAREA":
		                field.values[0] = e.target.value;
		                this.setTextAreaHeight(e);
		                break;
		            case "DROPDOWN":
		                for(var option of e.target.options) {
		                    if(option.selected) {
			                	field.values[0] = option.value;
		                    }
		                }
		                break;
		            case "MULTISELECT":
		                break;
		        }
		        //console.log(field);
		    },
		    setTextAreaHeight(e) {
		        var area = e.target;
		        if(area.offsetHeight < area.scrollHeight) {
                    area.style.height = (area.scrollHeight + 5) + "px";
                }
                if(e.key == "Delete" || e.key == "Backspace" || (e.key == "x" && e.ctrlKey)) {
                    area.style.height = 5 + "px";
                    if(area.offsetHeight < area.scrollHeight) {
	                    area.style.height = (area.scrollHeight + 5) + "px";
	                }
                }
		    }
		}
	</script>
</fieldvalue>