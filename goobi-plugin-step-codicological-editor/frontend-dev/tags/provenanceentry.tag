<provenanceentry>
    <div class="provenance-entry">
        Provenienz: {props.value.type}
        <div class="action">
            <a onclick={deleteProvenance}>
              <i class="fa fa-minus-circle"></i>
            </a>
        </div>
        
    </div>
    <div class="field-detail" each={key in Object.keys(props.value)} if={key != 'type'}>
        <div class="field-label">
            <div class="label-text">
                {key}
            </div>
        </div>
        <div class="value">
            {props.value[key]}
        </div>
    </div>
    
    <style>
        .provenance-entry {
            display: flex;
            width: 100%;
            padding: 10px;
            background-color: #f4f4f4;
            color: #555;
            justify-content: space-between;
        }
        .action a {
            font-size: 16px;
            color: #777;
            cursor: pointer;
        }
        .action a:hover {
            color: #9E9E9E;
        }
    </style>
    
    <script>
    	export default {
    		onBeforeMount() {
    			console.log(this.props)
    		},
    		deleteProvenance() {
    			console.log("deleting this provenance")
    		}
    	}
    </script>

</provenanceentry>