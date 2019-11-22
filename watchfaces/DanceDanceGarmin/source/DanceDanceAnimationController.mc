using Toybox.WatchUi;

class DanceDanceAnimationController {
    private var _animation;
    private var _textLayer;
    private var _playing;

    function initialize() {
        _playing = false;
    }

    function handleOnShow(view) {
        if( view.getLayers() == null ) {
            // Initialize the Animation
            _animation = new WatchUi.AnimationLayer(
                Rez.Drawables.dancers,
                {
                    :locX=>0,
                    :locY=>0,
                }
                );

            // Build the time overlay
            _textLayer = buildTextLayer();

            view.addLayer(_animation);
            view.addLayer(_textLayer);
        }

    }

    function handleOnHide(view) {
        view.clearLayers();
        _animation = null;
        _textLayer = null;
    }

    // Function to initialize the time layer
    private function buildTextLayer() {
        var info = System.getDeviceSettings();
        // Word aligning the width and height for better blits
        var width = (info.screenWidth * .60).toNumber() & ~0x3;
        var height = info.screenHeight * .25;

        var options = {
            :locX => ( (info.screenWidth - width) / 2 ).toNumber() & ~0x03,
            :locY => (info.screenHeight - height) / 2,
            :width => width,
            :height => height,
            :visibility=>true
        };

        // Initialize the Time over the animation
        var textLayer = new WatchUi.Layer(options);
        return textLayer;
    }

    function getTextLayer() {
        return _textLayer;
    }


    function play() {
        if(!_playing) {
            _animation.play({
                :delegate => new DanceDanceAnimationDelegate(self)
                });
            _playing = true;
        }
    }

    function stop() {
        if(_playing) {
            _animation.stop();
            _playing = false;
        }
    }

}