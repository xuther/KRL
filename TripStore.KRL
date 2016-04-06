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
	
	rule collect_trips {
		select when explicit trip_processed 
		pre {
			milage = event:attr("_milage").klog("Collect Trips milage: ");
		}
		fired {
			set ent:trips {[ent:runningCollectID, "milage"]} milage;
			set ent:trips {[ent:runningCollectID, "time"]} time:now();
			set ent:runningCollectID ent:runningCollectID +1;
			log ("Collect_Trips: " + milage);
		}
	}

	rule collect_long_trips {
		select when explicit found_long_trip
		pre {
			milage = event:attr("_milage").klog("Collect Trips milage: ");
		}
		fired {
			set ent:longTrips {[ent:runningLongCount, "milage"]} milage;
			set ent:longTrips {[ent:runningLongCount, "time"]} time:now();
			set ent:runningLongCount ent:runningLongCount +1;
			log ("Collect_long_Trips: " + ent:trips);
		}
	}

	rule clear_trips {
		select when car trip_reset 
		fired {
			clear ent:trips;
			clear ent:longTrips;
			clear ent:runningLongCount;
			clear ent:runningCollectID;
			log("Cleared trips.");
		}
	}	
}