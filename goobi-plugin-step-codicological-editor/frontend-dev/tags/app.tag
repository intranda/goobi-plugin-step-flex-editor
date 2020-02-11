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
	<div class="row">
		<div class="col-md-12">
			<button class="btn btn-primary" onclick={printState}>Print state</button>
		</div>
	</div>
  
  <script>
  import Box from './box.tag';
  export default {
    components: {
      Box  
    },
    onBeforeMount(props, state) {
      this.state = {
          vocabularies: {},
          boxes: [{},{},{}],
      };
      fetch(`/goobi/plugins/ce/process/${props.goobi_opts.processId}/mets`).then(resp => {
		resp.json().then(json => {
			this.state.boxes = json;
			console.log(this.state.boxes[0])
			this.update();
		})
      })
      fetch(`/goobi/plugins/ce/vocabularies`).then(resp => {
		resp.json().then(json => {
			this.state.vocabularies = json;
			this.update();
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
