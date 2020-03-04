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
			<!-- <button class="btn btn-danger" onclick={printState}>Print state</button> -->
			<button class="btn btn-primary pull-right" onclick={showImages}>Digitalisate einblenden</button>
		</div>
		<div class="col-md-6">
			<button class="btn btn-primary" onclick={showPreview}>Vorschau anzeigen</button>
			<div class="pull-right">
				<button class="btn">{msg('cancel')}</button>
				<button class="btn btn-success" style="margin-left: 15px;" onclick={save}>{msg('save')}</button>
			</div>
		</div>
	</div>
	<Preview if={state.showPreview} values={ state.previewVals } hide={hidePreview}/>
	<Imagemodal 
		if={state.showImages} 
		processId={props.goobi_opts.processId} 
		images={state.images}
		imageFolder={state.imageFolder} 
		hide={hideImages} 
		msg={msg}
	/>
	
	<style>
	</style>
  
  <script>
  import Box from './box.tag';
  import Preview from './preview.tag';
  import Imagemodal from './imagemodal.tag';
  export default {
    components: {
      Box,
      Preview,
      Imagemodal
    },
    onBeforeMount(props, state) {
      this.state = {
    	  msgs: {},
          vocabularies: {},
          vocabLoaded: false,
          boxes: [{},{},{}],
          boxesLoaded: false,
          showPreview: false,
          imageFolder: "orig",
          images: []
      };
      fetch(`/goobi/plugins/ce/process/${props.goobi_opts.processId}/mets`).then(resp => {
		resp.json().then(json => {
			this.state.boxes = json;
			this.state.boxesLoaded = true;
			if(this.state.vocabLoaded) {
				this.update();
			}
		});
      });
      fetch(`/goobi/plugins/ce/process/${props.goobi_opts.processId}/images`).then(resp => {
  		resp.json().then(json => {
  			this.state.images = json.imageNames;
  			this.state.imageFolder = json.folder;
  			if(this.state.vocabLoaded) {
  				this.update();
  			}
  		});
      });
      fetch(`/goobi/plugins/ce/vocabularies`).then(resp => {
		resp.json().then(json => {
			this.state.vocabularies = json;
			this.state.vocabLoaded = true;
			if(this.state.boxesLoaded) {
				this.update();
			}
		});
      });
      fetch(`/goobi/api/messages/${props.goobi_opts.language}`, {
          method: 'GET',
          credentials: 'same-origin'
      }).then(resp => {
        resp.json().then(json => {
          this.state.msgs = json;
          this.update();
        });
      });
    },
    onMounted(props, state) {
    },
    onBeforeUpdate(props, state) {
    },
    onUpdated(props, state) {
    },
    printState() {
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
    },
    showPreview() {
    	this.state.showPreview = true;
    	var previewVals = [];
    	for(var col of this.state.boxes) {
    		for(var box of col.boxes) {
    			for(var field of box.fields) {
    				if(field.show) {
    					for(var value of field.values) {
    						previewVals.push({name: field.name, value: value})
    					}
    				}
    			}
    		}
    	}
    	this.state.previewVals = previewVals;
    	this.update();
    },
    hidePreview() {
    	this.state.showPreview = false;
    	this.update();
    },
    showImages() {
    	this.state.showImages = true;
    	this.update();
    },
    hideImages() {
    	this.state.showImages = false;
    	this.update();
    }
  }
  </script>
</app>
