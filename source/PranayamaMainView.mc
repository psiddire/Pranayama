import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Attention;
import Toybox.SensorHistory;
import Toybox.Application.Storage;
import Toybox.Time;

enum SessionState {
    STATE_WELCOME,
    STATE_BHASTRIKA_INTRO,
    STATE_BHASTRIKA,
    STATE_REST_1,
    STATE_KAPALABHATI_INTRO,
    STATE_KAPALABHATI,
    STATE_REST_2,
    STATE_NADI_SHODHANA_INTRO,
    STATE_NADI_SHODHANA,
    STATE_REST_3,
    STATE_BHRAMARI_INTRO,
    STATE_BHRAMARI,
    STATE_COMPLETE
}

class PranayamaMainView extends WatchUi.View {

    private var _state as SessionState = STATE_WELCOME;
    private var _timer as Timer.Timer?;
    private var _sessionTime as Number = 0;
    private var _timerTicks as Number = 0;  // Track timer ticks (10 per second)
    private var _animationPhase as Float = 0.0;
    private var _breathingCycle as Number = 0;
    private var _isInhaling as Boolean = true;
    private var _startStressLevel as Number? = null;
    private var _endStressLevel as Number? = null;
    private var _sessionStartTime as Time.Moment? = null;
    private var _totalSessionDuration as Number = 0;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // No layout needed for basic test
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw based on current state
        switch (_state) {
            case STATE_WELCOME:
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Pranayama", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 50, Graphics.FONT_SMALL, "10-minute session", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 30, Graphics.FONT_TINY, "4 breathing techniques", Graphics.TEXT_JUSTIFY_CENTER);
                
                // Show session statistics
                var stats = getSessionStats();
                if (stats != null) {
                    var totalSessions = stats.get("totalSessions");
                    var completedSessions = stats.get("completedSessions");
                    if (totalSessions != null && totalSessions instanceof Number && (totalSessions as Number) > 0) {
                        dc.drawText(centerX, centerY + 10, Graphics.FONT_TINY, 
                            "Sessions: " + completedSessions + "/" + totalSessions, 
                            Graphics.TEXT_JUSTIFY_CENTER);
                    }
                }
                
                dc.drawText(centerX, centerY + 70, Graphics.FONT_SMALL, "Tap to begin", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_BHASTRIKA_INTRO:
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Bhastrika", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 20, Graphics.FONT_TINY, "Rapid forceful breathing", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 0, Graphics.FONT_TINY, "Inhale and exhale forcefully", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 60, Graphics.FONT_SMALL, "Starting in " + (3 - _sessionTime) + "...", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_BHASTRIKA:
                // Rapid orange pulsing for bellows breath - sync with breathing instruction
                var isInhaling = (_sessionTime % 2 == 0);
                var breathPhase = (_timerTicks % 10) / 10.0;  // 0-1 over 1 second
                var radiusVariation = isInhaling ? (breathPhase * 25) : (25 - (breathPhase * 25));
                var bhastrikaRadius = 40 + radiusVariation;
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX, centerY, bhastrikaRadius.toNumber());
                
                // Breathing instruction over circle
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var instruction = isInhaling ? "INHALE" : "EXHALE";
                dc.drawText(centerX, centerY - 5, Graphics.FONT_LARGE, instruction, Graphics.TEXT_JUSTIFY_CENTER);
                
                // Progress info
                dc.drawText(centerX, centerY + 70, Graphics.FONT_TINY, "Time: " + _sessionTime + "s", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_KAPALABHATI_INTRO:
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Kapalabhati", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 20, Graphics.FONT_TINY, "Forceful exhale", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY, Graphics.FONT_TINY, "Passive inhale", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 20, Graphics.FONT_TINY, "Pump the belly out", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 60, Graphics.FONT_SMALL, "Starting in " + (3 - _sessionTime) + "...", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_KAPALABHATI:
                // Golden shining effect - sync with breathing
                var isPumpingOut = (_sessionTime % 2 == 0);
                var kapalaPhase = (_timerTicks % 10) / 10.0;  // 0-1 over 1 second
                var kapalaVariation = isPumpingOut ? (15 - (kapalaPhase * 15)) : (kapalaPhase * 15);
                var kapalabhatiRadius = 40 + kapalaVariation;
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX, centerY, kapalabhatiRadius.toNumber());
                
                // Breathing instruction over circle  
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var kapalaInstruction = isPumpingOut ? "PUMP OUT" : "LET IN";
                dc.drawText(centerX, centerY - 5, Graphics.FONT_LARGE, kapalaInstruction, Graphics.TEXT_JUSTIFY_CENTER);
                
                // Progress info
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX, centerY + 70, Graphics.FONT_TINY, "Time: " + _sessionTime + "s", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_NADI_SHODHANA_INTRO:
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Nadi Shodhana", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 0, Graphics.FONT_TINY, "Alternate nostril", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 60, Graphics.FONT_SMALL, "Starting in " + (3 - _sessionTime) + "...", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_NADI_SHODHANA:
                // Proper Nadi Shodhana: Inhale left → Exhale right → Inhale right → Exhale left
                var nadiCycle = _sessionTime % 16;  // 16 second full cycle
                var nadiPhase = 0;  // 0=inhale left, 1=exhale right, 2=inhale right, 3=exhale left
                var nadiInhaling = false;
                var leftActive = false;
                var rightActive = false;
                
                if (nadiCycle < 4) {
                    nadiPhase = 0; nadiInhaling = true; leftActive = true;  // Inhale left nostril
                } else if (nadiCycle < 8) {
                    nadiPhase = 1; nadiInhaling = false; rightActive = true;  // Exhale right nostril
                } else if (nadiCycle < 12) {
                    nadiPhase = 2; nadiInhaling = true; rightActive = true;  // Inhale right nostril
                } else {
                    nadiPhase = 3; nadiInhaling = false; leftActive = true;  // Exhale left nostril
                }
                
                var nadiBreathPhase = (_timerTicks % 40) / 40.0;  // 0-1 over 4 seconds
                var nadiRadiusVariation = nadiInhaling ? (nadiBreathPhase * 15) : (15 - (nadiBreathPhase * 15));
                
                var leftRadius = leftActive ? (30 + nadiRadiusVariation) : 25;
                var rightRadius = rightActive ? (30 + nadiRadiusVariation) : 25;
                
                var leftColor = leftActive ? Graphics.COLOR_BLUE : Graphics.COLOR_DK_GRAY;
                var rightColor = rightActive ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_GRAY;
                
                dc.setColor(leftColor, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX - 40, centerY, leftRadius.toNumber());
                dc.setColor(rightColor, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX + 40, centerY, rightRadius.toNumber());
                
                // Breathing instruction over circles
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var nadiInstruction = "";
                if (nadiPhase == 0) { nadiInstruction = "INHALE LEFT"; }
                else if (nadiPhase == 1) { nadiInstruction = "EXHALE RIGHT"; }
                else if (nadiPhase == 2) { nadiInstruction = "INHALE RIGHT"; }
                else { nadiInstruction = "EXHALE LEFT"; }
                dc.drawText(centerX, centerY + 15, Graphics.FONT_SMALL, nadiInstruction, Graphics.TEXT_JUSTIFY_CENTER);
                
                // Progress info
                dc.drawText(centerX, centerY + 70, Graphics.FONT_TINY, "Time: " + _sessionTime + "s", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_BHRAMARI_INTRO:
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Bhramari", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 20, Graphics.FONT_TINY, "Humming Bee Breath", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 0, Graphics.FONT_TINY, "Inhale normally", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 20, Graphics.FONT_TINY, "Exhale with humming", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY + 60, Graphics.FONT_SMALL, "Starting in " + (3 - _sessionTime) + "...", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_BHRAMARI:
                // Purple vibrating circle for humming bee - sync with breathing
                var bhramariCycle = _sessionTime % 12;  // 12s cycle: 4s inhale, 8s hum exhale
                var isInhalingBhramari = (bhramariCycle < 4);
                var bhramariPhase = isInhalingBhramari ? 
                    ((_timerTicks % 40) / 40.0) :  // 0-1 over 4 seconds for inhale
                    ((_timerTicks % 80) / 80.0);   // 0-1 over 8 seconds for exhale
                
                var bhramariVariation = isInhalingBhramari ? 
                    (bhramariPhase * 20) :  // Expand during inhale
                    (20 - (bhramariPhase * 5));  // Contract slowly during hum exhale
                
                // Add vibration during humming
                var vibration = isInhalingBhramari ? 0 : (Math.sin(_animationPhase * 8.0) * 2);
                var bhramariRadius = 40 + bhramariVariation + vibration;
                dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX, centerY, bhramariRadius.toNumber());
                
                // Breathing instruction over circle
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var bhramariInstruction = isInhalingBhramari ? "INHALE" : "HUM EXHALE";
                dc.drawText(centerX, centerY - 5, Graphics.FONT_LARGE, bhramariInstruction, Graphics.TEXT_JUSTIFY_CENTER);
                
                // Progress info
                dc.drawText(centerX, centerY + 70, Graphics.FONT_TINY, "Time: " + _sessionTime + "s", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_REST_1:
            case STATE_REST_2:
            case STATE_REST_3:
                // Gentle breathing circle (draw animation first)
                var restRadius = 30 + (Math.sin(_animationPhase * 0.5) * 10);
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX, centerY + 10, restRadius.toNumber());
                
                // Text over animation
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Rest Period", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 0, Graphics.FONT_TINY, "Breathe naturally", Graphics.TEXT_JUSTIFY_CENTER);
                
                // Progress info
                dc.drawText(centerX, centerY + 70, Graphics.FONT_TINY, "Time: " + _sessionTime + "s", Graphics.TEXT_JUSTIFY_CENTER);
                break;
                
            case STATE_COMPLETE:
                dc.drawText(centerX, centerY - 80, Graphics.FONT_MEDIUM, "Complete!", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(centerX, centerY - 50, Graphics.FONT_SMALL, "Well done!", Graphics.TEXT_JUSTIFY_CENTER);
                
                // Show stress level comparison
                if (_startStressLevel != null && _endStressLevel != null) {
                    var stressDiff = _endStressLevel - _startStressLevel;
                    var stressText = "";
                    var stressColor = Graphics.COLOR_WHITE;
                    
                    if (stressDiff <= -5) {
                        stressText = "Stress: Much lower!";
                        stressColor = Graphics.COLOR_GREEN;
                    } else if (stressDiff < 0) {
                        stressText = "Stress: Lower";
                        stressColor = Graphics.COLOR_DK_GREEN;
                    } else if (stressDiff == 0) {
                        stressText = "Stress: Same level";
                        stressColor = Graphics.COLOR_BLUE;
                    } else if (stressDiff <= 5) {
                        stressText = "Stress: Slightly higher";
                        stressColor = Graphics.COLOR_YELLOW;
                    } else {
                        stressText = "Stress: Higher";
                        stressColor = Graphics.COLOR_RED;
                    }
                    
                    dc.setColor(stressColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(centerX, centerY - 20, Graphics.FONT_SMALL, stressText, Graphics.TEXT_JUSTIFY_CENTER);
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(centerX, centerY, Graphics.FONT_TINY, "Before: " + _startStressLevel + " | After: " + _endStressLevel, Graphics.TEXT_JUSTIFY_CENTER);
                } else {
                    dc.drawText(centerX, centerY - 10, Graphics.FONT_TINY, "Stress data unavailable", Graphics.TEXT_JUSTIFY_CENTER);
                }
                
                dc.drawText(centerX, centerY + 60, Graphics.FONT_TINY, "Tap to restart", Graphics.TEXT_JUSTIFY_CENTER);
                break;
        }
    }

    function onHide() as Void {
    }
    
    private function triggerHapticFeedback() as Void {
        if (Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(25, 200)];  // 25% intensity, 200ms duration
            Attention.vibrate(vibeData);
        }
    }
    
