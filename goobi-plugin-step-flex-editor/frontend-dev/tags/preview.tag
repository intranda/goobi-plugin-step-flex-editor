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
                            <!-- <template if={item.values.length == 1}>{item.values[0].value}</template>-->
                            <ul >
                                <li each={(value, idx) in item.values}>
                                    <template if={typeof value === 'string'}>
                                        {value}
                                    </template>
                                    <template if={typeof value !== 'string'}>
                                        {value.value}
                                    </template>
                                    <template if={typeof value !== 'string' && value.groupValue}>
                                        <ul each={mdType in Object.keys(value.groupValue.values)}>
                                            <li>
                                                {props.msg("ruleset_" + mdType)}: {mdToTitle(mdType, value.groupValue.values[mdType], item)}
                                            </li> 
                                        </ul>
                                        <template if={idx != item.values.length-1}>--</template>
                                    </template>
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
		import {vocabularyForMetadataType, recordMainValue, recordTitle, recordFromMainEntry} from '../vocabulary_util.js'
		export default {
			onBeforeMount(state, props) {
				console.log("preview:", props)
				this.listenerFunction = this.keyListener.bind(this);
				document.addEventListener("keyup", this.listenerFunction)
			},
			onMounted() {
				this.state.values = this.props.values
				console.log(this.state.values);
				this.update();
		    },
		    onBeforeUnmount() {
		    	document.removeEventListener("keyup", this.listenerFunction);
		    },
		    keyListener(e) {
		    	if(e.key == "Escape") {
		    		this.props.hide();
		    	}
		    },
			mdToTitle(mdType, mainEntry, item) {
				console.log(mdType, mainEntry, item.groupMappings);
				let mappings = item.groupMappings[0].mappings;
				let vocabulary = vocabularyForMetadataType(mappings, mdType, this.props.vocabularies);
				if(!vocabulary) {
					return mainEntry;
				}
				let record = recordFromMainEntry(mainEntry, mdType, item.groupMappings, vocabulary);
				let title = recordTitle(record, vocabulary);
				if(title.length == 0) {
					return mainEntry;
				}
				return title;
			}
		}
	</script>
</preview>