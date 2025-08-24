import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PranayamaApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new PranayamaMainView();
        var delegate = new PranayamaMainDelegate();
        delegate.setView(view);
        return [ view, delegate ];
    }
}

function getApp() as PranayamaApp {
    return Application.getApp() as PranayamaApp;
}