<box>
	<div class="box box-color orange box-bordered">
		<div class="box-title">{props.box.name}</div>
		<div class="box-content nopadding">
			<div class="box-content-top" if={ props.box.fields.filter( field => !field.show).length > 0}>
				<a class="badge" each={field in props.box.fields} onclick={ () => showField(field)} if={!field.show}>
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
		.box-content-top {
			padding: 10px;
			background-color: #f9f9f9;
			border-bottom: 1px solid #f4f4f4;
		}
		.box-content-top .badge {
			margin-right: 5px;
			margin-bottom: 5px;
			margin-top: 5px;
		}
		.box-content-top .badge .fa {
			margin-right: 3px;
		}
		.field-detail {
			display: flex;
			line-height: 24px;
			border-bottom: 1px solid #f4f4f4;
		}
		.field-detail .field-label {
			display: flex;
			flex-basis: 40%;
			padding: 10px;
			font-weight: bold;
			background-color: #f9f9f9;
		}
		.field-detail .field-label .label-text {
			flex-grow: 1;
		}
		.field-detail .field-label .action a {
			font-size: 16px;
			color: black;
			cursor: pointer;
		}
		.field-detail .value {
			padding: 10px;
			flex-grow: 1;
		}
	</style>

	<script>
	import Fieldvalue from './fieldvalue.tag';
	export default {
	    components: {
			Fieldvalue	        
	    },
	    onBeforeMount(state, props) {
	        
	    },
	    onMounted(state, props) {
	        console.log(this.props)
	    },
	    showField(field) {
	        field.show = true;
	        this.update();
	    },
	    emptyField(field) {
	        field.show = false;
	        field.values = [];
	        this.update();
	    }
	}
		
	</script>
</box>