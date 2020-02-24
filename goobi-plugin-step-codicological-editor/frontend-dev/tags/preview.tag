<preview>
	<div class="my-modal-bg" onclick={props.hide}>
		<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
			<div class="box-title">
				<span>Vorschauansicht</span>
				<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
			</div>
			<div class="box-content">
				<table class="preview-table">
				<tbody>
					<tr each={ item in state.values}>
						<th>{item.name}</th>
						<td>{item.value}</td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<style>
		.my-modal-bg {
			display: flex;
			justify-content: center;
			align-items: center;
			position: fixed;
			top: 0px;
			right: 0px;
			bottom: 0px;
			left: 0px;
			background-color: rgba(255, 255, 255, 0.5);
		}
		.icon-only-button {
			background: none;
			border: none;
			padding-right: 10px;
		}
		.my-modal-bg .box {
			min-width: 50vw;
			max-height: 90vh;
		}
		.my-modal-bg .box .box-title {
			color: white;
		}
		.my-modal-bg .box .preview-table th {
			padding-right: 20px;			
			font-weight: bold;
		}
		.my-modal-bg .box .preview-table th,td {
		    padding-bottom: 15px;
		  }
	</style>
	<script>
		export default {
			onBeforeMount(state, props) {
				this.listenerFunction = this.keyListener.bind(this);
				document.addEventListener("keyup", this.listenerFunction)
			},
			onMounted() {
				this.state.values = this.props.values
				this.update();
		    },
		    onBeforeUnmount() {
		    	document.removeEventListener("keyup", this.listenerFunction);
		    },
		    keyListener(e) {
		    	if(e.key == "Escape") {
		    		this.props.hide();
		    	}
		    }
		}
	</script>
</preview>