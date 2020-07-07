<box>
	<div class="box box-color orange box-bordered box-small">
		<div class="box-title">
			<h3>
				{props.box.name}
			</h3>
		</div>
		<div class="box-content nopadding">
			<div class="box-content-top" if={ props.box.fields.filter( field => !field.show).length > 0}>
				<div class="inner-addon right-addon" if={props.box.fields.filter( field => !field.show ).length > 7}>
					<i class="fa fa-search"></i>
					<input type="text" class="form-control" onkeyup={filter} placeholder="Filter">
					</input>
				</div>
				<a class="badge badge-intranda-light" each={field in state.filteredFields} onclick={ () => showField(field)}>
					<i class="fa fa-plus-circle"></i>
					{field.name}
				</a>
			</div>
			<div class="field-detail" each={field in props.box.fields} if={field.show}>
				<div class="field-label">
					<div class="label-text">
						{field.name}
					</div>
					<div class="action">
						<a onclick={ () => emptyField(field)}>
							<i class="fa fa-minus-circle"></i>
						</a>
					</div>
				</div>
				<div class="value">
					<Fieldvalue field={field} vocabularies={props.vocabularies}></Fieldvalue>
				</div>
			</div>
		</div>
	</div>

	<style>
		.box-title {
			color: white;
		}
		.box .box-title h3 {
			margin-left: 10px;
		}
		.box-content-top {
			padding: 10px;
			background-color: #f4f4f4;
			border-bottom: 1px solid #ddd;
		}
		.box-content-top .badge {
			margin-right: 5px;
			margin-top: 5px;
		}
		.box-content-top .badge:hover {
			color: white;
			background-color: #9E9E9E;
		}
		.box-content-top .badge .fa {
			margin-right: 3px;
		}
		.field-detail {
			display: flex;
			line-height: 24px;
			border-bottom: 1px solid #ddd;
		}
		.field-detail .field-label {
			display: flex;
			flex-basis: 40%;
			padding: 10px;
			background-color: #f4f4f4;
			color: #555;
		}
		.field-detail .field-label .label-text {
			flex-grow: 1;
		}
		.field-detail .field-label .action a {
			font-size: 16px;
			color: #777;
			cursor: pointer;
		}
		.field-detail .field-label .action a:hover {
			color: #9E9E9E;
		}
		.field-detail .value {
			padding: 10px;
			flex-grow: 1;
            max-width: 60%;
		}
		.inner-addon {
		    position: relative;
		    margin-bottom: 10px;
		}
		.inner-addon .fa {
		    position: absolute;
		    padding: 5px 10px 5px 5px;
		    pointer-events: none;
		}
		.right-addon .fa { 
			right: 0px;
		}
	</style>

	<script>
	import Fieldvalue from './fieldvalue.tag';
	export default {
	    components: {
			Fieldvalue	        
	    },
	    onBeforeMount(state, props) {
	        this.state = {
	        	filteredFields: [],
	        	search: ''
	        }
	    },
	    onMounted(state, props) {
	        this.filterFields();
	    },
	    showField(field) {
	        field.show = true;
	        this.filterFields();
	    },
	    emptyField(field) {
	        field.show = false;
	        field.values = [];
	        this.filterFields();
	    },
	    filter(e) {
	        this.state.search = e.target.value.toLowerCase();
	        this.filterFields();
	    },
	    filterFields() {
	    	if(this.state.search == '') {
	            this.state.filteredFields = this.props.box.fields.filter(field => !field.show);
	            this.update();
	        }
	        this.state.filteredFields = this.props.box.fields
	        	.filter(field => field.name.toLowerCase().indexOf(this.state.search) >= 0 && !field.show);
	        this.update();
	    }
	}
		
	</script>
</box>