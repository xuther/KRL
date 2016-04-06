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
			set ent:trips {[time:now()]} milage;
			log ("Collect_Trips: " + ent:trips);
		}
	}	
}