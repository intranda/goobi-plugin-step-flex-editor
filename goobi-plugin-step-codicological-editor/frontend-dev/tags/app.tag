<app>
	<h1>It works! Hello from app.tag!</h1>  
  
  <script>
  export default {
    onBeforeMount(props, state) {
      this.state = {
              vocabularies: {},
              boxes: {},
      };
//       fetch(`/goobi/plugins/mdel/process/${props.goobi_opts.processId}/dd`).then(resp => {
//         resp.json().then(json => {
//           this.state.dd= json;
//           this.update();
//         })
//       })
//       fetch(`/goobi/api/messages/${props.goobi_opts.language}`).then(resp => {
//         resp.json().then(json => {
//           this.state.msgs = json;
//           this.update();
//         })
//       })
    },
    onMounted(props, state) {
      console.log("mounted", state.wantedMsgs);
    },
    onBeforeUpdate(props, state) {
    },
    onUpdated(props, state) {
      console.log(state, state.allowedMeta)
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
