<box>
	<div class="box box--action section mb-3">
		<!-- BOX TITLE -->
		<div class="box__title">
			<h3>
				{props.box.name}
			</h3>
		</div>
		<!-- BOX TITLE -->

		<!-- BOX CONTENT -->
		<div>
			<!-- BOX CONTENT TOP -->
			<div
				class="bg-neutral p-3 border-bottom"
				if={ state.filteredFields.length > 0 || state.search.length > 0}>
				<div
					class="input-group"
					if={props.box.fields.filter( field => !field.show ).length > 7 || state.search.length > 0}>
					<span class="input-group-text fa fa-search" aria-hidden="true" />
					<input type="text" class="form-control" onkeyup={filter} placeholder="Filter">
					</input>
				</div>
				<a
					class="badge badge-intranda-light"
					each={field in state.filteredFields}
					onclick={ () => showField(field)}>
					<span class="fa fa-plus-circle" aria-hidden="true" />
					<span>{field.name}</span>
				</a>
			</div>

			<!-- COMPONENT for fields whose types are not MODAL_PROVENANCE -->
			<div class="form-row"
				each={field in props.box.fields}
				if={field.show && field.type != "MODAL_PROVENANCE"}>
				<div class="form-label">
					{field.name}
				</div>
				<div class="form-input">
					<Fieldvalue field={field} vocabularies={props.vocabularies}></Fieldvalue>
				</div>
				<div class="btn btn-blank font-light fs-500">
					<a onclick={ () => emptyField(field)}>
						<span class="fa fa-trash" aria-hidden="true" />
					</a>
				</div>
			</div>

			<!-- COMPONENT for fields of type MODAL_PROVENANCE -->
            <template each={(field, idx) in props.box.fields} if={field.show && field.type == "MODAL_PROVENANCE"}>
                <Provenanceentry
                    each={(value, groupIdx) in field.values}
                    field={field}
                    groupValue={value.groupValue}
                    vocabularies={props.vocabularies}
                    msg={props.msg}
                    deleteValue={getDeleteValueFromFieldFunction(field, groupIdx)} />
            </template>

		</div>
		<!-- // BOX CONTENT -->
	</div>

    <Provenancemodal
        if={state.showProvenanceModal}
        hide={hideProvenanceModal}
        field={state.provenanceField}
        vocabularies={props.vocabularies}
        msg={props.msg}
        valuesChanged={valuesChanged} />

	<script>
	import Fieldvalue from './fieldvalue.tag';
	import Provenancemodal from './provenancemodal.tag';
	import Provenanceentry from './provenanceentry.tag';
	export default {
	    components: {
			Fieldvalue,
			Provenancemodal,
			Provenanceentry
	    },

	    /* triggered before mounting */
	    onBeforeMount(state, props) {
	        this.state = {
	        	filteredFields: [],
	        	search: '',
	        	showProvenanceModal: false
	        };
	    },

	    /* triggered after mounted */
	    onMounted(state, props) {
	        this.filterFields();
	    },

	    /* used in the provenancemodal.tag as hide */
	    hideProvenanceModal() {
	    	this.state.showProvenanceModal = false;
	    	this.update();
	    },

	    /* triggered when a fa-plus-circle button is clicked */
	    showField(field) {
	        field.show = true;
	        if(field.multiVocabulary) {
	        	this.state.showProvenanceModal = true;
	        	this.state.provenanceField = field;
	        }
	        this.filterFields();
	        this.update();
	    },

	    /* triggered when a fa-minus-circle button is clicked, used to delete a field */
	    emptyField(field) {
	        field.show = false;
	        field.values = [];
	        this.filterFields();
	    },

	    /* triggered when the text input in the BOX CONTENT TOP component gets an input */
	    filter(e) {
	        this.state.search = e.target.value.toLowerCase();
	        console.log(this.state.search.length);
	        this.filterFields();
	    },

	    /* used by other functions to filter the fields */
	    filterFields() {
	    	if(this.state.search == '') {
	            this.state.filteredFields = this.props.box.fields.filter(field => !field.show || field.repeatable);
	            this.update();
	            return;
	        }
	        this.state.filteredFields = this.props.box.fields
	        	.filter(field => field.name.toLowerCase().indexOf(this.state.search) >= 0 && !field.show);
	        this.update();
	    },

	    /* used in the provenancemodal.tag as valuesChanged */
	    valuesChanged() {
	    	console.log(this.state.provenanceField);
	    	this.update();
	    },

	    /* used in the provenanceentry.tag as deleteValue */
	    getDeleteValueFromFieldFunction(field, valueIndex) {
	    	return () => {
	    		console.log("deleting:", field.values, valueIndex);
	    		field.values.splice(valueIndex, 1);
	    		this.update();
	    	}
	    }
	}

	</script>
</box>