# <====== PATHS
CURRENT_PATH=$(pwd)
BINARIES_PATH="$(CURRENT_PATH)/bin"
TEMPORARY_PATH="$(CURRENT_PATH)/tmp"
ENCODER_PATH="$(CURRENT_PATH)/tmp/encoder"
ENCODER_PATH="$(CURRENT_PATH)/tmp/decoder"
VVC_PATH="$(CURRENT_PATH)/tmp/VVCSoftware_VTM/"
FFMPEG_PATH="$(CURRENT_PATH)/tmp/FFmpeg"
# ======= PATHS ======>

# <====== BINARIES
ENCODER="$(BINARIES_PATH)/vvencFFapp"
DECODER="$(BINARIES_PATH)/vvdecapp"
SUBPICMERGEAPP="$(BINARIES_PATH)/SubpicMergeAppStatic"
FFMPEG="$(BINARIES_PATH)/ffmpeg"
FFPLAY="$(BINARIES_PATH)/ffplay"
FFPROBE="$(BINARIES_PATH)/ffprobe"
# ======= BINARIES ======>

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
	mkdir $(ENCODER_PATH)
	git clone https://github.com/fraunhoferhhi/vvdec/ $(ENCODER_PATH)
	cd $(ENCODER_PATH)
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