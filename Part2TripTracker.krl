ruleset track_trip_Part2 {
	meta {
		name "Trip Tracker Part 2"
		description <<
			Trip Tracker Part 2 for project 1.
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on
	}

	rule process_trip {
		select when car new_trip
		pre {
			milage = event:attr("milage").klog("Passed in milage: ");
		}
		{
			send_directive("trip") with 
				trip_length = "#{milage}";
		}
		always{
			raise explicit event trip_processed with _milage = milage
			log("Message fired with input " + input);
		}
	}

	rule find_long_trips {
		select when explicit trip_processed 
		pre {
			milage = event:attr("_milage").klog("Milage passed into explicit event: ");
		}
		always {
			log("find_long_trips was fired with milage of" + milage);
		}
	}

	rule found_long_trip {
		select when explicit found_long_trip 
		pre {
			milage = event:att("_milage").klog("Long trip found: ");
		}
	}
}