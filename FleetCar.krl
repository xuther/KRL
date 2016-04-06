ruleset fleet_car {
	meta{
		name "Fleet_Car"
		description <<
			ruleset for a car in the fleet.
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on
	}

	rule subscribeToParent {
		select when wrangler init_events
		pre {
			parent_results = wrangler_api:parent();
	       	parent = parent_results{'parent'};
	       	parent_eci = parent[0];
	       	attrs = {}.put(["name"],"Fleet")
                      .put(["name_space"],"Tutorial_Subscriptions")
                      .put(["my_role"],"Vehicle")
                      .put(["your_role"],"Fleet")
                      .put(["target_eci"],parent_eci.klog("target Eci: "))
                      .put(["channel_type"],"Fleet")
                      .put(["attrs"],"success")
                      ;

		}	
		{
			noop();
		}
		always {
			raise wrangler event "subscription"
			attributes attrs;
		}
	}
}