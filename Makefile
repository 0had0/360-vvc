# <====== PATHS
CURRENT_PATH := $(shell pwd)
BINARIES_PATH=$(CURRENT_PATH)/bin
IN_PATH=$(CURRENT_PATH)/inputs
OUT_PATH=$(CURRENT_PATH)/outputs
CF_PATH=$(CURRENT_PATH)/src/cfg
LOG_PATH=$(CURRENT_PATH)/logs

# <=== Temporary ===>
TEMPORARY_PATH=$(CURRENT_PATH)/tmp
ENCODER_PATH=$(CURRENT_PATH)/tmp/encoder
DECODER_PATH=$(CURRENT_PATH)/tmp/decoder
VVC_PATH=$(CURRENT_PATH)/tmp/VVCSoftware_VTM/
FFMPEG_PATH=$(CURRENT_PATH)/tmp/FFmpeg
# ======= PATHS ======>

# <====== BINARIES
ENCODER=vvencFFapp #$(BINARIES_PATH)/vvencFFapp
DECODER=vvdecapp #$(BINARIES_PATH)/vvdecapp
SUBPICMERGEAPP=SubpicMergeAppStatic #$(BINARIES_PATH)/SubpicMergeAppStatic
FFMPEG=ffmpeg #$(BINARIES_PATH)/ffmpeg
FFPLAY=ffplay #$(BINARIES_PATH)/ffplay
FFPROBE=ffprobe #$(BINARIES_PATH)/ffprobe
MP4BOX=MP4Box #$(BINARIES_PATH)/MP4Box
# ======= BINARIES ======>

FRAMES_TO_BE_ENCODED=256

.env:
	@echo "Creating .env file with current configuration..."
	@echo "CURRENT_PATH=$(CURRENT_PATH)" > .env
	@echo "BINARIES_PATH=$(BINARIES_PATH)" >> .env
	@echo "IN_PATH=$(IN_PATH)" >> .env
	@echo "OUT_PATH=$(OUT_PATH)" >> .env
	@echo "CF_PATH=$(CF_PATH)" >> .env
	@echo "LOG_PATH=$(LOG_PATH)" >> .env
	@echo "ENCODER=$(ENCODER)" >> .env
	@echo "FRAMES_TO_BE_ENCODED=$(FRAMES_TO_BE_ENCODED)" >> .env
	@echo "MP4BOX=$(MP4BOX)" >> .env
	@echo ".env file created successfully."

install_encoder:
	cd $(TEMPORARY_PATH)
	mkdir $(ENCODER_PATH)
	git clone https://github.com/fraunhoferhhi/vvenc/ $(ENCODER_PATH)
	cd $(ENCODER_PATH)
	mkdir build
	cd build
	cmake ..
	make install-ffapp=1 -j
	make install-release
	cp ../bin/release-static $(BINARIES_PATH)
	cd $(CURRENT_PATH)
install_decoder:
	cd $(TEMPORARY_PATH)
	mkdir $(DECODER_PATH)
	git clone https://github.com/fraunhoferhhi/vvdec/ $(DECODER_PATH)
	cd $(DECODER_PATH)
	mkdir build
	cd build
	cmake ..
	make -j
	make all
	cp ../bin $(BINARIES_PATH)
	cd $(CURRENT_PATH)
install_SubPictureMerger:
	cd $(TEMPORARY_PATH)
	mkdir $(VVC_PATH)
	git clone https://vcgit.hhi.fraunhofer.de/jvet/VVCSoftware_VTM.git $(VVC_PATH)
	cd $(VVC_PATH)
	mkdir build
	cd build
	cmake ..
	make -j
	make install-release
install_ffmpeg:
	mkdir $(FFMPEG_PATH)
	git clone https://github.com/jeanlf/FFmpeg/tree/vvdec_ovvc_latest $(FFMPEG_PATH)
	cd $(FFMPEG_PATH)
	./configure --enable-libvvdec --enable-libvvenc
	make -j
	make install
	cp ./ffmpeg $(BINARIES_PATH)
	cp ./ffplay $(BINARIES_PATH)
	cp ./ffprobe $(BINARIES_PATH)
install_gpac:
install: install_encoder install_decoder install_ffmpeg install_SubPictureMerger install_gpac
	@mkdir $(TEMPORARY_PATH)
	@mkdir $(BINARIES_PATH)
	@echo "Launching Install Script, this may take a while.."

# STREAM_A := $(OUT_PATH)/streamA.266
# STREAM_A_NHML := $(OUT_PATH)/streamA.nhml
# STREAM_B := $(OUT_PATH)/streamB.266

# $(STREAM_A):
# 	exec $(ENCODER) -c $(CF_PATH)/streamA.cfg -i --Size 1920x108 --FrameRate 25 --FramesToBeEncoded 256 --InputFile $(IN_PATH)/input_1920x108_25.yuv --BitstreamFile $(STREAM_A) &> $(LOG_PATH)/streamA.encoder.log
# $(STREAM_A_NHML):
# 	$(MP4BOX) -add $(STREAM_A) -new $(OUT_PATH)/streamA.mp4
# 	gpac -i $(OUT_PATH)/streamA.mp4 -o $(OUT_PATH)/streamA.nhml:pckp

# exp1: "$(OUT_PATH)/streamA.266" "$(OUT_PATH)/streamB.266"


# Wildcard target for any stream (e.g., A, B, C, ...)
# %:
# 	@$(MAKE) process CFG=stream$*.cfg INPUT_FILE=input_$*.yuv OUTPUT_FILE_PREFIX=stream$*

# Derived Variables for Processing (set for each invocation)
# BITSTREAM_FILE := $(OUT_PATH)/$(OUTPUT_FILE_PREFIX).266
# MP4_FILE := $(OUT_PATH)/$(OUTPUT_FILE_PREFIX).mp4
# NHML_FILE := $(OUT_PATH)/$(OUTPUT_FILE_PREFIX).nhml
# ENCODER_LOG := $(LOG_PATH)/$(OUTPUT_FILE_PREFIX).encoder.log

# Processing Target
# process: $(NHML_FILE)

# $(NHML_FILE): $(MP4_FILE)
# 	$(GPAC) -i $(MP4_FILE) -o $(NHML_FILE):pckp

# $(MP4_FILE): $(BITSTREAM_FILE)
# 	$(MP4BOX) -add $(BITSTREAM_FILE) -new $(MP4_FILE)

# $(BITSTREAM_FILE):
# 	exec $(ENCODER) -c $(CF_PATH)/$(CFG) -i --Size $(FRAME_SIZE) --FrameRate $(FRAME_RATE) --FramesToBeEncoded $(FRAMES_TO_BE_ENCODED) --InputFile $(IN_PATH)/$(INPUT_FILE) --BitstreamFile $(BITSTREAM_FILE) &> $(ENCODER_LOG)

# process: .env
# 	for file in $(IN_PATH)/*.yuv; do \
# 		echo "Processing $($$file)"; \
# 		./encode-streams.sh $$file; \
# 	done

# 	for file in $(OUT_PATH)/*.266; do \
#         echo "Processing $$file"; \
# 		./generate-nhml.sh $$file; \
# 	done