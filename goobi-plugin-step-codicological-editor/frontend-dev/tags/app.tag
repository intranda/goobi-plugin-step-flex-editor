<app>
	<div class="row">
		<div class="col-md-4">
			<Box each={box in state.boxes[0].boxes} box={box} vocabularies={state.vocabularies}></Box>
		</div>
		<div class="col-md-4">
			<Box each={box in state.boxes[1].boxes} box={box} vocabularies={state.vocabularies}></Box>
		</div>
		<div class="col-md-4">
			<Box each={box in state.boxes[2].boxes} box={box} vocabularies={state.vocabularies}></Box>
		</div>
	</div>  
	<div class="row" style="margin-top: 15px;">
		<div class="col-md-6">
			<button class="btn btn-danger" onclick={printState}>Print state</button>
			<button class="btn btn-primary pull-right" onclick={printState}>Digitalisate einblenden</button>
		</div>
		<div class="col-md-6">
			<button class="btn btn-primary">Vorschau anzeigen</button>
			<div class="pull-right">
				<button class="btn">Abbrechen</button>
				<button class="btn btn-success" style="margin-left: 15px;" onclick={save}>Speichern</button>
			</div>
		</div>
	</div>
	
	<style>
	</style>
  
  <script>
  import Box from './box.tag';
  export default {
    components: {
      Box  
    },
    onBeforeMount(props, state) {
      this.state = {
          vocabularies: {},
          vocabLoaded: false,
          boxes: [{},{},{}],
          boxesLoaded: false
      };
      fetch(`/goobi/plugins/ce/process/${props.goobi_opts.processId}/mets`).then(resp => {
		resp.json().then(json => {
			this.state.boxes = json;
			this.state.boxesLoaded = true;
			console.log(this.state.boxes[0])
			if(this.state.vocabLoaded) {
				this.update();
			}
		})
      })
      fetch(`/goobi/plugins/ce/vocabularies`).then(resp => {
		resp.json().then(json => {
			this.state.vocabularies = json;
			this.state.vocabLoaded = true;
			if(this.state.boxesLoaded) {
				this.update();
			}
		})
      })
    },
    onMounted(props, state) {
      console.log("mounted", state.wantedMsgs);
    },
    onBeforeUpdate(props, state) {
    },
    onUpdated(props, state) {
    },
    printState() {
  	  console.log(this.state.boxes[2]);  
    },
    save() {
    	fetch(`/goobi/plugins/ce/process/${this.props.goobi_opts.processId}/mets`, {
    		method: "POST",
    		body: JSON.stringify(this.state.boxes)
    	})
    },
    msg(str) {
      if(Object.keys(this.state.msgs).length == 0) {
          return "*".repeat(str.length);
      }
      if(this.state.msgs[str]) {
        return this.state.msgs[str];
      }
      return "???" + str + "???";
    }
  }
  </script>
</app>
