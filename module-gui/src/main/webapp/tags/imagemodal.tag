<imagemodal>
	<!-- hide is defined in app.tag as hideImages -->
	<div class="my-modal-bg" onclick={props.hide}>
		<div class="box box-color box-bordered" onclick={ e => e.stopPropagation()}>
			
			<!-- BOX TITLE -->
			<div class="box-title">
				<span>Bildanzeige</span>
				<!-- hide is defined in app.tag as hideImages -->
				<button class="icon-only-button pull-right" onclick={props.hide}><i class="fa fa-times"></i></button>
			</div>
			<!-- // BOX TITLE -->
			
			<!-- BOX CONTENT -->
			<div class="box-content">
				<!-- IMAGE -->
				<div class="image-container">
					<img src={state.imageSource}></img>
				</div>
				<!-- // IMAGE -->
				
				<!-- BUTTONS to change pages -->
				<div class="paginator">
					<button class="btn" onclick={firstPage}>
						<i class="fa fa-angle-double-left"></i>
					</button>
					<button class="btn btn-primary" onclick={prevPage}>
						<i class="fa fa-angle-left" aria-hidden="true"></i>
						<span>{msg('previousImage')}</span>
					</button>
					<span class="current-page">{msg('seite')} {state.currentPageNumber + 1} {msg('von')} {props.images.length}</span>
					<button class="btn btn-primary" onclick={nextPage}>
						<span>{msg('nextImage')}</span>
						<i class="fa fa-angle-right" aria-hidden="true"></i>
					</button>
					<button class="btn" onclick={lastPage}>
						<i class="fa fa-angle-double-right"></i>
					</button>
				</div>
				<!-- // BUTTONS -->
			</div>
			<!-- BOX CONTENT -->
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
			max-height: 90vh;
		}
		.my-modal-bg .box .box-title {
			color: white;
            font-size: 16px;
		}
		.image-container {
			display: flex;
			justify-content: center;
		}
		.image-container img {
			max-height: 75vh;
		}
		.paginator {
			display: flex;
			justify-content: center;
			margin-top: 15px;
		}
		.paginator .btn {
			margin-right: 5px;
		}
		.paginator .current-page {
			line-height: 30px;
			margin-right: 20px;
            margin-left: 15px;
		}
		img {
			border: 1px solid #ddd;
		}
        .fa-angle-right {
            margin-left: 5px;
        }
	</style>
	
	<script>
		export default {
			/* triggered before mounting */
			onBeforeMount(state, props) {
				this.listenerFunction = this.keyListener.bind(this);
				document.addEventListener("keyup", this.listenerFunction);
			},
			
			/* triggered after mounted */
			onMounted() {
				this.state.currentPageNumber = 0;
				this.setImageSource();
			},
			
			/* triggered before unmounting */
			onBeforeUnmount() {
		    	document.removeEventListener("keyup", this.listenerFunction);
		    },
		    
		    /* listener function of keys */
		    keyListener(e) {
		    	if(e.key == "Escape") {
		    		// hide is defined in app.tag as hideImages
		    		this.props.hide();
		    	}
		    },
		    
		    /* used to retrieve values from msg */
			msg(key) {
				return this.props.msg(key);
			},
			
			/* triggered when the button `<<` is clicked */
			firstPage() {
				this.state.currentPageNumber = 0;
				this.setImageSource();
			},
			
			/* triggered when the button `< Vorheriges Bild` is clicked */
			prevPage() {
				this.state.currentPageNumber = Math.max(0, this.state.currentPageNumber-1);
				this.setImageSource();	
			},
			
			/* triggered when the button `Nächstes Bild >` is clicked */
			nextPage() {
				this.state.currentPageNumber = Math.min(this.props.images.length-1, this.state.currentPageNumber+1);
				this.setImageSource();				
			},
			
			/* triggered when the button `>>` is clicked */
			lastPage() {
				this.state.currentPageNumber = this.props.images.length-1;
				this.setImageSource();
			},
			
			/* used to set the source of the image to be shown */
			setImageSource() {
				var imageName = this.props.images[this.state.currentPageNumber];
				var height = Math.floor(window.innerHeight*0.6);
				var width = Math.floor(window.innerWidth*0.5);
				this.state.imageSource = `/goobi/api/process/image/${this.props.processId}/${this.props.imageFolder}/${imageName}/full/!${height},${width}/0/default.jpg`;
				this.update();
			}
		}
	</script>
</imagemodal>