    private function getCurrentStressLevel() as Number? {
        if (SensorHistory has :getStressHistory) {
            var stressIterator = SensorHistory.getStressHistory({:period => 1});  // Last 1 minute
            if (stressIterator != null) {
                var sample = stressIterator.next();
                if (sample != null && sample.data != null) {
                    return sample.data;
                }
            }
        }
        return null;
    }
    
    private function saveSessionData(completed as Boolean) as Void {
        var sessionData = {
            "timestamp" => Time.now().value(),
            "completed" => completed,
            "duration" => _totalSessionDuration,
            "startStress" => _startStressLevel,
            "endStress" => _endStressLevel,
            "stressImprovement" => (_startStressLevel != null && _endStressLevel != null) ? 
                (_startStressLevel - _endStressLevel) : null
        };
        
        // Get existing sessions or create new array
        var existingSessions = Storage.getValue("sessionHistory");
        if (existingSessions == null || !(existingSessions instanceof Array)) {
            existingSessions = [] as Array;
        } else {
            existingSessions = existingSessions as Array;
        }
        
        // Add new session
        existingSessions.add(sessionData);
        
        // Keep only last 50 sessions to manage storage
        if (existingSessions.size() > 50) {
            existingSessions = existingSessions.slice(-50, null);
        }
        
        // Save updated history
        Storage.setValue("sessionHistory", existingSessions);
        
        // Update statistics
        var statsData = Storage.getValue("sessionStats");
        var stats;
        if (statsData == null || !(statsData instanceof Dictionary)) {
            stats = {
                "totalSessions" => 0,
                "completedSessions" => 0,
                "totalMinutes" => 0,
                "avgStressImprovement" => 0
            } as Dictionary;
        } else {
            stats = statsData as Dictionary;
        }
        
        var totalSessions = stats.get("totalSessions");
        var completedSessions = stats.get("completedSessions");
        var totalMinutes = stats.get("totalMinutes");
        
        var totalSessionsNum = (totalSessions != null && totalSessions instanceof Number) ? 
            (totalSessions as Number) : 0;
        var completedSessionsNum = (completedSessions != null && completedSessions instanceof Number) ? 
            (completedSessions as Number) : 0;
        var totalMinutesNum = (totalMinutes != null && totalMinutes instanceof Number) ? 
            (totalMinutes as Number) : 0;
        
        stats.put("totalSessions", totalSessionsNum + 1);
        if (completed) {
            stats.put("completedSessions", completedSessionsNum + 1);
        }
        stats.put("totalMinutes", totalMinutesNum + (_totalSessionDuration / 60));
        
        Storage.setValue("sessionStats", stats);
    }
    
