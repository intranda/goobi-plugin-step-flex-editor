<fieldvalue>
	<input type="text" class="form-control" onkeyup={changeValue} if={props.field.type == 'INPUT'}></input>
	<textarea class="form-control" onkeyup={changeValue} if={props.field.type == 'TEXTAREA'}></textarea>
	<input type="checkbox" onchange={changeValue} if={props.field.type == 'BOOLEAN'}></input>
	<select class="form-control" onchange={changeValue} if={props.field.type == 'DROPDOWN'}>
		<option each={record in state.vocab.records} value="{record.fields[1].value}">{record.fields[0].value}</option>
	</select>
	
	<style>
/* 	input[type=checkbox] { */
/* 		-ms-transform: scale(1.5); /* IE */ */
/* 		-moz-transform: scale(1.5); /* FF */ */
/* 		-webkit-transform: scale(1.5); /* Safari and Chrome */ */
/* 		-o-transform: scale(1.5); /* Opera */ */
/* 		transform: scale(1.5); */
/* 	} */
	</style>
	<script>
		export default {
		    onBeforeMount() {
		        this.state = {
		            vocab: {}
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