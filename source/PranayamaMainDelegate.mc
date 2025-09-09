import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class PranayamaMainDelegate extends WatchUi.BehaviorDelegate {

    private var _view as PranayamaMainView?;

    function initialize() {
        BehaviorDelegate.initialize();
        _view = null;
    }
    
    function setView(view as PranayamaMainView) as Void {
        _view = view;
    }

    function onSelect() as Lang.Boolean {
        if (_view != null) {
            _view.startSession();
        }
        return true;
    }
    
    function onTap(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
        if (_view != null) {
            _view.startSession();
        }
        return true;
    }
    
    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        
        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_ENTER) {
            // Top right button or select - advance to next state
            if (_view != null) {
                _view.nextState();
            }
            return true;
        } else if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_ESC) {
            // Bottom right button or back - exit the app
            if (_view != null) {
                _view.handleEarlyExit();  // Save incomplete session data
            }
            System.exit();
            return true;
        }
        
        return false;
    }
}