    private function getSessionStats() as Dictionary? {
        var stats = Storage.getValue("sessionStats");
        if (stats != null && stats instanceof Dictionary) {
            return stats as Dictionary;
        }
        return null;
    }
    
    function handleEarlyExit() as Void {
        // Save incomplete session data if session was started
        if (_sessionStartTime != null && _state != STATE_WELCOME && _state != STATE_COMPLETE) {
            var endTime = Time.now();
            _totalSessionDuration = endTime.subtract(_sessionStartTime).value();
            _endStressLevel = getCurrentStressLevel();
            saveSessionData(false);  // Mark as incomplete
        }
    }
    
    function startSession() as Void {
        switch (_state) {
            case STATE_WELCOME:
                _state = STATE_BHASTRIKA_INTRO;
                _sessionTime = 0;
                _timerTicks = 0;
                _sessionStartTime = Time.now();  // Capture session start time
                _startStressLevel = getCurrentStressLevel();  // Capture initial stress level
                startTimer();
                break;
            case STATE_BHASTRIKA_INTRO:
            case STATE_BHASTRIKA:
            case STATE_REST_1:
            case STATE_KAPALABHATI_INTRO:
            case STATE_KAPALABHATI:
            case STATE_REST_2:
            case STATE_NADI_SHODHANA_INTRO:
            case STATE_NADI_SHODHANA:
            case STATE_REST_3:
            case STATE_BHRAMARI_INTRO:
            case STATE_BHRAMARI:
                // Already in session, do nothing
                break;
            case STATE_COMPLETE:
                // Restart
                _state = STATE_WELCOME;
                _startStressLevel = null;
                _endStressLevel = null;
                _sessionStartTime = null;
                _totalSessionDuration = 0;
                break;
        }
        WatchUi.requestUpdate();
    }
    
