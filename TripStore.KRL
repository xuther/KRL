ruleset trip_store {
	meta {
		name "Trip_Store"
		description <<
			Store Trips
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on 
	}

	global {
		trips = function() {
			trips = ent:trips;
			trips;
		}

		long_trips = function() {
			long_trips = ent:longTrips;
			long_trips;
		}

		short_trips = function() {
			trips = trips().klog("Trips: ");
			//longTrips = long_trips().klog("LongTrips: ");

			//trips.filter(function(x)
			trips;
		}
	}
	
	rule collect_trips {
		select when explicit trip_processed 
		pre {
			milage = event:attr("_milage").klog("Collect Trips milage: ");
			time = event:attr("_time").klog("Time: ");
			id = event:attr("_tripID").klog("TripID: ");
		}
		fired {
			set ent:trips {[id, "milage"]} milage;
			set ent:trips {[id, "time"]} time;
			log ("Collect_Trips: " + milage);
		}
	}

	rule collect_long_trips {
		select when explicit found_long_trip
		pre {
			milage = event:attr("_milage").klog("Collect Trips milage: ");
			time = event:attr("_time").klog("Time: ");
			id = event:attr("_tripID").klog("TripID: ");
		}
		fired {
			set ent:longTrips {[ent:runningLongCount, "milage"]} milage;
			set ent:longTrips {[ent:runningLongCount, "time"]} time:now();

			log ("Collect_long_Trips: " + milage + ": ID: " + id);
		}
	}

	rule clear_trips {
		select when car trip_reset 
		fired {
			clear ent:trips;
			clear ent:longTrips;
			log("Cleared trips.");
		}
	}	
}