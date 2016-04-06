ruleset trip_store {
	meta {
		name "Trip_Store"
		description <<
			Store Trips
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on 
		provides trips, long_trips, short_trips
	}

	global {
		trips = function() {
			trips = ent:trips;
			trips;
		}

		long_trips = function() {
			long_trips = ent:longTrips.klog("LongTrips: ");
			long_trips;
		}

		short_trips = function() {
			trips = ent:trips.klog("Trips: ");
			longTripMap = ent:longTrips.klog("LongTrips: ");

			short = trips.filter(function(k,v) {
					longTripMap.keys([k]) != null;
				});
			
			short;
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
			time = event:attr("_time").klog("time: ");
			id = event:attr("_tripID").klog("TripID: ");
		}
		fired {
			set ent:longTrips {[id, "milage"]} milage;
			set ent:longTrips {[id, "time"]} time:now();

			log ("Collect_long_Trips: " + milage + ": ID: " + id);
		}
	}

	rule clear_trips {
		select when car trip_reset 
		fired {
			clear ent:trips;
			clear ent:longTrips;
			clear ent:TripID;
			log("Cleared trips.");
		}
	}	
}