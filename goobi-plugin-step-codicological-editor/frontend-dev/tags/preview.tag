<preview>
	<div class="my-modal-bg" onclick={props.hide}>
		<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
			<div class="box-title">
				<span>Vorschauansicht</span>
				<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
			</div>
			<div class="box-content">
				<table class="table">
				<tbody>
					<tr each={ item in state.values}>
						<th>{item.name}</th>
						<td>
                            <template if={item.values.length == 1}>{item.values[0].value}</template>
                            <ul if={item.values.length != 1}>
                                <li each={value in item.values}>
                                    {value}
                                </li>
                            </ul>
                        </td>
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
            z-index: 9999;
		}
		.icon-only-button {
			background: none;
			border: none;
			padding-right: 10px;
		}
		.my-modal-bg .box {
			width: 50vw;
		}
		.my-modal-bg .box .box-title {
			color: white;
            font-size: 16px;
		}
		.box .box-content {
			max-height: 90vh;
			overflow-y: auto;
            padding: 0;
		}
		.table th {
            font-weight: normal;
            width: 33%;
        }
        .table > tbody > tr > td {
            padding: 8px;
        }
        ul {
            padding: 0;
            list-style-type: none;
            margin: 0;
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