<app>
    <div class="flow">
        <div class="row">
            <div class="col-12 col-md-6 col-xxl-4">
                <Box
                    each={box in state.boxes[0].boxes}
                    box={box}
                    vocabularies={state.vocabularies}
                    msg={msg}></Box>
            </div>
            <div class="col-12 col-md-6 col-xxl-4">
                <Box
                    each={box in state.boxes[1].boxes}
                    box={box}
                    vocabularies={state.vocabularies}
                    msg={msg}></Box>
            </div>
            <div class="col-12 col-md-6 col-xxl-4">
                <Box
                    each={box in state.boxes[2].boxes}
                    box={box}
                    vocabularies={state.vocabularies}
                    msg={msg}></Box>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 d-flex justify-content-between">
                <!-- BUTTON "Plugin verlassen" -->
                <button
                    class="btn btn-blank"
                    onclick={leavePlugin}>
                    {msg('pluginLeave')}
                </button>
                <!-- BUTTON "Digitalisate anzeigen" -->
                <button
                    class="btn btn-primary pull-right"
                    onclick={showImages}>
                    <span class="fa fa-image" aria-hidden="true" />
                    <span>{msg('plugin_codicological_showImages')}</span>
                </button>
            </div>
            <div class="col-md-6 d-flex justify-content-between">
                <!-- BUTTON "Vorschau anzeigen" -->
                <button
                    class="btn btn-primary"
                    onclick={showPreview}>
                    <span class="fa fa-desktop" aria-hidden="true" />
                    <span>{msg('plugin_codicological_showPreview')}</span>
                </button>
                <!-- BUTTONS "Speichern" and "Speichern und verlassen" -->
                <div class="d-flex gap-2">
                    <button
                        class="btn btn-blank"
                        onclick={save}>
                        <span class="fa fa-floppy-o" />
                        <span>{msg('save')}</span>
                    </button>
                    <button
                        class="btn btn-success"
                        onclick={saveAndExit}>
                        <span class="fa fa-floppy-o" />
                        <span>{msg('plugin_codicological_saveAndExit')}</span>
                    </button>
                </div>
            </div>
        </div>

        <!-- PREVIEW of the Metadaten -->
        <Preview
            if={state.showPreview}
            values={ state.previewVals }
            hide={hidePreview}
            msg={msg}
            vocabularies={state.vocabularies}/>
    </div>

	<!-- IMAGE -->
	<Imagemodal
		if={state.showImages}
		processId={props.goobi_opts.processId}
		images={state.images}
		imageFolder={state.imageFolder}
		hide={hideImages}
		msg={msg}
	/>

  <script>
  import Box from './box.tag';
  import Preview from './preview.tag';
  import Imagemodal from './imagemodal.tag';
  const goobi_path = location.pathname.split('/')[1];
  export default {
    components: {
      Box,
      Preview,
      Imagemodal
    },

    /* triggered before mounting */
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

      fetch(`/${goobi_path}/api/plugins/flexeditor/process/${props.goobi_opts.processId}/mets`).then(resp => {
		resp.json().then(json => {
			this.state.boxes = json;
			this.state.boxesLoaded = true;
// 			if(this.state.vocabLoaded) {
// 				console.log("get boxes - update")
				this.update();
// 			}
		});
      });

      fetch(`/${goobi_path}/api/plugins/flexeditor/process/${props.goobi_opts.processId}/images`).then(resp => {
  		resp.json().then(json => {
  			this.state.images = json.imageNames;
  			this.state.imageFolder = json.folder;
//   			if(this.state.vocabLoaded) {
//   				console.log("get images - update")
  				this.update();
//   			}
  		});
      });

      fetch(`/${goobi_path}/api/plugins/flexeditor/vocabularies`).then(resp => {
		resp.json().then(json => {
			this.state.vocabularies = json;
			console.log(this.state.vocabularies);
			this.state.vocabLoaded = true;
// 			if(this.state.boxesLoaded) {
// 				console.log("get vocab - update")
				this.update();
// 			}
		});
      });

      fetch(`/${goobi_path}/api/messages/${props.goobi_opts.language}`, {
          method: 'GET',
          credentials: 'same-origin'
      }).then(resp => {
        resp.json().then(json => {
          this.state.msgs = {...this.state.msgs, ...json};
          this.update();
        });
      });

      console.log(props);

      fetch(`/${goobi_path}/api/plugins/flexeditor/process/${props.goobi_opts.processId}/ruleset/messages/${props.goobi_opts.language}`, {
          method: 'GET',
          credentials: 'same-origin'
      }).then(resp => {
        resp.json().then(json => {
          for(let key of Object.keys(json)) {
            this.state.msgs["ruleset_" + key] = json[key];
          }
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

    /* triggered when the button `Speichern` is clicked */
    save() {
    	fetch(`/${goobi_path}/api/plugins/flexeditor/process/${this.props.goobi_opts.processId}/mets`, {
    		method: "POST",
    		body: JSON.stringify(this.state.boxes)
    	}).catch(err => {
    		alert("There was an error saving your data");
    	})
    },

    /* triggered when the button `Speichern und verlassen` is clicked */
    saveAndExit() {
    	fetch(`/${goobi_path}/api/plugins/flexeditor/process/${this.props.goobi_opts.processId}/mets`, {
    		method: "POST",
    		body: JSON.stringify(this.state.boxes)
    	}).then( r => {
    		this.leavePlugin();
    	}).catch(err => {
    		alert("There was an error saving your data");
    	})
    },

    /* used to retrieve values from msg */
    msg(str) {
      if(Object.keys(this.state.msgs).length == 0) {
          return "*".repeat(str.length);
      }
      if(this.state.msgs[str]) {
        return this.state.msgs[str];
      }
      return "???" + str + "???";
    },

    /* triggered when the button `Vorschau anzeigen` is clicked */
    showPreview() {
    	this.state.showPreview = true;
    	var previewVals = [];
    	for(var col of this.state.boxes) {
    		for(var box of col.boxes) {
    			for(var field of box.fields) {
    				if(field.show) {
						previewVals.push(field);
    				}
    			}
    		}
    	}
    	this.state.previewVals = previewVals;
    	this.update();
    },

    /* used in the preview.tag as hide */
    hidePreview() {
    	this.state.showPreview = false;
    	this.update();
    },

    /* triggered when the button `Digitalisate anzeigen` is clicked */
    showImages() {
    	this.state.showImages = true;
    	this.update();
    },

    /* used in the imagemodal.tag as hide */
    hideImages() {
    	this.state.showImages = false;
    	this.update();
    },

    /* triggered when the button `Plugin verlassen` or `Speichern und verlassen` is clicked */
    leavePlugin() {
    	document.querySelector('#restPluginFinishLink').click();
    }
  }
  </script>
</app>
