# The order of the sources does matter.
LUASOURCES := src/requires.lua
LUASOURCES += src/options.lua

SOURCES += src/util/util.moon
SOURCES += src/util/Point.moon
SOURCES += src/util/Region.moon
SOURCES += src/util/VideoPoint.moon
SOURCES += src/util/video_to_screen.moon

SOURCES += src/encode/EncodingParameters.moon
SOURCES += src/encode/MpvFilter.moon
SOURCES += src/encode/Track.moon
SOURCES += src/encode/formats/Format.moon
SOURCES += src/encode/formats/H264Format.moon
SOURCES += src/encode/formats/RawVideoFormat.moon
SOURCES += src/encode/formats/VP8Format.moon
SOURCES += src/encode/formats/VP9Format.moon
SOURCES += src/encode/backends/Backend.moon
SOURCES += src/encode/backends/FfmpegBackend.moon
SOURCES += src/encode/backends/MpvBackend.moon
SOURCES += src/encode/encode.moon

SOURCES += src/interface/Option.moon
SOURCES += src/interface/pages/Page.moon
SOURCES += src/interface/pages/CropPage.moon
SOURCES += src/interface/pages/EncodeOptionsPage.moon
SOURCES += src/interface/pages/PreviewPage.moon
SOURCES += src/interface/pages/MainPage.moon

SOURCES += src/main.moon

TMPDIR       := build
JOINEDSRC    := $(TMPDIR)/webm_bundle.moon
OUTPUT       := $(JOINEDSRC:.moon=.lua)
JOINEDLUASRC := $(TMPDIR)/webm.lua
RESULTS      := $(addprefix $(TMPDIR)/, $(SOURCES:.moon=.lua))
MPVCONFIGDIR := ~/.config/mpv/

.PHONY: all clean

all: $(JOINEDLUASRC)

$(OUTPUT): $(JOINEDSRC)
	@printf 'Building %s\n' $@
	@moonc -o $@ $< 2>/dev/null

$(JOINEDSRC): $(SOURCES) | $(TMPDIR)
	@printf 'Generating %s\n' $@
	@cat $^ > $@

$(JOINEDLUASRC): $(LUASOURCES) $(OUTPUT) | $(TMPDIR)
	@printf 'Joining with Lua sources into %s.\n' $@
	@cat $^ > $@

$(TMPDIR)/%.lua: %.moon
	@printf 'Building %s\n' $@
	@moonc -o $@ $< 2>/dev/null

$(TMPDIR):
	@mkdir -p $@

$(TMPDIR)/%/: | $(TMPDIR)
	@mkdir -p $@

install: $(OUTPUT)
	install -d $(MPVCONFIGDIR)/scripts/
	install -m 644 $(JOINEDLUASRC) $(MPVCONFIGDIR)/scripts/

clean:
	@rm -rf $(TMPDIR)
