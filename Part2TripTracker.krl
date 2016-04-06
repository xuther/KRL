ruleset track_trip_Part2 {
	meta {
		name "Trip_Tracker_2"
		description <<
			Trip Tracker Part 2 for project 1.
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on 
	}

	global {
		long_milage = 50
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
			raise explicit event trip_processed with 
				_milage = milage;
			log("Message fired with input " + input);
		}
	}

	rule find_long_trips {
		select when explicit trip_processed 
		pre {
			milage = event:attr("_milage").klog("Milage passed into explicit event: ");
		}
		fired {
			//Init if not there
			//set ent:long_milage init if not ent:long_milage{["_0"]};

			raise explicit event found_long_trip with
				_milage = milage 
				if(milage > long_milage);
		}
	}

	rule found_long_trip {
		select when explicit found_long_trip 
		pre {
			milage = event:attr("_milage").klog("Long trip found: ");
		}
		fired {
			//I misunderstood this - i though we were finding the longest trip. 
			//set ent:long_milage milage;
			log("Found longest trip: " + milage);
		}
	}
}