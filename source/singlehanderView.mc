import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Time;
using Toybox.SensorHistory as Sensor;
import Toybox.ActivityMonitor;
import Toybox.Application;


class singlehanderView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }
    
	private function generateHandCoordinates(centerPoint as Array<Number>, angle as Float, handLength as Number, tailLength as Number, startWidth as Number, endWidth as Number) as Array< Array<Float> > {
        // Map out the coordinates of the watch hand
        var coords = [[-(startWidth / 2), tailLength] as Array<Number>,
                      [-(endWidth / 2), -handLength] as Array<Number>,
                      [endWidth / 2, -handLength] as Array<Number>,
                      [startWidth / 2, tailLength] as Array<Number>] as Array< Array<Number> >;
        var result = new Array< Array<Float> >[4];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i++) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

            result[i] = [centerPoint[0] + x, centerPoint[1] + y] as Array<Float>;
        }
        return result;
    }

    // Draws the clock tick marks around the outside edges of the screen.
    private function drawHashMarks(dc as Dc, scale_to_fenix as Number) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var outerRad = width / 2;
        var innerRadFiveMinutes = outerRad - 10 * scale_to_fenix;
        var innerRadFifteenMinutes = outerRad - 15 * scale_to_fenix;
        var innerRadHours = outerRad - 25 * scale_to_fenix;
    
        // 5 minute hashes
        // 1 hour contains 12 hashes of 5 minutes, hence the whole dial has 144 of them
        for (var i = 1; i <= 144; i += 1) {
            var angle = i * (Math.PI/144)*2;
            var sY = outerRad + innerRadFiveMinutes * Math.sin(angle);
            var eY = outerRad + outerRad * Math.sin(angle);
            var sX = outerRad + innerRadFiveMinutes * Math.cos(angle);
            var eX = outerRad + outerRad * Math.cos(angle);
            dc.drawLine(sX, sY, eX, eY);
        }
        // 15 minute hashes
        // 1 hour contains 4 hashes of 15 minutes, hence the whole dial has 48 of them
        for (var i = 1; i <= 48; i += 1) {
            var angle = i * (Math.PI/48)*2;
            var sY = outerRad + innerRadFifteenMinutes * Math.sin(angle);
            var eY = outerRad + outerRad * Math.sin(angle);
            var sX = outerRad + innerRadFifteenMinutes * Math.cos(angle);
            var eX = outerRad + outerRad * Math.cos(angle);
            dc.drawLine(sX, sY, eX, eY);
        }

        // Half-hours hour
        for (var i = 1; i <= 24; i += 1) {
            var angle = i * (Math.PI/24)*2;
            var sY = outerRad + innerRadHours * Math.sin(angle);
            var eY = outerRad + outerRad * Math.sin(angle);
            var sX = outerRad + innerRadHours * Math.cos(angle);
            var eX = outerRad + outerRad * Math.cos(angle);
            dc.drawLine(sX, sY, eX, eY);
        }


        // Full hour
        for (var i = 1; i <= 12; i += 1) {
            var angle = i * (Math.PI/12)*2;
            var sY = outerRad + innerRadHours * Math.sin(angle);
            var eY = outerRad + outerRad * Math.sin(angle);
            var sX = outerRad + innerRadHours * Math.cos(angle);
            var eX = outerRad + outerRad * Math.cos(angle);
            dc.drawLine(sX, sY, eX, eY);
        }
    }

    private function drawMainNumbers(dc as Dc, scale_to_fenix as Number) as Void {
    	var width = dc.getWidth();
        var height = dc.getHeight();
        
        var outerRad = width / 2;
        var innerRad = outerRad - 25 * scale_to_fenix;
		var distfromside = 45 * scale_to_fenix;
		
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);

        // Set up a for loop and draw all 12 numberals in their correct position
        for (var i = 1; i <= 12; i += 1) {
            // Decide what digit to draw
            var actualNumber = (i+2) % 12 + 1;
            
            // Depending on the user's device setting for 24-hour time, add 12 to the number if we're past midday
            if (System.getDeviceSettings().is24Hour && System.getClockTime().hour >= 12){
                actualNumber = actualNumber + 12;
            }

            // Pad the number with 0
            if (actualNumber < 10) {
                actualNumber = "0" + actualNumber;
            }
            var angle = i * (Math.PI/6);
            var sY = outerRad + innerRad * Math.sin(angle);
            var sX = outerRad + innerRad * Math.cos(angle);
            var eY = outerRad + (outerRad - distfromside) * Math.sin(angle);
            var eX = outerRad + (outerRad - distfromside) * Math.cos(angle);
            dc.drawText(eX, eY, Graphics.FONT_SYSTEM_SMALL, actualNumber, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

		// FURTHER WORK REQUIRED: Use a thicker or different font for watches withn fancier displays like the Venu 2
		// dc.drawText(width/2, width-distfromside, Graphics.FONT_NUMBER_MILD, 6, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// dc.drawText(width-distfromside, width/2, Graphics.FONT_NUMBER_MILD, 3, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// dc.drawText(distfromside, width/2, Graphics.FONT_NUMBER_MILD, 9, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		
    }

    private function drawMainTriangles(dc as Dc, count as Number, skipper as Number, thickness as Number, shortener as Number, scale_to_fenix as Number) as Void {
    	var width = dc.getWidth();
        var height = dc.getHeight();
        
        thickness = thickness * scale_to_fenix;
        shortener = shortener * scale_to_fenix;

        var outerRad = (width) / 2;
        var innerRad = outerRad - 20*scale_to_fenix + shortener;

        for (var i = 0; i < count; i += 1) {
        	if (skipper == 0 ||  i % skipper != 0){
	        	// s in on the inside 
	            var angle = i * (Math.PI/count)*2;
	            var sY = outerRad + innerRad * Math.sin(angle);
	            var sX = outerRad + innerRad * Math.cos(angle);
	
	            var eY_u = outerRad + (outerRad + 10*scale_to_fenix) * Math.sin(angle) + thickness * Math.cos(angle);
	            var eX_u = outerRad + (outerRad + 10*scale_to_fenix) * Math.cos(angle) + thickness * Math.sin(angle);
	            
	            var eY_l = outerRad + (outerRad + 10*scale_to_fenix) * Math.sin(angle) - thickness * Math.cos(angle);
	            var eX_l = outerRad + (outerRad + 10*scale_to_fenix) * Math.cos(angle) - thickness * Math.sin(angle);
	
	            dc.fillPolygon([[sY, sX],[eY_u, eX_u],[eY_l, eX_l]]);
            }
        }
    }


	function drawHand(dc, angle, length, width, scale_to_fenix as Number)
	{
		length = length * scale_to_fenix;
		width = width * scale_to_fenix;
		
		// Map out the coordinates of the watch hand
		var coords = [
			[-(width/2),0],
			[-(width/2), -length],
			[width/2, -length],
			[width/2, 0]
			];
		var result = new [4];
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		
		// Transform the coordinates
		for (var i = 0; i < 4; i += 1)
		{
		var x = (coords[0] * cos) - (coords[1] * sin);
		var y = (coords[0] * sin) + (coords[1] * cos);
		result= [ centerX+x, centerY+y];
		}
		
		// Draw the polygon
		dc.fillPolygon(result);
		dc.fillPolygon(result);
	}


    // Update the view
    function onUpdate(dc as Dc) as Void {
    	var lume_color = Graphics.COLOR_ORANGE;
    
		var scale_to_fenix = dc.getWidth().toFloat()/260;
		var hand_coord_centre = dc.getWidth()/2;
    
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

		// Enable anti-aliasing, if available
		if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}

		// Draw the tick marks around the edges of the screen
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        drawHashMarks(dc, scale_to_fenix);
        drawMainNumbers(dc, scale_to_fenix);
        
        // Drawing the triangles around the dial
        dc.setColor(lume_color, Graphics.COLOR_TRANSPARENT);
        // drawMainTriangles(dc, 4, 0, 15, 0, scale_to_fenix); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function
        // drawMainTriangles(dc, 12, 3, 12, -16, scale_to_fenix); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function
		
	    
        // Computing hand angles, convert time to minutes and compute the angle.
        // Get current time
        var clockTime = System.getClockTime();
        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = hourHandAngle / (12 * 60.0);
        hourHandAngle = hourHandAngle * Math.PI * 2;

		// Use gray to draw the hour and minute hands
		dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);        
        
        // Draw hands
        var minusradius = -10 * scale_to_fenix;
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        
		

		// Main hand
		dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
			125 * scale_to_fenix,
			minusradius+35,
			12 * scale_to_fenix,
			3 * scale_to_fenix));    

        dc.fillCircle(hand_coord_centre, hand_coord_centre, -minusradius + 1 * scale_to_fenix);
        
		// LUMES, hence changing to the right color
		dc.setColor(lume_color,Graphics.COLOR_TRANSPARENT);
        
        // Spike lume
		dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
			110 * scale_to_fenix,
			minusradius-5,
			6 * scale_to_fenix,
			1*scale_to_fenix));
         
    }
    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
