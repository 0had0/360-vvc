# 360 video viewport adaptation using VVC subpictures

## Description

360 video streaming requires a large amount of bandwidth in order to deliver a good experience. By lowering the resolution of hidden parts of the immersive video, a much more efficient transmission is possible. However, this requires tracking the user head movements to update the high-quality regions, which can introduce lag in quality adaptation depending on random access properties of the video. This project will study the latest VVC video compression standard to understand how streams with different resolutions and random access characteristics can be merged into a single decodable bitstream.

##	Expected tasks
-	study of high level syntax of a VVC bitstream
-	study of a research paper on the topic
-	video sequence selection and encoding using available open-source tools
-	PoC showing multiple reassembled bitstream for pre-defined head positions
-	Integrated demo within GPAC

##  Initial Work
###	Setting up encoder software and test sequences
The VVC reference software is publicly available and described here:
https://jvet.hhi.fraunhofer.de/

However, an alternative, faster encoder is available here:

https://github.com/fraunhoferhhi/vvenc/

This encoder supports VVC subpicture-like generation and is a good starting point.

You will get and compile the software.  You will need to use the so-called full feature version, e.g. for cmake by adding the option -DVVENC_INSTALL_FULLFEATURE_APP=1

You will also need to pass to the encoder the option –TreatAsSubPic: this makes sure that the generated stream is a valid, single subpicture, i.e. all subpicture constraints on motion constraints and post-processing filters are respected. These streams should then be simply mergeable.

You will then select sample streams, both plane 2D video for simple testing, and 360 EQR videos for more advanced testing.
Be careful that subpictures in VVC must have width and height of a multiple of the maximum “block” size, which by default is 128 in vvenc and in the VVC reference software.

###	Setting up playback
A fast command line decoder called vvdec is available here:
https://github.com/fraunhoferhhi/vvdec

You will need to compile and install it on your laptop.

For visual playback, you will either have to:
- decode to YUV using vvdec, and play the YUV with your favorite viewer (ffplay, gpac, …)
- or recompile ffmpeg with the indicated patches:
https://github.com/fraunhoferhhi/vvenc/wiki/FFmpeg-Integration

For bitstream manipulation, you will need to get and compile GPAC (preferably with the custom FFmpeg installed):
    https://github.com/gpac/gpac


##	Study work
You will first need to understand the concepts of VVC and subpictures, the attached resource 
“Overview of the Versatile Video Coding VVC Standard and its Applications” is a good starting point.

You will then need to understand the goal of this project, which is to recombine VVC subpictures into a single bitstream. This approach is described in the attached paper “On Subpicture-based Viewport-dependent 360-degree Video Streaming using VVC” which you will need to study.

The merging of several VVC streams into a single one requires modifying the bitstream at a few places. You need to get familiar with the following elements of the VVC syntax:
-	Slices, tiles and subpictures (section 6.3.1)
-	Sequence parameter set syntax (section 7.3.2.4)
-	Slice and Picture header syntax (section 7.3.7)


talk about ALF and STA
