<vocabentryform>
<div class="wrapper">
	<span class="vocabentrylink" if={!state.extended} onclick={toggleExtended}>
		<i class="fa fa-chevron-right icon-left"></i>Neu anlegen
	</span>
	<div class="vocabentryform" if={state.extended}>
	    <span class="form-label vocabentrylink" onclick={toggleExtended}>
	    	<i class="fa fa-chevron-down icon-left"></i>Neu anlegen
	    </span>
	    <div class="form-group" each={entry in state.struct}>
	        <label for="{props.vocabname + '_' + entry.label}">{entry.label}</label> 
	        <input
	            type="input"
	            class="form-control"
	            id="{props.vocabname + '_' + entry.label}"
	            placeholder="{entry.label}"
	            onkeyup={e => editField(entry.label, e.target.value)}
	        ></input>
	    </div>
	</div>
</div>

<style>
   .wrapper {
       margin-bottom: 15px;
   }
   .vocabentryform {
        position: relative;
        display: flex;
        flex-wrap: wrap;
        max-width: 100%;
        border: 1px solid #ccc;
        padding: 5px;
        padding-top: 10px;
        padding-bottom: 0px;
   }
   .vocabentryform .form-group {
        width: 50%;
   }
   
   .vocabentryform .form-group:nth-child(odd) {
       padding-left: 5px;
   }
   .vocabentryform .form-group:nth-child(even) {
       padding-right: 5px;
   }
   .vocabentryform .form-label {
       position: absolute;
       top: -10px;
       left: 5px;
       background-color: white;
       padding: 0 3px;
   }
   .icon-left {
   	   margin-right: 5px;
   }
   .vocabentrylink {
       cursor: pointer;
   }
</style>

<script>
export default {
    onBeforeMount(state, props) {
    	this.state = {
    		struct: {},
    		fields: []
    	}
    	this.state.struct = this.props.vocabularies[this.props.vocabname].struct
    	for(let entry of this.state.struct) {
    		this.state.fields.push({
    			label: entry.label,
    			value: ""
    		})
    	}
    },
    onMounted() {
    	console.log("vocabentry", this.state)
    },
    onBeforeUnmount() {
    },
    msg(key) {
        return this.props.msg(key);
    },
    toggleExtended() {
    	this.state.extended = !this.state.extended;
    	this.update();
    },
    editField(fieldLabel, value) {
		let field = this.state.fields.find(f => f.label === fieldLabel)
    	if(field) {
    		field.value = value;
    	}
    	this.update();
    },
}

</script>
</vocabentryform>