<vocabentryform>
<div class="vocabentryform">
    <div class="form-label">Neu anlegen</div>
    <div class="form-group" each={entry in state.struct}>
        <label for="{props.vocabname + '_' + entry.label}">{entry.label}</label> 
        <input
            type="input"
            class="form-control"
            id="{props.vocabname + '_' + entry.label}"
            placeholder="{entry.label}"
        ></input>
    </div>
</div>

<style>
   .vocabentryform {
        position: relative;
        display: flex;
        flex-wrap: wrap;
        max-width: 100%;
        border: 1px solid #ccc;
        padding: 5px;
        padding-top: 10px;
        padding-bottom: 0px;
        margin-bottom: 15px;
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
</style>

<script>
export default {
    onBeforeMount(state, props) {
    	this.state = {
    		struct: {}
    	}
    	this.state.struct = this.props.vocabularies[this.props.vocabname].struct
    },
    onMounted() {
    	console.log("vocabentry", this.state)
    },
    onBeforeUnmount() {
    },
    msg(key) {
        return this.props.msg(key);
    },
}

</script>
</vocabentryform>