    function nextState() as Void {
        // Advance to next state manually (for button press)
        switch (_state) {
            case STATE_WELCOME:
                _state = STATE_BHASTRIKA_INTRO;
                _sessionTime = 0;
                _timerTicks = 0;
                startTimer();
                break;
            case STATE_BHASTRIKA_INTRO:
                _state = STATE_BHASTRIKA;
                _sessionTime = 0;
                _timerTicks = 0;
                _breathingCycle = 0;
                break;
            case STATE_BHASTRIKA:
                _state = STATE_REST_1;
                _sessionTime = 0;
                _timerTicks = 0;
                _breathingCycle = 0;
                break;
            case STATE_REST_1:
                _state = STATE_KAPALABHATI_INTRO;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_KAPALABHATI_INTRO:
                _state = STATE_KAPALABHATI;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_KAPALABHATI:
                _state = STATE_REST_2;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_REST_2:
                _state = STATE_NADI_SHODHANA_INTRO;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_NADI_SHODHANA_INTRO:
                _state = STATE_NADI_SHODHANA;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_NADI_SHODHANA:
                _state = STATE_REST_3;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_REST_3:
                _state = STATE_BHRAMARI_INTRO;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_BHRAMARI_INTRO:
                _state = STATE_BHRAMARI;
                _sessionTime = 0;
                _timerTicks = 0;
                break;
            case STATE_BHRAMARI:
                _state = STATE_COMPLETE;
                stopTimer();
                break;
            case STATE_COMPLETE:
                _state = STATE_WELCOME;
                break;
        }
        triggerHapticFeedback();  // Haptic feedback for manual state changes
        WatchUi.requestUpdate();
    }
    
