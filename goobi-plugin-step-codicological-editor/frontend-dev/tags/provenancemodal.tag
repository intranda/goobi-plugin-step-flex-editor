<provenancemodal>
<div class="my-modal-bg" onclick={props.hide}>
	<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
		<div class="box-title">
			<span>{props.field.name}</span>
			<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
		</div>
        <div class="box-content">
            <template each={group in props.field.groupMappings}>
                <div class="form-group">
                  <label for="searchPerson">{group.sourceVocabulary} durchsuchen</label>
                  <input 
                    type="input" 
                    class="form-control" 
                    id="searchPerson" 
                    placeholder="{group.sourceVocabulary} durchsuchen" 
                    onkeyup={(e) => filterVocabulary(group.sourceVocabulary, e)}>
                </div>
                <table class="table" if={state.filteredVocabs[group.sourceVocabulary] && state.filteredVocabs[group.sourceVocabulary].length != 0}>
                    <thead>
                        <tr>
                            <th each={mapping in group.mappings}>{mapping.vocabularyName}</th>
                            <th>Aktion</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr each={value in state.filteredVocabs[group.sourceVocabulary]}>
                            <td each={mapping in group.mappings}>
                                <template if={value.fields.find(f => f.label == mapping.vocabularyName)}>
                                    {value.fields.find(f => f.label == mapping.vocabularyName).value}
                                </template>
                            </td>
                            <td><button class="btn btn-primary" onclick={() => addValue(group, value)}><i class="fa fa-plus"></i></button></td>
                        </tr>
                    </tbody>
                </table>
            </template>
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
		min-width: 50vw;
	}
	.my-modal-bg .box .box-title {
		color: white;
        font-size: 16px;
	}
    .my-modal-bg .box .box-content {
        max-height: 90vh;
        overflow-y: auto;
    }
</style>

<script>
export default {
			onBeforeMount(state, props) {
				this.listenerFunction = this.keyListener.bind(this);
				document.addEventListener("keyup", this.listenerFunction);
				this.state = {
					filteredVocabs: {}
				}
			},
			onMounted() {
				console.log(this.props.field)
				let vocabs = this.props.vocabularies;
				let field = this.props.field;
				this.state = {
					vocabs: {...vocabs},
					filteredVocabs: {}
				}
				console.log(this.state)
			},
			onBeforeUnmount() {
		    	document.removeEventListener("keyup", this.listenerFunction);
		    },
		    keyListener(e) {
		    	if(e.key == "Escape") {
		    		this.props.hide();
		    	}
		    },
			msg(key) {
				return this.props.msg(key);
			},
			filterVocabulary(vocabularyName, e) {
				let term = e.target.value.toLowerCase();
				if('' == term || !this.state.vocabs[vocabularyName]) {
					this.state.filteredVocabs[vocabularyName] = null;
					this.update();
					return;
				}
				this.state.filteredVocabs[vocabularyName] = this.state.vocabs[vocabularyName].records.filter(val => {
					return val.fields.map(f => f.value.toLowerCase()).join(" ").indexOf(term) >= 0;
				})
				this.update();
			},
			addValue(group, value) {
				let groupValue = {
						type: group.label,
						groupName: group.groupName,
						sourceVocabulary: group.sourceVocabulary
				};
				let complexValue = {};
				for(let mapping of group.mappings) {
					let field = value.fields.find(field => field.label == mapping.vocabularyName);
					if(field) {
						complexValue[mapping.vocabularyName] = field.value; 
					}
				}
				groupValue.values = complexValue;
				console.log(groupValue)
				this.props.field.values.push({groupValue: groupValue});
				this.props.valuesChanged();
			}
		}

</script>
</provenancemodal>