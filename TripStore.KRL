ruleset trip_store {
	meta {
		name "Trip_Store"
		description <<
			Store Trips
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on 
		use module b507199x5 alias wranglerOS
		provides trips, long_trips, short_trips, getParent
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

			toCompare = ["milage", "time"];

			short = trips.filter(function(k,v) {
					value = longTripMap.keys([k]).klog("KeyReturned:");
					value.length().klog("Length: ") eq 0;
				});
			
			short;
		}

		getParent = function() {
			WranglerIsConfusing = wranglerOS:subscriptions().klog("What we get back from first Layer: ");
			subs = WranglerIsConfusing{"subscriptions"}.klog("What we get back from subscriptions: ");
			parent = subs{"subscribed"}.filter(
					function(x) {
						stuff = x.values().head();
						namespace = stuff{"name_space"} eq "Fleet_Subscription";
						parent = stuff{"relationship"} eq "Vehicle";
						namespace && parent
					}
				).klog("Parent post-filter: ");
			parValues = parent.values().head();
			parValues{"target_eci"}
		}
	}

	rule genReport {
		select when car report 
		pre {
			index = event:attr("reportIndex").klog("Index being sent.");
			parent = getParent()
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