    private function startTimer() as Void {
        if (_timer != null) {
            _timer.stop();
        }
        _timer = new Timer.Timer();
        _timer.start(method(:onTimerTick), 100, true);  // 100ms = 10 times per second for smooth animation
    }
    
    private function stopTimer() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
    
    function onTimerTick() as Void {
        _timerTicks++;
        
        // Update session time every 10 ticks (1 second)
        if (_timerTicks % 10 == 0) {
            _sessionTime++;
        }
        
        // Update animation phase for smooth breathing circle (10 times per second)
        _animationPhase += 0.06;  // Smoother increment for 10fps
        if (_animationPhase >= (2.0 * Math.PI)) {
            _animationPhase = 0.0;
        }
        
        // 10-minute session timing
        // 4 techniques of ~2 minutes each + rest periods + intros = ~10 minutes total
        var bhastrikaTime = 120;     // 2 minutes
        var kapalabhatiTime = 120;   // 2 minutes  
        var nadiShodhanaTime = 150;  // 2.5 minutes
        var bhramariTime = 120;      // 2 minutes
        var restTime = 20;           // 20 seconds rest
        var introTime = 3;           // 3 seconds intro
        
        // Update breathing cycle tracking
        if (_state == STATE_BHASTRIKA && _sessionTime % 2 == 0) {
            _breathingCycle = _sessionTime / 2;
        } else if (_state == STATE_KAPALABHATI) {
            _breathingCycle = _sessionTime;  // 1 pump per second
        }
        
        if (_state == STATE_BHASTRIKA_INTRO && _sessionTime >= introTime) {
            _state = STATE_BHASTRIKA;
            _sessionTime = 0;
            _timerTicks = 0;
            _breathingCycle = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_BHASTRIKA && _sessionTime >= bhastrikaTime) {
            _state = STATE_REST_1;
            _sessionTime = 0;
            _timerTicks = 0;
            _breathingCycle = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_REST_1 && _sessionTime >= restTime) {
            _state = STATE_KAPALABHATI_INTRO;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_KAPALABHATI_INTRO && _sessionTime >= introTime) {
            _state = STATE_KAPALABHATI;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_KAPALABHATI && _sessionTime >= kapalabhatiTime) {
            _state = STATE_REST_2;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_REST_2 && _sessionTime >= restTime) {
            _state = STATE_NADI_SHODHANA_INTRO;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_NADI_SHODHANA_INTRO && _sessionTime >= introTime) {
            _state = STATE_NADI_SHODHANA;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_NADI_SHODHANA && _sessionTime >= nadiShodhanaTime) {
            _state = STATE_REST_3;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_REST_3 && _sessionTime >= restTime) {
            _state = STATE_BHRAMARI_INTRO;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_BHRAMARI_INTRO && _sessionTime >= introTime) {
            _state = STATE_BHRAMARI;
            _sessionTime = 0;
            _timerTicks = 0;
            triggerHapticFeedback();
        } else if (_state == STATE_BHRAMARI && _sessionTime >= bhramariTime) {
            _state = STATE_COMPLETE;
            _endStressLevel = getCurrentStressLevel();  // Capture final stress level
            
            // Calculate total session duration
            if (_sessionStartTime != null) {
                var endTime = Time.now();
                _totalSessionDuration = endTime.subtract(_sessionStartTime).value();
            }
            
            // Save completed session data
            saveSessionData(true);
            
            stopTimer();
            triggerHapticFeedback();
        }
        
        WatchUi.requestUpdate();
    }
}