<provenancemodal>
<div class="my-modal-bg" onclick={props.hide}>
	<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
		<div class="box-title">
			<span>Provenienz hinzufügen</span>
			<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
		</div>
        <div class="box-content">
            <div class="form-group">
              <label for="searchPerson">Person suchen</label>
              <input type="input" class="form-control" id="searchPerson" placeholder="Person suchen" onkeyup={filterPersons}>
            </div>
            <table class="table" if={state.filteredPersons.length != 0}>
                <thead>
                    <tr>
                        <th>Vorname</th>
                        <th>Nachname</th>
                        <th>GND</th>
                        <th>Aktion</th>
                    </tr>
                </thead>
                <tbody>
                    <tr each={person in state.filteredPersons}>
                        <td>{person.fields[0].value}</td>
                        <td>{person.fields[1].value}</td>
                        <td></td>
                        <td><button class="btn btn-primary" onclick={() => addPerson(person)}><i class="fa fa-plus"></i></button></td>
                    </tr>
                </tbody>
            </table>
            <div class="form-group">
              <label for="searchInstitution">Institution suchen</label>
              <input type="input" class="form-control" id="searchInstitution" placeholder="Institution suchen" onkeyup={filterInstitutions}>
            </div>
            <table class="table" if={state.filteredInstitutions.length != 0}>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>GND</th>
                        <th>Aktion</th>
                    </tr>
                </thead>
                <tbody>
                    <tr each={institution in state.filteredInstitutions}>
                        <td>{institution.fields[0].value}</td>
                        <td><template if={institution.fields[1]}>{institution.fields[1].value}</template></td>
                        <td><button class="btn btn-primary" onclick={() => addInstitution(institution)}><i class="fa fa-plus"></i></button></td>
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
					filteredPersons: [],
					filteredInstitutions: []
				}
			},
			onMounted() {
				let vocabs = this.props.vocabularies;
				let field = this.props.field;
				this.state = {
					personVocabulary: { ...vocabs[field.sourceVocabularies[0]]},
					institutionVocabulary: { ...vocabs[field.sourceVocabularies[1]]},
					filteredPersons: [],
					filteredInstitutions: []
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
			filterPersons(e) {
				let term = e.target.value.toLowerCase();
				if('' == term) {
					this.state.filteredPersons = [];
					this.update();
					return;
				}
				this.state.filteredPersons = this.state.personVocabulary.records.filter(person => {
					return person.fields.map(f => f.value.toLowerCase()).join(" ").indexOf(term) >= 0;
				})
				this.update();
			},
			filterInstitutions(e) {
				let term = e.target.value.toLowerCase();
				if('' == term) {
					this.state.filteredInstitutions = [];
					this.update();
					return;
				}
				this.state.filteredInstitutions = this.state.institutionVocabulary.records.filter(institution => {
					return institution.fields.map(f => f.value.toLowerCase()).join(" ").indexOf(term) >= 0;
				})
				console.log(this.state.filteredInstitutions)
				this.update();
			},
			addPerson(person) {
				let complexValue = {
						type: "Person",
				};
				for(let mapping of this.props.field.complexMappings) {
					let field = person.fields.find(field => field.label == mapping.vocabularyName);
					if(field) {
						complexValue[mapping.vocabularyName] = field.value; 
					}
				}
				this.props.field.values.push({complexValue: complexValue});
				this.props.valuesChanged();
			},
			addInstitution(inst) {
				let complexValue = {
						type: "Institution",
				};
				for(let mapping of this.props.field.complexMappings) {
					let field = inst.fields.find(field => field.label == mapping.vocabularyName);
					if(field) {
						complexValue[mapping.vocabularyName] = field.value; 
					}
				}
				this.props.field.values.push({complexValue: complexValue});
				this.props.valuesChanged();
			}
		}

</script>
</provenancemodal>