ruleset track_trips {
	meta {
		name "Trip Tracker"
		description <<
			Trip Tracker for project 1.
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on
	}

	rule process_trip {
		select when echo message
		pre {
			milage = event:attr("milate").klog("Passed in milage: ");
		}
		{
			send_directive("trip") with 
				trip_length = "#{input}";
		}
		always{
			log("Message fired with input " + input);
		}
	}
}